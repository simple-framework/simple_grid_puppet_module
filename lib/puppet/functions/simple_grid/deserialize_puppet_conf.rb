Puppet::Functions.create_function(:'simple_grid::deserialize_puppet_conf') do
    dispatch :deserialize_puppet_conf do
        param 'String', :puppetfile
    end
    def deserialize_puppet_conf(puppetfile)
        _data = Hash.new
        section_key = ""
        File.open(puppetfile, "r").each do |line|
            if line.include? "["
                section_key = line.strip
                _data.update(section_key => {})
            elsif line.include? "="
                split_data = line.split('=')
                key = split_data[0].strip
                value = split_data[1].strip
                _data[section_key].update(key => value)
            end
        end
        _data
    end
end