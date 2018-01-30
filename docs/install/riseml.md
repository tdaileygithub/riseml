---
description: Instructions for manual installation via Helm
---
# Install RiseML

Before installing or upgrading, please always **check the [release notes](https://github.com/riseml/riseml/blob/master/RELEASES.md)** of the current version for upgrade or installation information.

## Add RiseML Repository

RiseML's cluster components are installed with the package manager Helm.
You need to add RiseML to your Helm repositories:
```
$ helm repo add riseml-charts https://cdn.riseml.com/helm-charts
"riseml-charts" has been added to your repositories
```

## Install using Helm

You can install RiseML using the configuration file prepared in the previous [step](configuration.md):

```
$ helm install riseml-charts/riseml --name riseml --namespace riseml -f riseml-config.yml
```

Helm will deploy RiseML system components and output what it has done.
At the end, it prints information on how to configure the client:
```
NOTES:

RiseML was deployed. It may take a few minutes for all services to be operational.
You can watch the progress with this command (all Pods should be RUNNING):
  watch -n 1 kubectl get pods -n=riseml

To set up your client, look up your RiseML master's hostname or ip address and run:
  export RISEML_HOSTNAME=<YOUR MASTER HOSTNAME/IP>

### RiseML Client
You can get the RiseML client from here: http://docs.riseml.com/install/cli.html
To configure the RiseML client, run:
  riseml user login --api-key mlrise --host $RISEML_HOSTNAME

You can find some examples to run on https://github.com/riseml/examples
More information is available in our documentation: https://docs.riseml.com
```

If you installed using the `nodePorts: false` option the output above may look slightly different.

Before setting up the client, you should wait until all Pods switch to a `RUNNING` state:
```
$ watch -n 1 kubectl get pods -n=riseml
```

When finished, you can continue with installing the [Command-Line Interface](cli.md).
