# Understanding RiseML

RiseML provides a simple yet powerful abstraction for machine learning engineers working on GPU infrastructure both in the cloud and on bare metal.
ML engineers access RiseML via a command-line interface (CLI) that hides the working details of the underlying cluster hardware which introduces a new layer tightly coupled to machine learning concepts.
Researchers using RiseML think in terms of _experiments_ that train a model.
Under the hood, RiseML takes care of executing these experiments on the infrastructure in a robust manner, including deciding on which nodes specific parts of an experiment are executed.

## Architecture

![alt text](/img/architecture.png "Architecture")

RiseML's architecture consists of three main layers: The CLI, a backend component, and Kubernetes as a cluster orchestration framework.
Kubernetes manages the cluster's nodes and also provides access to GPUs that are present on the nodes.
Using Kubernetes allows RiseML jobs to run stateless and conflict-free.

RiseML's backend consists of multiple components that run on top of Kubernetes. RiseML takes care
of versioning and running your experiments, gathering their logs, and tracking the state of each experiment. This is the core of RiseML. By providing an API, cluster-external applications,
such as RiseML's CLI, can access anc control your clusters using RiseML's abstractions.

All experiments on the RiseML cluster run in containers, lightweight "virtual machines", running Linux.
This enables installing project dependencies that don't interfere with each other.
For example, it is possible to run different Linux distributions on the same cluster or even the same node at the same time.
Each container is started from an image.
The image contains the container's filesystem, including all system libraries, your machine learning code, and other dependencies you need to run your code. RiseML allows for the customization of images using [build steps](guide/advanced/custom_images.md).

## Concepts

### User

In RiseML, a user provides a means of ownership and access management.
Each user is identified with a username and email address.
A user can own multiple projects and start experiments.
While admin users are allowed access to all projects, non-admin users are only allowed to access their own projects and experiments.
In addition, admin users can perform cluster management.

### Project

A project consists of machine learning code, data and information related to currently running and past experiments.
Each project belongs to a user and has a name that can be freely chosen at creation.
A project's root can be any directory that contains a RiseML config (```riseml.yml```).
Upon starting an experiment, the directory tree below the root is versioned and prepared for execution on the cluster.

### Experiment

An experiment is a single instance of your model with its associated architcture, training data, and hyperperameters. Upon starting an experiment, the directory tree below the root is versioned and prepared for execution on the cluster.

### Experiment Set

An experiment set is a group of experiments and behaves itself like a single experiment.
This is useful for [hyperparameter optimization](https://github.com/riseml/docs/blob/master/guide/advanced/hyper.md) in which multiple experiments, that differ only in their model parameters, get executed.
The possible parameter combinations can be defined in the RiseML config.
By default RiseML performs a grid search over the entire parameter space.

### Job

A job is a specific execution unit of your experiment or experiment set and gets scheduled onto a single node within your cluster.
The job type you will mostly see are training jobs.
These can be either single `train` jobs for non-distributed experiments or multiple worker jobs per distributed experiment.
The specific names of the latter depend on your framework, e.g. `ps` (parameter server), `worker`, and, for Tensorflow, `master`.
Other job types are `build`, for building an experiment's image, and
framework-dependent auxiliary jobs, such as `tensorboard` for Tensorflow.


