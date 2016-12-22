# TODO

- `Dockerfile.bk`'s approach of allowing `ID` to be used to launch multiple instances of BookKeeper on the same machine is probably plain wrong.

  - compare to one of the ZooKeeper images that has a similar arrangement

- `Dockerfile.wp` hasn't been tried

- `docker-compose.yml` so that `docker-compose up` works, for getting all nicely started (local development).

Contributions are welcome.

- For `Dockerfile.bk`:
  - compare with https://hub.docker.com/r/michalrmiller/docker-bookkeeper/ for Kubernetes compatibility:

> The only change from a default Bookkeeper configuration is prefering to
use the containers hostname over it's IP address. This is because Kubernetes
PetSet abstraction guarantees a stable hostname between crashes.

	In fact, could we simply use `michalrmiller/docker-bookkeeper`?
