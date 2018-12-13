Facter.add('execution_completed') do
    setcode do
      begin
        data = YAML.load(File.read("/etc/simple_grid/.deploy_status.yaml"))
        data['execution_completed'].join(',')
      rescue Exception => ex
        "uninitialized"
      end
    end
  end