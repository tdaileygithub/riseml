## Preparations

Training a machine learning model, usually requires two things: *training data* and *machine learning code*.
The training data contains examples from which a model can be learned.
Your machine learning code is an algorithmic representation of your model and learning strategy.
The code reads the training data, updates the model's parameters, and stores the model on the disk.


### Data Setup

During installation and setup, a `data` folder to store training data was configured.
When you start an experiment, this shared folder is made accessible via `/data` in your runtime environment.

Say the shared storage is mounted in `/shared_data` on your local workstation.
You can create any subdirectory below this where you can place your data:

```
$ cd /shared_data/ai-toaster
$ find .
.
./images/train/1.jpg
./images/train/2.jpg
```
In the runtime environment of your experiment, you will be able to access `/data/ai-toaster/images/train/1.jpg` etc.

### Project Setup

The code to compute your model is developed locally and resides on your local workstation.
To associate and configure a project you need to create a configuration file.
The configuration file specifies your project name and how to run experiments.
It should reside in the root of your project and, preferably, use the default filename of `riseml.yml`.
Here is a sample configuration for a project called *ai-toaster*:

```
project: ai-toaster
train:
  framework: tensorflow
  tensorflow:
    version: 1.2.0
    tensorboard: true
  install:
    - pip install Pillow
  resources:
    cpus: 2
    mem: 4096
  run: >-
    python train_model.py --num-layers 64
                          --learning-rate 0.01
                          --training-data /data/ai-toaster
```
The configuration file specifies the project name and the required resources for your training jobs.
Resources always specifies the *minimal* requirements that are guaranteed during training.
In practice, if more CPU or Memory resources are available, the experiment will be able to use them.

The configuration also specifies the execution environment via the image tag: a base image with Tensorflow as well additional build steps (like installing the Pillow library).
The execution environment should include all libraries required by your code (e.g. what is typically provided in a *requirements.txt* for Python).
The `run` instruction specifies the command to execute in order to train the model.
Here, the file `train_model.py`, as well as other files possibly required by it, must reside in the project folder or be part of your execution environment.
You can find more details on the ```riseml.yml``` in the [Configuring Experiments](/reference/experiments/config.md) section.
