# TODO

## Dockerfile.bk

- `Dockerfile.bk`'s approach of allowing `ID` to be used to launch multiple instances of BookKeeper on the same machine is probably plain wrong.

Will make three different Dockerfiles now, to get going further. But ideally, shouldn't BookKeeper allow settings to be provided via env.vars like Write Proxy now (since 0.4.0) does. That feels more natural for Dockerization.

- compare with https://hub.docker.com/r/michalrmiller/docker-bookkeeper/ for Kubernetes compatibility:

> The only change from a default Bookkeeper configuration is prefering to
use the containers hostname over it's IP address. This is because Kubernetes
PetSet abstraction guarantees a stable hostname between crashes.

## Dockerfile.wp

- `Dockerfile.wp` hasn't been tried

## Docker-compose

- `docker-compose.yml` so that `docker-compose up` works, for getting all nicely started (local development).

Contributions are welcome.
