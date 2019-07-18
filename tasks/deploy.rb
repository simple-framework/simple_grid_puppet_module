#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'open3'
require 'puppet'
require 'yaml'
require_relative "../../ruby_task_helper/files/task_helper.rb"

class Deploy < TaskHelper
    def init_deploy(execution_id, deploy_step, deploy_status_file, deploy_status_success, deploy_status_error)
        current_deploy_status = Hash.new
        output = String.new
        timestamp = Time.now.strftime("%d/%m/%Y %H:%M")
        puppet_apply = "puppet apply -e \"class{'simple_grid::deploy::lightweight_component::init':execution_id =>#{execution_id}, deploy_step=>#{deploy_step}}\""


        stdout, stderr, status = Open3.capture3(puppet_apply)
        
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
            current_deploy_status['status'] = deploy_status_success 
        else
            output = stderr
            current_deploy_status['status'] = deploy_status_error
        end
        current_deploy_status['logs'] << timestamp + " : " + output
        
        File.open(deploy_status_file, "w") { |f| 
            f.write(deploy_status_file_hash.to_yaml)
        }

        return status.success?, output
        
    end

    def task(execution_id:nil, deploy_step:nil, deploy_status_file:nil, deploy_status_success:nil, deploy_status_failure:nil, **kwargs)
        status, output = init_deploy(execution_id, deploy_step, deploy_status_file, deploy_status_success, deploy_status_failure) 
        {status: status, output: output }
    end
end

if __FILE__ == $0
    Deploy.run
end