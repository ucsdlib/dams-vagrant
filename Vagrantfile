# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.hostname = "dams"
  config.vm.box = "ubuntu/trusty64"

  # Below needed for Vagrant versions < 1.6.x
  # config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network :forwarded_port, guest: 8080, host: 8080 # Tomcat
  config.vm.network :forwarded_port, guest: 3000, host: 3000 # DAMSPAS

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
  end

  # using vagrant-triggers plugin, remove downloads and damspas directories on destroy
  config.trigger.after :destroy do
    run "rm -rf damspas"
    run "rm -rf downloads"
  end

  shared_dir = "/vagrant"

  config.vm.provision "shell", path: "./install_scripts/bootstrap.sh", args: shared_dir
  config.vm.provision "shell", path: "./install_scripts/java.sh", args: shared_dir
  config.vm.provision "shell", path: "./install_scripts/tomcat7.sh", args: shared_dir
  config.vm.provision "shell", path: "./install_scripts/solr.sh", args: shared_dir
  config.vm.provision "shell", path: "./install_scripts/damsrepo.sh", args: shared_dir
  config.vm.provision "shell", path: "./install_scripts/wowza.sh", args: shared_dir
  config.vm.provision "shell", path: "./install_scripts/rbenv.sh", privileged: false
  config.vm.provision "shell", path: "./install_scripts/ruby.sh", privileged: false
  config.vm.provision "shell", path: "./install_scripts/damspas.sh", args: shared_dir, privileged: false
end
