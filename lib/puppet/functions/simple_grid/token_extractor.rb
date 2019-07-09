Puppet::Functions.create_function(:'simple_grid::token_extractor') do
    dispatch :parse_param do
    end

     def parse_param()
        return_value = Array.new
        tokenfiles = Dir.entries('/tmp/ce/').reject { |f| File.directory?(f) }
        tokenfiles.each { |file|
                file = "/tmp/ce/" + file
                return_value << IO.readlines(file)[2]
                }
        return_value        
     end
end
