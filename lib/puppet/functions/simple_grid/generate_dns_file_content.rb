require 'yaml'
require 'ipaddr'
Puppet::Functions.create_function(:'simple_grid::generate_dns_file_content') do
    dispatch :generate_dns_file_content do
        param 'String', :augmented_site_level_config_file
        param 'String', :subnet
        param 'String', :meta_info_prefix
        param 'String', :dns_key
    end
    def generate_dns_file_content(augmented_site_level_config_file, subnet, meta_info_prefix, dns_key)
        dns_content = Array.new
        net = IPAddr.new subnet
        ip_range = net.to_range.to_a
        ip_offset = 1
        ip_index = 10
        data = YAML.load_file(augmented_site_level_config_file)
        if data.key?('dns')
            return ''
        end
        lightweight_components = data['lightweight_components']
        lightweight_components.each do |lightweight_component|
            name = lightweight_component['name']
            meta_info_parent = generate_meta_info_parent_name(meta_info_prefix,name)
            meta_info = data[meta_info_parent]
            container_type = meta_info['type']
            host_fqdn = lightweight_component['deploy']['node']
            host_ip =  get_host_ip(data['site_infrastructure'],host_fqdn)
            ip_address = ip_range[ip_index]
            ip_index=ip_index+1
            execution_id = lightweight_component['execution_id']
            fqdn = host_fqdn.split('.')
            hostname = fqdn[0]
            domain = fqdn[1, fqdn.length].join('.')
            if meta_info['docker_run_parameters'].key?("hostname")
                container_fqdn = meta_info['docker_run_parameters']['hostname'] 
            else
                container_fqdn = [name, hostname, execution_id].join("_") + ".#{domain}"
            end    
            dns_content << {"container_fqdn" => "#{container_fqdn}", "host_fqdn" => host_fqdn, "host_ip" => host_ip,'container_ip' => ip_address.to_s, 'type' => container_type, 'execution_id' => execution_id}
        end
        dns_content.to_yaml.lines.to_a[1..-1].join
    end

    def get_host_ip(site_infrastructure, host_fqdn)
        site_infrastructure.each do |node|
            if node['fqdn'] == host_fqdn
                return node['ip_address']
            end
        end
    end

    def generate_meta_info_parent_name(meta_info_prefix, component_name)
        meta_info_prefix + component_name.downcase
    end
end
