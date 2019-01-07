require 'yaml'
Puppet::Functions.create_function(:'simple_grid::generate_deploy_status') do
    dispatch :generate_deploy_status do
        param 'Hash', :content
        param 'String', :fqdn
    end
    def generate_deploy_status(content, fqdn)
        execution_ids = Array.new
        content['lightweight_components'].each do |lc|
            if lc['deploy']['node'] == fqdn 
                data = {
                    "execution_id" => lc['execution_id'],
                    "status"       => "pending",
                    "logs"         => []
                }
                execution_ids << data
            end
        end
        execution_ids 
    end
end
