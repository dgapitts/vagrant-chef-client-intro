
#download postgres cookbook 
echo '*** upload pre-requisite cookbooks : [apt,build-essential, chef-sugar, openssl] ***'
cd /vagrant/chef-repo/cookbooks
knife cookbook upload apt
knife cookbook upload build-essential
knife cookbook upload chef-sugar
knife cookbook upload openssl

echo '*** upload postgresql cookbooks ***'
knife cookbook upload postgresql