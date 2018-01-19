## Experiment States

An experiment follows the following state model.
It starts in _CREATED_ and ends in _KILLED_, _FAILED_ or _FINISHED_ states. A typical experiment runs through five states:
_CREATED_, _BUILDING_, _STARTING_, _RUNNING_, _FINISHED_.
In case there is a cached build available for an experiment the _BUILDING_ state is skipped.

<img src="/img/lifecycle.png" alt="Life Cycle" style="max-width: 400px" />

| State    | Description                                       |
| -------- | ------------------------------------------------- |
| CREATED  | An experiment was created, nothing is running yet |
| BUILDING | A machine image for an experiment is being built  |
| PENDING  | The experiment is waiting for available resources |
| STARTING | The experiment is starting                        |
| RUNNING  | The experiment is running                         |
| KILLED   | The experiment was manually killed                |
| FAILED   | The experiment failed (```exit code != 0```)      |
| FINISHED | The experiment finished (```exit code == 0```)    |
