# Check Requirements
Before installing Kubernetes or RiseML, please take into account the following requirements:


## Hardware requirements

RiseML runs on top of Kubernetes.
To ensure fast response times, we recommend the following.

For the **RiseML system components**, a dedicated node with:

|               | Requirement | Description            |
| ------------- | ----------- | ---------------------- |
| CPU           | ≥ 4         | 4 moderately fast CPUs can accommodate hundreds of parallel experiments |
| Memory        | ≥ 8GB       | 8GB of RAM can accommodate hundreds of parallel experiments             |
| Disk          | ≥ 500GB     | RiseML will use the Docker daemon of these nodes to build experiment images. To allow caching build steps, the node should have enough storage. |


This **only includes the management infrastructure** and not the resource requirements for your actual experiments.

For a large number of parallel users or projects, you should use several docker build nodes.
You can specify system and build nodes using Kubernetes node selectors when installing RiseML.

## Network requirements

To install and run RiseML, your nodes need **Internet access** to pull the required docker images.
Furthermore, communication between the nodes must be possible via the Kubernetes overlay network.
The communication between the RiseML client and the RiseML cluster depends on the way your Kubernetes cluster is configured:

- **Cloud integration**: if your setup supports cloud integration (e.g., if you installed Kubernetes via [kops](https://github.com/kubernetes/kops)) and you configure RiseML to use the cloud integration (set `nodePorts: false` during RiseML installation), separate load balancers will be created for the API (on port 80) and for syncing data (on port 8765)
- **No cloud integration**: if you set `nodePorts: true` during installation, the API port 31213 and sync port 31876 will be opened on your nodes; you can use, e.g., the Kubernetes master's IP and these ports to access RiseML with the CLI

Note that **the communication between the client and the RiseML API is not encrypted by default.** Please [contact us](mailto:contact@riseml.com) if you require an encrypted connection, e.g. over the Internet.

## Software requirements
The latest RiseML version has the following software requirements on your cluster's nodes:

|               | Version   | Comments                |
| ------------- | --------- | ----------------------- |
| Linux kernel  | ≥ 3.10    |                         |
| Docker        | ≥ 1.12.6  |                         |
| Kubernetes    | ≥ 1.8.0   |                         |
| Helm          | ≥ 2.5     | If you use RBAC, you need to [configure permissions](kubernetes.md#permissions) |
| Nvidia driver | ≥ 375     | (**Optional**) GPU only |

The following Linux distributions have been tested: Ubuntu 16.04 LTS.

**GPU support**: Requires NVIDIA driver installed on each node, and driver files available in the same path on each node. The following GPUs have been tested: Tesla K80, GeForce Titan X.

**Storage software**: If you use NFS or GlusterFS (see below), all Kubernetes nodes need to have the `nfs-common` (for NFS) or `glusterfs-client` (for GlusterFS) packages installed.


## Storage Requirements

RiseML requires at least two Kubernetes [persistent volumes](https://kubernetes.io/docs/concepts/storage/volumes/) (PV):

- **data**: where your training data resides
- **output**: where experiments write their output (trained model, logs, checkpoints etc.) in user and project-specific directories

You need to create these volumes in Kubernetes before you install RiseML.
The volumes can use all protocols supported by [Kubernetes volumes](https://kubernetes.io/docs/concepts/storage/volumes/) (NFS, GlusterFS, etc.), as long as they allow parallel write access (*ReadWriteMany*) from many nodes.
**For test installations**, we also support using temporary storage on the nodes by enabling an internal NFS provisioner (see [configure persistence](kubernetes.md#persistence)) which creates these volumes for you.

On production systems, you should also persist experiment, code, image and log information to separate volumes.
The following lists all requirements:

|                     | Requirement | Description        |
| ------------------- | ----------- | ------------------ |
| Input Data          | Kubernetes PV         | Training data is made available to each experiment in `/data` via this volume. Specify a volume with size at least 50Gi. |
| Output Data         | Kubernetes PV         | Trained models and intermediate data is written to this volume (in user and project-specific sub-directories). Specify a volume with size at least 50Gi.  |
| Persistent Database | Kubernetes PV (30Gi)  | (**Optional**) To persist your database you need to provide a Kubernetes persistent volume (PV). Can be skipped for test installations.|
| Versioned Code (Git)| Kubernetes PV (30Gi)  | (**Optional**) To persist versioned experiment code you need to provide a PV. Can be skipped for test installations.|
| Persistent Logs     | Kubernetes PV (30Gi)  | (**Optional**) To persist your job logs you need to provide a PV. Can be skipped for test installations.|
| Persistent Registry | Kubernetes PV (100Gi) | (**Optional**) To persist your registry images you need to provide a PV. Can be skipped for test installations.|
