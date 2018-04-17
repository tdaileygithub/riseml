# Customizing Images

When configuring an experiment you can use an image from a set of publicly available images and even customize it further using build steps.

Instead of using build steps, you can also generate your own image using Docker and make it publicly available.

## Build Steps

Here's an example for a TensorFlow image with an added build step:

```
project: hello-tensorflow
train:
  framework: tensorflow
  tensorflow:
    version: 1.2.1
    tensorboard: true
  install:
  - pip install Pillow
  run: nvidia-smi
```

The ```name``` section chooses an image from a set of publicly available images.
The ```install``` section contains a list of build steps: commands whose changes to the filesystem are persisted to customize your build.
To speedup experiments, builds are cached between consecutive runs.
Changes in the code or in the list of commands invalidates the build cache.
The ```run``` section contains a command that is executed within the experiment's container.

## Docker

**Note:** We strongly recommend using [build steps]() instead of using Docker to create custom images.

Instead of using the ```install``` build steps you can create custom images with Docker.
For this you need to create a ```Dockerfile```, build an image locally using ```docker build```, and push the image to Docker's public registry: [Docker Hub](https://hub.docker.com/).
When configuring the experiment specify your image together with your Docker Hub username, e.g., ```paul/tensorflow```.
RiseML then pulls the image from [Docker Hub](https://hub.docker.com/).
In fact, [RiseML's official images](https://hub.docker.com/u/riseml/) are also stored on Docker Hub.
For details, check out the [Docker builder reference](https://docs.docker.com/engine/reference/builder/).

