#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'yaml'
require_relative "../../ruby_task_helper/files/task_helper.rb"

# This task runs on CM node
class DeployStatus <TaskHelper

    def task(deploy_status_file:nil, execution_id:nil, **kwargs)
        deploy_status_file_hash = YAML.load(File.read(deploy_status_file))
        deploy_statuses = deploy_status_file_hash['deploy_status']
        current_deploy_status = Hash.new
        deploy_statuses.each do |deploy_status|
            if deploy_status['execution_id'].to_i == execution_id.to_i 
                current_deploy_status = deploy_status
                break
            end
        end
        current_deploy_status.to_yaml
    end
end

if __FILE__ == $0
    DeployStatus.run
end
