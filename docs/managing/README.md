## Maintenance

This section describes [user management](/managing/README.md#user-management) as well as [upgrading](/managing/README.md#upgrade) and [uninstalling](/managing/README.md#uninstall) RiseML.


### User Management
RiseML's user management system is built around user names and API keys.
Additionally, you can specify an email for each user.
Upon installation, an initial user named `admin` was created for you, with which you can easily create more users:
```
$ riseml user create --username bob --email bob@example.org
```
This will output a generated API key for the new user.

<!--**TODO: Show how to switch between users.**-->

To see the user's details again at a later point in time, use the `display` subcommand:
```
$ riseml user display Bob
```

You can also get a list of all users with:
```
$ riseml user list
```

Finally, to disable a user:
```
$ riseml user disable bob
```

<!--
### Backup
In case you want to backup RiseML's data, you can use Kubernetes' and/or your
cloud provider's facilities to make snapshots of RiseML's persistent volumes.
This will include the internal database, the internal Git storage, and the logs gathered from the jobs.
If you're using RiseML's provided NFS server for input data or output storage, this will be included as well.
If not, it is up to you to backup your external NFS.

#### Restore

-->

### Upgrade

<!--
Your RiseML cluster will keep itself up-to-date automatically by periodically scanning RiseML's main servers for new versions.
To manually start this check and eventually upgrade, you can use the CLI:
```
riseml system upgrade
```
-->


If you want to upgrade your cluster, you can use Helm and a new version of RiseML's Helm chart:
```
$ helm repo update
$ helm upgrade riseml riseml-charts/riseml -f riseml-config.yml
```
However, please note that you need to respecify all configuration options from the install step.
Before upgrading, please also **check the [release notes](https://github.com/riseml/riseml/blob/master/RELEASES.md)** of the current version for upgrade or installation information.

In case your CLI becomes out-of-date, it will give you a warning when you issue a command.
If your cluster does not support the CLI's version at all, the CLI will exit with an error message.
To upgrade your client to professional, follow the installation steps again. To upgrade to enterprise, please email us at [contact@riseml.com](mailto:contact@riseml.com).

### Uninstall
You can uninstall RiseML using Helm:
```
$ helm delete --purge riseml
```
