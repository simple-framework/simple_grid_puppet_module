Facter.add('execution_pending') do
    setcode do
      begin
        data = YAML.load(File.read("/etc/simple_grid/.deploy_status.yaml")) #try lookup
        execution_pending = []
        data['deploy_status'].each do |deploy_status|
          if deploy_status['status'] == 'pending'
            execution_pending << deploy_status['execution_id']
          end
        end
        execution_pending.join(',')
      rescue Exception => ex
        ex.message
      end
    end
end