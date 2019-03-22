Puppet::Functions.create_function(:'simple_grid::get_dns_info') do 
    dispatch :get_dns_info do
        param 'Hash', :augmented_site_level_config
        param 'Integer', :execution_id
    end
    def get_dns_info(augmented_site_level_config, execution_id)
        all_dns_info = augmented_site_level_config['dns']
        all_dns_info.each do |dns_info|
            if dns_info['execution_id'] == execution_id
                return dns_info
            end
        end
    end
end