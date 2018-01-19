# Check Installation and Register

## System Check
Finally, you should check your whole setup.
First, verify that all nodes are reported with their resources:
```
$ riseml system info
RiseML Client/Server Version: 1.0.0/1.0.0
RiseML Cluster ID: 30ac0e42-e199-11e7-bbbd-0a580af4149c
Kubernetes Version 1.6 (Build Date: 2017-04-19T20:22:08Z)

NODE                CPU  MEM    GPU  GPU MEM
ip-172-31-25-223    2    3.8    0    0
ip-172-31-27-167    2    3.8    0    0
ip-172-31-23-87     2    3.8    0    0
ip-172-31-29-130    32   480.2  8    89.4
ip-172-31-31-92     2    3.8    0    0
--------------------------------------------
Total               40   495.2  8    89.4
```

The list of nodes will exclude your master node and report the number of CPUs, GPUs, and amount of memory for each node as reported by Kubernetes.
If any of your node misses GPUs, check the Kubernetes and kubelet configuration on that node (see [Kubernetes configuration](#kubernetes.md)).

Next, verify that RiseML system components could successfully connect to the NVIDIA driver on your GPU nodes:

```
$ riseml system info -g
NODE              DRIVER  NAME       ID  MEM   SERIAL
ip-172-31-29-130  384.90  Tesla K80  0   11.2  0325016130551
                          Tesla K80  1   11.2  0325016130551
                          Tesla K80  2   11.2  0325016132175
                          Tesla K80  3   11.2  0325016132175
                          Tesla K80  4   11.2  0325016131981
                          Tesla K80  5   11.2  0325016131981
                          Tesla K80  6   11.2  0325016132289
                          Tesla K80  7   11.2  0325016132289
```
This should report the NVIDIA driver version and GPUs.
If this information is missing, see [Troubleshooting](#troubleshooting.md).


Then, you can start a test experiment:
```
$ riseml system test
```
This will start a simple experiment within your cluster.
Verify that it is running with
```
$ riseml status
```
After about five minutes it will complete and you will be able to see its status only in `riseml status -a`.

## Account Registration

If you provided a wrong or no account key during installation, you can register your cluster with an account later on.
Registering will give you a more profound and integrated user experience as you become a member of the RiseML community.

To register an unregistered cluster:
```
$ riseml account register
```
This will ask you for an account key and register your cluster.