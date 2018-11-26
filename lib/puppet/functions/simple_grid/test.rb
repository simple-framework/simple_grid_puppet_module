
        return_value = Array.new
        tokenfiles = Dir.entries('/tmp/ce/').reject { |f| File.directory?(f) }
        tokenfiles.each { |file| 
        file = "/tmp/ce/" + file
        puts file
        #puts IO.readlines(file)[2]
        return_value << IO.readlines(file)[2]
        }
        puts return_value
