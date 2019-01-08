require 'yaml'
Puppet::Functions.create_function(:'simple_grid::update_execution_request_history') do
    dispatch :update_execution_request_history do 
        param 'String', :deploy_status_file
        param 'Integer', :execution_id
    end
    def update_execution_request_history(deploy_status_file, execution_id)
        data = YAML.load(File.read(deploy_status_file))
        File.open(deploy_status_file, 'w') { |deploy_status_file|
            data['execution_request_history'] << Time.now.strftime("%d/%m/%Y %H:%M") + " : " + execution_id.to_s
            deploy_statuses = data['deploy_status']
            deploy_statuses.each do |deploy_status| 
                if deploy_status['execution_id'] == execution_id
                    deploy_status['logs'] << Time.now.strftime("%d/%m/%Y %H:%M") + " : Execution request"
                end
            end
            deploy_status_file.write data.to_yaml
        }    
    end    
end
