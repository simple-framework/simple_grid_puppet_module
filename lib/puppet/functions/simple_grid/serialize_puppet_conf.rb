Puppet::Functions.create_function(:'simple_grid::serialize_puppet_conf') do
    dispatch :serialize_puppet_conf do
        param 'Hash', :puppetfile_content
    end
    def serialize_puppet_conf(puppetfile_content)
        _output = String.new
        puppetfile_content.each do |section, section_content| 
            _output << section << "\n"
            section_content.each do |key, value|
                _output << key << " = " << value << "\n" 
            end
        end
        _output
    end
end