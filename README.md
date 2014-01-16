rax_workstation
===============

A platform to allow developers and operations to kick the tires on various rackspace cloud APIs, automation tools, and command line utilities

Getting Started
===============
In order to use rax_workstation you're going to need:

 - Vagrant (1.4.x) or higher
 - Virtualbox 4.2.x or higher

Getting started is easy first clone this repository

```
git clone https://github.com/rackerlabs/rax_workstation.git
```

Once you've cloned the repository just vagrant up the box

```
cd rax_workstation
vagrant up
```

ssh into the rax_workstation
```
vagrant ssh
```

SSH keys are awesome so create a keypair as below, because this is a demo/development
I opted for less security and just pressed enter for the passphrase

```
vagrant@rax-workstation:~$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/vagrant/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/vagrant/.ssh/id_rsa.
Your public key has been saved in /home/vagrant/.ssh/id_rsa.pub.
The key fingerprint is:
eb:c0:ba:da:30:d7:4f:e9:04:17:79:3e:ce:73:7b:54 vagrant@rax-workstation
The key's randomart image is:
+--[ RSA 2048]----+
|                 |
|         .       |
|        o .      |
|         +      E|
|      . S o    . |
|     o o = .  .  |
|  o . + = + ..   |
|   = . B   o ..  |
|  ..+.  +   ..   |
+-----------------+
```

Next it's time to log into the rax cloud and add the ssh-key, in the home directory
of vagrant source the openstackrc.sh file

```
vagrant@rax-workstation:~$ source openstackrc.sh 
Please enter your Openstack Username: demo
Please enter your OpenStack Password: 
Please enter your Region (ORD, DFW, IAD, SYD): IAD
Please enter HEAT tenant ID (Rackspace Account ID): 666666
vagrant@rax-workstation:~$
```

Add your ssh public key

```
nova keypair-add --pub-key ~/.ssh/id_rsa.pub ansible_demo
```

You now are setup to create servers and interact with all the cli tools. Some things you 
should be able to do:

```
vagrant@rax-workstation:~$ knife rackspace server list
Instance ID                           Name                 Public IP        Private IP      Flavor          Image                                 State 
c9469ebb-d8f1-474d-8816-a834b41a7ff5  network_test         162.242.232.4    10.176.166.249  performance1-1  df27d481-63a5-40ca-8920-3d132ed643d9  active
2224ff34-125b-4321-8e45-e2475157408f  docker.example.com   162.242.231.12   10.176.160.241  performance1-1  80fbcb55-b206-41f9-9bc2-2dd7aac6c061  active

vagrant@rax-workstation:~$ nova list
:7801:0103:90a8:d07e:ff20:25e3, 162.242.231.12; private=10.176.160.241                      |
| 91e8c268-09fd-4110-9784-3e20a51aa5b7 | iad.docker          | ACTIVE | None       | Running     | public=162.242.212.132, 2001:4802:7801:0102:90a8:d07e:ff20:0daf; private=10.176.130.19                      |
| c9469ebb-d8f1-474d-8816-a834b41a7ff5 | network_test        | ACTIVE | None       | Running     | JOHNYI=192.168.0.2; public=2001:4802:7801:0103:90a8:d07e:ff20:1d8d, 162.242.232.4; private=10.176.166.249   |

vagrant@rax-workstation:~$ ipython
Python 2.7.3 (default, Sep 26 2013, 20:03:06) 
Type "copyright", "credits" or "license" for more information.

IPython 0.12.1 -- An enhanced Interactive Python.
?         -> Introduction and overview of IPython's features.
%quickref -> Quick reference.
help      -> Python's own help system.
object?   -> Details about 'object', use 'object??' for extra details.

In [1]: import pyrax

In [2]: pyrax.set_setting('identity_type', 'rackspace')

In [3]: pyrax.set_cre
pyrax.set_credential_file  pyrax.set_credentials      

In [3]: pyrax.set_credential_file('./.rax_creds_file')

In [4]: cs = pyrax.connect_to_cloudservers(region='IAD')

In [5]: cs.list()
Out[5]: 
[<Server: network_test>,
 <Server: docker.example.com>,
 <Server: queue.demo>,
 <Server: iad.docker>]

```

How about boot a server via commandline?
```
vagrant@rax-workstation:~$ nova boot --key-name ansible_demo --image 80fbcb55-b206-41f9-9bc2-2dd7aac6c061 \
> --flavor performance1-1 --poll first_boot
+------------------------+--------------------------------------+
| Property               | Value                                |
+------------------------+--------------------------------------+
| status                 | BUILD                                |
| updated                | 2014-01-16T01:53:24Z                 |
| OS-EXT-STS:task_state  | scheduling                           |
| key_name               | ansible_demo                         |
| image                  | Ubuntu 12.04 LTS (Precise Pangolin)  |
| hostId                 |                                      |
| OS-EXT-STS:vm_state    | building                             |
| flavor                 | 1 GB Performance                     |
| id                     | ea3b7250-84b5-414d-b531-bf4dd830cf18 |
| user_id                | 10044828                             |
| name                   | first_boot                           |
| adminPass              | Q9WUzLfDDr7D                         |
| tenant_id              | 843368                               |
| created                | 2014-01-16T01:53:23Z                 |
| OS-DCF:diskConfig      | AUTO                                 |
| accessIPv4             |                                      |
| accessIPv6             |                                      |
| progress               | 0                                    |
| OS-EXT-STS:power_state | 0                                    |
| config_drive           |                                      |
| metadata               | {}                                   |
+------------------------+--------------------------------------+
Instance building... 100% complete
Finished
vagrant@rax-workstation:~$ nova ssh first_boot
The authenticity of host '162.242.223.59 (162.242.223.59)' can't be established.
ECDSA key fingerprint is 4e:e3:91:f2:d3:aa:fa:66:d7:64:89:f6:e0:f1:90:43.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '162.242.223.59' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 12.04.3 LTS (GNU/Linux 3.2.0-55-virtual x86_64)

 * Documentation:  https://help.ubuntu.com/

  System information as of Thu Jan 16 01:54:26 UTC 2014

  System load:  0.23              Processes:           67
  Usage of /:   4.9% of 19.68GB   Users logged in:     0
  Memory usage: 4%                IP address for eth0: 162.242.223.59
  Swap usage:   0%                IP address for eth1: 10.176.167.35

  Graph this data and manage this system at https://landscape.canonical.com/


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

-bash: warning: setlocale: LC_ALL: cannot change locale (en_US)
_____________________________________________________________________
WARNING! Your environment specifies an invalid locale.
 This can affect your user experience significantly, including the
 ability to manage packages. You may install the locales by running:

   sudo apt-get install language-pack-en
     or
   sudo locale-gen en_US

To see all available language packs, run:
   apt-cache search "^language-pack-[a-z][a-z]$"
To disable this message for all users, run:
   sudo touch /var/lib/cloud/instance/locale-check.skip
_____________________________________________________________________

-bash: warning: setlocale: LC_ALL: cannot change locale (en_US)
root@first-boot:~# 
```

