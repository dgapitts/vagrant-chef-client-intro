echo '*** download and extract base gettingstartedwithchef cp1 tarfile ***'
wget http://gettingstartedwithchef.com/downloads/cp1.tgz
tar zxf cp1.tgz
. bashrc.append.txt
rm cp1.tgz


echo '*** copy BOTH private_user and organisation_validator keys to under /vagrant/chef-repo/.chef/ ***'
#copy *both* private and validator keys to under /vagrant/chef-repo/.chef/
cp /vagrant/dgapitts.pem /vagrant/chef-repo/.chef/
cp /vagrant/dgapitts_demo-validator.pem /vagrant/chef-repo/.chef/
sudo cp /vagrant/chefclient01.pem /etc/chef/client.pem


echo '*** copy *editted* knife.rb to under /vagrant/chef-repo/.chef/ ***'
#copy *editted* knife.rb to under /vagrant/chef-repo/.chef/
cp /vagrant/knife.rb /vagrant/chef-repo/.chef/knife.rb

echo '/vagrant/chef-repo/.chef:'
ls -l /vagrant/chef-repo/.chef

#download postgres cookbook 
cd /vagrant/chef-repo/cookbooks
knife cookbook site download postgresql
tar zxf postgresql-3.4.20.tar.gz
rm postgresql*tar.gz


echo '*** done with step01 ***'
