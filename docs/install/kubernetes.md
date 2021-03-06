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

## Install & Setup Helm
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

## GPU Support

*This setup is only required on nodes with a GPU.
If, for example, your master has no GPUs, you should only perform the following steps on your nodes with a GPU*

Most likely, you want to use GPUs during your machine learning experiments.
For this, you have to install NVIDIA drivers and nvidia-docker2 and enable Kubernetes'
device plugin feature on each worker node.

First, install the drivers.
E.g., on Ubuntu (**Note: all versions after 375 are supported**):
```
$ apt-get update
$ apt-get install -y nvidia-375 libcuda1-375 nvidia-modprobe
```

Next, [install nvidia-docker2](https://nvidia.github.io/nvidia-docker/).
E.g., on Ubuntu:
```
$ curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  apt-key add -
$ curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list | \
  tee /etc/apt/sources.list.d/nvidia-docker.list
$ apt-get update
$ apt-get -y install nvidia-docker2
```

Use `apt-cache madison nvidia-docker2 nvidia-container-runtime` in case you have a version
mismatch between your Docker version and nvidia-docker2 to list available combinations
(nvidia-docker2's version number contains the respective docker version), e.g.:
```
$ apt-get install -y nvidia-docker2=2.0.2+docker17.03.2-1 nvidia-container-runtime=1.1.1+docker17.03.2-1
```

Make nvidia-docker2 your default Docker runtime by editing `/etc/docker/daemon.json`:
```
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
```

And restart your Docker daemon:
```
$ systemctl restart docker
```

Next, you have to reconfigure the kubelet on your GPU node to enable its DevicePlugin support.
Add the `--feature-gates=DevicePlugins=true` flag to the startup script.
For example, if you used `kubeadm` to setup the cluster:
```
$ echo Environment=\"KUBELET_EXTRA_ARGS=--feature-gates=DevicePlugins=true\" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
$ systemctl daemon-reload
$ systemctl restart kubelet
```
This should restart the Kubernetes kubelet and make Kubernetes' GPU support available for this node.

Finally, install Nvidia's device plugin for Kubernetes into your cluster:
```
$ kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v1.9/nvidia-device-plugin.yml
```

To verify that a node registers with available GPUs use the following command:
```
$ kubectl get nodes -o=custom-columns=NAME:.metadata.name,GPUs:.status.capacity.'nvidia\.com/gpu'
NAME              GPUs
ip-172-31-30-98   1
```


## Node Labels

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


## Persistence

RiseML creates [persistent volume claims](https://kubernetes.io/docs/concepts/storage/volumes/#persistentvolumeclaim) for the storage it requires.
Below, we describe how to create the corresponding persistent volumes **manually**.
Once the volumes are needed by RiseML, Kubernetes will assign the volumes to the claims by RiseML automatically.

The corresponding persistent volumes can also be created **dynamically**, if you have setup a storage provisioner, as described, for example, [here](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#provisioning).
For testing and evaluation purposes, we provide an [internal NFS provisioner](configuration.md#internal-nfs-provisioner), that you can configure when you install RiseML.
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

### Persisting the Database, Git, Registry and Logs ####

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




