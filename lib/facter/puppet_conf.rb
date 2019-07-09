Facter.add('puppet_conf') do
  setcode do
    begin
      _output = String.new
      File.open("/etc/puppetlabs/puppet/puppet.conf", 'r') do |f|
        f.each_line do |line|
          _output << line.gsub("\n", "") << "; "
        end
      end
      _output
    rescue Exception => ex
      ex.class
    end
  end
end