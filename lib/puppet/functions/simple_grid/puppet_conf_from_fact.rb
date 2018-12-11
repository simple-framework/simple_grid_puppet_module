Puppet::Functions.create_function(:'simple_grid::puppet_conf_from_fact') do
    dispatch :puppet_conf_from_fact do
        param 'String', :puppetfile_content
    end
    def puppet_conf_from_fact(puppetfile_content)
        _output_array = puppetfile_content.split(";")
        _data = Hash.new
        _output_array.each do |line|
            if line.include? "["
                section_key = line.strip
                _data.update(section_key => {})
            # elsif line.include? "="
            #     split_data = line.split('=')
            #     key = split_data[0].strip
            #     value = split_data[1].strip
            #     _data[section_key].update(key => value)
            end
        end
        _data
    end
end