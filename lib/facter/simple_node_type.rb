Facter.add('simple_node_type') do
    setcode do
        begin
            _output = String.new
            # if puppetserver is present and running, config_master
            File.open("/etc/simple_grid/.node_type", 'r') do |f|
                _output = f.read()
            end
            _output
        rescue => exception
          exception.class  
        end
    end
end