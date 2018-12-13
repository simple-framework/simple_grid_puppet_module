Facter.add('execution_pending') do
    setcode do
      begin
        data = YAML.load(File.read("/etc/simple_grid/.deploy_status.yaml"))
        data['execution_pending'].join(',')
      rescue Exception => ex
        "uninitialized"
      end
    end
  end