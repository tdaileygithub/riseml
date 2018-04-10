# Command-Line Interface

## Introduction

The RiseML command line interface (CLI) is a tool for running machine learning experiments and administering RiseML clusters.
See the [installation instructions](/install/cli.md#installation-setup) in case there is no CLI installed on your system.
Use the following syntax to execute the CLI in your terminal window:
```
riseml [command] [parameters]
```
Command specifies the command to execute, e.g., ```train```, ```status``` or ```kill```.
Some commands infer the current project by looking for the ```riseml.yml``` configuration file in the current path.
Parameters are optional. Passing ```-h``` as a parameter lists the available parameters for a command.
Passing `--version` without any command prints the CLI's version number.

## Configuration
RiseML's CLI stores its configuration in the file `$HOME/.riseml/config`.
To initialize the configuration, you need to run the `riseml user login` command.
It will ask you for the endpoint to the API server as well as the SYNC endpoint and test the connection.
Except for the current user's API key, you can get all of their values from your cluster administrator, who retrieved them during installation.

To switch your user, you can run `riseml user login` again or replace the api-key in the config file.

## Commands

* [train](/reference/cli.md#train)
* [status](/reference/cli.md#status)
* [kill](/reference/cli.md#kill)
* [logs](/reference/cli.md#logs)
* [monitor](/reference/cli.md#monitor)
* [ls](/reference/cli.md#ls)
* [cp](/reference/cli.md#cp)
* [rm](/reference/cli.md#rm)
* [system](/reference/cli.md#system)
* [user](/reference/cli.md#user)
* [account](/reference/cli.md#account)

### train

Start an experiment according to the definition given in a config file (```riseml.yml```).
All files in the project directory (except ones residing in `.git` folders or specified
in `.gitignore` and `.risemlignore`) will be pushed to RiseML. Log outputs of the experiments will be streamed immediately.
It is safe to exit the command via ```ctrl+c```.
The experiments will continue running and log streaming can be continued via the ```logs``` command.

```
riseml train [-f CONFIG_FILE]
```

Arguments:

| Name             | Description            | Default    |
| ---------------- | ---------------------- | ---------- |
| -f CONFIG_FILE   | Configuration filename | riseml.yml |


### status

Shows status of experiments.
The default is to show currently running experiments.
If an ID is provided, a detailed status report is shown.

```
riseml status [-a] [-l] [id]
```

Arguments:

| Name | Description                                           | Default         |
| ---- | ----------------------------------------------------- | --------------- |
| id   | ID for which to report detailed status                | .[current user] |
| -a   | Show all experiments, including stopped, failed, etc. |                 |
| -l   | Enable long output with more details                  |                 |


### kill

Kill one or more experiments.
The default is to kill the last started experiment in the current project.

```
riseml kill [id [id ...]] [-f]
```

Arguments:

| Name        | Description | Default                                    |
| ----------- | ----------- | ------------------------------------------ |
| id [id ...] | IDs to kill | last started experiment in current project |
| -f          | force kill the job |                                     |


### logs

Print log output of the experiment.
The default is to show logs for the last started experiment in the current project.


```
riseml logs [id]
```

Arguments:

| Name | Description         | Default                                    |
| ---- | ------------------- | ------------------------------------------ |
| id   | ID to show logs for | last started experiment in current project |


### monitor

Monitor an experiment's resources.
The default is to monitor the last started experiment in the current project.


```
riseml monitor [id]
```

Arguments:

| Name | Description   | Default                                    |
| ---- | ------------- | ------------------------------------------ |
| id   | ID to monitor | last started experiment in current project |


### ls

Lists a directory or a file on the data or output storage.


```
riseml ls uri
```

Arguments:

| Name | Description   |
| ---- | ------------- |
| uri  | Uri to list. Begin with  'data://' or 'output://' to discern between data and output storage. |


### cp

Copies files or directories from or to your data or output storage.

```
riseml cp source-uri [source-uri ...] dest-uri
```

Arguments:

| Name       | Description   |
| ---------- | ------------- |
| source-uri | Uri to copy from. This is remote, if it begins with `data://` or `output://`, otherwise it specifies a local path. |


### rm

Remove one or multiple files/directories from the data our output storage recursively.

```
riseml rm uri [uri ...]
```

Arguments:

| Name | Description   |
| ---- | ------------- |
| uri  | Uri to remove, begin with `data://` or `output://` to discern between data and output storage |

### system

Access system level features, intended for cluster administrators.

```
riseml system {test,info}
```

Subcommands:

| Name | Description                      |
| ---- | -------------------------------- |
| info | Show available cluster resources |
| test | Run system self check            |


### system info

Show resources available on each cluster node and installed versions of RiseML and K8S.

```
riseml system info [-l]
```

Arguments:

| Name | Description                    |
| ---- | ------------------------------ |
| -l   | Show more detailed information |

### system test

Run system self check or stress tests.

```
riseml system test [--nodename NODENAME] [--num-jobs NUM_JOBS] [--num-cpus NUM_CPUS] [--mem MEM] [--force-build-steps]
```

Arguments:

| Name                  | Description                                        |
| --------------------- | -------------------------------------------------- |
| --nodename NODENAME   | Node's hostname to schedule jobs on                |
| --num-jobs NUM\_JOBS  | Number of jobs to run                              |
| --num-cpus NUM\_CPUS  | CPUs per job to stress                             |
| --mem MEM             | Memory per job to stress                           |
| --force-build-steps   | Cause each job to perform considerable build steps |


### user

Manage users within the RiseML cluster.

```
riseml user {create,update,disable,list,display,login}
```

Subcommands:

| Name    | Description                   |
| ------- | ----------------------------- |
| list    | List existing users           |
| display | Show info about a single user |
| create  | Create a new user             |
| update  | Update (and enable) a user    |
| disable | Disable a user                |
| login   | Login as new a user           |


### user list

List existing users.

```
riseml user list
```


### user display

Show info about a single user.

```
riseml user display username
```

Arguments:

| Name     | Description  |
| -------- | ------------ |
| username | User to show |


### user create

Create a new user.

```
riseml user create --username USERNAME --email EMAIL
```

Arguments:

| Name                | Description           |
| ------------------- | --------------------- |
| --username USERNAME | Name of the new user  |
| --email EMAIL       | Email of the new user |


### user update

Update a user's email.
Also enables a disabled user.

```
riseml user update --username USERNAME --email EMAIL
```

Arguments:

| Name                | Description           |
| ------------------- | --------------------- |
| --username USERNAME | Name of the new user  |
| --email EMAIL       | Email of the new user |


### user disable

Disable users to prevent them from accessing the cluster.

```
riseml user disable USERNAME
```

Arguments:

| Name     | Description     |
| -------- | --------------- |
| username | User to disable |


### user login

Login as a new user and create a new config file `$HOME/.riseml/config`.
You will be asked the location of the API server as well as your API key and a connection check will be performed.

```
riseml user login
```



### account

Manage the account associated with your cluster.

```
riseml account {info, register, upgrade, sync}
```

Subcommands:

| Name     | Description                                     |
| -------- | ----------------------------------------------- |
| info     | Display info about your account                 |
| register | Register/associate an account with your cluster |
| upgrade  | Upgrade your account                            |
| sync     | Synchronize account information                 |


### account info

Display account information.

```
riseml account info
```

### account register

Register an account with your cluster.
You can register a new account (a web browser will be opened or a link will be shown) or you can associate an account key with your cluster.

```
riseml account register
```

### account upgrade

Upgrade your account to another plan.
Opens a web browser or displays a link (if no web browser available).

```
riseml account upgrade
```

### account sync

Synchronize information about your account from RiseML to your cluster.
Needed if you upgrade your account to another plan and want to enable features on your cluster.

```
riseml account sync
```