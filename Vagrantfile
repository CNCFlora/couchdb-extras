# -*- mode: ruby -*-
# vi: set ft=ruby

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "private_network", ip: "192.168.50.151"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  if Vagrant.has_plugin?("vagrant-cachier")
      config.cache.scope = :box
  end

  config.vm.provision "docker" do |d|
    d.run "couchdb0", image: "cncflora/couchdb",  args: "-p 5984:5984"
    d.run "couchdb1", image: "cncflora/couchdb",  args: "-p 5985:5984"
    d.run "couchdb2", image: "cncflora/couchdb",  args: "-p 5986:5984"
    d.run "es0", image: "cncflora/elasticsearch",  args: "-p 9200:9200 -p 9300:9300"
    d.run "es1", image: "cncflora/elasticsearch",  args: "-p 9201:9200 -p 9301:9300"
  end

  config.vm.provision :shell, :path => "vagrant.sh"
end

