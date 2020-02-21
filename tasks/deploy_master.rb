#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'yaml'
require 'fileutils'
require_relative "../../ruby_task_helper/files/task_helper.rb"

class DeployMaster < TaskHelper
    def process_execution_status(execution_status_file)
        copy_data = false
        data = File.read(execution_status_file)
        yaml_data = Array.new
        data.each_line do |line|
            if copy_data == false and line.strip.include? '{' then
                copy_data = true
            end
            if copy_data
                yaml_data << line
            end
        end
        yaml_data = yaml_data[0,yaml_data.length - 2]
        File.open(execution_status_file + ".yaml", 'w') do |file|
                file.puts yaml_data
        end
        deploy_status = YAML.load_file(execution_status_file + ".yaml")
        return deploy_status
    end

    def task(simple_config_dir:nil, augmented_site_level_config_file:nil, dns_key:nil, deploy_step_1:nil, deploy_step_2:nil, deploy_status_file:nil, execution_status_file_name:nil, deploy_status_success:nil, deploy_status_failure:nil, modulepath:nil, timestamp:nil, log_dir:nil, stage_final:nil, stage_config_file:nil, **kwargs )
        _overall_deployment_status_file_name = "#{log_dir}/#{timestamp}_deployment_output.yaml"
        _data = YAML.load_file(augmented_site_level_config_file)
        _proceed_deploy_step_2 = true
        _lightweight_components = _data['lightweight_components']
        puts _lightweight_components
        _output = Array.new
        _output << "****** DEPLOY STEP 1 ********"
        _output << "*****************************"
        # Deploy Stage step 1
        _lightweight_components.each do |_lightweight_component, index|
            _execution_id = _lightweight_component['execution_id']
            _name = _lightweight_component['name']
            _node_fqdn = _lightweight_component['deploy']['node']
            _deploy_status_output_dir = "#{log_dir}/#{_execution_id}/#{timestamp}"
            _execution_status_output_file = "#{_deploy_status_output_dir}/#{execution_status_file_name}"
            #create log directory on 
            unless File.directory?(_deploy_status_output_dir)
                FileUtils.mkdir_p(_deploy_status_output_dir)
            end

            deploy_command = "bolt task run simple_grid::deploy"\
            " execution_id=#{_execution_id}"\
            " deploy_step=#{deploy_step_1}"\
            " augmented_site_level_config_file=#{augmented_site_level_config_file}"\
            " dns_key=#{dns_key}"\
            " deploy_status_file=#{deploy_status_file}"\
            " deploy_status_success=#{deploy_status_success}"\
            " deploy_status_failure=#{deploy_status_failure}"\
            " timestamp='#{timestamp}'"\
            " deploy_step_1=#{deploy_step_1}"\
            " deploy_step_2=#{deploy_step_2}"\
            " log_dir=#{log_dir}"\
            " --modulepath #{modulepath}"\
            " --targets #{_node_fqdn}"\
            
            execution_status_command = "bolt task run simple_grid::deploy_status \
                deploy_status_file=#{deploy_status_file} \
                execution_id=#{_execution_id} \
                timestamp=#{timestamp} \
                augmented_site_level_config_file=#{augmented_site_level_config_file} \
                dns_key=#{dns_key} \
                deploy_step=#{deploy_step_1} \
                deploy_step_1=#{deploy_step_1} \
                deploy_step_2=#{deploy_step_2} \
                log_dir=#{log_dir} \
                --modulepath #{modulepath} \
                --targets #{_node_fqdn} \
                > #{_execution_status_output_file}"

            puts "Executing Step 1 deployment of #{_name} on #{_node_fqdn} with execution_id = #{_execution_id}"
            deploy_stdout, deploy_stderr, deploy_status = Open3.capture3(deploy_command)  
            
            puts "Fetching Step 1 deployment status for #{_name} on #{_node_fqdn} with execution_id = #{_execution_id}"
            execution_status_stdout, execution_status_stderr, execution_status_status = Open3.capture3(execution_status_command)
            execution_status = process_execution_status(_execution_status_output_file)
            deploy_status = execution_status['deploy_status']
            _current_output = {
                "execution_id" => _execution_id,
                "component" => _name,
                "node" => _node_fqdn,
                "deploy_step_1_status" => deploy_status['status'],
                "deploy_step_1_puppet_status" => deploy_status['puppet_status'],
                "container_id" => deploy_status['container_id'],
                "container_status"=>  deploy_status['container_status'],
                "log_file" => _execution_status_output_file,
            }
            _output << _current_output

            ## Save output files for pre_deploy_step_1
            log_location = "#{log_dir}/#{_execution_id}/#{timestamp}"
            File.open("#{log_location}/puppet_deploy_step_1.log", 'w') { |file|
                file.write(execution_status['puppet_deploy_step_1'])
            }
            execution_status['pre_config'].each do |filename, data|
                File.open("#{log_location}/#{filename}", "w") { |file|
                    file.write(data)
                }
            end
            
            if deploy_status['status'] != deploy_status_success
                _proceed_deploy_step_2 = false
                puts "Execution of Deployment Step 1 for execution ID #{_execution_id} failed. Check output available at #{_execution_status_output_file} for details."
                # puts "Latest log entry for Puppet Agent on #{_node_fqdn} was: #{deploy_status['logs'].last}"
                _output << "FAILED Execution! Please go through the logs mentioned above. If that does not clearly indicate any error, please contact the SIMPLE support team."
                break
            end
        end
        
        # Deploy Stage step 2
        if _proceed_deploy_step_2 == true
            _output << "****** DEPLOY STEP 2 ********"
            _output << "*****************************"
            _lightweight_components.each do |_lightweight_component, index|
                _execution_id = _lightweight_component['execution_id']
                _name = _lightweight_component['name']
                _node_fqdn = _lightweight_component['deploy']['node']
                _deploy_status_output_dir = "#{log_dir}/#{_execution_id}/#{timestamp}"
                _execution_status_output_file = "#{_deploy_status_output_dir}/#{execution_status_file_name}" 
                deploy_command = "bolt task run simple_grid::deploy"\
                " execution_id=#{_execution_id}"\
                " deploy_step=#{deploy_step_2}"\
                " deploy_status_file=#{deploy_status_file}"\
                " augmented_site_level_config_file=#{augmented_site_level_config_file}"\
                " dns_key=#{dns_key}"\
                " deploy_status_success=#{deploy_status_success}"\
                " deploy_status_failure=#{deploy_status_failure}"\
                " timestamp=#{timestamp}"\
                " deploy_step_1=#{deploy_step_1}"\
                " deploy_step_2=#{deploy_step_2}"\
                " log_dir=#{log_dir}"\
                " --modulepath #{modulepath}"\
                " --targets #{_node_fqdn}"\
                
                execution_status_command = "bolt task run simple_grid::deploy_status \
                    deploy_status_file=#{deploy_status_file} \
                    execution_id=#{_execution_id} \
                    timestamp=#{timestamp} \
                    augmented_site_level_config_file=#{augmented_site_level_config_file}\
                    dns_key=#{dns_key}\
                    deploy_step=#{deploy_step_2}\
                    deploy_step_1=#{deploy_step_1}\
                    deploy_step_2=#{deploy_step_2}\
                    log_dir=#{log_dir}\
                    --modulepath #{modulepath} \
                    --targets #{_node_fqdn} \
                    > #{_execution_status_output_file}"
                puts execution_status_command
                puts "Executing Step 2 deployment of #{_name} on #{_node_fqdn} with execution_id = #{_execution_id}"
                deploy_stdout, deploy_stderr, deploy_status = Open3.capture3(deploy_command)  
                
                puts "Fetching Step 2 deployment status for #{_name} on #{_node_fqdn} with execution_id = #{_execution_id}"
                execution_status_stdout, execution_status_stderr, execution_status_status = Open3.capture3(execution_status_command)
                execution_status = process_execution_status(_execution_status_output_file)
                deploy_status = process_execution_status(_execution_status_output_file)['deploy_status']
                if deploy_status['status'] == deploy_status_failure
                    puts "Execution of Deployment Step 2 for execution ID #{_execution_id} failed. Check output available at #{_execution_status_output_file} for details."
                    # puts "Latest log entry for Puppet Agent on #{_node_fqdn} was: #{deploy_status['logs'].last}"
                    break
                end
                _current_output = {
                    "execution_id" => _execution_id,
                    "component" => _name,
                    "node" => _node_fqdn,
                    "deploy_step_2_puppet_status" => deploy_status['puppet_status'],
                    "log_file" => _execution_status_output_file
                }
                _output << _current_output

                ## Save output files for pre_deploy_step_2
                log_location = "#{log_dir}/#{_execution_id}/#{timestamp}"
                File.open("#{log_location}/puppet_deploy_step_2.log", 'w') { |file|
                    file.write(execution_status['puppet_deploy_step_2'])
                }
                execution_status['pre_init'].each do |filename, data|
                    File.open("#{log_location}/#{filename}", "w") { |file|
                        file.write(data)
                    }
                end
                File.open("#{log_location}/init.log", 'w') { |file|
                    file.write(execution_status['init'])
                }
                execution_status['post_init'].each do |filename, data|
                    File.open("#{log_location}/#{filename}", "w") { |file|
                        file.write(data)
                    }
                end
            end
        end

        File.open(_overall_deployment_status_file_name,"w") { |file|
            file.write _output.to_yaml
        }

        File.open(stage_config_file,"w") { |file|
            file.write stage_final
        }
        

        _output.to_yaml
    end
end

if __FILE__ == $0
    DeployMaster.run
end