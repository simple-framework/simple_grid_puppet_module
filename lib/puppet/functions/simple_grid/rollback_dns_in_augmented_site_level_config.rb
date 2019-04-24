require 'yaml'

Puppet::Functions.create_function(:'simple_grid::rollback_dns_in_augmented_site_level_config') do
    dispatch :rollback_dns_in_augmented_site_level_config do
        param 'String', :augmented_site_level_config_file
        param 'String', :dns_key
    end
    def rollback_dns_in_augmented_site_level_config(augmented_site_level_config_file, dns_key)
        data = YAML.load_file(augmented_site_level_config_file)
        if !data.key?(dns_key)
            return augmented_site_level_config.to_yaml()
        end
        data.delete_if {|key, value| key == dns_key}
        data.to_yaml()
    end
end
