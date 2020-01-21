#!/opt/puppetlabs/puppet/bin/ruby
require 'yaml'
require 'open3'
require 'json'
require_relative "../../ruby_task_helper/files/task_helper.rb"

class Deploy < TaskHelper
        # Get all ip addresses
        def get_element_ip(site_level_config_file_path, element)
        ip = Array.new
        data = YAML::load_file(site_level_config_file_path)
        site_infrastructure = data["site_infrastructure"]
        lightweight_components = data["lightweight_components"]
        lightweight_components.each do |lc|
                if lc["type"] == element then
                site_infrastructure.each do |node|
                        if node['fqdn'] == lc['deploy']['node']
                        ip << node["ip_address"]
                        end
                end
                end
        end
        return ip
        end
        def swarm_leave_managers(main_manager, network, ingress_network_name, modulepath)
                puts "Removing main manager on #{main_manager}"
                get_cmd = "bolt task run simple_grid::swarm_leave force=true --nodes #{main_manager} --modulepath #{modulepath}" 
                stdout, stderr, status = Open3.capture3(get_cmd)
                puts get_cmd
                if !status.success?
                        raise "Failed to leave swarm manager: #{stderr}"
                end
                puts "Removing substitute ingress network on #{main_manager}"
                rm_cmd = "bolt command run 'docker network rm #{ingress_network_name}' --nodes #{main_manager} --modulepath #{modulepath}" 
                stdout, stderr, status = Open3.capture3(rm_cmd)
                puts rm_cmd
                if !status.success?
                        raise "Failed to remove #{ingress_network_name} network on #{main_manager}: #{stderr}"
                end
        end
        # Generate, extract token and join docker swarm
        def swarm_leave_workers(wn_ip, modulepath)
                wn_ip.each do |wip|
                        puts  "***"
                        leave_cmd = "bolt task run simple_grid::swarm_leave force=true --nodes #{wip} --modulepath #{modulepath}"
                        puts leave_cmd
                        puts  "***"
                        stdout, stderr, status = Open3.capture3(leave_cmd)
                        if status.success?
                                puts stdout
                        else
                                puts stderr
                        end
                end
        end
        def get_managers_and_workers(augmented_site_level_config_file)
                data = YAML::load_file(augmented_site_level_config_file)
                lightweight_components = data['lightweight_components']
                site_infrastructure = data['site_infrastructure']
                swarm_manager_ip = String.new
                swarm_worker_ip_array = Array.new
                lightweight_components.each do |lightweight_component|
                        node_fqdn = lightweight_component['deploy']['node']
                        site_infrastructure.each do |infrastructure|
                                if infrastructure['fqdn'] == node_fqdn
                                        if lightweight_component['execution_id'] == 0
                                                swarm_manager_ip = infrastructure['ip_address']
                                        else
                                                unless swarm_worker_ip_array.include? infrastructure['ip_address']
                                                        swarm_worker_ip_array << infrastructure['ip_address']
                                                end
                                        end
                                end
                        end
                end
                return swarm_manager_ip, swarm_worker_ip_array   
        end
        def task(augmented_site_level_config_file:nil, network:nil, subnet:nil, ingress_network_name:nil, modulepath:nil, **kwargs)
                swarm_manager_ip, swarm_worker_ip_array = get_managers_and_workers(augmented_site_level_config_file)
                swarm_leave_workers(swarm_worker_ip_array, modulepath)
                swarm_leave_managers(swarm_manager_ip, network, ingress_network_name, modulepath)
                
                puts "#########################"
                puts "Removed swarm manager on #{swarm_manager_ip}"
                puts "Removed swarm workers on the following nodes:"
                puts swarm_worker_ip_array
                puts "#########################"
                {status: 'success'}
        end
end
                
if __FILE__ == $0
        Deploy.run
end

