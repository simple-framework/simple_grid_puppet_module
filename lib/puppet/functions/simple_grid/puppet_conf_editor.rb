Puppet::Functions.create_function(:'simple_grid::puppet_conf_editor') do
    dispatch :edit_puppet_conf do
        param 'String', :puppetfile
        param 'String', :section
        param 'String', :key
        param 'String', :value
    end
    def edit_puppet_conf(puppetfile, section, key, value)
        _data = deserialize(puppetfile)     
        if _data.keys.include? "[master]"
            _data.fetch("[master]").update(node_terminus => "execyolo")
        end 

        if _data.keys.include? "[agent]"
        end

        _data.include? " [master]"
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
    def serialize(puppetfile)
    end
end