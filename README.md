  Configuration Management Setup Template
------------------------------------------

```
git clone --recursive https://git.nordisch.org/darix/cfgmgmt-template.git /srv/cfgmgmt
ln -s /srv/cfgmgmt/config/salt_master.conf /etc/salt/master.d
```

If you only want to listen on some internal interface

`echo "interface: 127.0.0.1" > /etc/salt/master.d/bind_local_only.conf`

We want secure permissions for this setup. If you want to edit as a non-root user you call it like:

`/srv/cfgmgmt/tools/fix-permissions username`

If you omit the username parameter it defaults to root.

Last but not least I would recommend create your own branch for using:

```
cd /srv/cfgmgmt
git branch production
```

If you want to keep up to date with later fixes in the template

```
cd /srv/cfgmgmt
git fetch origin
git rebase origin/main
```

# First steps for actually using it

## Prequisites

We have some code that assumes that the domain grain works. As such each machine
you want to manage via Saltstack and this template needs to have:

1. A hostname of the form `machinename.domain`. Domain can include many levels, but it needs to exist
2. A working reverse dns.
3. The hostname and reverse dns should be properly set up before the you start salt-minion for the first time.

## Before we introduce the first minion

Our formula can deploy `authorized_keys` files to each minion. Not just to the root account actually. If we want to use that we need to tell the formula about the ssh keys. The list of all available ssh keys is tracked in `/srv/cfgmgmt/sshkeys/users`.

A file in this directory has the format:

```
# cat alice.sls
sshkeys:
  users:
    alice:
      - ssh-ed25519 ...
      - ssh-rsa ...
```

In a pillar while we can later define for which user we want to deploy, which ssh key into an authorized_keys file.

```
sshkeys:
  root:
    users:
      - alice
  # this assumes the home directory for the 2 users exists,
  # they wont be created. only the .ssh subdirectory
  alice:
    users:
      - alice
  bob:
    users:
      - bob
```

## Our first minion

By default salt-minion will look for `salt.domain` for the salt master. If that is can not be resolved you can tell it in the configuration which salt-master to use. But I would recommend not touching `/etc/salt/minion`. Instead we add all our custom settings in `/etc/salt/minion.d/`

```
echo "master: mcp.domain" > /etc/salt/minion.d/salt_master.conf
```

On the first start it will create `/etc/salt/minion_id` based on the current hostname. If you ever need to fix the salt minion id later on.

Once you started your salt-minion, you can check `salt-key -L` on your salt-master.

```
Unaccepted Keys:
machinename.domain
```

To accept the minion you run `salt-key --accept=machinename.domain`
You can remove minions from the salt-master with

`salt-key --delete=machinename.domain`

There are also short version of the `--accept` ( `-a` ) and `--delete` (`-d`), but be careful, if you accidently upper case the short form your might accept more entries than expected, as e.g. `-D` is the short version of `--delete-all` and `-A` is `--accept-all`. Ask me how I know. :)


Now you would think "oh i can deploy the basic settings". We are close but not quite ready for that.

First we need create your minion pillar file. For this we replace all the dots with underscore.

```
touch /srv/cfgmgmt/pillar/minions/machhinename_domain.sls
```

## Our first role - What is a role anyway?

We treat our salt configuration like bricks (we sometimes refer to them as profile). Each brick handles one piece of software and the configuration. Then we combine all the bricks to build ourself a workload on a machine.

So if we want `machinename.domain` to handle forgejo for us.

```
echo -e "roles:\n  - forgejo" >> /srv/cfgmgmt/pillar/minions/machhinename_domain.sls
```

```
touch /srv/cfgmgmt/pillar/roles/forgejo.sls
touch /srv/cfgmgmt/salt/roles/forgejo.sls
```

Of course we have not provided any data yet. So nothing would really be changed if we redeploy.

In `/srv/cfgmgmt/pillar/roles/forgejo.sls` you would provide the specific configuration for all the services, which is then used by your salt code or a formula to configure all the services. If you are using formulas to handle parts, check the `pillar.example` of the formulas.

In `/srv/cfgmgmt/salt/roles/forgejo.sls` we configure which bricks/profiles/formulas to load:


```
include:
  - step-ca
  - postgresql-server
  - redis
  - forged.forgejo
  - forged.forgejo-runner
  - nginx
```