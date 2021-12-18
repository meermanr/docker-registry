# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.hostname = "docker-registry"

  config.vagrant.plugins = ["vagrant-docker-compose"]

  config.vm.provision :docker
  config.vm.provision :docker_compose, 
    compose_version: "1.29.2",
    yml: "/vagrant/docker-compose.yml",
    run: "always"

  config.vm.provision "Avahi",
    type: "shell",
    inline: <<-SHELL
      set -e
      apt-get update
      apt-get install -y avahi-daemon
    SHELL
end
