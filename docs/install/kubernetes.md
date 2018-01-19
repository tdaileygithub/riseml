# Configure Kubernetes

Before installing RiseML, you might need to configure your Kubernetes installation according to your actual needs.
Most prominently, you will have to install Helm, unless it is already installed (e.g., Stackpoint.io installs it by default), and extend its permissions.
The rest of this document assumes you already have a properly configured [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (the Kubernetes CLI).

## Create Namespace

Since RiseML is installed in its own Kubernetes namespace, `riseml`:
```
$ kubectl create namespace riseml
namespace "riseml" created
```
All experiments will be created and run in this namespace.

## <a id="helm-setup"></a>Install & Setup Helm
[Helm](https://github.com/kubernetes/helm) is Kubernetes' official package manager.
You can get its command line client by running:
```
$ curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
```
Next, you have to install Helm's server-side component (Tiller) into your cluster.
But before doing that, you need to permit Helm and, thereby, RiseML, to access cluster-wide resources.
If your cluster is not using role-based access control (RBAC) you can skip setting up permissions.

### Permissions
The following commands create a service account for tiller and assign it the `cluster-admin` role.
You can also follow the [instructions provided by Helm](https://github.com/kubernetes/helm/blob/master/docs/rbac.md).
```
$ kubectl create serviceaccount tiller --namespace kube-system
$ kubectl create clusterrolebinding tiller-cluster-admin-binding \
          --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
```

### Deploy Tiller
Deploy Tiller with this account (skip the `--service-account` flag if you do not use RBAC):
```
$ helm init --service-account tiller --tiller-namespace kube-system
```

The full installation manual for Helm can be found [here](https://docs.helm.sh/using_helm/#installing-helm).

## <a id="gpu-support"></a>GPU Support

*This setup is only required on nodes with a GPU.
If, for example, your master has no GPUs, you should only perform the following steps on your nodes with a GPU*

Most likely, you want to use GPUs during your machine learning experiments.
For this, you have to install NVIDIA drivers on each worker node.
The driver files need to be accessible in the same directory on each node.

First, install the drivers.
E.g., on Ubuntu (**Note: all versions after 375 are supported**):
```
$ apt-get update
$ apt-get install -y nvidia-375 libcuda1-375 nvidia-modprobe
```

The driver files are now installed on the host, but reside in several different parts of the filesystem.
We recommend to use [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) by NVIDIA to collect the driver files into a single path:

```bash
$ wget https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
$ sudo dpkg -i nvidia-docker*.deb && rm nvidia-docker*.deb
```

Then, use our script to link the drivers into a directory:
```bash
$ wget https://cdn.riseml.com/scripts/setup_driver.sh && chmod a+x setup_driver.sh
$ ./setup_driver.sh /var/lib/nvidia-docker/volumes/nvidia_driver/latest
```

The driver files are now available in `/var/lib/nvidia-docker/volumes/nvidia_driver/latest`.
You can use a different path, but you need to provide it when installing RiseML and it needs to be the same on all nodes.

Next, you have to reconfigure the kubelet on your GPU node to enable its GPU support.
Add the `--feature-gates=Accelerators=true --allow-privileged=true` flags to the startup script.
For example, if you used `kubeadm` to setup the cluster:
```
$ echo Environment=\"KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true --feature-gates=Accelerators=true\" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
$ systemctl restart kubelet
```
This should restart the Kubernetes kubelet and make Kubernetes' GPU support available for this node.

To verify that a node registers with available GPUs use the following command (*change the node name in the command below*):
```
$ kubectl get nodes ip-172-31-30-98 -o=custom-columns=NAME:metadata.name,GPU:.status.capacity.'alpha\.kubernetes\.io/nvidia-gpu'
NAME              GPU
ip-172-31-30-98   1
```


## <a id="labels"></a> Node Labels

You can use node labels to control where RiseML places system components and schedules experiments.
A node label consists of a *key* and a *value*.
Node labels can be assigned to nodes at any time using `kubectl` (see below).

We recommend to explicitly label one node as **system node**, where the RiseML components like database and Git server will run (*adjust the node name below*):

```
kubectl label node ip-172-43-21-53 riseml.com/system-node=true
```

We also recommend to label one node as a **build node**, where container images will be built.
This allows Kubernetes to re-use the local build cache (*adjust the node name below*):

```
kubectl label node ip-172-43-21-53 riseml.com/build-node=true
```

By default RiseML will always try to schedule experiments on non-system nodes.
However, if Kubernetes allows it, experiments will also be run on the same nodes as RiseML system components if no other resources are available.

You can use your own naming scheme for node labels or you can use the default names above.
In the next step, when deploying RiseML, you can specify the label selectors (i.e., keys and values) that identify the different types of nodes.


## <a id="persistence"></a> Persistence

RiseML creates [persistent volume claims](https://kubernetes.io/docs/concepts/storage/volumes/#persistentvolumeclaim) for the storage it requires.
Below, we describe how to create the corresponding persistent volumes **manually**.
Once the volumes are needed by RiseML, Kubernetes will assign the volumes to the claims by RiseML automatically.

The corresponding persistent volumes can also be created **dynamically**, if you have setup a storage provisioner, as described, for example, [here](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#provisioning).
For testing and evaluation purposes, we provide an [internal NFS provisioner](configuration.md#internal-nfs), that you can configure when you install RiseML.
If you choose to use the internal NFS provisioner, you don't need to create any volumes and can skip this step.

### Data and Output Volumes

RiseML requires two [persistence volumes](https://kubernetes.io/docs/concepts/storage/volumes/) (PV): one for **data** and one for **output**.

Here are two volumes backed by NFS (you can use any volume type that supports *ReadWriteMany* access; some examples can be found in the [kubernetes repository](https://github.com/kubernetes/examples/tree/master/staging/volumes)):

```
$ cat nfs-pvs.yml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: riseml-output
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  claimRef:
    namespace: riseml
    name: riseml-output-claim
  nfs:
    path: /output
    server: fs-59258290.efs.eu-west-1.amazonaws.com
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: riseml-data
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  claimRef:
    namespace: riseml
    name: riseml-data-claim
  nfs:
    path: /data
    server: fs-59258290.efs.eu-west-1.amazonaws.com
```
To create the volumes run `kubectl apply -f nfs-pv.yaml`.

The `claimRef` section reserves the volumes for the claims RiseML creates, identified via the name.

Note that in the example above, we used the same NFS server for both volumes, but with different exports.
However, the two volumes are used completely independently, and you are free to use any backing storage that you have available.
For example, you could also use GlusterFS for one and NFS for the other volume.

### <a id="persistent-database"></a> Persisting the Database, Git, Registry and Logs ####

For production workloads, at least the database and Git should be persistent across container restarts.
Losing job logs may not be critical.
Images in the registry will be rebuilt if they are required but cannot be found.

Here is a configuration for a GlusterFS volume:

```
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-db
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: default
  claimRef:
    namespace: riseml
    name: riseml-db-claim
  glusterfs:
    path: riseml-pv-001
    endpoints: gluster-endpoint
```
You will need at least one physical volume with enough capacity for each component (DB, Git, logs, and/or registry).
The `claimRef` section reserves the volume for the particular RiseML component.
The following names can be used for the `claimRef`: `riseml-db-claim`, `riseml-git-claim`, `riseml-registry-claim`, `riseml-logs-claim`.
You can create each physical volume using `kubectl apply` and then check for their existence with `kubectl get pv`.

The persistent volume(s) will be automatically assigned once you deploy RiseML on Kubernetes with enabled persistence.
Note: you do not necessarily need to use GlusterFS but can use any of the [supported volume types](https://kubernetes.io/docs/concepts/storage/volumes/) of Kubernetes.




