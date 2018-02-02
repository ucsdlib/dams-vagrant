# DAMS Vagrant (+ Ansible )
UCSD DAMS Vagrant Virtual Machine that is provisioned via Ansible.

## Requirements
* [Vagrant](https://www.vagrantup.com/)
* [VirtualBox](https://www.virtualbox.org/)
* [Ansible](https://docs.ansible.com/ansible/latest/intro_installation.html)

## Provision
1. `git clone git@github.com:ucsdlib/dams-vagrant.git`
2. `cd dams-vagrant`
3. `make all`
4. `ansible-playbook main.yml`

At this point the virtual machine will be up and running! You do **not** need to
run `vagrant up`.

You can confirm this by browsing to damspas or one of the
tomcat apps using links documented in the [Environment](#environment) section.

## Usage
If you have previously provisioned the virtual machine, you may just start it with `vagrant up`.

You can [shell into the machine](https://www.vagrantup.com/docs/cli/ssh.html) with `vagrant ssh` or `ssh -p 2222 vagrant@localhost`

The Tomcat and Postgres services will start on boot, but you will need to start the Rails webserver for damspas yourself:

```
vagrant ssh
cd /vagrant/damspas
bundle exec unicorn -p 3000
```

## Additional Data
You can load test records into DAMS Repository, installed in the Vagrant VM, using cURL:

```
curl -u dams:dams -d @your_damspas_path/damspas/spec/fixtures/damsObject.xml http://localhost:8080/dams/api/objects/bd22194583
```

## Environment
* Ubuntu 16.04.3 64-bit machine with:
  * [Tomcat 7](http://tomcat.apache.org) at [http://localhost:8080](http://localhost:8080)
    * Manager username = "tomcat", password = "tomcat"
  * [DAMS Repository](https://github.com/ucsdlib/damsrepo) at [http://localhost:8080/dams](http://localhost:8080/dams)
    * Repository code will be available in the /dams-vagrant root on the host machine. You can edit source using your editor of choice.
    * Installed in Tomcat container
    * Data and configuration files in "/pub/dams"
  * [Digital Collections](https://github.com/ucsdlib/damspas) at [http://localhost:3000](http://localhost:3000)
    * Repository code will be available in the /dams-vagrant root on the host machine. You can edit source using your editor of choice.
    * On the guest/vm the code directory is available in `/vagrant/damspas`
  * [Solr 4.0.0](http://lucene.apache.org/solr/) at [http://localhost:8080/solr](http://localhost:8080/solr), for indexing & searching your content.
    * Installed in Tomcat container
    * Data and configuration files in "/var/lib/tomcat7/solr"

## Thanks

This VM setup was (**originally**) heavily influenced (read: copied) from [Fedora 4 VM](https://github.com/fcrepo4-labs/fcrepo4-vagrant).
While it has since been modified/ported to Ansible and made significantly more
idempotent, we thank for the Fedora 4 crew for the original work!
