# User Management
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