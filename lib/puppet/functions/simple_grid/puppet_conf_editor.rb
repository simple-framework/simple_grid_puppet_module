Puppet::Functions.create_function(:'simple_grid::puppet_conf_editor') do
    dispatch :edit_puppet_conf do
        param 'String', :puppetfile
        param 'String', :section
        param 'String', :key
        param 'String', :value
        param 'Boolean', :write_file
    end
    def edit_puppet_conf(puppetfile, section, key, value, write_file)
        _data = deserialize(puppetfile)
        _section_name = "[" + section + "]"
        _output = "False"
        if !(_data.keys.include? _section_name)
            _data.update(_section_name => Hash.new)
        end
        _data[_section_name].update( key => value)
        serialize(puppetfile, _data, write_file)
    end

    def deserialize(puppetfile)
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
    def serialize(puppetfile, data, write_file)
        _output = String.new
        data.each do |section, section_content| 
            _output << section << "\n"
            section_content.each do |key, value|
                _output << key << " = " << value << "\n" 
            end
        end
        if write_file == true
            File.open(puppetfile, "w") {|file| file.write(_output)}
        end
        _output
    end
end