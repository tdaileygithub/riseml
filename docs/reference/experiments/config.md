# Experiment Configuration

The `riseml.yml` file is the single source of truth for your RiseML project.
It defines your experiment, i.e., which image and commands to run, which framework to use,
and which resources to acquire.

For reference, the following will give you an overview of the
`riseml.yml`'s possibilities, grouped by feature.

## Set project name
**Required.** Set the name of your current project.
```yaml
project: name-of-project
```

## Specify which base image to use
**Optional.** In case you do not wish to use the provided frameworks (see below) you can choose to run an experiment in a custom Docker image. Use the `image` field to provide a valid DockerHub reference. Additionally you can provide an `install` field to supplement steps before the experiment is run; these are specified as a YAML list.

```yaml
train:
  image: pytorch/pytorch
  install:
  - pip install -r requirements.txt
```

### Recommended Images

Here is a list of repositories and images that we recommend:

| Framework      | Repository                            | Comments                                       |
| ------------   | ------------------------------------- | ---------------------------------------------  |
| Base image with CUDA | [```nvidia/cuda```](https://hub.docker.com/r/nvidia/cuda/) | Follow the link to find the different tags (CUDA 8, 9 etc.). Usually, you need a `devel` image, e.g. tag `9.1-cudnn7-devel` |
| Keras          | [```gw000/keras```](https://hub.docker.com/r/gw000/keras/) |  Use tags `2.1.3-py2-tf-gpu`/`2.1.3-py3-tf-gpu` for Python 2/3 with GPU |
| Torch          | [```kaixhin/cuda-torch```](https://hub.docker.com/r/kaixhin/cuda-torch/)   | Remove `cuda-` prefix for CPU only |
| Caffe          | [```bvlc/caffe```](https://hub.docker.com/r/bvlc/caffe/)   | Use `gpu` tag for GPU support, `intel` for Intel-optimized images. |
| CNTK           | [```microsoft/cntk```](https://hub.docker.com/r/microsoft/cntk/) |  Use tags `2.3-gpu-python3.5-cuda8.0-cudnn6.0`/`2.3-gpu-python2.7-cuda8.0-cudnn6.0` for Python 2/3 with GPU |
| Theano         | [```kaixhin/cuda-theano```](https://hub.docker.com/r/kaixhin/cuda-theano/)   | Remove `cuda-` prefix for CPU only |
| Lasagne        | [```kaixhin/cuda-lasagne```](https://hub.docker.com/r/kaixhin/cuda-lasagne/) | Remove `cuda-` prefix for CPU only |


*For **TensorFlow**, we recommend using the `framework` field (described below under [Integrate with Tensorflow](#integrate-with-tensorflow))*

### Specify command to run
**Required.** You must tell RiseML which command it should run within your final image.
This should start your experiment.

```yaml
train:
  run: python run.py --num-epochs 2 --num-layers 4 --embedding-size 32
```

You can also specify multiple commands as a YAML list, if required:

```yaml
train:
  run:
    - echo Hello World!
    - python run.py --num-epochs 2 --num-layers 4 --embedding-size 32
```

If any of these commands fails, execution will stop immediately. Hence, the following
commands will not get executed.

## Specify resources
**Required.** You can specify the resources you want your experiment to consume.
`cpus` is the number or fraction of CPUs you require,
`mem` denotes your memory requirements in gigabytes, and
`gpus` is the number of GPUs your experiment needs with the default as 0.

```yaml
train:
  resources:
    cpus: 2
    mem: 4
    gpus: 2
```

## Define a Hyperparameter Experiment
**Optional.** You can define a hyperparameter experiment by adding one or multiple
parameter definitions. `parameters` is a YAML map, whose keys are the names of the
parameters you want to define. Its values either contain a YAML list of possible values
or describe a `range` of numerical values by giving a `min`, `max`, and `step`.

```yaml
train:
  parameters:
    num-epochs:
      range:
        min: 3
        max: 5
        step: 1
    embedding-size:
      - 16
      - 32
  concurrency: 2
```

RiseML will create and execute sub-experiments for every combination of possible parameter values.
You can control how many experiments it executes in parallel by specifying a `concurrency`, which defaults to 1.
To make your hyperparameter experiment work, you have to put the parameters into
your `run` command. RiseML will take care of replacing the placeholders with concrete
values for the given sub-experiments.

```yaml
train:
  run: python run.py --num-epochs {{num-epochs}} --embedding-size {{embedding-size}}
```

## Integrate with Tensorflow
To use RiseML's Tensorflow integration, you can specify `framework: tensorflow`
and add a `tensorflow` section.
Currently, the Tensorflow integration supports specifying the version to use, adding a Tensorboard to your
experiment, and running your experiment in a distributed fashion.

```yaml
train:
  framework: tensorflow
  tensorflow:
    version: 1.5.0
    tensorboard: true
    distributed:
      ps: 1
      worker: 3
```

This will run your experiment with one parameter server and 3 workers, of which one of them is the master, together with a Tensorboard.
Resource constraints will be taken from your main `resources` section.
However, you can also override them in each node of your distributed job, even for the master,
by adding `resources` subsections that follow the same rules as the main `resources` section:

```yaml
train:
  tensorflow:
    distributed:
      ps:
        count: 1
        resources:
          cpus: 2
          mem: 2
      worker:
        count: 3
        resources:
          cpus: 1
          mem: 4
          gpus: 2
      master:
        resources:
          cpus: 2
          mem: 8
          gpus: 2
```
