Puppet::Functions.create_function(:'simple_grid::puppet_conf_editor') do
    dispatch :edit_puppet_conf do
        param 'String', :puppetfile
        param 'String', :section
        param 'String', :key
        param 'String', :value
    end
    def edit_puppet_conf(puppetfile, section, key, value)
        _data = deserialize(puppetfile)
        _section_name = "[" + section + "]"
        _output = "False"
        if !(_data.keys.include? _section_name)
            _data.update(_section_name => Hash.new)
        end
        _data[_section_name].update( key => value)
        serialize(puppetfile, _data)
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
    def serialize(puppetfile, data)
        _output = String.new
        data.each do |section, section_content| 
            _output << section << "\n"
            section_content.each do |key, value|
                _output << key << " = " << value << "\n" 
            end
        end
        File.open(puppetfile, "w") {|file| file.write(_output)}
        _output
    end
end