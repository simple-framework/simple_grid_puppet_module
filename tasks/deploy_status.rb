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
        post_init_hook_logs = Hash.new
        log_files = String.new
        deploy_status_file_hash = YAML.load(File.read(deploy_status_file))
        deploy_statuses = deploy_status_file_hash['deploy_status']

        deploy_statuses.each do |deploy_status|
            if deploy_status['execution_id'].to_i == execution_id.to_i 
                current_deploy_status = deploy_status
                break
            end
        end
        
        log_dir = "#{log_dir}/#{execution_id}/#{timestamp}"
        Dir.glob("#{log_dir}/*.log") {|file|
            log_files = "#{log_files} #{file}"
            filename = File.basename(file)
            if filename == "puppet_deploy_step_1.log"
                puppet_deploy_step_1_logs = File.read(file)
            elsif filename == "puppet_deploy_step_2.log"
                puppet_deploy_step_2_logs = File.read(file)
            else
                hook_or_event = filename.split('-')[0]
                # filename = filename.split('-').drop 2
                if hook_or_event == "pre_config"
                    pre_config_hook_logs[filename] = File.read(file)
                elsif hook_or_event == "pre_init"
                    pre_init_hook_logs[filename] = File.read(file)
                elsif hook_or_event == "init"
                    init_event_logs = File.read(file)
                elsif hook_or_event == "post_init"
                    post_init_hook_logs[filename] = File.read(file)
                end    
            end
        }
        
        { 
            deploy_status: current_deploy_status, 
            log_files: log_files, 
            puppet_deploy_step_1: puppet_deploy_step_1_logs,
            puppet_deploy_step_2: puppet_deploy_step_2_logs,
            pre_config: pre_config_hook_logs,
            pre_init: pre_init_hook_logs,
            init: init_event_logs,
            post_init: post_init_hook_logs
        }
    end
end

if __FILE__ == $0
    DeployStatus.run
end
