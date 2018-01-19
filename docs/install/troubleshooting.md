# Troubleshooting

## Command Line Interface

### My client cannot connect to the RiseML cluster

Please check whether all connection parameters of the client are set correctly:
```
$ cat ~/.riseml/config
```

This should show you the following variables for your cluster: `api-server`, `sync-server` and for your user: `api-key`.


### I can't see GPU information with `riseml system info -l`

The most likely cause is that the RiseML monitor component that reports this information couldn't connect to the NVIDIA driver.
On the given node, verify that the path you provided in `nvidiaDriverDir` contains the driver files:

```
$ ls /var/lib/nvidia-docker/volumes/nvidia_driver/latest
bin  lib  lib64

```

This directory must contain the `bin` `lib` and `lib64` directories of the driver that is currently in use by the host.
If you upgraded your driver, you must update this directory and restart the RiseML monitor component on this node.
The easiest way is by rebooting that node.

For further troubleshooting, check the logs of the RiseML monitoring component on that node.
First, find the name of the monitor pod on the node.
For example, if the node is named *ip-172-31-30-98*:
```
$ kubectl describe node ip-172-31-30-98 | grep riseml-monitor | awk '{print $2}'
riseml-monitor-snbxg
```

And then check the logs with:
```
$ kubectl logs riseml-monitor-snbxg -n=riseml | head -n 3
INFO:__main__:Docker client version: {'ApiVersion': '1.24', 'Version': '1.12.6-cs13', 'GitCommit': '0ee24d4', 'KernelVersion': '4.4.0-64-generic', 'Os': 'linux', 'BuildTime': '2017-07-24T18:27:43.543428213+00:00', 'Arch': 'amd64', 'GoVersion': 'go1.6.4'}
INFO:__main__:GPUs: {'/dev/nvidia0': {'serial': '0324516189437', 'mem_total': 11995578368, 'bus_id': '0000:00:1E.0', 'name': 'Tesla K80', 'handle': <pynvml.LP_struct_c_nvmlDevice_t object at 0x7f30466369d8>, 'minor': 0}}
INFO:amqp:Connection attempt to amqp://rabbitmq-service
```
The first lines should report the found GPUs as in the example above and will report an error otherwise.
