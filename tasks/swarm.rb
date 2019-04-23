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
        # Init Swarm on CE and create WN simple
        def swarm_init(main_manager, network, subnet, modulepath)
                puts  "** Initializing SWARM on #{main_manager} **"
                init_cmd = "bolt task run docker::swarm_init --node #{main_manager} --modulepath #{modulepath}"
                system init_cmd
                puts  "** Creating SIMPLE Network on #{main_manager} **"
                nw_cmd = "bolt command run "+"'"+"docker network create --attachable --driver=overlay --subnet=#{subnet} #{network}"+ "'" + " --nodes  #{main_manager}"
                puts  "***"
                system nw_cmd

        end
        def swarm_join_managers(main_manager, managers, modulepath)
                puts  "** Generating Token for swarm managers on #{main_manager} **"
                puts  "***"
                get_cmd = "bolt task run simple_grid::swarm_token node_role=manager --nodes #{main_manager} --modulepath #{modulepath}" 
                stdout, stderr, status = Open3.capture3(get_cmd)
                puts  "** Extracting Token **"
                puts  "***"
                puts get_cmd
                if status.success?
                        token = stdout
                        token = token.split("\n")[2].delete(' ')
                        puts token
                        puts  "***"
                else
                        raise "Failed to get token for managers: #{stderr}"
                end
                managers.each do |ip|
                        puts  "***"
                        puts  "** Join as Manager:#{ip} with token:#{token} **"
                        join_cmd = "bolt task run simple_grid::swarm_join token=#{token}  manager_ip=#{main_manager}:2377 --nodes #{ip} --modulepath #{modulepath}"
                        puts join_cmd
                        puts  "***"
                        stdout, stderr, status = Open3.capture3(join_cmd)
                        if status.success?
                                puts stdout
                        else
                                puts stderr
                        end 
                end
        end
        # Generate, extract token and join docker swarm
        def swarm_join_workers(main_manager,wn_ip, modulepath)
                puts  "** Generating Token on #{main_manager} **"
                puts  "***"
                get_cmd = "bolt task run simple_grid::swarm_token node_role=worker --nodes #{main_manager} --modulepath #{modulepath}" 
                stdout, stderr, status = Open3.capture3(get_cmd)
                puts  "** Extracting Token **"
                puts  "***"
                puts get_cmd
                if status.success?
                        token = stdout
                        token = token.split("\n")[2].delete(' ')
                        puts token
                        puts  "***"
                else
                        raise "Failed to get token for worker: #{stderr}"
                end
                wn_ip.each do |wip|
                        puts  "***"
                        puts  "** Join Manager:#{main_manager} Worker:#{wip} with token:#{token} **"
                        join_cmd = "bolt task run simple_grid::swarm_join token=#{token}  manager_ip=#{main_manager}:2377 --nodes #{wip} --modulepath #{modulepath}"
                        puts join_cmd
                        puts  "***"
                        stdout, stderr, status = Open3.capture3(join_cmd)
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
        def task(augmented_site_level_config_file:nil, network:nil, subnet:nil, modulepath:nil, **kwargs)
                swarm_manager_ip, swarm_worker_ip_array = get_managers_and_workers(augmented_site_level_config_file)
                swarm_init(swarm_manager_ip, network, subnet, modulepath)
                swarm_join_workers(swarm_manager_ip, swarm_worker_ip_array, modulepath)
                puts "#########################"
                puts "Setting up swarm manager on #{swarm_manager_ip}"
                puts "Setting up swarm workers on the following nodes:"
                puts swarm_worker_ip_array
                puts "#########################"
                #ce_ip = get_element_ip(augmented_site_level_config_file,"compute_element")
                #main_manager = ce_ip[0]
                #managers = ce_ip.drop(1)
                #wn_ip = get_element_ip(augmented_site_level_config_file,"worker_node")
                #puts "+++++++++++++++++++++++++"
                #puts ce_ip, main_manager, managers.class
                #puts "&&&&&&&&&&&&&&&&&&&&&&&&&"
                #swarm_init(main_manager, network, subnet, modulepath)
                #swarm_join_managers(main_manager, managers,modulepath) 
                #swarm_join_workers(main_manager,wn_ip, modulepath) 
                {status: 'success'}
        end
end
                
if __FILE__ == $0
        Deploy.run
end

