#!/opt/puppetlabs/puppet/bin/ruby
require 'yaml'
require 'json'
require 'open3'
require_relative "../../ruby_task_helper/files/task_helper.rb"

# This task is run on the LC node. 
class RollbackPreDeploy < TaskHelper
    def puppet_agent_command()
        status = Hash.new
        puppet_apply = "puppet apply -e \"class {'simple_grid::pre_deploy::lightweight_component::rollback':} \" "
        stdout, stderr, status = Open3.capture3(puppet_apply)    
        if !status.success?
            status = {"status" => status.success?, "stderr" => stderr}
        else 
            status = {"status" => status.success?, "stderr" => stdout}
        end
        status
    end
    def task(**kwargs)
        result = puppet_agent_command()
        {rollback_pre_deploy_status: result}
    end
end

if __FILE__ == $0
    RollbackPreDeploy.run
end