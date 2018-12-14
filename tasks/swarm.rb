#!/opt/puppetlabs/puppet/bin/ruby
require 'yaml'
require 'open3'
require 'json'

#augmented_site_level_config_file_path = "/etc/simple_grid/site_config/augmented_site_level_config_file.yaml"

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
# Init Swarm on CE and create NW simple
def swarm_init(ce_ip, modulepath)
        puts ce_ip.class
        ce_ip.each_with_index do |ip, index|
                puts ip
                puts  "** Initializing SWARM on #{ip} **"
                init_cmd = "bolt task run docker::swarm_init --node #{ip} --modulepath #{modulepath}"
                puts  "*** index was #{index}"
                system init_cmd
                if index == 0
                        puts  "** Creating SIMPLE Network on #{ip} **"
                        nw_cmd = "bolt command run "+"'"+"docker network create --attachable --driver=overlay --subnet=10.0.1.0/24 simple"+ "'" + " --nodes  #{ip}"
                        puts  "***"
                        system nw_cmd
                end
        end
end
# Generate, extract token and join docker swarm
def swarm_token(ce_ip,wn_ip, modulepath)
        token = Array.new
        ce_ip.each do |cip|
                puts  "** Generating Token on #{cip} **"
                puts  "***"
                get_cmd = "bolt task run docker::swarm_token node_role=worker --nodes #{cip} --modulepath #{modulepath} > /tmp/#{cip}" 
                system get_cmd
                puts  "** Extracting Token **"
                puts  "***"
                token = IO.readlines("/tmp/#{cip}")[2]
                token = token.delete(' ')
                token = token.chop
                puts token
                puts  "***"
                wn_ip.each do |wip|
                        puts  "***"
                        puts  "** Join Manager:#{cip} Worker:#{wip} with token:#{token} **"
                        join_cmd = "bolt task run docker::swarm_join listen_addr=10.0.1.10  token=#{token}  manager_ip=#{cip}:2377 --nodes #{wip} --modulepath #{modulepath}"
                        puts join_cmd
                        puts  "***"
                        system join_cmd
                end
        end
end

params = JSON.parse(STDIN.read)
augmented_site_level_config_file_path = params['augmented_site_level_config_file']
modulepath = params['modulepath']
begin
        ce_ip = get_element_ip(augmented_site_level_config_file_path,"compute_element")
        wn_ip = get_element_ip(augmented_site_level_config_file_path,"worker_node")
        swarm_init(ce_ip, modulepath)
        swarm_token(ce_ip,wn_ip, modulepath) 

rescue Exception => e
  puts({ status: 'failure', error: e.message, exception: e.message })
  exit 1
end
