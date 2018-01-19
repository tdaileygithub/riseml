# Quick Start

This guide will get you started with RiseML.
In the following, we are going to assume that you already have a running [installation of RiseML](/install).

First, we're going to create an empty project folder:
```
$ mkdir simple-project
$ cd simple-project
```

Next, we initialize it with an example project:
```
$ riseml init
riseml.yml successfully created
```

Let's have a look at the generated project file `riseml.yml`:
```yaml
project: simple-project
train:
  framework: tensorflow
  tensorflow:
    version: 1.2.0
  install:
    - apt-get -y update
    - apt-get -y install git
    - git clone https://github.com/tensorflow/models
  resources:
    gpus: 0
    cpus: 1
    mem: 512
  run:
  - python models/tutorials/image/imagenet/classify_image.py
```

This defines configurations to run an experiment.
One of the Tensorflow tutorials is cloned inside a standard Tensorflow image.
The tutorial code is executed via the specified command.
The configuration also specifies the resources the experiment requires.

You can start the experiment by running:
```
$ riseml train -l
project created: tiny (3c94096e-e197-11e7-adef-0a580af40eac)
Syncing project (0 B, 3 files)...done
1.build       | [2017-12-15T12:55:34Z] --> STARTING
1.build       | [2017-12-15T12:55:34Z] Reason: PREPARE
1.build       | [2017-12-15T12:55:34Z] Message: Preparing environment
1.build       | [2017-12-15T12:55:49Z] Preparing image for your experiment
1.build       | [2017-12-15T12:55:49Z] Downloading your code
1.build       | [2017-12-15T12:55:49Z] Running install commands...
1.build       | [2017-12-15T12:55:49Z] Step 1 : FROM tensorflow/tensorflow:1.2.0
1.build       | [2017-12-15T12:55:49Z] Pulling from tensorflow/tensorflow
1.build       | [2017-12-15T12:55:49Z] --> RUNNING
...
1.build       | [2017-12-15T13:00:08Z] ...stored 80%
1.build       | [2017-12-15T13:00:19Z] ...stored 90%
1.build       | [2017-12-15T13:00:31Z] ...stored 100%
1.build       | [2017-12-15T13:00:35Z] Build process finished.
1             | [2017-12-15T13:00:35Z] --> PENDING
1.train       | [2017-12-15T13:00:35Z] --> PENDING
1.build       | [2017-12-15T13:00:35Z] --> FINISHED
1.build       | [2017-12-15T13:00:35Z] Reason: COMPLETED
1.build       | [2017-12-15T13:00:35Z] Exit Code: 0
1.tensorboard | [2017-12-15T13:00:35Z] --> PENDING
1             | [2017-12-15T13:00:35Z] --> STARTING
1.train       | [2017-12-15T13:00:35Z] --> STARTING
1.train       | [2017-12-15T13:00:35Z] Reason: PREPARE
1.train       | [2017-12-15T13:00:35Z] Message: Preparing environment
1.tensorboard | [2017-12-15T13:00:35Z] --> STARTING
1.tensorboard | [2017-12-15T13:00:35Z] Reason: PREPARE
1.tensorboard | [2017-12-15T13:00:35Z] Message: Preparing environment
1.train       | [2017-12-15T13:02:03Z] >> Downloading inception-2015-12-05.tgz 100.0%
1.train       | [2017-12-15T13:02:03Z] Successfully downloaded inception-2015-12-05.tgz 88931400 bytes.
1.train       | [2017-12-15T13:02:03Z] giant panda, panda, panda bear, coon bear, Ailuropoda melanoleuca (score = 0.89107)
1.train       | [2017-12-15T13:02:03Z] indri, indris, Indri indri, Indri brevicaudatus (score = 0.00779)
1.train       | [2017-12-15T13:02:03Z] lesser panda, red panda, panda, bear cat, cat bear, Ailurus fulgens (score = 0.00296)
1.train       | [2017-12-15T13:02:03Z] custard apple (score = 0.00147)
1.train       | [2017-12-15T13:02:03Z] earthstar (score = 0.00117)
1.train       | [2017-12-15T13:02:04Z] --> FINISHED
1.train       | [2017-12-15T13:02:04Z] Reason: COMPLETED
1.train       | [2017-12-15T13:02:04Z] Message: Command python models/tutorials/image/imagenet/classify_image.py return code: 0
1.train       | [2017-12-15T13:02:04Z] Exit Code: 0
1             | [2017-12-15T13:02:04Z] --> FINISHED
```

Congratulations, you successfully ran your first machine-learning experiment on RiseML!
This actually:
* sent your project directory to the RiseML cluster
* built a container image for your experiment with your revisioned code
* ran the image on one of your cluster's nodes
* stored the output in a specific output directory for this experiment

You should continue reading the [User Guide](/guide) to know what else RiseML offers you.
