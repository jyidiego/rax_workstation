#!/bin/bash

# Add vagrant to the staff group
# usermod -G staff vagrant

apt-get -y update
apt-get -y install curl build-essential libxml2-dev libxslt-dev git zlib1g-dev libssl-dev subversion dkms
# apt-get -y install linux-headers-generic linux-image-extra-`uname -r`
apt-get -y install linux-headers-generic
apt-get -y install python openssh-server python-dev software-properties-common ipython

#
# Install easy_install, pip, and the openstack python libs, and ansible
#
curl https://pypi.python.org/packages/source/s/setuptools/setuptools-1.1.6.tar.gz | tar xvzf -;cd setuptools-1.1.6;python setup.py install
easy_install pip
pip install python-novaclient
pip install python-swiftclient
pip install python-heatclient
pip install python-cinderclient
pip install python-keystoneclient
pip install python-troveclient
pip install python-neutronclient
pip install pyrax
pip install ansible
pip install supernova
pip install rackspace-monitoring-cli
pip install eventlet
pip install swiftly
git clone https://github.com/rackerlabs/python-cloudlb.git $HOME/cloudlb;cd $HOME/cloudlb;python setup.py install;cd $HOME
git clone https://github.com/jyidiego/clb.git $HOME/clb;cd $HOME/clb;python setup.py install;cd $HOME
chmod -R 544 /usr/local/lib/python2.7/dist-packages/python_dateutil-*-py2.7.egg/EGG-INFO/* # needed because perms are screwed.

#
# install lava client
#
curl -L http://bit.ly/cbdclient | tar xvzf -;cd python-lava*;python setup.py install;cd $HOME

#
# Remove source directories
rm -rf $HOME/clb $HOME/cloudlb $HOME/python-lava*

#
# NOT NEEDED: Install chef client and knife
#
# curl -L https://www.opscode.com/chef/install.sh | sudo bash
# dpkg -i /vagrant/chef_11.6.0-1.ubuntu.12.04_amd64.deb
# /opt/chef/embedded/bin/gem install --no-rdoc --no-ri knife-rackspace
# /opt/chef/embedded/bin/gem install berkshelf

#
# Install chef client and knife
#
# curl -L https://www.opscode.com/chef/install.sh | sudo bash /dev/stdin -P chefdk

#
# Install knife-rackspace plugin
#
# su - vagrant -c "/opt/chefdk/embedded/bin/gem install knife-rackspace"

#
# Create message of the day file
#
cat <<EOF > /etc/motd.tail
 Rackspace Public Cloud/Openstack Automation Platform

 This platform comes with the following Openstack SDKs
 and command line utilities:

 Version Control Tools: git, subversion
 Automation Tools: ansible
 Python: pyrax, nova, swift, clb, heat, keystone, cinder, neutron, trove, lava, swiftly, rax-mon-<command>

 RUN THIS COMMAND TO START: source openstackrc.sh
EOF


#
# copy and set permissions for openstack rc file
#
cp /vagrant/openstackrc.sh /home/vagrant
cp /vagrant/.openstack_cli_functions.sh /home/vagrant
# mkdir /home/vagrant/.chef
# cp /vagrant/knife.rb /home/vagrant/.chef
# chown vagrant:vagrant /home/vagrant/openstackrc.sh /home/vagrant/.openstack_cli_functions.sh
# chown -R vagrant:vagrant /home/vagrant/.chef
