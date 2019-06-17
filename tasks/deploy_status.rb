#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'yaml'
require_relative "../../ruby_task_helper/files/task_helper.rb"

# This task runs on CM node
class DeployStatus <TaskHelper
    
    def get_container_info(execution_id, simple_config_dir)
        container_info.Hash.new
         dns_file = "#{simple_config_dir}/.dns.yaml"
         dns_file_array = YAML.load(File.read(dns_file))
         container_fqdn = String.new
         dns_file_array.each do |dns_info|
                if dns_info['execution_id'] == execution_id
                    container_fqdn = dns_info['container_fqdn:']
                end
        command="/usr/bin/docker inspect --format='{{.ID}}' #{container_fqdn}"
        stdout, stderr, status =Open3.capture3(command)
        container_info['container_id']  =  stdout
        command="/usr/bin/docker inspect --format='{{.State.Status}}' #{container_fqdn}"
        stdout, stderr, status =Open3.capture3(command)
        container_info['container_status']  =  stdout
        return container_info
        end


    def task(deploy_status_file:nil, execution_id:nil, **kwargs)
        deploy_status_file_hash = YAML.load(File.read(deploy_status_file))
        deploy_statuses = deploy_status_file_hash['deploy_status']
        current_deploy_status = Hash.new
        deploy_statuses.each do |deploy_status|
            if deploy_status['execution_id'].to_i == execution_id.to_i 
                current_deploy_status = deploy_status
                break
            end
        end
        

        current_deploy_status.to_yaml
    end
end

if __FILE__ == $0
    DeployStatus.run
end
