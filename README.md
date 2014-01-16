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
```


