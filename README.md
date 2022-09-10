# ser2net as a Docker container

> ser2net is a program for allowing connections between gensio accepters and gensio connectors. Generally, this would be a network connections to serial ports or IPMI Serial Over Lan (SOL) connections, but there are lots of gensios and lots of options. See gensio(5) for information on gensios.

## Images

All images are published to the following registries

* 🥇 [GitHub](https://github.com/jippi/docker-ser2net/pkgs/container/docker-ser2net) as `ghcr.io/jippi/docker-ser2net` ⬅️ **Recommended**
* 🥈 [AWS](https://gallery.ecr.aws/i2s8u4z7/ser2net) as `public.ecr.aws/i2s8u4z7/ser2net` ⬅️ Great alternative
* ⚠️ [Docker Hub](https://hub.docker.com/r/jippi/ser2net/) as `jippi/docker-ser2net` ⬅️ Only use `:latest` as [tags might disappear](https://www.docker.com/blog/scaling-dockers-business-to-serve-millions-more-developers-storage/)

Image tags with software specifications and version information can be found in the table below

| **Tag**                   | **Version**                                                                 | **OS (Debian)**        | **Size**        |
|-------------------------- |---------------------------------------------------------------------------- |----------------------- |---------------- |
| `latest`                  | [latest †](https://github.com/cminyard/ser2net/releases/latest)             | bullseye (11.4)        | ~80 MB         |
| `$version`                | `$version`                                                                  | bullseye (11.4)        | ~80 MB         |

_† Automation checks for new ser2net releases nightly (CEST, ~3am), so there might be a day or two latency for most recent release_

### docker run

```sh
touch $(pwd)/ser2net.yaml

docker run \
    --name ser2net \
    --network=host \
    --restart=unless-stopped \
    --detach \
    --volume $(pwd)/ser2net.yaml:/etc/ser2net/ser2net.yaml \
    --device  /dev/ttyUSB0 \
    ghcr.io/jippi/docker-ser2net
```

### docker-compose

```sh
touch $(pwd)/ser2net.yaml
```

and add your ser2net configuration into the `ser2net.yaml` file.

```yaml
version: '3.4'
services:
  ser2net:
    container_name: ser2net
    image: ghcr.io/jippi/docker-ser2net
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./ser2net.yaml:/etc/ser2net/ser2net.yaml
    devices:
      - /dev/ttyUSB0
```

## Further help and docs

For any help specific to ser2net please head over to https://github.com/cminyard/ser2net
