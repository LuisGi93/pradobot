Vagrant.configure("2") do |config|
  config.vm.box = "dummy"

  config.vm.define "pradobot-aws" do |host|
    host.vm.hostname = "pradobot-aws"
  end
  config.vm.provider :aws do |aws, override|
    aws.access_key_id = ""
    aws.secret_access_key = ""
    aws.session_token = ""
    aws.keypair_name = ""
    aws.region= "us-west-2"
    aws.security_groups = ""
    aws.instance_type= 't2.micro'
   
    aws.ami = "ami-d57dcfb5"

    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = ""
  end
  
    config.vm.provision :ansible do |ansible|
	ansible.playbook = "pradobot.yml"
	ansible.force_remote_user= true
  end
end
