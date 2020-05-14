#!/opt/puppetlabs/puppet/bin/ruby
require 'yaml'
require 'open3'
require 'json'
require_relative "../../ruby_task_helper/files/task_helper.rb"

class Deploy < TaskHelper
        def swarm_leave(member_ips, modulepath)
                member_ips.each do |wip|
                        puts  "***"
                        leave_cmd = "bolt task run simple_grid::swarm_leave force=true --targets #{wip} --modulepath #{modulepath}"
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
        def get_swarm_members(augmented_site_level_config_file)
                data = YAML::load_file(augmented_site_level_config_file)
                lightweight_components = data['lightweight_components']
                site_infrastructure = data['site_infrastructure']
                swarm_member_ip_array = Array.new
                lightweight_components.each do |lightweight_component|
                        node_fqdn = lightweight_component['deploy']['node']
                        site_infrastructure.each do |infrastructure|
                                if infrastructure['fqdn'] == node_fqdn
                                        unless swarm_member_ip_array.include? infrastructure['ip_address']
                                        swarm_member_ip_array << infrastructure['ip_address']
                                        end        
                                end
                        end
                end
                return swarm_member_ip_array   
        end
        def task(augmented_site_level_config_file:nil, network:nil, subnet:nil, ingress_network_name:nil, modulepath:nil, **kwargs)
                swarm_members = get_swarm_members(augmented_site_level_config_file)
                swarm_leave(swarm_members, modulepath)
                
                puts "#########################"
                puts "Removed docker swarm on the following nodes:"
                puts swarm_members
                puts "#########################"
                {status: 'success'}
        end
end
                
if __FILE__ == $0
        Deploy.run
end

