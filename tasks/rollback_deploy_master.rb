#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'yaml'
require_relative "../../ruby_task_helper/files/task_helper.rb"

class RollbackDeployMaster < TaskHelper
    def process_deploy_status(execution_status)
        copy_data = false
        data = execution_status.split("\n")
        yaml_data = Array.new
        data.each do |line|
            if copy_data == false and line.strip.include? '{' then
                copy_data = true
            end
            if copy_data
                yaml_data << line
            end
        end
        yaml_data = yaml_data[0,yaml_data.length - 2]
        deploy_status = YAML.load(yaml_data.join("\n"))
        return deploy_status
    end
    def task(simple_config_dir:nil, remove_images:nil, augmented_site_level_config_file:nil, deploy_status_file:nil, deploy_status_output_dir:nil, deploy_status_success:nil, deploy_status_failure:nil, deploy_status_pending:nil, modulepath:nil, dns_key:nil, **kwargs )
        _overall_deployment_status_file_name = simple_config_dir + "/deployment_output.yaml"
        _data = YAML.load_file(augmented_site_level_config_file)
        _lightweight_components = _data['lightweight_components']
        _output = Array.new
        _lightweight_components.each do |_lightweight_component, index|
            _execution_id = _lightweight_component['execution_id']
            _name = _lightweight_component['name']
            _node_fqdn = _lightweight_component['deploy']['node']
            _deploy_status_output_file = "#{deploy_status_output_dir}/.#{_execution_id}.status" 
            deploy_command = "bolt task run simple_grid::rollback_deploy "\
            " execution_id=#{_execution_id}"\
            " remove_images=#{remove_images}"\
            " augmented_site_level_config_file=#{augmented_site_level_config_file}"\
            " deploy_status_file=#{deploy_status_file}"\
            " deploy_status_success=#{deploy_status_success}"\
            " deploy_status_failure=#{deploy_status_failure}"\
            " deploy_status_pending=#{deploy_status_pending}"\
            " dns_key=#{dns_key}"\
            " --modulepath #{modulepath}"\
            " --nodes #{_node_fqdn}"

            puts "Rolling back deployment of #{_name} on #{_node_fqdn} with execution_id = #{_execution_id}"
            deploy_stdout, deploy_stderr, deploy_status = Open3.capture3(deploy_command)  
            rollback_status = process_deploy_status(deploy_stdout)
            _current_output = {
                "execution_id" => _execution_id,
                "component" => _name,
                "node" => _node_fqdn,
                "container_stopped" => rollback_status['container_status'],
                "puppet_status" => rollback_status['puppet_status'],
                "container_name" => rollback_status['container_name']
            }
            _output << _current_output
        end
        #delete overall deployment file
        File.delete(_overall_deployment_status_file_name) if File.exists?(_overall_deployment_status_file_name)
        "#{_output.to_yaml}\n Note: This output is not saved!"
    end
end

if __FILE__ == $0
    RollbackDeployMaster.run
end