Facter.add('execution_completed') do
    setcode do
      begin
        data = YAML.load(File.read("/etc/simple_grid/.deploy_status.yaml"))
        execution_completed = []
        data['deploy_status'].each do |deploy_status| 
          if deploy_status['status'] == "completed"
            execution_completed << deploy_status['execution_id']
          end
        end
        execution_completed.join(',')
      rescue Exception => ex
        ex.message
      end
    end
  end