  Configuration Management Setup Template
------------------------------------------

- `git clone --recursive https://git.nordisch.org/darix/cfgmgmt-template.git cfgmgmt`
- `ln -s /srv/cfgmgmt/config/salt_master.conf /etc/salt/master.d`

If you only want to listen on some internal interface

- `echo "interface: 127.0.0.1" > /etc/salt/master.d/bind_local_only.conf`

We want secure permissions for this setup. If you want to edit as a non-root user you call it like:

- `/srv/cfgmgmt/tools/fix-permissions username`

If you omit the username parameter it defaults to root.
