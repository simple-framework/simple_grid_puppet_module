require 'yaml'
Puppet::Functions.create_function(:'simple_grid::set_execution_status') do
    dispatch :set_execution_status do 
        param 'String', :deploy_status_file
        param 'Integer', :execution_id
        param 'String', :execution_status
    end
    def set_execution_status(deploy_status_file, execution_id, execution_status)
        data = YAML.load(File.read(deploy_status_file))
        deploy_statuses = data['deploy_status']
        deploy_statuses.each do |deploy_status| 
            if deploy_status['execution_id'] == execution_id
                deploy_status['status'] = execution_status
            end
        end
        File.open(deploy_status_file, 'w') do |deploy_status_file|
            deploy_status_file.write data.to_yaml
        end    
    end
end
