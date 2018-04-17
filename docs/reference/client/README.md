# Python Client

RiseML provides a python library with which you can report results of experiments to the RiseML API. You can find the package in [Github](https://github.com/riseml/client-python).



## `report_result(**kwargs)`
You can provide `experiment_id` as part of `kwargs` explcitly. Otherwise, it will be inferred from the environment.

- Args: `**kwargs`: arbitrary arguments with result: value pairs.

- Returns: `None`


Example:
```
import riseml
riseml.report_result(accuracy=.3, loss=.1)
```
