require 'yaml'
Puppet::Functions.create_function(:'simple_grid::init_swarm_status_file_content') do 
    dispatch :init_swarm_status_file_content do
        param 'Hash'  , :augmented_site_level_config
        param 'String', :dns_key
    end
    def init_swarm_status_file_content(augmented_site_level_config, dns_key)
        dns = augmented_site_level_config[dns_key]
        no_of_managers = (0.3 * dns.size).ceil
        main_manager = String.new
        managers = Array.new
        dns.each_with_index do |dns_entry, index|
            if dns_entry['execution_id'] == 0
                main_manager = dns_entry['host_fqdn']
                no_of_managers = no_of_managers -1
                next
            end
            if managers.size <= no_of_managers
                unless managers.include? dns_entry['host_fqdn']
                    managers << dns_entry['host_fqdn']
                end
            end
        end
        
        file_content = {
            "main_manager" => main_manager,
            "managers"     => managers
        }
        return file_content.to_yaml
    end
end