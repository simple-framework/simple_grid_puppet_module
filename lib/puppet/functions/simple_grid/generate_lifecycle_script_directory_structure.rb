require 'yaml'
Puppet::Functions.create_function(:'simple_grid::generate_lifecycle_script_directory_structure') do
        dispatch :get_lifecycle_scripts do
                param 'String', :site_level_config_file_path
        end
        def get_lifecycle_scripts(site_level_config_file_path)
                lightweight_components = Hash.new
                exec_id = Hash.new
                data = YAML.load_file(site_level_config_file_path)
                lightweight_components = data["lightweight_components"]
                lightweight_components.each do |key, lc|
                        exec_id.store(key["execution_id"],key["lifecycle_hooks"])
                end
                return exec_id
        end
end