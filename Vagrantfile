# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  #config.omnibus.chef_version = :latest


  config.vm.define "chefclient" do |opsc64|
    opsc64.vm.box = "opscode-centos-6.4"
    opsc64.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4_provisionerless.box"
    opsc64.vm.hostname = "chefclient01"
    #opsc64.vm.network :public_network



    opsc64.vm.provision :chef_client do |chefclient|
        chefclient.chef_server_url = "https://api.opscode.com/organizations/dgapitts_demo"
        chefclient.validation_key_path = "./dgapitts_demo-validator.pem"
        chefclient.validation_client_name = "dgapitts_demo-validator"
        chefclient.node_name = "chefclient01"
        #chefclient.memory = 1024
        #chefclient.customize ["modifyvm", :id, "--memory", "2048"]
        #chefclient.cpus =1
        
    end
  end

end
