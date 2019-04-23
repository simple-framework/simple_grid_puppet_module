require 'yaml'
Puppet::Functions.create_function(:'simple_grid::get_execution_ids') do
        dispatch :get_execution_ids do
                param 'String', :augmented_site_level_config_file_path
                param "String", :fqdn
        end
        def get_execution_ids(augmented_site_level_config_file_path, fqdn)
                exec_ids = Array.new
                data = YAML.load_file(augmented_site_level_config_file_path)
                lightweight_components = data["lightweight_components"]
                lightweight_components.each do |lightweight_component, index|
                    if lightweight_component["deploy"]["node"] == fqdn.strip
                        exec_ids << { "execution_id" =>lightweight_component["execution_id"], "id" => lightweight_component['id']}
                    end   
                end
                return exec_ids
        end
end