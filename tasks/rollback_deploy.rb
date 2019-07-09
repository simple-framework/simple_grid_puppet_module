#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'open3'
require 'puppet'
require 'yaml'
require_relative "../../ruby_task_helper/files/task_helper.rb"

# This task is run on the LC node. It stored output on /etc/simple_grid/.deploy.log
class RollbackDeploy < TaskHelper
    def init_deploy(execution_id, deploy_status_file)
        current_deploy_status = Hash.new
        output = String.new
        timestamp = Time.now.strftime("%d/%m/%Y %H:%M")
        puppet_apply = "puppet apply -e \"class{'simple_grid::deploy::lightweight_component::rollback':execution_id =>#{execution_id}}\""
        stdout, stderr, status = Open3.capture3(puppet_apply)
        if status.success?
            output = stdout
        else
            output = stderr
        end
        return status.success?, output
        current_deploy_status['logs'] << timestamp + " : " + output
        
        File.open(deploy_status_file, "w") { |f| 
            f.write(deploy_status_file_hash.to_yaml)
        }
    end
    def task(execution_id:nil,deploy_status_file:nil,**kwargs)
        status, output = init_deploy(execution_id, deploy_status_file)
        {status: status, output: output}
    end
end

if __FILE__ == $0
    RollbackDeploy.run
end