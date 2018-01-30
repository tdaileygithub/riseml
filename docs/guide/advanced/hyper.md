

## Hyperparameter Optimization

The performance of your final model is influenced by the training data, the kind of model, and the learning algorithm.
The model as well as your learning algorithms have parameters of their own, like the number of layers in a neural network or the learning rate in gradient descent.
In order to find the best model, it makes sense to find a good combination of these parameters.
This is the task of *hyperparameter optimization*.

With RiseML, you can easily perform a grid search over different hyperparameter configurations.
This is enabled by the *parameters* section in the job configuration.
Here is an example:

```
project: ai-toaster
train:
  resources:
    cpus: 2
    mem: 4096
    gpus: 2
  parameters:
    lr:
      - 0.0001
      - 0.001
    lr-decay:
      - 1e-6
      - 1e-7
    epochs:
      - 20
      - 30
  concurrency: 2
  image:
    name: nvidia/cuda:8.0-cudnn7-runtime
  run: >-
    python train_model.py --num-layers {{num-layers}}
                          --learning-rate {{learning-rate}}
                          --training-data /data/ai-toaster
```
The *parameters* section defines the individual parameters and their possible values.
Here, a total of 2 (lr) \* 2 (lr-decay) \* 2 (epochs) = 8 combinations are defined.
During execution, the actual value of each parameter is passed to the command instead of ```{{parameter-name}}```.

Executing `riseml train` will start a hyperparameter experiment with a sub-experiment for each combination:
```
$ riseml train
Syncing project (1.3 MB, 7 files)...done
144             | [2017-08-30T09:59:06Z] --> PENDING
144.1           | [2017-08-30T09:59:06Z] --> PENDING
144.2           | [2017-08-30T09:59:06Z] --> CREATED
....
```

By default, only a single sub-experiment will be run in parallel.
You can control this via the *concurrency* parameter, so in the example above 2 sub-experiments will be run in parallel.
Each sub-experiment will have its own ID, e.g., 144.1 and 144.2 as in the example above.

<!-- **TODO: diagram parallel execution** -->

The `riseml status` command will show you what combinations have been run already:

```
ID: 144
Type: Set
State: STARTING
Project: ai-toaster

EXP ID STATE     AGE           PARAMS
144.1  STARTING  8 second(s)   epochs=20, lr=0.0001, lr-decay=1e-6
144.2  STARTING  8 second(s)   epochs=20, lr=0.0001, lr-decay=1e-7
144.3  CREATED   8 second(s)   epochs=20, lr=0.001, lr-decay=1e-6
144.4  CREATED   8 second(s)   epochs=20, lr=0.001, lr-decay=1e-7
144.5  CREATED   8 second(s)   epochs=30, lr=0.0001, lr-decay=1e-6
144.6  CREATED   8 second(s)   epochs=30, lr=0.0001, lr-decay=1e-7
144.7  CREATED   8 second(s)   epochs=30, lr=0.001, lr-decay=1e-6
144.8  CREATED   8 second(s)   epochs=30, lr=0.001, lr-decay=1e-7
```


### Hyperparameter Optimization Output

In order to find the best hyperparameter combination, each sub-experiment needs to output a measure of its performance.
Often this is something like the accuracy or loss on a development set.
With Tensorflow, such statistics can be recorded and compared via [Tensorboard](/guide/tensorboard.md).
Each experiment's parameters are also written to the output directory as part of the configuration in a file called `riseml-configuration.yml`:

```
image:
  name: nvidia/cuda:8.0-cudnn7-runtime
params:
  epochs: 20
  lr: 0.0001
  lr-decay: 1e-7
project: ai-toaster
resources:
  cpus: 2
  gpus: 2
  mem: 4096
revision: 4efd8d995e0c1635296ec3c404276c8d4ff2d87c
run:
  run: >-
    python train_model.py --num-layers {{num-layers}}
                          --learning-rate {{learning-rate}}
                          --training-data /data/ai-toaster

```
This allows you to write performance measures to the output directory and link them to the parameters that were used to produce them.


If you have enabled the [Tensorboard](/guide/tensorboard.md) integration, Tensorboard provides real-time statistics for all experiments below the parent directory (e.g., `144`above).
This allows you to compare different runs in real-time:

![alt text](/img/tensorboard_hyper.png "Tensorboard for Hyperparameter Optimization")

