#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'yaml'
require 'fileutils'
require_relative "../../ruby_task_helper/files/task_helper.rb"

class CheckStage < TaskHelper
    def extract_stage(bolt_output)
        found_index = 0
        lines = bolt_output.split("\n")
        lines.each_with_index do |line, index|
            if line.strip == "STDOUT:"
                found_index = index + 1
                break
            end
        end
        return lines[found_index].strip()
    end
    def task(augmented_site_level_config_file:nil, site_infrastructure_key:nil, **kwargs)
        output = {}
        augmented_site_level_config = YAML.load_file(augmented_site_level_config_file)
        site_infrastructure = augmented_site_level_config[site_infrastructure_key]
        site_infrastructure.each do |node|
            fqdn = node['fqdn']
            bolt_cmd = "bolt command run 'cat /etc/simple_grid/.stage' -t #{fqdn}"
            stdout, stderr, status = Open3.capture3(bolt_cmd)
            if status.success?
                output[fqdn] = extract_stage(stdout)
            end
        end
        return output
    end
end

if __FILE__ == $0
    CheckStage.run
end