# Starting Experiments on GPUs

In order to run experiments with GPUs, you need to specify the number of required GPUs in the job configuration:

```
project: ai-toaster
train:
  resources:
    cpus: 2
    mem: 4096
    gpus: 2
  image:
    name: nvidia/cuda:8.0-cudnn7-runtime
  run: >-
    python train_model.py --num-layers 64
                          --learning-rate 0.01
                          --training-data /data/ai-toaster
```
This will allocate the requested amount of GPUs for your experiment.
Note that a single job can only run on a single node.
Therefore, a job cannot use more GPUs than what any single node provides. However, an experiment can contain multiple jobs as in [distributed training](advanced/distributed_tensorflow.md) training or even sub-experiments as in [hyperparameter optimization](advanced/hyper.md).

**Important**: To make use of the GPUs, you need to use or build an image that provides the required libraries, e.g. CUDA, for GPUs.
We recommend using the official `nvidia/cuda` or `tensorflow-gpu` images (if you use Tensorflow) or derivations thereof.


If your training job uses GPUs, you will be able to monitor their utilization, power usage, and temperature via the `riseml monitor --gpu` command:

```
$ riseml monitor 139 --gpu
139.train (STATE: ● RUNNING)
  ID   NAME       UTIL  MEM        POWER     TEMP  BUS ID
  0    Tesla K80  69%   10.7/11.2  126/149W  73C   0000:00:1E.0
```
