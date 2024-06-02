# OpenSSH-Server

[OpenSSH-Server](https://www.openssh.com/) is a sandboxed environment that allows SSH access without giving keys to the entire server. Granting SSH access via a private key often means providing full server access. This container creates a limited and sandboxed environment that others can SSH into. Users only have access to the folders mapped and the processes running inside this container.

[![OpenSSH-Server](https://github.com/DockForge/.github/raw/main/assets/logos/ssh-logo.png)](https://www.openssh.com/)


## Supported Architectures

We utilize the Docker manifest for multi-platform awareness. More information is available from Docker [here](https://distribution.github.io/distribution/spec/manifest-v2-2/#manifest-list).

Simply pulling `dublok/openssh-server:latest` should retrieve the correct image for your architecture, but you can also pull specific architecture images via tags.



## Application Setup

If the `PUBLIC_KEY`, `PUBLIC_KEY_FILE`, or `PUBLIC_KEY_DIR` variables are set, the specified keys will automatically be added to `authorized_keys`. Otherwise, you can manually add keys to `/config/.ssh/authorized_keys` and restart the container. Note that removing these environment variables will not remove the keys from `authorized_keys`. `PUBLIC_KEY_FILE` and `PUBLIC_KEY_DIR` can also be used with Docker secrets.

We provide the option to enable password-based access via the `PASSWORD_ACCESS` and `USER_PASSWORD` variables. However, we discourage using password authentication for public-facing SSH endpoints.

To connect to the server, use:

```sh
ssh -i /path/to/private/key -p PORT USER_NAME@SERVERIP
```

Setting `SUDO_ACCESS` to `true` allows passwordless sudo. The `USER_PASSWORD` and `USER_PASSWORD_FILE` variables allow setting an optional sudo password.

Users will only have access to the folders mapped and the processes running inside this container. Add any volume mappings as needed for user access. 

A sample use case is when a server admin wants automated incoming backups from a remote server but does not want all remote admins to have full access to the local server. This container can be set up with a mounted folder for incoming backups and `rsync` installed for limited access.

It is also possible to run multiple instances of this container with different ports, folders, and private keys for compartmentalized access.


#### Tips

You can volume map your own text file to `/etc/motd` to override the message displayed upon connection. Additionally, you can set the Docker argument `hostname`.

## Key Generation

This container includes a helper script to generate an SSH private/public key. To generate a key, run:

```sh
docker run --rm -it --entrypoint /keygen.sh dublok/openssh-server
```

Follow the prompts to generate the keys. The generated keys are displayed on your console output, so make sure to save them after generation.




## Usage

To help you get started creating a container from this image, you can use either Docker Compose or the Docker CLI.

### Docker Compose (recommended, [click here for more info](https://docs.docker.com/compose/gettingstarted/))

```yaml
---
services:
  openssh-server:
    image: dublok/openssh-server:latest
    container_name: openssh-server
    hostname: openssh-server #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - PUBLIC_KEY=yourpublickey #optional
      - PUBLIC_KEY_FILE=/path/to/file #optional
      - PUBLIC_KEY_DIR=/path/to/directory/containing/_only_/pubkeys #optional
      - PUBLIC_KEY_URL=https://github.com/username.keys #optional
      - SUDO_ACCESS=false #optional
      - PASSWORD_ACCESS=false #optional
      - USER_PASSWORD=password #optional
      - USER_PASSWORD_FILE=/path/to/file #optional
      - USER_NAME=dockforge #optional
      - LOG_STDOUT= #optional
    volumes:
      - /path/to/openssh-server/config:/config
    ports:
      - 2222:2222
    restart: unless-stopped
```

### Docker CLI ([click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

```bash
docker run -d \
  --name=openssh-server \
  --hostname=openssh-server `#optional` \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e PUBLIC_KEY=yourpublickey `#optional` \
  -e PUBLIC_KEY_FILE=/path/to/file `#optional` \
  -e PUBLIC_KEY_DIR=/path/to/directory/containing/_only_/pubkeys `#optional` \
  -e PUBLIC_KEY_URL=https://github.com/username.keys `#optional` \
  -e SUDO_ACCESS=false `#optional` \
  -e PASSWORD_ACCESS=false `#optional` \
  -e USER_PASSWORD=password `#optional` \
  -e USER_PASSWORD_FILE=/path/to/file `#optional` \
  -e USER_NAME=dockforge `#optional` \
  -e LOG_STDOUT= `#optional` \
  -p 2222:2222 \
  -v /path/to/openssh-server/config:/config \
  --restart unless-stopped \
  dublok/openssh-server:latest
```

## Parameters

Containers are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `--hostname=` | Optionally the hostname can be defined. |
| `-p 2222` | SSH port |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Etc/UTC` | Specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `-e PUBLIC_KEY=yourpublickey` | Optional SSH public key, which will automatically be added to `authorized_keys`. |
| `-e PUBLIC_KEY_FILE=/path/to/file` | Optionally specify a file containing the public key (works with Docker secrets). |
| `-e PUBLIC_KEY_DIR=/path/to/directory/containing/_only_/pubkeys` | Optionally specify a directory containing the public keys (works with Docker secrets). |
| `-e PUBLIC_KEY_URL=https://github.com/username.keys` | Optionally specify a URL containing the public key. |
| `-e SUDO_ACCESS=false` | Set to `true` to allow `dockforge`, the SSH user, sudo access. Without `USER_PASSWORD` set, this will allow passwordless sudo access. |
| `-e PASSWORD_ACCESS=false` | Set to `true` to allow user/password SSH access. You will want to set `USER_PASSWORD` or `USER_PASSWORD_FILE` as well. |
| `-e USER_PASSWORD=password` | Optionally set a sudo password for `dockforge`, the SSH user. If this or `USER_PASSWORD_FILE` are not set but `SUDO_ACCESS` is set to true, the user will have passwordless sudo access. |
| `-e USER_PASSWORD_FILE=/path/to/file` | Optionally specify a file that contains the password. This setting supersedes the `USER_PASSWORD` option (works with Docker secrets). |
| `-e USER_NAME=dockforge` | Optionally specify a user name (Default: `dockforge`) |
| `-e LOG_STDOUT=` | Set to `true` to log to stdout instead of file. |
| `-v /config` | Contains all relevant configuration files. |



## Environment Variables from Files (Docker Secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

For example:

```bash
-e FILE__MYVAR=/run/secrets/mysecretvariable
```

This will set the environment variable `MYVAR` based on the contents of the `/run/secrets/mysecretvariable` file.


## Umask for Running Applications

For all of our images, we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting. Keep in mind, umask subtracts from permissions based on its value, it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## User / Group Identifiers

When using volumes (`-v` flags), permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify, and any permissions issues will vanish like magic.

In this instance, `PUID=1000` and `PGID=1000`. To find yours, use `id your_user` as below:

```bash
id your_user
```

Example output:

```text
uid=1000(your_user) gid=1000(your_user) groups=1000(your_user)
```



## Support Info

* Shell access while the container is running:

    ```bash
    docker exec -it openssh-server /bin/bash
    ```

* To monitor the logs of the container in real-time:

    ```bash
    docker logs -f openssh-server
    ```

* Container version number:

    ```bash
    docker inspect -f '{{ index .Config.Labels "build_version" }}' openssh-server
    ```

* Image version number:

    ```bash
    docker inspect -f '{{ index .Config.Labels "build_version" }}' dublok/openssh-server:latest
    ```

