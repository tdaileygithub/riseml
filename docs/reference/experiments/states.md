## Experiment States

An experiment follows the following state model.
It starts in _Created_ and ends in _Killed_, _Failed_ or _Finished_ states. A typical experiment runs through five states:
_Created_, _Building_, _Starting_, _Running_, _Finished_.
In case there is a cached build available for an experiment the _Building_ state is skipped.

<img src="/img/lifecycle.png" alt="Life Cycle" />

| State    | Description                                       |
| -------- | ------------------------------------------------- |
| Created  | An experiment was created, nothing is running yet |
| Building | A machine image for an experiment is being built  |
| Pending  | The experiment is waiting for available resources |
| Starting | The experiment is starting                        |
| Running  | The experiment is running                         |
| Killed   | The experiment was manually killed                |
| Failed   | The experiment failed (exit code ≠ 0)      |
| Finished | The experiment finished (exit code = 0)    |
