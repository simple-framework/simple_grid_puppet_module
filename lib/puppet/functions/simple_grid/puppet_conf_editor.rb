Puppet::Functions.create_function(:'simple_grid::puppet_conf_editor') do
    dispatch :edit_puppet_conf do
        param 'Hash', :puppetfile_data
        param 'Hash', :data
    end
    def edit_puppet_conf(puppetfile_data, data)
        data.each do |section_name, key_value|
            _section_name = "[" + section_name + "]"
            if !(puppetfile_data.keys.include? _section_name)
                puppetfile_data.update(_section_name => Hash.new)
            end
            key_value.each do |key, value|
                puppetfile_data[_section_name].update(key => value)
            end   
        end 
        puppetfile_data
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