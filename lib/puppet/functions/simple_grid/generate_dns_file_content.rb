require 'yaml'
require 'psych'
require 'ipaddr'
require_relative 'get_level_2_configurator.rb'

Puppet::Functions.create_function(:'simple_grid::generate_dns_file_content') do
    dispatch :generate_dns_file_content do
        param 'String', :augmented_site_level_config_file
        param 'String', :subnet
        param 'String', :meta_info_prefix
        param 'String', :dns_key
        optional_param 'Boolean', :generate_unique_hosts
    end
    def generate_dns_file_content(augmented_site_level_config_file, subnet, meta_info_prefix, dns_key, generate_unique_hosts=false)
        dns_content = Array.new
        final_dns_content = Array.new
        final_fqdn_content = Array.new
        net = IPAddr.new subnet
        ip_range = net.to_range.to_a
        ip_offset = 1
        ip_index = 10
        data = YAML.load_file(augmented_site_level_config_file)
        dns_pre_exists = data.key?(dns_key)
        if dns_pre_exists
            dns_content = YAML.load(data[dns_key].to_yaml)
            # return {
            #     "dns_pre_exists" => true,
            #     "string"         => data[dns_key],
            #     "hash"           => YAML.load(data[dns_key].to_yaml)
            # }
        else
            lightweight_components = data['lightweight_components']
            lightweight_components.each do |lightweight_component|
                name = lightweight_component['name']
                meta_info_parent = generate_meta_info_parent_name(meta_info_prefix,name)
                meta_info = data[meta_info_parent]
                container_type = meta_info['type']
                host_fqdn = lightweight_component['deploy']['node']
                host_ip =  get_host_ip(data['site_infrastructure'],host_fqdn)
                level_2_configurator = simple_get_level_2_configurator(augmented_site_level_config_file, lightweight_component)
                ip_address = ip_range[ip_index]
                ip_index=ip_index+1
                execution_id = lightweight_component['execution_id']
                fqdn = host_fqdn.split('.')
                hostname = fqdn[0]
                domain = fqdn[1, fqdn.length].join('.')
                if meta_info['level_2_configurators']["#{level_2_configurator}"]['docker_run_parameters'].key?("hostname")
                    container_fqdn = meta_info['level_2_configurators']["#{level_2_configurator}"]['docker_run_parameters']['hostname'] 
                else
                    container_fqdn = [name, hostname, execution_id].join("_") + ".#{domain}"
                end
                dns_entry = {"container_fqdn" => "#{container_fqdn}", "host_fqdn" => host_fqdn, "host_ip" => host_ip,'container_ip' => ip_address.to_s, 'type' => container_type, 'execution_id' => execution_id}
                dns_content << dns_entry
            end
        end
        if generate_unique_hosts
            dns_content.each do |dns|
                if not final_fqdn_content.include? dns['host_fqdn']
                    final_dns_content << dns
                    final_fqdn_content << dns['host_fqdn']
                end
            end
        else
            final_dns_content = dns_content
        end
        { "string"         => final_dns_content.to_yaml.lines.to_a[1..-1].join, 
          "hash"           => final_dns_content,
          "dns_pre_exists" => dns_pre_exists
        }
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
