require 'yaml'
Puppet::Functions.create_function(:'simple_grid::generate_execution_ids') do
    dispatch :generate_execution_ids do
        param 'Hash', :content
        param 'String', :fqdn
    end
    def generate_execution_ids(content, fqdn)
        execution_ids = Array.new
        content['lightweight_components'].each do |lc|
            if lc['deploy']['node'] == fqdn 
                execution_ids << lc['execution_id']
            end
        end
        execution_ids 
    end
end
