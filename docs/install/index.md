# Installation & Setup

If you want to get RiseML running very quickly, we provide two easy ways of installing RiseML below.
For production-grade workloads, you may want to follow the [custom installation steps](#custom-installation).
If you need support, please [contact us](mailto:contact@riseml.com).

## Quick Installation

The following installation options are available:

- **AWS**: we provide an installer to deploy a complete cluster on AWS in minutes (including GPU support). You can choose what kind of nodes and how many to deploy on. All you need is an account on AWS and your AWS API key and secret.
- **Kubernetes Test Installation**: if you have a working Kubernetes installation, we provide an example configuration and steps that allow a quick RiseML installation for testing/evaluation purposes.

**[Continue here](quicksetup.md)**, if you want to perform a quick installation.

## Custom Installation

The following steps describe a custom installation.

##### Step 0: Prerequisites
First, you should check [our requirements](requirements.md) to make sure that your cluster setup satisfies them.
If you don't have a Kubernetes installation or cluster please refer to the [Kubernetes documentation](https://kubernetes.io/docs/setup/pick-right-solution/)
to get an overview of the different possibilities.

##### Step 1: Configure Kubernetes
Before starting to configure and install RiseML's cluster components, you need to [setup your Kubernetes](kubernetes.md) installation accordingly.
This includes installing Helm, Kubernetes' package manager, together with correct permissions, configuring GPU support (if required), and preparing persistent storage for production-grade installations.

##### Step 2: Prepare and Configure RiseML's Installation
Next, you need to prepare a [configuration file](configuration.md) that is passed to RiseML's installation process.
This will give RiseML information such as where to find training data, where to put experiments' results, and whether to use persistent storage.

##### Step 3: Install RiseML's Cluster Components
After you have prepared the configuration, you can [install RiseML](riseml.md) into Kubernetes using Helm.
You will need a RiseML account key which you can get for free by signing up on our [website](https://riseml.com/pricing).

##### Step 4: Install RiseML's CLI
Next, you need to [install RiseML's CLI](cli.md) on every machine you wish to use RiseML on.
This is done by downloading the correct binary for your machine's platform and configuring it to use your specific cluster and user.

##### Step 5: Check Your Installation
As a final step, we recommend that you [check your installation](register.md) to verify everything is set up correctly and works as expected.

#### Troubleshooting
If you have trouble during installation refer to the [troubleshooting guide](troubleshooting.md) or [contact us](mailto:contact@riseml.com).