WHOAMI := $(lastword $(MAKEFILE_LIST))
SSHCONFIG=.ssh-config
INVENTORY=hosts
SAMPLEVAGRANTFILE=https://raw.githubusercontent.com/jhriv/vagrant-as-infrastructure/master/Vagrantfile.sample
VERSION=0.2.6
.PHONY: menu all clean up roles force-roles Vagrantfile-force ping ip update version

menu:
	@echo 'up: Create VMs'
	@echo 'roles: Populate Galaxy roles from "roles.yml" or "config/roles.yml"'
	@echo 'force-roles: Update all roles, overwrting when required'
	@echo 'ansible.cfg: Create default ansible.cfg'
	@echo '$(SSHCONFIG): Create ssh configuration (use "make <file> SSHCONFIG=<file>" to override name)'
	@echo '$(INVENTORY): Create ansible inventory (use "make <file> INVENTORY=<file>" to overrride name)'
	@echo 'ip: Display the IPs of all the VMs'
	@echo 'all: Create all of the above'
	@echo
	@echo '"make all SSHCONF=sshconf INVENTORY=ansible-inv"'
	@echo ''
	@echo 'python: Installs python on Debian systems'
	@echo 'root-key: Copies vagrant ssh key for root'
	@echo 'clean: Removes ansible files'
	@echo 'Vagrantfile-force: Overwrites Vagrantfile with sample Vagrantfile'
	@echo 'version: Prints current version'
	@echo 'udpate: Downloads latest version from github'
	@echo '        WARNING: this *will* overwrite $(WHOAMI).'

all: up roles ansible.cfg $(SSHCONFIG) $(INVENTORY) ip

clean:
	@echo Removing ansible files
	@rm -f ansible.cfg $(SSHCONFIG) $(INVENTORY)

up:
	@vagrant up

roles: $(wildcard roles.yml config/roles.yml)
	@echo 'Downloading roles'
	@ansible-galaxy install --role-file=$< --roles-path=roles

force-roles: $(wildcard roles.yml config/roles.yml)
	@echo 'Downloading roles (forced)'
	@ansible-galaxy install --role-file=$< --roles-path=roles --force

ansible.cfg: $(SSHCONFIG) $(INVENTORY)
	@echo "Creating $@"
	@echo '[defaults]' > $@
	@echo 'inventory = $(INVENTORY)' >> $@
	@echo '' >> $@
	@echo '[ssh_connection]' >> $@
	@echo 'ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s -F $(SSHCONFIG)' >> $@

$(SSHCONFIG): $(wildcard .vagrant/machines/*/*/id) Vagrantfile
	@echo "Creating $@"
	@vagrant ssh-config > $@ \
		|| ( RET=$$?; rm $@; exit $$RET; )

# Because of the pipe, extrodinary means have to be used to save the return
# code of "vagrant status"
$(INVENTORY): $(wildcard .vagrant/machines/*/*/id) Vagrantfile
	@echo "Creating $@"
	@( ( ( vagrant status; echo $$? >&3 ) \
		|  perl -nE 'if (/^$$/.../^$$/){say qq($$1) if /^(\S+)/;}' > $@ ) 3>&1 ) \
		|  ( read x; exit $$x ) \
		|| ( RET=$$?; rm $@; exit $$RET )

Vagrantfile:
	@echo 'Either use "vagrant init <box>" to create a Vagrantfile,'
	@echo '"cp Vagrantfile.sample Vagrantfile" if you cloned the repo, or download'
	@echo '$(SAMPLEVAGRANTFILE)'
	@false

Vagrantfile-force:
	@echo Downloading $(SAMPLEVAGRANTFILE)
	@curl --output Vagrantfile $(SAMPLEVAGRANTFILE)

ping: ansible.cfg
	@ansible -m ping all

ip: ansible.cfg
	@ansible -a 'hostname -I' all || { ret=$$?; echo Do you need to install python? \(make python\); exit $$ret; }

python: ansible.cfg
	@ansible all -m raw -a 'sudo apt-get install --assume-yes python python-apt'

root-key: ansible.cfg
	@ansible all -b -m file -a 'dest=/root/.ssh state=directory mode=0700 owner=root group=root'
	@ansible all -b -m copy -a 'src=.ssh/authorized_keys dest=/root/.ssh/authorized_keys remote_src=true'

update:
	@wget --quiet https://github.com/jhriv/vagrant-as-infrastructure/raw/master/Makefile --output-document=$(WHOAMI)

version:
	@echo '$(VERSION)'
