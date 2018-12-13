Facter.add('simple_stage') do
    setcode do
      begin
        File.read("/etc/simple_grid/.stage", 'r')
      rescue Exception => ex
        "uninitialized"
      end
    end
  end