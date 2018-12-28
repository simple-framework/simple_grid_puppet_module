require 'yaml'
Puppet::Functions.create_function(:'simple_grid::check_current_execution_id') do
    dispatch :check_current_execution_id do 
        param 'String', :deploy_status_file
        param 'Integer', :execution_id
    end
    def check_current_execution_id(deploy_status_file, execution_id)
        YAML.load(File.read(deploy_status_file)) do |data|
            execution_pending = data['execution_pending']
            if execution_pending.empty? 
                return false
            end
            if execution_pending[0] == execution_id
                return true
            else
                return false
            end
        end
    end
end
