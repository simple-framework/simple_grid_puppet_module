#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'open3'
require 'puppet'
require_relative "../../ruby_task_helper/files/task_helper.rb"

# This task is run on the LC node. It stored output on /etc/simple_grid/.deploy.log
class Deploy < TaskHelper
    def init_deploy(execution_id)
        deploy_log_file = "/etc/simple_grid/.0.deploy_" + Time.now.strftime("%d-%m-%Y_%H-%M") + ".log"
        puppet_apply = "puppet apply -e \"class{'simple_grid::deploy::lightweight_component::init':execution_id =>#{execution_id}}\" > #{deploy_log_file}"
        stdout, stderr, status = Open3.capture3(puppet_apply)
        raise Puppet::Error, ("stderr: '#{stderr}'") if status !=0
        output = IO.read(deploy_log_file)
    end
    def task(execution_id:nil, **kwargs)
        result = init_deploy(execution_id)
        {status: result}
    end
end

if __FILE__ == $0
    Deploy.run
end