## Horovod

[Horovod](https://github.com/uber/horovod) is a distributed training framework for TensorFlow. The goal of Horovod is to make distributed Deep Learning fast and easy to use. It is an effortless alternative to manually creating a [Distributed TensorFlow](/guide/advanced/distributed_tensorflow.md) model.

With Horovod it is relatively straightforward to take a single-GPU TensorFlow model and train it on multiple GPUs - even across nodes. Depending on model architecture and network performance it can scale almost linearly by just adding more GPUs.

![alt text](/img/horovod_benchmark.png "Horovod Benchmark")

### How does it work?

Horovod runs a copy of the training script on each worker which reads a chunk of the data, runs it through the model and computes model updates (gradients). Then, it uses a [ring-allreduce algorithm](http://www.cs.fsu.edu/~xyuan/paper/09jpdc.pdf) that allows workers to average gradients and disperse them to all nodes without the need for a parameter server. Finally, the model is updated and the process repeats.

For optimal performance Horovod relies on message passing interface (MPI) primitives. While it is relatively easy to install MPI on a workstation, installation of MPI on a cluster typically requires some effort. With RiseML there is no need to configure MPI, everything is automatically set up when running a Horovod experiment.

### Usage

RiseML makes it is very easy to train Horovod models. We just need to make a small change to the `riseml.yml`. Let's take a look at an example:

```
project: example
train:
  framework: tensorflow
  tensorflow:
    version: 1.5.0
    horovod:
      workers: 32
  resources:
    gpus: 4
    cpus: 12
    mem: 4096
  run:
  - python train.py
```

In this case 32 workers will be started with 4 GPUs each - in total 128 GPUs. RiseML runs one Horovod process per GPU, thus in this case: 128 Horovod processes with one GPU each.

Each process executes the `run` command in parallel. In case the `run` attribute has multiple lines each process executes a line and then waits until all processes across all workers have finished execution before continuing with the next one.

**Note:** For maximum performance we recommend requesting the maximum number of GPUs available per worker to minimize communication overhead.

#### Number of processes per GPU

You can also change the number of processes per worker. By default RiseML runs one Horovod process per GPU. In case a worker doesn't have a GPU it runs one process per worker. Overriding the number of processes per worker is simple:

```
  tensorflow:
    horovod
      workers:
        count: 32
        processes: 1
```

This might come handy if you train a model that is already multi-GPU aware and you only want to use Horovod for distributing computation across nodes, not GPUs.

#### TensorFlow version

Choose the TensorFlow version with the `version` attribute. Currently following versions available:

| TensorFlow | Horovod |
| ---------- | ------- |
| 1.4.0      | 0.11.3  |
| 1.4.1      | 0.11.3  |
| 1.5.0      | 0.11.3  |

### Source-code modifications

Horovod requires you to make modifications to your TensorFlow program. Check out the [Horovod Documentation](https://github.com/uber/horovod#usage) for details. There are also a few [examples](https://github.com/uber/horovod/tree/master/examples) that are officially maintained to get started. There is also a [blog article](https://eng.uber.com/horovod/) by the Horovod authors that is worth reading.

### System Requirements

We recommend a high-throughput / low-latency network configuration with at least 25 Gbps inter-node bandwidth dedicated to Horovod, ideally InfiniBand or equivalent.

#### Azure

High-performance networking (30 Gbps) is available to all Azure GPU VMs. To enable it choose _Accelerated Networking_. For more details check [Microsoft's announcement](https://azure.microsoft.com/en-us/blog/maximize-your-vm-s-performance-with-accelerated-networking-now-generally-available-for-both-windows-and-linux/). Additionally, [InfiniBand support](https://azure.microsoft.com/de-de/blog/more-gpus-more-power-more-intelligence/) is available to select VMs.

#### AWS

High-performance networking (25 Gbps) is available to all EC2 GPU instances. To enable it choose _Enhanced Networking_ or _Elastic Network Adapter (ENA)_. For more details check [Amazon's docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/enhanced-networking.html). For better connectivity make sure to run the nodes in the same [Placement Group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html).
