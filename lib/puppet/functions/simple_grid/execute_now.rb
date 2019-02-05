require 'yaml'
Puppet::Functions.create_function(:'simple_grid::execute_now') do
    dispatch :execute_now do 
        param 'String', :deploy_status_file
        param 'Integer', :execution_id
        param 'String', :initial_deploy_status
    end
    def execute_now(deploy_status_file, execution_id, initial_deploy_status)
        execute_now_bool = false
        data = YAML.load(File.read(deploy_status_file))
        deploy_statuses = data['deploy_status']
        execution_pending = []
        deploy_statuses.each do |deploy_status|
            if deploy_status['status'] == initial_deploy_status
                execution_pending << deploy_status['execution_id']
            end
        end
        execution_pending = execution_pending.sort
        if execution_pending.empty? 
            execute_now_bool = false
        elsif execution_pending[0] == execution_id
            execute_now_bool =  true
        end    
        execute_now_bool
    end
end
