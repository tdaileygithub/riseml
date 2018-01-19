## Runtime Environment

RiseML provides each job within an experiment with a specific runtime environment.
This environment consists of three parts: a) a mounted directory for input data, b) a mounted directory for writing output, and c) a set of environment variables.

### Mounts
Your experiment's job has access to two mounted directories.

**/data**: A read-only folder called `/data` gives you access to your RiseML's cluster-wide shared training data, which is configured by your RiseML admin.
Depending on how your organization structures its data, it can contain a multitude of datasets.

**/output**: A writable folder named `/output` is made available only for your experiment to write its output.
You can write logs, checkpoints, or models into this directory.
Be aware that if your experiment consists of multiple jobs, e.g., for distributed training (but not for hyperparameter optimization), they will share the same output folder.
If you have mounted your output network storage locally, you will see that every experiment's outputs are structured as follows:

```
/:username/:project/[:series_id]/:experiment_id
```

### Environment Variables
While running, an experiment has access to the following environment variables:

| Variable           | Description                                          |
| ------------------ | ---------------------------------------------------- |
| `OUTPUT_DIR`       | Directory where the experiment can write its output. Currently always `/output`.  |
| *`HYPER_PARAM_NAME`* | If you run [hyperparameter optimization](/guide/advanced/hyper.md), an environment variable with the uppercase name of each defined parameter is created. It contains the value used for the current experiment. Examples: `LEARNING_RATE`, `LR_DECAY`, `NUM_LAYERS` ... |
| `TF_CONFIG`        | For Distributed Tensorflow, this variable contains a cluster definition describing the master and workers and under which IP:PORT they can be accessed (see [Distributed Training](/guide/advanced/distributed.md) for more details). |
| `EXPERIMENT_ID`    | ID of the current experiment. Used by client libraries, e.g., to report results.  |
