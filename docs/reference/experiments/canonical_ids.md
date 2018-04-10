# Canonical Experiment Identifiers

The canonical ID is a hierarchical identifier scheme to access projects, experiment sets, experiments, job types, and jobs.
It can be supplied to some ```riseml``` CLI commands, such as ```status```, ```logs```, and ```kill```.
It consists of segments of numbers and strings separated by dots, e.g., ```paul.1``` to access the 1<sup>st</sup> experiment from the user paul.
Here is a more complex example: the 3<sup>rd</sup> worker in the 1<sup>st</sup> sub-experiment of the 18<sup>th</sup> experiment of user paul.

```
paul.18.1.worker.3
|    |  | |      \_ job number
|    |  | \_ job type
|    |  \_ experiment
|    \_ experiment set
\_ username
```

## Segments

| Segment        | Type         | Description                                                        |
| -------------- | -------------|------------------------------------------------------------------- |
| username       | ```string``` | default: current user                                              |
| experiment set | ```number``` | experiment ID (hyperparameter optimization only)                   |
| experiment     | ```number``` | incrementing for every experiment                                  |
| job type       | ```string``` |                                                                    |
| job number     | ```number``` | incrementing for every job within its type (only if more than one) |

The user segments is optional.
If not set, the value is automatically set to the current user.
Canonical IDs of hyperparameter optimization experiments contain experiment IDs to identify the set of all sub-experiments.
Similarly, the canonical ID of a distributed training experiment contains an additional number to identify each job type, e.g., each worker or parameter server.

## Examples

| Canonical ID          | Description                                                                      |
| --------------------- | -------------------------------------------------------------------------------- |
| ```1```               | experiment of current user                                                       |
| ```paul```            | all experiments by paul                                                          |
| ```14.3```            | 3<sup>rd</sup> sub-experiment in 14<sup>th</sup> experiment (hyperparameter optimization) |
| ```1.build```         | 1<sup>st</sup> experiment's build job                                            |
| ```18.ps```           | 18<sup>th</sup> experiment's parameter server job (distributed training)         |
| ```18.worker.3```     | 18<sup>th</sup> experiment's 3<sup>rd</sup> worker job (distributed training)    |
