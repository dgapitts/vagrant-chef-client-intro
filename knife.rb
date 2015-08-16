# See https://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "dgapitts"
client_key               "/vagrant/chef-repo/.chef/dgapitts.pem"
validation_client_name   "dgapitts_demo-validator"
validation_key           "/vagrant/chef-repo/.chef/dgapitts_demo-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/dgapitts_demo"
cookbook_path            ["/vagrant/chef-repo/cookbooks"]
