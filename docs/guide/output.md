# Writing Output

Your experiment may need to store intermediate or final results like checkpoints or models.
An output folder is made available in `/output` in the execution environment of your experiment.

Let's assume your code writes a model to the file `/output/toaster.model`.
Also, you mounted the `output` folder that was configured while installing RiseML on `/shared_output` on your local workstation.
The output will contain the following files (assuming your username is `your-username`):
```
$ ls /shared_output
your-username
$ find /shared_output/your-username
/shared_output/your-username/ai-toaster
/shared_output/your-username/ai-toaster/138
/shared_output/your-username/ai-toaster/138/riseml-configuration.yml
/shared_output/your-username/ai-toaster/138/toaster.model
/shared_output/your-username/ai-toaster/137/riseml-configuration.yml
....

```
The output of each experiment is in a separate directory, grouped by user, so you cannot accidentally overwrite or mix it with another experiment's output.
The output path is structured according to the [canonical ID](/reference/experiments/canonical_ids.md), and consists of the username, project name, experiment set (if it has one), and experiment (but not the job type and id).
In addition, the file `riseml-configuration.yml` contains the configuration that you used to start the job.
```
$ cat /shared_output/your-username/ai-toaster/138/riseml-configuration.yml
image:
  name: tensorflow/tensorflow:1.2.0
  install:
  - apt-get -y update
  - apt-get -y install git
  - git clone https://github.com/tensorflow/models
...
```

This makes it easy to look up parameters that you used to produce an output.
It also allows you to download or move around the output folder while keeping a reference to your configuration.
