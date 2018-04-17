# Upgrade

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

# Uninstall
You can uninstall RiseML using Helm:
```
$ helm delete --purge riseml
```
