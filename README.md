# RiseML

<img src="https://cdn.riseml.com/img/banner_github_blueprint.png" />

[RiseML](https://riseml.com) is a deep learning platform for [Kubernetes](https://kubernetes.io)

This repository contains the [central issue tracker](https://github.com/riseml/riseml/issues) for RiseML.

## Installation

The latest version of RiseML is v1.0.3. See the [release notes](RELEASES.md#riseml-v103-20180129) for details and upgrading.

### Software Requirements

|               | Version   | Comments                |
| ------------- | --------- | ----------------------- |
| Linux kernel  | ≥ 3.10    |                         |
| Docker        | ≥ 1.12.6  |                         |
| Kubernetes    | ≥ 1.6.0   |                         |
| Helm          | ≥ 2.5     | If you use RBAC, you need to [configure permissions](http://docs.riseml.com/install/kubernetes.html#helm-setup) |
| NVIDIA driver | ≥ 375     | (**Optional**) GPU only |

## Documentation

Documentation for RiseML can be found at <https://docs.riseml.com>.

Sources: https://github.com/riseml/riseml/tree/master/docs

## More Repositories

### [riseml/cli](https://github.com/riseml/cli)

A command line interface to connect to the RiseML API server and to manage experiments on RiseML.

### [riseml/config-parser](https://github.com/riseml/config-parser)

A config parser to validate and parse `riseml.yml` files.

### [riseml/client-python](https://github.com/riseml/client-python)

A Python SDK to report experiment results to the RiseML API server.

### [riseml/examples](https://github.com/riseml/examples)

Machine learning examples for getting started with RiseML.

### [riseml/monitor](https://github.com/riseml/monitor)

A component to publish utilization stats and node information to the RiseML API server.
