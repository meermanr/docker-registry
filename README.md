# Docker registry and caching proxy

Pull-through cache based on [rpardini/docker-registry-proxy: An HTTPS Proxy for Docker providing centralized configuration and caching of any registry (quay.io, DockerHub, k8s.gcr.io)](https://github.com/rpardini/docker-registry-proxy)

## Setup

Configure your secrets for any source registries by creating `.env` (whcih is ignored by git) and populating it with two environment variables, for example:

```bash
REGISTRIES=k8s.gcr.io quat.io mirror.gcr.io mirrors--dockerhub.company.com
AUTH_REGISTRIES=auth.docker.io:meermanr:dckr_pat_myPASSWORD registry-1.docker.io:meermanr:dckr_pat_myPASSWORD mirrors--dockerhub.company.com:robert.meerman@company.com:REDACTEDREDACTED
```

Bring-up your registry:

```bash
vagrant up
```

Note the IP address / hostname, either emprically:

```bash
vagrant ssh
hostname -f   # Fully Qualified Domain Name (FQDN)
hostname -I   # IP addresses
```

or by observing the hostname in `Vagrantfile` is set to `docker-registry`. Other hosts in the same subnet will see it as `docker-registry.local` so long as they are running a multicast Domain Name Service (mDNS) such as [Avahi](https://www.avahi.org)).

## Usage
### Configure client to use caching proxy

Configure another host's docker daemon to use it as an HTTP/HTTPS proxy. Below is a quick-start script you can paste into a bash shell of GNU/Linux hosts:

(!) Note that both HTTP and HTTPS traffic are proxied *without* TLS: both URLs below use plain HTTP!

```bash
set -e
sudo -i
mkdir -p /etc/systemd/system/docker.service.d
cat << EOD > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://docker-registry.local:3128/"
Environment="HTTPS_PROXY=http://docker-registry.local:3128/"
EOD
curl http://docker-registry.local:3128/ca.crt > /usr/share/ca-certificates/docker_registry_proxy.crt
echo "docker_registry_proxy.crt" >> /etc/ca-certificates.conf
update-ca-certificates --fresh
systemctl daemon-reload
systemctl restart docker.service
apt-get update
apt-get install -y avahi-daemon
set +e
```

## Push to registry

```bash
docker pull ubuntu                                          # Download docker.io/library/ubuntu
docker tag ubuntu docker-registry.local/foo/bar:v1.2.3.4    # New name, local to the current host
docker push docker-registry.local/foo/bar:v1.2.3.4          # Upload to our own registry
```

## Deleting image from registry

Delete a specific tag, `FOO/BAR:v1.2.3.4`:

```bash
vagrant ssh
docker-compose stop registry
rm -r /vagrant/registry/docker/registry/v2/repositories/foo/bar/_manifests/tags/v1.2.3.4
docker-compose run --rm --no-deps registry \
    registry garbage-collect \
        --delete-untagged=true \
        /etc/docker/registry/config.yml
docker-compose start registry
```

Delete image `FOO/BAR` (all versions):

```bash
vagrant ssh
docker-compose stop registry
rm -r /vagrant/registry/docker/registry/v2/repositories/foo/bar/
docker-compose run --rm --no-deps registry \
    registry garbage-collect \
        --delete-untagged=true \
        /etc/docker/registry/config.yml
docker-compose start registry
```

