Vagrant::Config.run do |config|
  config.vm.box = "ubuntu-1104-server-amd64"
  config.vm.box_url = "http://dl.dropbox.com/u/7490647/talifun-ubuntu-11.04-server-amd64.box"
  config.vm.provision :shell, :path => "setup_env.sh"
end
