#!/opt/puppetlabs/puppet/bin/ruby
require 'yaml'
require 'open3'
require 'json'

site_level_config_file_path = "/etc/simple_grid/simple_grid_site_config/site-level-configuration-file.yaml"
#hostname = Array.new
#ce_ip =  Array.new

# Get Hostname all hostnames
def get_hostname(site_level_config_file_path)
        site_infrastructure = Hash.new
        hostname = Array.new
        data = YAML.load_file(site_level_config_file_path)
        site_infrastructure = data["site_infrastructure"]
        site_infrastructure.each do |site_infra|
                hostname << site_infra["hostname"]
        end
        return hostname
end
# Get only CE ip Address
def get_ce_ip(site_level_config_file_path)
        site_infrastructure = Hash.new
        lightweight_components = Hash.new
        type = Hash.new
        hostname = Array.new
        nodes =Array.new
        node =Array.new
        ip_ce = Array.new
        data = YAML.load_file(site_level_config_file_path)
        site_infrastructure = data["site_infrastructure"]
        lightweight_components = data["lightweight_components"]
        lightweight_components.each do |lc|
                if lc["type"] == "compute_element" then
                      nodes << lc["nodes"]
                      nodes.each do |node_array|
                        node_array.each do |value|
                        site_infrastructure.each do |site_infra|
                          if site_infra["hostname"] ==  value["node"]
                             ip_ce << site_infra["ip_address"]
                          end
                        end
                      end
                end
        end
        end
        return ip_ce
end
# Get all ip addresses
def get_element_ip(site_level_config_file_path, element)
        site_infrastructure = Hash.new
        lightweight_components = Hash.new
        type = Hash.new
        hostname = Array.new
        nodes =Array.new
        node =Array.new
        ip = Array.new
        data = YAML.load_file(site_level_config_file_path)
        site_infrastructure = data["site_infrastructure"]
        lightweight_components = data["lightweight_components"]
        lightweight_components.each do |lc|
                if lc["type"] == element then
                      nodes << lc["nodes"]
                      nodes.each do |node_array|
                        node_array.each do |value|
                        site_infrastructure.each do |site_infra|
                          if site_infra["hostname"] ==  value["node"]
                             ip << site_infra["ip_address"]
                          end
                        end
                      end
                end
        end
        end
        return ip
end
# Init Swarm on CE and create NW simple
def swarm_init(ce_ip)
        ce_ip.each do |ip|
        puts  "** Initializing SWARM on #{ip} **"
        init_cmd = "bolt task run docker::swarm_init --node #{ip} --modulepath /etc/puppetlabs/code/environments/master/modules/"
        puts  "***"
        system init_cmd
        puts  "** Creating SIMPLE Network on #{ip} **"
        nw_cmd = "bolt command run "+"'"+"docker network create --attachable --driver=overlay --subnet=10.0.1.0/24 simple"+ "'" + " --nodes  #{ip}"
        puts  "***"
        system nw_cmd
        end
end
# Generate, extract token and join docker swarm
def swarm_token(ce_ip,wn_ip)
        token = Array.new
        ce_ip.each do |cip|
                puts  "** Generating Token on #{cip} **"
                puts  "***"
                get_cmd = "bolt task run docker::swarm_token node_role=worker --nodes  #{cip} > /tmp/ce/#{cip}"
                system get_cmd
                puts  "** Extracting Token **"
                puts  "***"
                token = IO.readlines("/tmp/ce/#{cip}")[2]
                token = token.delete(' ')
                token = token.chop
                puts token
                puts  "***"
                wn_ip.each do |wip|
                        puts  "***"
                        puts  "** Join Manager:#{cip} Worker:#{wip} with token:#{token} **"
                        join_cmd = "bolt task run docker::swarm_join listen_addr=10.0.1.10  token=#{token}  manager_ip=#{cip}:2377 --nodes #{wip}"
                        puts join_cmd
                        puts  "***"
                        system join_cmd
                        end
        end
end

begin

#hostname = get_hostname(site_level_config_file_path)
ce_ip = get_element_ip(site_level_config_file_path,"compute_element")
wn_ip = get_element_ip(site_level_config_file_path,"worker_node")

swarm_init(ce_ip)
swarm_token(ce_ip,wn_ip) 

rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
