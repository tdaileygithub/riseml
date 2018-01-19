# <a id="quick-setup"></a>Quick Setup

For both quick installations options, **please have your account key ready**.
If you don't have one yet, please obtain one by [registering](https://riseml-staging.com/pricing).
You can continue with the installation on [AWS](#aws) or on a [bare Kubernetes cluster](#kubernetes).

## <a id="aws"></a> Install on AWS

If you have chosen to try out RiseML on AWS, we provide a quick start installer.
The installer will guide you through installing Kubernetes and RiseML on AWS.
All you need is a workstation with **Linux (x84_64) or MacOS (x84_64)** and an **[access key](http://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html)** for your AWS account.

### Getting started
To get started execute this command on your favourite terminal

    bash -c "$(curl -fsSL https://get.riseml.com)"

This command will guide you through the installation process.
**Note**: if you register for an account on the homepage you will get a **personalized link** for downloading the installer, and you don't need to provide the account key as shown below.

  The following shows a sample output of the installer using 1 master, 1 GPU, and 3 worker nodes:

    Installing the RiseML cluster
    RiseML account key: dc6s49mblq5ifxokdkorqtdx3h06nkwm
    AWS Availability Zone [default: us-east-1]:
    Master Node type [default: m4.2xlarge]:
    Number of Master Nodes [default: 1]:
    GPU Enabled (y/n)[default: n]: y
    GPU Node type [default: p2.xlarge]:
    Number of GPU Nodes [default: 1]:
    Worker Node type [default: m4.large]:
    Number of Worker Nodes [default: 3]:
    Your cluster ID is 2df8a0ae-2eb4-49b3-ba78-5486e0a8668f

	--- output trimmed ---

    To install RiseML on AWS we need your credentails.
    AWS access key: AKI*****************
    AWS secret access key: 9azJha**********************************
    We are about to create these components on AWS:
      1 (m4.large) for the master node
      3 (m4.large) for the worker nodes
      1 (p2.xlarge) for the GPU worker nodes
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

    The RiseML client is installed in /home/satran/.riseml/bin directory. Add these to your profile environment.
      export PATH=/home/satran/.riseml/bin:$PATH


    To destroy this cluster:
      riseml-install -cleanup

    You can run these commands to get started with your cluster:
      riseml init
      riseml train -l

    For more information check out our docs https://docs.riseml.com


On a successful execution of the command, it will provide you with details about your cluster and how to run a simple experiment. You can store these in a document or run `riseml-install` again. Ensure you add the riseml `bin` directory to your path.



### <a id="aws-requirements"></a> Requirements
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

## <a id="kubernetes"></a> Install on Bare Kubernetes

For this installation, you will need a **Kubernetes cluster** with version at least 1.8 that is already **installed and working**.
If you don't have a Kubernetes cluster, you can check the [Kubernetes docs](https://kubernetes.io/docs/setup/pick-right-solution/) for the various installation options.
An easy solution that works well in most cases is installing using [kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/).


Your cluster needs **one node that is big enough** (at least 4 CPUs, check [requirements](requirements.md)) and not the Kubernetes master.
If you want to use the master node for RiseML, you need to enable the master for regular workloads, see [below](#untaint-master).

The installation will be good for **testing and evaluating RiseML**.
It uses temporary internal storage on your nodes.
If you restart some nodes, it is possible that information on experiments or your experiment data is lost.
If you want to avoid this, you should perform a [custom installation](README.md#custom-installation).

### Install Helm

Run the following, to install Helm on your Kubernetes cluster:
```
$ curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
$ kubectl create serviceaccount tiller --namespace kube-system
$ kubectl create clusterrolebinding tiller-cluster-admin-binding \
          --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
$ helm repo add riseml-charts https://cdn.riseml.com/helm-charts
$ helm init --service-account tiller --tiller-namespace kube-system
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
### <a id="untaint-master"></a> Optional: Run Regular Workloads on Master

By default, the Kubernetes master does not allow any regular workloads to run on it.
If you want RiseML services to run on the master, you need to run:

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

Note that this will also allow other workloads besides RiseML to run on your master.
