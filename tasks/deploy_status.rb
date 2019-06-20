#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'yaml'
require 'open3'
require_relative "../../ruby_task_helper/files/task_helper.rb"

# This task runs on CM node
class DeployStatus <TaskHelper

    def task(deploy_status_file:nil, augmented_site_level_config_file:nil, dns_key:nil, execution_id:nil, **kwargs)
        deploy_status_file_hash = YAML.load(File.read(deploy_status_file))
        deploy_statuses = deploy_status_file_hash['deploy_status']
        current_deploy_status = Hash.new
        current_container_status = Array.new
        augmented_site_level_config  = YAML.load(File.read(augmented_site_level_config_file))
        dns_array = augmented_site_level_config[dns_key]
        deploy_statuses.each do |deploy_status|
            if deploy_status['execution_id'].to_i == execution_id.to_i 
                current_deploy_status = deploy_status
                break
            end
        end
        dns_array.each do |dns_info|
            if dns_info['execution_id'] == execution_id.to_i
                container_fqdn = dns_info['container_fqdn']
                command="docker inspect --format='{{.ID}}' #{container_fqdn}"
                stdout, stderr, status =Open3.capture3(command)
                if status.success?
                    current_deploy_status["container_id"] = stdout.split.join ' '
                else 
                    current_deploy_status["container_id"] = stderr.split.join ' '
                end
                command="docker inspect --format='{{.State.Status}}' #{container_fqdn}"
                stdout, stderr, status =Open3.capture3(command)
                if status.success?
                    current_deploy_status["container_status"] = stdout.split.join ' '
                else
                    if stderr.include? "Template"
                        current_deploy_status["container_status"] = "The container is not up. The container_id is related to Docker Swarm and not to a SIMPLE lightweight component."
                    else
                        current_deploy_status["container_status"] = stderr.split.join ' '
                    end
                end
                break
            end
        end
        current_deploy_status.to_yaml
    end
end

if __FILE__ == $0
    DeployStatus.run
end
