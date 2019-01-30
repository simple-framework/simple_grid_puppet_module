require 'yaml'
Puppet::Functions.create_function(:'simple_grid::get_lightweight_component') do
    dispatch :get_lightweight_component do
        param 'String', :augmented_site_level_config_file
        param 'Integer', :execution_id
    end
    def get_lightweight_component(augmented_site_level_config_file, execution_id)
        data = YAML.load(File.read(augmented_site_level_config_file))
        lightweight_components = data['lightweight_components']
        current_lightweight_component = Hash.new
        lightweight_components.each do |lightweight_component|
            if lightweight_component['execution_id'].to_i == execution_id.to_i
                current_lightweight_component = lightweight_component
                break
            end
        end
        current_lightweight_component
    end
end