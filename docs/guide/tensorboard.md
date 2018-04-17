# TensorBoard

TensorBoard is a suite of visualization tools provided by Tensorflow.
The tools help to understand, debug, and optimize Tensorflow models.
Via its Tensorflow integration, RiseML allows access to TensorBoard while running an experiment.

![alt text](/img/tensorboard.png "TensorBoard")

The integration is enabled in the configuration file via the `framework` and `tensorflow` options:

```
project: ai-toaster
train:
  framework: tensorflow
  tensorflow:
    distributed: false
    tensorboard: true
    version: 1.2.0
  resources:
    cpus: 2
    mem: 4096
    gpus: 0
  run:
    - python run.py --embedding-size 32 --verbosity INFO
```
First, the `framework: tensorflow` parameter enables the Tensorflow integration.
The integration is then configured with the parameters below `tensorflow:`.
When `tensorboard` is `true`, a TensorBoard instance is started on the cluster, which  reads summaries below the experiment's `OUTPUT_DIR`.
You can use the `riseml status` command to obtain a URL where you can access it:

```
$ riseml status 8
ID: 8
Type: Experiment
State: RUNNING
Image: tensorflow/tensorflow:1.2.1-gpu
Framework: tensorflow
Framework Config:
  tensorboard: True
Tensorboard: http://34.253.200.241:31213/train-rj1z-tb
...
```

TensorBoard will be shut down automatically once the associated experiment finishes.
To obtain an offline version you can always run an instance of TensorBoard on your local workstation (assuming you have Tensorflow installed):

```
$ tensorboard --logdir=/shared_output/your-user/ai-toaster/9
Starting TensorBoard 54 at http://angry-toaster:2222
(Press CTRL+C to quit)

```
