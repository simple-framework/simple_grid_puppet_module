require 'yaml'
Puppet::Functions.create_function(:'simple_grid::init_swarm_status_file_content') do 
    dispatch :init_swarm_status_file_content do
        param 'Array'  , :dns
    end
    def init_swarm_status_file_content(dns)
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