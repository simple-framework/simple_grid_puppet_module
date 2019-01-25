require 'yaml'
Puppet::Functions.create_function(:'simple_grid::post_execution_deploy_status') do
    dispatch :post_execution_deploy_status do
        param 'String', :deploy_status_file
        param 'Integer', :execution_id
    end
    def post_execution_deploy_status(deploy_status_file, exeuction_id)
        new_deploy_status = {}
        data = YAML.load(File.read(deploy_status_file)) 
        data['execution_request_history'] << execution_id
        data['deploy_status'].each do |deploy_status|
            if deploy_status['execution_id'].to_i == execution_id.ro_i
                deploy_status['status'] = ''
            end 
        end
        execution_pending = data['execution_pending']
        if execution_pending.empty?
            return data
        elsif execution_pending[0].to_i != execution_id
            raise Exception "Execution ID's do not match"
        end
        execution_completed = data['execution_completed']
        executed = execution_pending.shift
        execution_completed.unshift executed
        new_deploy_status.update( 'execution_pending'   => execution_pending)
        new_deploy_status.update( 'execution_completed' => execution_completed)
        new_deploy_status
    end
end
