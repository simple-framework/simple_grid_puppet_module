#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'yaml'
require 'open3'
require_relative "../../ruby_task_helper/files/task_helper.rb"

# This task runs on CM node
class DeployStatus <TaskHelper

    def task(deploy_status_file:nil, augmented_site_level_config_file:nil, dns_key:nil, execution_id:nil, timestamp:nil, deploy_step:nil, deploy_step_1:nil, deploy_step_2:nil, log_dir:nil, **kwargs)
        
        current_deploy_status = Hash.new
        puppet_deploy_step_1_logs = String.new
        pre_config_hook_logs = Hash.new
        puppet_deploy_step_2_logs = String.new
        pre_init_hook_logs = Hash.new
        init_event_logs = String.new
        post_init_hool_logs = Hash.new

        deploy_status_file_hash = YAML.load(File.read(deploy_status_file))
        deploy_statuses = deploy_status_file_hash['deploy_status']

        deploy_statuses.each do |deploy_status|
            if deploy_status['execution_id'].to_i == execution_id.to_i 
                current_deploy_status = deploy_status
                break
            end
        end
        
        log_dir = "#{log_dir}/#{execution_id}/#{timestamp}"
        { deploy_status: current_deploy_status.to_yaml, pre_config_logs: Hash.new}
    end
end

if __FILE__ == $0
    DeployStatus.run
end
