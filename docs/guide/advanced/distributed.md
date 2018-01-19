

## Distributed Training (with TensorFlow)

Training big neural networks is computationally intensive.
In the era of big data, training a model to convergence may take a prohibitively long time.
In addition, huge machine learning models may not fit onto the GPUs of a single node.
Therefore, it can be desirable to perform *distributed training* across multiple machines to speed up training or to be able to even train the model in the first place.

Distributed training is performed differently with different frameworks.
There is no one size fits all solution.
Instead, what works depends on the model and data; and you will need to try different variations.
Currently, RiseML offers a distributed training integration with Tensorflow.
Tensorflow supports different kinds of distributed training, e.g., synchronous or asynchronous updates, data-parallelism and model-parallelism (see the [Tensorflow Documentation on Distributed Training](https://www.tensorflow.org/deploy/distributed#replicated_training).
For all of these approaches, Tensorflow uses the underlying concepts of *workers*, *parameter servers*, and *master*.

![alt text](/img/distributed_training.png "Distributed Training")

**Workers** take care of the heavy computation.
They read the training data and compute updates to the model - in parallel.
These updates are then sent to **parameter servers**.
These act as a shared storage for the model.
Other workers can always obtain an up-to-date version of parameters from the parameter servers.
To avoid bottlenecks, one can use several parameter servers that track different parts of the model.
One worker is also designated as **master**.
It coordinates the training process and takes care of maintenance operations such as writing intermediate checkpoints of the model to the disk.

To start a worker, parameter server, or master, the Tensorflow convention is to run the same codebase on all nodes and execute different code paths based on an environment variable.
The *TF_CONFIG* environment variable on each node defines the roles of all nodes and how they can be reached (IP and port).
The content of the TF_CONFIG variable is (serialized) JSON, e.g.:

```json
{
   "cluster":{
      "ps":[
         "host1:2222",
         "host2:2222"
      ],
      "worker":[
         "host3:2222",
         "host4:2222",
         "host5:2222"
      ]
   },
   "task":{
      "type":"worker",
      "index":1
   }
}
```

The `cluster` information specifies the different components and the IPs and ports by which they can be reached.
`task` defines the role of the current host.
The index is zero-based, thus the code above specifies the second worker.
Because each host has a different role or index, the TF_CONFIG variable needs to be different for each host.
Furthermore, in order to correctly specify the `cluster` information, it must be clear where each component is running beforehand.
Of course, RiseML takes care of generating the correct TF_CONFIG for each experiment.

The code on each node reads the TF_CONFIG variable and acts accordingly.
Here is an example from the official Tensorflow repository:

```python
  tf_config_json = json.loads(os.environ.get('TF_CONFIG'))
  cluster = tf_config_json.get('cluster')
  job_name = tf_config_json.get('task', {}).get('type')
  task_index = tf_config_json.get('task', {}).get('index')
  cluster_spec = tf.train.ClusterSpec(cluster)
  server = tf.train.Server(cluster_spec,
                           job_name=job_name,
                           task_index=task_index)
  if job_name == 'ps':
    # Start a parameter server.
    server.join()
    return
  elif job_name in ['worker']:
     # start a master/worker
    return run(server.target, job_name == 'master', *args, **kwargs)

```

To start a distributed training job with Tensorflow you need to 1) enable the Tensorflow integration and 2) specify the number of components and their required resources.
Here is an example:

```
project: ai-toaster
train:
  framework: tensorflow
  resources:
    cpus: 2
    mem: 16384
    gpus: 4
  tensorflow:
    version: 1.2.1-gpu
    distributed:
      worker: 3
      ps:
        count: 2
        resources:
          cpus: 2
          mem: 16384
          gpus: 0
  run: >-
    python train_model.py --num-layers {{ num-layers }}
                          --learning-rate {{ learning-rate }}
                          --training-data /data/my-project
```
The Tensorflow integration is enabled with `framework: tensorflow`.
Additionally, the `tensorflow` section describes how to perform distributed computing.
Here, we request 3 workers.
The first worker (with index 0) is also designated as master.
The workers each need 2 CPUs, 16GB of RAM, and 4 GPUs (defined in the default resource section below `train`).
In addition, we request two parameter servers without GPUs (defined in the `distributed` section).
If desired, it is possible to specify different resource requirements for workers and the master in the same way as for parameter servers.

Starting a distributed experiment works the same way as for regular experiments:

```
$ riseml train
Syncing project (5.7 MB, 6 files)...done
4             | [2017-08-31T07:23:46Z] --> BUILDING
4.build       | [2017-08-31T07:23:46Z] --> PENDING
4.master      | [2017-08-31T07:23:46Z] --> CREATED
4.ps.1        | [2017-08-31T07:23:46Z] --> CREATED
4.worker.1    | [2017-08-31T07:23:46Z] --> CREATED
4.worker.2    | [2017-08-31T07:23:46Z] --> CREATED
4.build       | [2017-08-31T07:23:50Z] Building your image
```

After generating the TF_CONFIG environment variable, RiseML starts all of the processes, monitors their state, and takes care of teardown in case a critical component fails.
Here, three workers (including the "master worker") and one parameter server were created.
If the *master* fails, the remaining parameter servers are automatically killed and no manual intervention is necessary.
If the remaining components finish successfully, the parameter servers are also terminated, so you don't need to write code to terminate them automatically.

After executing `riseml train`, like for regular experiments, you will receive a stream of logs, in this case of all workers, parameter servers, and the master.
Issuing `riseml status` will show their status and you can also monitor their utilization:

```
$ riseml monitor 4
ID         PROJECT    STATE    CPU % MEM % MEM-Used / Total GPU %  GPU-MEM % GPU-MEM Used/Total
4.master   ai-toaster RUNNING  262   0.1   0.5 / 480.3      N/A    N/A       N/A / N/A
4.ps.1     ai-toaster RUNNING  84    0.7   0.2 / 31.4       N/A    N/A       N/A / N/A
4.worker.1 ai-toaster RUNNING  514   0.1   0.4 / 480.3      N/A    N/A       N/A / N/A
4.worker.2 ai-toaster RUNNING  107   0.0   0.2 / 480.3      N/A    N/A       N/A / N/A
```

To kill the distributed experiment, use the canonical ID of the experiment `riseml kill 4`.

If your code writes Tensorflow summary information, progress can also be visualized via Tensorboard in a browser.
How to enable and access Tensorboard is described in the [Tensorboard Guide](/guide/tensorboard.md).

As with regular experiments, an output directory is defined in the `OUTPUT_DIR` environment variable.
For distributed training, this directory is shared between all jobs.
This allows the components to share data, e.g., the master can write checkpoints and request a parameter server to load its parameters from this checkpoint.
In addition, this allows Tensorflow summary information to be written and visualized in Tensorboard.
