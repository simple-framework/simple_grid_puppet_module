require 'yaml'
require 'open3'
require 'json'
Puppet::Functions.create_function(:'simple_grid::list_module_dependencies') do
        dispatch :list_module_dependencies do
        end
        def list_module_dependencies()
            cmd_string = 'puppet config print modulepath'
            stdout, stderr, status = Open3.capture3(cmd_string)
            file_path = String.new
            if status.success?
                modulepaths = stdout.split ':'
                modulepaths.each do |modulepath|
                    metadata_path = "#{modulepath}/simple_grid/metadata.json"
                    if File.exists? metadata_path
                            file_path = metadata_path
                            break
                    end
                end
                if file_path.empty? 
                    raise StandardError.new "metadata.json for simple_grid_puppet_module not found"
                end
            else
                raise StandardError.new "Could not find modulepath to install dependencies for simple_grid module"
            end
            metadata_json = File.open file_path
            metadata = JSON.load metadata_json
            metadata_json.close
            return metadata["dependencies"]    
        end
end