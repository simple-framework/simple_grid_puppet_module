#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'open3'
require 'puppet'
require 'yaml'
require_relative "../../ruby_task_helper/files/task_helper.rb"

# This task is run on the LC node. It stored output on /etc/simple_grid/.deploy.log
class Deploy < TaskHelper
    def init_deploy(execution_id, deploy_status_file)
        current_deploy_status = Hash.new
        output = String.new
        timestamp = Time.now.strftime("%d/%m/%Y %H:%M")
        puppet_apply = "puppet apply -e \"class{'simple_grid::deploy::lightweight_component::init':execution_id =>#{execution_id}}\""
        stdout, stderr, status = Open3.capture3(puppet_apply)
        
        #raise Puppet::Error, ("stderr: '#{stderr}'") if status !=0
        # Find element in deploy_status file
        deploy_status_file_hash = YAML.load(File.read(deploy_status_file))
        deploy_statuses = deploy_status_file_hash['deploy_status']
        deploy_statuses.each do |deploy_status|
            if deploy_status['execution_id'].to_i == execution_id.to_i
                current_deploy_status = deploy_status
                break
            end
        end

        # update current_deploy_status and return values
        if status.success?
            output = stdout
            current_deploy_status['status'] = "success" 
        else
            output = stderr
            current_deploy_status['status'] = "error"
        end
        current_deploy_status['logs'] << timestamp + " : " + output
        
        File.open(deploy_status_file, "w") { |f| 
            f.write(deploy_status_file_hash.to_yaml)
        }

        return status.success?, output
        
    end
    def task(execution_id:nil, deploy_status_file:nil, **kwargs)
        status, output = init_deploy(execution_id, deploy_status_file)
        {status: status, output: output}
    end
end

if __FILE__ == $0
    Deploy.run
end