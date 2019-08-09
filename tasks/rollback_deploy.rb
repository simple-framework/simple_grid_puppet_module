#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'open3'
require 'puppet'
require 'yaml'
require_relative "../../ruby_task_helper/files/task_helper.rb"

# This task is run on the LC node. It stored output on /etc/simple_grid/.deploy.log
class RollbackDeploy < TaskHelper
    def init_deploy(augmented_site_level_config_file, execution_id, deploy_status_file, deploy_status_success, deploy_status_failure, deploy_status_pending, dns_key)
        current_deploy_status = Hash.new
        current_dns_info = Hash.new
        output = String.new
        timestamp = Time.now.strftime("%d/%m/%Y %H:%M")

        # get dns info
        augmented_site_level_config  = YAML.load(File.read(augmented_site_level_config_file))
        dns_array = augmented_site_level_config[dns_key]
        dns_array.each do |dns_info|
            if dns_info['execution_id'] == execution_id.to_i
                current_dns_info = dns_info
                break
            end
        end

        # Find element in deploy_status file
        deploy_status_file_hash = YAML.load(File.read(deploy_status_file))
        deploy_statuses = deploy_status_file_hash['deploy_status']
        deploy_statuses.each do |deploy_status|
            if deploy_status['execution_id'].to_i == execution_id.to_i
                current_deploy_status = deploy_status
                break
            end
        end

        # run puppet
        puppet_apply = "puppet apply -e \"class{'simple_grid::deploy::lightweight_component::rollback':execution_id =>#{execution_id}}\""
        puppet_stdout, puppet_stderr, puppet_status = Open3.capture3(puppet_apply)
        #handle puppet
        if puppet_status.success?
            output = puppet_stdout
            current_deploy_status['puppet_status'] = deploy_status_pending
        else
            output = puppet_stderr
            current_deploy_status['puppet_status'] = "#{deploy_status_failure}-rollback"
        end
        current_deploy_status['logs'] << timestamp + " : " + output
        
         # run container id
         container_id_command="docker inspect --format='{{.ID}}' #{current_dns_info['container_fqdn']}"
         container_id_stdout, container_id_stderr, container_id_status =Open3.capture3(container_id_command)
         
         # handle container id
         if container_id_status.success?
             current_deploy_status["container_id"] = "#{container_id_stdout.split.join ' '} - rollback error"
         else
             current_deploy_status["container_id"] = "Container removed successfully!"
         end  
        
        # run container status
        container_status_command="docker inspect --format='{{.State.Status}}' #{current_dns_info['container_fqdn']}"
        container_stdout, container_stderr, container_status =Open3.capture3(container_status_command)
        
        # handle container status
        if container_status.success?
            current_deploy_status["container_status"] = container_stdout.split.join ' '
            current_deploy_status['status'] = "#{deploy_status_failure}-rollback_failed"
        else
            current_deploy_status['status'] = deploy_status_pending
            if container_stderr.include? "Template"
                current_deploy_status["container_status"] = "The container is not up. The container_id is related to Docker Swarm and not to a SIMPLE lightweight component. This outcome is not an issue during rollback. You can ignore this error."
            else
                current_deploy_status["container_status"] = "#{container_stderr.split.join ' '}. You can ignore this error."
            end
        end
        
        File.open(deploy_status_file, "w") { |f| 
            f.write(deploy_status_file_hash.to_yaml)
        }
        return !container_status.success?, current_dns_info['container_fqdn'], puppet_status, output
    end
    def task(augmented_site_level_config_file:nil, execution_id:nil,deploy_status_file:nil, deploy_status_success:nil, deploy_status_failure:nil, deploy_status_pending:nil, dns_key:nil, **kwargs)
        container_status, container_name, puppet_status, output = init_deploy(augmented_site_level_config_file, execution_id, deploy_status_file, deploy_status_success, deploy_status_failure, deploy_status_pending, dns_key)
        {container_status: container_status, container_name: container_name, puppet_status: puppet_status ,puppet_output: output}
    end
end

if __FILE__ == $0
    RollbackDeploy.run
end