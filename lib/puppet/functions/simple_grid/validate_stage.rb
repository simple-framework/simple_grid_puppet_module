require 'open3'
# Function cannot be used since puppet needs root access to run bolt
Puppet::Functions.create_function(:'simple_grid::validate_stage') do
    dispatch :validate_stage do
        param 'String', :expected_stage
        param 'String', :augmented_site_level_config_file
        param 'String', :site_infrastructure_key
        param 'String', :modulepath
    end
    def extract_output(stdout)
        copy_data = false
        data = []
        stdout.split("\n").each do |line|
            if copy_data == false and line.strip.include? 'Finished on' then
                copy_data = true
                next
            end
            if copy_data and line.strip.length >1
                data << line.strip
            end
        end
        data = data[0,data.length - 2]
        data_string = data.join(' ').to_yaml
        data_obj = YAML.load(data_string)
    end
    def validate_stage(augmented_site_level_config_file, site_infrastructure_key, expected_stage, modulepath)
        check_stage_task = "bolt task run simple_grid::check_stage augmented_site_level_config_file=#{augmented_site_level_config_file} site_infrastructure_key=#{site_infrastructure_key} expected_stage=#{expected_stage} --modulepath=#{modulepath} -t localhost"
        stdout, stderr, status = Open3.capture3(check_stage_task)
        # output = extract_output(stdout)
        return stdout
    end
end
