#! /bin/bash
if [ ! -f /home/vagrant/already-installed-flag ]
then
  echo "ADD EXTRA ALIAS VIA .bashrc"
  cat /vagrant/bashrc.append.txt >> /home/vagrant/.bashrc
  echo "GENERAL APT-GET UPDATE"
  #yum -y update
  echo "INSTALL CURL"
  yum -y install curl
  #echo "INSTALL CHEF"
  #curl -L https://www.opscode.com/chef/install.sh | bash
  #echo "DOWNLOAD CHEF MASTER REPO"
  #wget http://github.com/opscode/chef-repo/tarball/master
  #tar -zxf master
  #mv chef-chef-repo* chef-repo
  #rm master
  echo "INSTALL GIT"
  yum -y install git
  echo "INSTALL VIM"
  yum -y install vim
  echo "INSTALL TREE"
  yum -y install tree
  echo "INSTALL UNZIP"
  yum -y install unzip

  touch /home/vagrant/already-installed-flag
  echo "Done!"
else
  echo "already installed flag set : /home/vagrant/already-installed-flag"
fi

