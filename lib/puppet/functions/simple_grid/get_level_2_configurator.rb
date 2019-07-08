require 'yaml'
def simple_get_level_2_configurator(augmented_site_level_config, current_lightweight_component)
    level_2_configurator = "DEFAULT"
        if current_lightweight_component.key?('preferred_tech_stack')
            if current_lightweight_component['preferred_tech_stack'].key?('level_2_configuration')
                level_2_configurator = current_lightweight_component["preferred_tech_stack"]["level_2_configuration"]
            end
        else
            if augmented_site_level_config.key?('preferred_tech_stack')
                if augmented_site_level_config['preferred_tech_stack'].key?('level_2_configuration')
                    level_2_configurator = augmented_site_level_config['preferred_tech_stack']['level_2_configuration']
                end
            end
        end
        return level_2_configurator
end
Puppet::Functions.create_function(:'simple_grid::get_level_2_configurator') do
    dispatch :get_level_2_configurator do
        param 'Hash', :augmented_site_level_config
        param 'Hash', :current_lightweight_component
    end
    def get_level_2_configurator(augmented_site_level_config, current_lightweight_component)
        level_2_configurator = "DEFAULT"
        if current_lightweight_component.key?('preferred_tech_stack')
            if current_lightweight_component['preferred_tech_stack'].key?('level_2_configuration')
                level_2_configurator = current_lightweight_component["preferred_tech_stack"]["level_2_configuration"]
            end
        else
            if augmented_site_level_config.key?('preferred_tech_stack')
                if augmented_site_level_config['preferred_tech_stack'].key?('level_2_configuration')
                    level_2_configurator = augmented_site_level_config['preferred_tech_stack']['level_2_configuration']
                end
            end
        end
        return level_2_configurator
    end
end