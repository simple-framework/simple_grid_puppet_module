require 'yaml'
Puppet::Functions.create_function(:'simple_grid::generate_lifecycle_script_directory_structure') do
        dispatch :get_lifecycle_scripts_dir_structure do
                param 'String', :site_level_config_file_path
                param 'String', :scripts_dir
        end
        def get_lifecycle_scripts_dir_structure(site_level_config_file_path, scripts_dir)
                scripts_dir_structure = Hash.new
                data = YAML.load_file(site_level_config_file_path)
                lightweight_components = data["lightweight_components"]
                lightweight_components.each do |lightweight_component|
                        all_original_scripts = lightweight_component["lifecycle_hooks"]
                        modified_hooks = Hash.new
                        all_original_scripts.each do |lifecycle_hook, original_scripts|
                                modified_hook = Array.new
                                original_scripts.each do |original_script|
                                        actual_script = "#{scripts_dir}/#{lightweight_component['execution_id']}/#{original_script.split('/')[-1]}"
                                        modified_hook << {"original_script" => original_script, "actual_script" => actual_script}
                                end
                                modified_hooks.store(lifecycle_hook, modified_hook)
                        end
                        scripts_dir_hash = {"source"=> lightweight_component["lifecycle_hooks"]}
                        scripts_dir_structure.store(lightweight_component["execution_id"],modified_hooks)
                end
                return scripts_dir_structure
        end
end