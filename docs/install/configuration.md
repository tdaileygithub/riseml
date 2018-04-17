# Configure RiseML's Installation

We will install RiseML using Helm, Kubernetes' package manager, in the next step.
But before doing that, we need to configure the RiseML installation for your environment.
Configuration options are specified in a YAML file, e.g. `riseml-config.yml`.

## Minimal Example

Here is a a minimal example with GPU support.
Please adjust for your environment accordingly.
In particular, use your account key and choose an admin API key.
All of the available options (including the ones used in this example) are explained below.

```
$ cat riseml-config.yml
accountKey: rhglxtzcl6sgy3wtac8fbcfjoda60uwu
adminApiKey: yourSecretApiKeyYouWantToUse1234
minio:
  secretKey: yourSecretMinioAccessKey
adminEmail: user@company.com
nvidiaDriverDir: /var/lib/nvidia-driver-dir
```

## General Configuration Options

| Name                             | Description |
| -------------------------------- | ---- |
| `accountKey`                     | **Your account key. You can get one [here](https://riseml.com/pricing).** |
| `adminApiKey`                    | **The API key to use for the admin user.** |
| `adminEmail`                     | **The email address of the admin user.** |
| `nvidiaDriverDir`                | **Path to NVIDIA driver on nodes.** Default: `/var/lib/nvidia-docker/volumes/nvidia_driver/latest`. |
| `useRBAC`                        | **Use Kubernetes' role-based access control (RBAC).** If your Kubernetes is using RBAC, RiseML will configure permissions for itself during installation accordingly. Default: `true`|

## Network Configuration Options

These options control which network configuration is used to provide access to the cluster externally.
The behaviour is as follows:
 - by default, the ports defined in `nodePorts` below are used on the cluster nodes
 - as an alternative, Kubernetes can automatically create load balancers provided by cloud providers such as AWS or Google Cloud Platform. Then you need to set `nodePorts: false` in your configuration.

Besides that, the options below usually **don't have to be set**:

| Name                             | Description |
| -------------------------------- | ---- |
| `nodePorts.web`                  | **Node port for communication access to RiseML API.** Default: `31213`. |
| `nodePorts.sync`                 | **Node port for syncing code to RiseML.** Default: `31876`. |
| `nodePorts.minioData`            | **Node port for minio accessing the `data` volume.** Default: `31900`. |
| `nodePorts.minioOutput`          | **Node port for minio accessing the `output` volume.** Default: `31901`. |
| `loadBalancerPorts.web`          | **Load balancer port for access to RiseML API.** Default: `80`. |
| `loadBalancerPorts.sync`         | **Load balancer port for syncing code to RiseML.** Default: `8765`. |
| `loadBalancerPorts.minioData`    | **Load balancer port for minio accessing the `data` volume.** Default: `9000`. |
| `loadBalancerPorts.minioOutput`  | **Load balancer port for minio accessing the `output` volume.** Default: `9001`. |

## Scheduling Configuration Options

These options control how workload on the cluster is scheduled and where RiseML itself is running.

| Name                             | Description |
| -------------------------------- | ---- |
| `nodeSelectors.riseml`           | **Kubernetes cluster-wide node selector for RiseML.** This will limit RiseML to run Pods only nodes which you have labeled in Kubernetes. This affects both training and system Pods. Put node labels and values directly below this key in the YAML file. Default: `{}` (empty) |
| `nodeSelectors.system`           | **Kubernetes node selector for system components.** This will schedule RiseML's system components on specific nodes which you have labeled in Kubernetes. Put node labels and values directly below this key in the YAML file. Default: `{}` |
| `nodeSelectors.training`         | **Kubernetes node selector for training.** This will limit training jobs to only run on accordingly labeled nodes. Put node labels and values directly below this key in the YAML file. Default: `{}` |
| `nodeSelectors.imageBuilder`      | **Kubernetes node selector for image build jobs.** This will schedule RiseML's image build jobs on specific nodes. Default: `{}` |
| `tolerations.training`            | **Kubernetes tolerations for training jobs.** Training and build jobs will use these tolerations. Put the list of tolerations directly below this key in the YAML file. Default: `[]` |


## Input and Output Data

Your experiments are going to read input data (training data, existing models etc.) and will write some output data (models, checkpoints etc.).
RiseML will read and write this data using Kubernetes volumes.
You either created these volumes in the [previous step](kubernetes.md#persistence), or you can configure the internal NFS provisioner below.

### Internal NFS Provisioner ####

For **test installations**, you can enable an internal NFS provisioner.
The provisioner will use local storage of one of your nodes to create NFS volumes for `data` and `output` volumes and export them inside the Kubernetes cluster.
This way, you do not have to create any Kubernetes volumes at all.
To enable the NFS provisioner, you can specifiy the following options when installing RiseML:

| Name                     | Description |
| ------------------------ | ------------------------------------------- |
| `nfsProvisioner.enabled` | **Whether to deploy the internal NFS provisioner.** Defaults to `false`. |
| `nfsProvisioner.path`    | **Use the storage on the node below `path` to create new exports.** Defaults to `/tmp/risemlnfs` |

You can specify the node(s) where the NFS provisioner may run, by defining the **system node** labels (see above).
Note that the NFS provisioner is **only meant for testing**, as the data may be lost with node or pod restarts.

If you use the internal NFS provisioner, you can access the data from your workstation by deploying [Minio](#minio), which provides an S3 compatible storage interface.

## Persistent Storage

A few RiseML components (e.g., database, Git) can also persist their state to disk.
For test installations you can skip their persistence configuration, but it is strongly recommended for production environments.
If you enable persistence using any of the options below, you need to have created the corresponding Kubernetes persistent volumes as described [here](kubernetes.md#persistence).

The following options are available:

| Name                             | Description |
| -------------------------------- | ---- |
| `git.persistence.enabled`        | Use a persistent volume claim (PVC) to persist data; default: `false`.|
| `git.persistence.existingClaim`  | Name of existing PVC; default: `empty` |
| `git.persistence.storageClass`   | Storage class of backing PVC; default: `empty` |
| `git.persistence.accessMode`     | Use volume as `ReadWriteOnce` or `ReadWriteMany`; default: `ReadWriteOnce` |
| `git.persistence.size`           | Size of data volume; default: `30Gi` |
| `git.persistence.subPath`        | Subdirectory of the volume to mount. Default: `empty` |
| `postgresql.persistence.*`         | Persistence configuration for database; same options as `git.persistence` |
| `logs.persistence.*`             | Persistence configuration for logs; same options as `git.persistence` |
| `registry.persistence.*`         | Persistence configuration for image registry; same options as `git.persistence`, but with default size of `100Gi` |

## Minio

[Minio](https://github.com/minio/minio) is an open source object storage server compatible with Amazon S3 APIs.
RiseML uses Minio to provide access the `data` and `output` volumes via the RiseML CLI.
You can also use Minio's web interface or the Minio [command line tool](https://github.com/minio/mc).
The following options configure Minio:


| Name               | Description |
| ------------------ | ------------------------------------------- |
| `minio.accessKey`  | **Access key to use for Minio.** Defaults to `minioaccess` |
| `minio.secretKey`  | **Secret key to use for Minio.** Defaults to `eEUc1g4tOhzbO2JzoLndRR3At4ctO9EM` |

## Private Registry on Google Cloud Platform

RiseML automatically detects if it is running on the Google Cloud and uses the default service account to obtain access to the registry associated with the Google Project.
This allows you to reference private images in this registry using the `image: ` section of the `riseml.yml` for your experiments.


## Example Configurations

Below are a few example configurations for different setups.

### Bare Metal

This configuration should work on bare metal Kubernetes deployments.
It uses node selectors for RiseML system components and build jobs.

```
accountKey: rhglxtzcl6sgy3wtac8fbcfjoda60uwu
adminApiKey: yourSecretApiKeyYouWantToUse1234
adminEmail: user@company.com
nvidiaDriverDir: "/openai/cuda_drivers"
minio:
  secretKey: yourSecretMinioAccessKey
nodeSelectors:
  system:
    riseml.com/system-node: "true"
  imageBuilder:
    riseml.com/build-node: "true"
```

You need to make sure that at least one node has each of the defined node labels:
```
kubectl label node <node-name> riseml.com/build-node=true
kubectl label node <node-name> riseml.com/system-node=true
```

### Bare Metal, Persistent Storage, Minio

In addition to the above, this configures persistent storage for the database and Git and uses Minio for accessing data.

```
accountKey: rhglxtzcl6sgy3wtac8fbcfjoda60uwu
adminApiKey: yourSecretApiKeyYouWantToUse1234
adminEmail: user@company.com
nvidiaDriverDir: "/openai/cuda_drivers"
minio:
  secretKey: yourSecretMinioAccessKey
nodeSelectors:
  system:
    riseml.com/system-node: "true"
  imageBuilder:
    riseml.com/build-node: "true"
minio:
  secretKey: mySecretMinioKey
  accessKey: myAccessMinioKey
postgresql:
  persistence:
    enabled: true
git:
  persistence:
    enabled: true
```

Note that (in addition to the `data` and `output` volumes) you need to create physical volumes for the claims `riseml-git-claim` and `riseml-db-claim` as described [here](kubernetes.md#persistence).