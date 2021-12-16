# Docker registry

Pull-through cache based on [rpardini/docker-registry-proxy: An HTTPS Proxy for Docker providing centralized configuration and caching of any registry (quay.io, DockerHub, k8s.gcr.io)](https://github.com/rpardini/docker-registry-proxy)

## Usage

Bring-up your registry:

```
vagrant up
vagrant ssh
cd registry
docker-compose up -d
```

Note the IP address / hostname. E.g. `docker-vagrant.local`.

Configure another host to use it as an HTTP/HTTPS proxy.

(!) Note that both HTTP and HTTPS traffic are proxies *without* TLS: both URLs below use plain HTTP!

(i) If you want to use `*.local` hostnames, you need to install `avahi-daemon` on your client machine.

```
# Add environment vars pointing Docker to use the proxy
mkdir -p /etc/systemd/system/docker.service.d
cat << EOD > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://docker-vagrant.local:3128/"
Environment="HTTPS_PROXY=http://docker-vagrant.local:3128/"
EOD

### UBUNTU
# Get the CA certificate from the proxy and make it a trusted root.
curl http://docker-vagrant.local:3128/ca.crt > /usr/share/ca-certificates/docker_registry_proxy.crt
echo "docker_registry_proxy.crt" >> /etc/ca-certificates.conf
update-ca-certificates --fresh
###

### CENTOS
# Get the CA certificate from the proxy and make it a trusted root.
curl http://docker-vagrant.local:3128/ca.crt > /etc/pki/ca-trust/source/anchors/docker_registry_proxy.crt
update-ca-trust
###

# Reload systemd
systemctl daemon-reload

# Restart dockerd
systemctl restart docker.service
```