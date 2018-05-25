# Quick Setup

For all of our quick installations options, **please have your account key ready**.
If you don't have one yet, please obtain one by [registering](https://riseml.com/pricing).
You can continue with the installation on [AWS](#aws), on [GKE](#gke) or on a [bare Kubernetes cluster](#kubernetes).

## <a name='aws'></a>Install on AWS

If you have chosen to try out RiseML on AWS, we provide a quick start installer.
The installer will guide you through installing Kubernetes and RiseML on AWS.
All you need is a workstation with **Linux (x84_64) or MacOS (x84_64)** and an **[access key](http://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html)** for your AWS account.

### Getting started
To get started execute this command on your favourite terminal

    bash -c "$(curl -fsSL https://get.riseml.com)"

This command will guide you through the installation process.
**Note**: if you register for an account on the homepage you will get a **personalized link** for downloading the installer, and you don't need to provide the account key as shown below.

  The following shows a sample output of the installer using 1 GPU worker and 3 CPU worker nodes with autoscaling enabled:

    Choose a region or availability zone in which to install RiseML. If a region is chosen
    the cluster will be in the spread across all of the region's availability zones.

    * AWS region or availability zone [default: us-east-1]:

    Configure CPU as well as GPU worker nodes. Make sure that the instance type is
    available in your region and that instance limits suffice. Autoscaling is enabled by
    default. Set min/max to the same value to disable autoscaling.

    * CPU workers
      min count [default: 0]:
      max count [default: 3]:
      instance type [default: m4.2xlarge]:

    * GPU workers
      min count [default: 0]:
      max count [default: 3]: 1
      instance type [default: p3.2xlarge]:

    Your cluster ID is 5f76fb19-cf34-481b-bb95-7b3185bcd498
    RiseML account key: dc6s49mblq5ifxokdkorqtdx3h06nkwm

	--- output trimmed ---

    To install RiseML on AWS we need your credentails.
    AWS access key: AKI*****************
    AWS secret access key: 9azJha**********************************
    We are about to create these components on AWS:
      1 (m4.2xlarge) nodes for the Kubernetes master
      1 (m4.2xlarge) nodes for the RiseML system
      0-3 (m4.2xlarge) nodes for the CPU workers
      0-1 (p3.2xlarge) nodes for the GPU workers
    These will be created using AWS Access Key: AKI*****************
    Are you sure you wish to continue (y/n)[default: n]: y

	--- output trimmed ---
	 ___ _   _  ___ ___ ___  ___ ___
    / __| | | |/ __/ __/ _ \/ __/ __|
    \__ \ |_| | (_| (_|  __/\__ \__ \
    |___/\__,_|\___\___\___||___/___/

    RiseML is successfully installed and registered!
    Your Account Key: dc6s49mblq5ifxokdkorqtdx3h06nkwm

    We have also created a user for you. This user has administrative access rights.
    User Name: admin
    API Key: RnrjsdzpdwGDu4bvi9B9bscgvJyGUe5d

    The RiseML client is installed in /home/satran/.riseml/bin directory. Add these to your
    profile environment.
      export PATH=/home/satran/.riseml/bin:$PATH


    To destroy this cluster:
      riseml-install -cleanup

    You can run these commands to get started with your cluster:
      riseml init
      riseml train -l

    For more information check out our docs https://docs.riseml.com


On a successful execution of the command, it will provide you with details about your cluster and how to run a simple experiment. You can store these in a document or run `riseml-install` again. Ensure you add the riseml `bin` directory to your path.



### Requirements
The installer requires you have an AWS IAM user with these permissions:
  - AmazonEC2FullAccess
  - AmazonS3FullAccess
  - IAMFullAccess

These requirements are mandated by the open source tool we use: [kops](https://github.com/kubernetes/kops). You will also need the access key and secret assess key for your account. You can find out more on how to get these keys here: http://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html

Currently, only the following OS(architecture) are supported:
  - Linux(amd64)
  - MacOS(amd64)

### Cleanup
Resources are expensive and it is necessary to delete the cluster after you have experimented with RiseML. The command below will delete all resources that was created by the installer.

    riseml-install -cleanup

### Troubleshooting
Ensure the `bin` directory is in your path by running the command below. The installer is copied to `$HOME/.riseml/bin` directory when you downloaded the script.

    export PATH=$HOME/.riseml/bin:$PATH

In case you run into trouble when executing the installer you can look through the logs which is stored in `$HOME/.riseml/install/log`. Sometimes the easiest step is to run the installer again (inside the `$HOME/.riseml/bin` directory):

    riseml-install

The installer keeps track of the installation progress and continues where it stopped.

If it doesn't seem to work you can run

    riseml-install -cleanup
	riseml-install -reset

to delete the cluster and clean up old cached files.

Next run `riseml-install` to try it out again.

#### Inspecting the Kubernetes cluster
To avoid overwriting existing Kubernetes configuration file the installer creates a separate configuration file: `~/.riseml/install/kubeconfig`. You should export `KUBECONFIG` variable using the following command:

    export KUBECONFIG=~/.riseml/install/kubeconfig

With this set you can troubleshoot your K8s cluster with `kubectl`.

## <a name='gke'></a>Install on GKE
This quick installation will show you how to setup a beta GKE cluster that is GPU-enabled.
You will need Google's `gcloud` CLI and `kubectl` for that.

**Note**: on GKE you will need to request GPU resources from google.  Depending on the type of GPUs you want to run this may take anywhere from a few hours to weeks or more.

Once GPU quota has been assigned by google start by creating a GKE Kubernetes cluster with some GPUs:
```
$ gcloud beta container clusters create test-3x4-k80 --project test-clusters --num-nodes=3 --machine-type=n1-standard-8 --accelerator type=nvidia-tesla-k80,count=4 --zone us-central1-c --cluster-version 1.10.2-gke.1
```

- [--machine-type=AWS Machine Types](https://cloud.google.com/compute/docs/machine-types)
- [--cluster-version=AWS Machine Types](https://cloud.google.com/kubernetes-engine/versioning-and-upgrades)

Next, update local .kube/config with the cluster that was just created

  gcloud container clusters get-credentials test-3x4-k80 --zone us-central1-c --project test-clusters

Next, install helm client

  curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash 

Helm is installed to /usr/local/bin/helm  

Next, install the Nvidia drivers to your cluster:

```
$ kubectl create -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/k8s-1.9/nvidia-driver-installer/cos/daemonset-preloaded.yaml
```

Wait a few minutes to let the driver installation finish. Continue with setting up
a RiseML namespace and Helm:

```
$ kubectl create namespace riseml
$ kubectl create serviceaccount tiller --namespace kube-system
$ kubectl create clusterrolebinding tiller-cluster-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
$ helm init --service-account tiller --tiller-namespace kube-system
$ helm repo add riseml-charts https://cdn.riseml.com/helm-charts
```

Create a configuration file `riseml-config.yml` and adjust **accountKey** and
**adminEmail** to your values:

```
$ cat riseml-config.yml
accountKey: <your_account_key>
adminApiKey: mlriseapikey
adminEmail: <your_email>
git:
  persistence:
     enabled: true
logs:
  persistence:
    enabled: true
nfsProvisioner:
  enabled: true
  path: /tmp/riseml
  persistence:
    enabled: true
nodePorts: false
nvidiaDriverDir: /home/kubernetes/bin/nvidia
postgresql:
  persistence:
    enabled: true
    subPath: data
registry:
  persistence:
    enabled: true
scheduleOnMaster: false
```

Next, install RiseML into your GKE cluster and wait for it to spin up completely:

```
$ helm install riseml-charts/riseml --name riseml --namespace riseml -f riseml-config.yml
$ watch kubectl -n riseml get pods
```

Wait until all pods are running and execute the commands the `helm install` gave you to get the connection info needed to login.

Next, download the RiseML CLI from http://docs.riseml.com/install/cli.html and login using
the info from above:

```
$ riseml user login --api-key XYZ --api-host XYZ:80
```

Finally, check your installation:

```
$ riseml system info
RiseML Client/Server Version: 1.0.3/1.1.0
RiseML Cluster ID: 575cbb40-1cae-11e8-ad4d-0a580a380032
Kubernetes Version 1.9+ (Build Date: 2018-01-31T22:30:55Z)

NODE CPU MEM GPU GPU MEM
gke-test-3x4-k80-default-pool-1e0c6fe8-dd26 7 26.0 4 44.7
gke-test-3x4-k80-default-pool-1e0c6fe8-qv7l 7 26.0 4 44.7
gke-test-3x4-k80-default-pool-1e0c6fe8-h2t3 7 26.0 4 44.7
--------------------------------------------------------------------
Total 21 77.9 12 134.1
```

## <a name='kubernetes'></a>Install on Bare Kubernetes

For this installation, you will need a **Kubernetes cluster** with version at least 1.8 that is already **installed and working**.
If you don't have a Kubernetes cluster, you can check the [Kubernetes docs](https://kubernetes.io/docs/setup/pick-right-solution/) for the various installation options.
An easy solution that works well in most cases is installing using [kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/).


Your cluster needs **one node that is big enough** (at least 4 CPUs, check [requirements](requirements.md)) and not the Kubernetes master.
If you want to use the master node for RiseML, you need to enable the master for regular workloads, see [below](#untaint-master).

The installation will be good for **testing and evaluating RiseML**.
It uses temporary internal storage on your nodes.
If you restart some nodes, it is possible that information on experiments or your experiment data is lost.
If you want to avoid this, you should perform a [custom installation](index.md#custom-installation).

### Install Helm

Run the following, to install Helm on your Kubernetes cluster:
```
$ curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
$ kubectl create serviceaccount tiller --namespace kube-system
$ kubectl create clusterrolebinding tiller-cluster-admin-binding \
          --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
$ helm init --service-account tiller --tiller-namespace kube-system
$ helm repo add riseml-charts https://cdn.riseml.com/helm-charts
```

### Label RiseML Node

We will use one node, where RiseML runs all of its services.
You can get all node's names by running `kubectl get nodes`.
Label the node of your choosing (as long as it has enough resources) using the following command:

```
kubectl label node <your_node> riseml.com/system-node=true
```

### Create RiseML Configuration

Create the configuration file `riseml-config.yml`:

```
$ cat riseml-config.yml
accountKey: <your_account_key>
adminApiKey: mlriseapikey
adminEmail: <your_email>
nvidiaDriverDir: "/var/lib/nvidia-driver"
minio:
  enabled: true
  secretKey: mlriseapikey
nfsProvisioner:
  enabled: true
  path: /tmp/risemlnfs
nodeSelectors:
  system:
    riseml.com/system-node: "true"
  imageBuilder:
    riseml.com/system-node: "true"
```

Adjust the following:
- **accountKey**: enter your account key
- **adminEmail**: enter your email
- **nvidiaDriverDir**: if you want GPU support, provide the directory where the driver can be found on all nodes; see [instructions](kubernetes.md#gpu-support)

If you want, you can also change:
- **adminApiKey**: select an api key (use only alphanumeric characters and 0-9)
- **minio.secretKey**: select a secret key (use only alphanumeric characters and 0-9)
- **nfsProvisioner.path**: a path on the RiseML system node where data is placed

### Install RiseML

Use Helm to install RiseML with your configuration:

```
$ helm install riseml-charts/riseml --name riseml --namespace riseml -f riseml-config.yml
NAME:   riseml
LAST DEPLOYED: Fri Dec 15 11:13:04 2017
NAMESPACE: riseml
STATUS: DEPLOYED

...


NOTES:

RiseML was deployed. It may take a while for all services to be operational.
You can watch the progress with this command (all Pods should be RUNNING):
  watch -n 1 kubectl get pods -n=riseml

To set up your client, look up your RiseML master's hostname or ip address and run:
  export RISEML_HOSTNAME=<YOUR MASTER HOSTNAME/IP>

### RiseML Client
You can get the RiseML client from here: http://docs.riseml.com/install/cli.html
To configure the RiseML client, run:
  riseml user login --api-key mlriseapikey --host $RISEML_HOSTNAME

### Minio Client (for accessing data)
You can get the Minio client from here: https://docs.minio.io/docs/minio-client-quickstart-guide
To configure the Minio client, run:
  mc config host add data http://$RISEML_HOSTNAME:31874 minioaccess mlriseapikey
  mc config host add output http://$RISEML_HOSTNAME:31875 minioaccess mlriseapikey

You can find some examples to run on https://github.com/riseml/examples
More information is available in our documentation: https://docs.riseml.com
```

Thats it! You can now [download and setup](cli.md) the RiseML command line client as output by the installation above.
For accessing internal data (e.g., uploading training data, our downloading the results of experiments) you can setup [Minio](https://docs.minio.io/docs/minio-client-quickstart-guide).

***
### Optional: Run Regular Workloads on Master

By default, the Kubernetes master does not allow any regular workloads to run on it.
If you want RiseML services to run on the master, you need to run:

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

Note that this will also allow other workloads besides RiseML to run on your master.
