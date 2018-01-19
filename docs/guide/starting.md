
## Starting Experiments
In order to start an experiment, you need to execute the `riseml train` command:
```
$ riseml train
Syncing project (16.8 MiB, 15 files)...done
138       | [2017-08-30T09:25:56Z] --> STARTING
138       | [2017-08-30T09:21:46Z] --> BUILDING
138.build | [2017-08-30T09:21:53Z] Building your image
138.build | [2017-08-30T09:21:53Z] Downloading code 
138.build | [2017-08-30T09:21:53Z] Running install commands...
138.build | [2017-08-30T09:21:53Z] Step 1 : FROM tensorflow/tensorflow:1.2.0
138.build | [2017-08-30T09:21:54Z] Pulling from tensorflow/tensorflow
...
```
It reads the configuration file (`riseml.yml` by default) and automatically synchronizes the project directory to RiseML, where it is stored in a version control system.
For efficiency reasons, only the differences from your last sync are automatically transmitted and versioned.

After the project is synchronized, an image of your runtime environment is built based on your configuration.
This image also includes a copy of your code.
The build is performed on the cluster by RiseML and the output of the build process is streamed to your terminal where you can observe the progress.
Output on the terminal is prefixed with a part of the [canonical ID](/reference/experiments/canonical_ids.md) (`138.build`).
Repeated builds of the same or similar execution environments will use a cache to speed up the process.

After the build completes, your required resources will be allocated and your experiment will begin.
You will receive a process stream of the console output in your terminal.
`Ctrl+C` will exit the stream.

```
138.build | [2017-08-30T09:25:56Z] --> FINISHED
138.train | [2017-08-30T09:26:01Z] --> STARTING
138.train | [2017-08-30T09:26:06Z] --> RUNNING
138.train | [2017-08-30T09:26:20Z] Successfully downloaded inception-2015-12-05.tgz
^C
Job will continue in background.
Type `riseml logs 138` to connect to log stream again.
```


### Stopping an Experiment
If, for any reason, you want to stop your experiment, this can be achieved with the `riseml kill` command:
```
$ riseml kill 138
killed experiment 138
```
The job will no longer appear in the output of `riseml status` if you don't use the `-a` (all) flag.

