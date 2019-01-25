require 'yaml'
Puppet::Functions.create_function(:'simple_grid::process_deploy_status') do
    dispatch :process_deploy_status do
        param 'String', :execution_status_file
    end
    def process_deploy_status(execution_status_file)
        copy_data = false
        data = File.read(execution_status_file)
        yaml_data = Array.new
        data.each_line do |line|
            if copy_data
                yaml_data << line
            end
            if line.include? "---"
                copy_data = true
            end
        end
        yaml_data = yaml_data[0,yaml_data.length - 4]
        File.open(execution_status_file + ".yaml", 'w') do |file|
            file.puts yaml_data
        end
        deploy_status = YAML.load_file(execution_status_file + ".yaml")
        return deploy_status
    end
end
