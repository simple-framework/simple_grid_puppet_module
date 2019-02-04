require 'yaml'
require 'ipaddr'
Puppet::Functions.create_function(:'simple_grid::generate_dns_file_content') do
    dispatch :generate_dns_file_content do
        param 'String', :augmented_site_level_config_file
        param 'String', :subnet
        param 'String', :meta_info_prefix
    end
    def generate_dns_file_content(augmented_site_level_config_file, subnet, meta_info_prefix)
        dns_content = Array.new
        
        net = IPAddr.new subnet
        ip_range = net.to_range.to_a
        ip_offset = 1
        container_names = Array.new
        data = YAML.load_file(augmented_site_level_config_file)
        lightweight_components = data['lightweight_components']
        lightweight_components.each do |lightweight_component|
            name = lightweight_component['name']
            meta_info_parent = generate_meta_info_parent_name(meta_info_prefix,name)
            meta_info = data[meta_info_parent]
            container_name = ""
            if meta_info['docker_run_parameters'].key?("hostname")
                container_names << meta_info['docker_run_parameters']['hostname'] 
            else
                execution_id = lightweight_component['execution_id']
                fqdn = lightweight_component['deploy']['node'].split('.')
                hostname = fqdn[0]
                domain = fqdn[1, fqdn.length].join('.')
                container_count = lightweight_component['deploy']['container_count'].to_i
                for index in 0..container_count
                    container_names << [name, index, hostname, execution_id, domain].join("_")
                end
            end
        end
        container_names.each_with_index do |container_name, index|
            ip_address = ip_range[index+1]
            dns_content << {"#{container_name}" => ip_address.to_s}
        end
        dns_content.to_yaml
    end

    def generate_meta_info_parent_name(meta_info_prefix, component_name)
        meta_info_prefix + component_name.downcase
    end
end
