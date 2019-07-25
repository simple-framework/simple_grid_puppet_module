#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'open3'
require 'puppet'
require 'yaml'
require 'fileutils'
require_relative "../../ruby_task_helper/files/task_helper.rb"

class Deploy < TaskHelper
    def init_deploy(execution_id, deploy_step, augmented_site_level_config_file, dns_key, deploy_status_file, deploy_status_success, deploy_status_error, timestamp, deploy_step_1, deploy_step_2, log_dir)
        current_deploy_status = Hash.new
        current_dns_info = Hash.new
        output = String.new
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

        #run puppet
        puppet_apply = "puppet apply -e \"class{'simple_grid::deploy::lightweight_component::init':execution_id =>#{execution_id}, deploy_step=>#{deploy_step}}, timestamp=>#{timestamp}\""
        puppet_stdout, puppet_stderr, puppet_status = Open3.capture3(puppet_apply)
        
        #handle puppet
        # update current_deploy_status and return values
        if puppet_status.success?
            output = puppet_stdout
            current_deploy_status['puppet_status'] = deploy_status_success 
        else
            output = puppet_stderr
            current_deploy_status['puppet_status'] = deploy_status_error
        end
        
        current_deploy_status['logs'] << timestamp + " : " + output

        # run container id
        container_id_command="docker inspect --format='{{.ID}}' #{current_dns_info['container_fqdn']}"
        container_id_stdout, container_id_stderr, container_id_status =Open3.capture3(container_id_command)
        
        #handle container id
        if container_id_status.success?
            current_deploy_status["container_id"] = container_id_stdout.split.join ' '
        else
            current_deploy_status["container_id"] = container_id_stderr.split.join ' '
        end    

        # run container status
        container_status_command="docker inspect --format='{{.State.Status}}' #{current_dns_info['container_fqdn']}"
        container_stdout, container_stderr, container_status =Open3.capture3(container_status_command)
        
        # handle container status
        if container_status.success?
            current_deploy_status["container_status"] = container_stdout.split.join ' '
            current_deploy_status['status'] = deploy_status_success
        else
            current_deploy_status['status'] = deploy_status_error
            if container_stderr.include? "Template"
                current_deploy_status["container_status"] = "The container is not up. The container_id is related to Docker Swarm and not to a SIMPLE lightweight component."
            else
                current_deploy_status["container_status"] = container_stderr.split.join ' '
            end
        end
        
        deploy_status_file_hash[execution_id] = current_deploy_status
        File.open(deploy_status_file, "w") { |f| 
            f.write(deploy_status_file_hash.to_yaml)
        }

        puppet_step_1_output_file = "#{log_dir}/#{execution_id}/#{timestamp}/puppet_deploy_step_1.log"
        puppet_step_2_output_file = "#{log_dir}/#{execution_id}/#{timestamp}/puppet_deploy_step_2.log"
        if deploy_step == deploy_step_1
            File.open(puppet_step_1_output_file, "w") { |f| 
                f.write(output)
            }
        elsif deploy_step == deploy_step_2
            File.open(puppet_step_2_output_file, "w") { |f| 
                f.write(output)
            }
        end

        return container_status.success?, output
        
    end

    def task(execution_id:nil, deploy_step:nil, augmented_site_level_config_file:nil, dns_key:nil, deploy_status_file:nil, deploy_status_success:nil, deploy_status_failure:nil, timestamp:nil, deploy_step_1:nil, deploy_step_2:nil, log_dir:nil,  **kwargs)
        status, output = init_deploy(execution_id, deploy_step, augmented_site_level_config_file, dns_key, deploy_status_file, deploy_status_success, deploy_status_failure) 
        {status: status, output: output }
    end
end

if __FILE__ == $0
    Deploy.run
end