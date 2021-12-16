# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.hostname = "docker-registry"

  config.vagrant.plugins = ["vagrant-docker-compose"]

  config.vm.provision :docker
  config.vm.provision :docker_compose, 
    yml: "/vagrant/docker-compose.yml",
    run: "always"
end
