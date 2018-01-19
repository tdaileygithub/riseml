# <a id="install-cli"></a>Install the Command-Line Interface

The RiseML CLI is available for Linux and macos (x86-64):

```
$ bash -c "$(curl -fsSL https://get.riseml.com/install-cli)"
```

Paste that in a terminal prompt.
The script installs the RiseML CLI in `~/.riseml/bin`.

Now, add the directory to your path:

```
$ export PATH=~/.riseml/bin:$PATH
```

To connect to a freshly installed RiseML cluster:
```
$ riseml user login --host CLUSTER-IP
```
Note: if your cluster is installed using the `nodeports: false` option (e.g. with our installer on AWS), two different IP endpoints are used for communication and you need to use the `--api-host` and `--sync-host` flags instead.

To log in with a previously created user, add an `api-key` option:

```
$ riseml user login --host CLUSTER-IP --api-key API-KEY
```

Replace `CLUSTER-IP` and `API-KEY` with your cluster's IP address or DNS name and your user's API key.

Now you can check your user information:

```
$ riseml whoami
```

To create more users and to switch between them, please refer to the [User Management](/managing/) section.
