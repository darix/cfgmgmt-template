  Configuration Management Setup Template
------------------------------------------

- `git clone --recursive https://git.nordisch.org/darix/cfgmgmt-template.git cfgmgmt`
- `ln -s /srv/cfgmgmt/config/salt_master.conf /etc/salt/master.d`

if you only want to listen on some internal interface

- `echo "interface: 127.0.0.1" > /etc/salt/master.d/bind_local_only.conf`
