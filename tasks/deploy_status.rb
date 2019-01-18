#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'yaml'
require_relative "../../ruby_task_helper/files/task_helper.rb"
require 'open3'

# This task runs on CM node
# Probe is run on LC node as a bolt task and the stdout is generated on CM node. 
# The probe scans the deploy_status.yaml file on LC. It goes to the entry of given execution_id and reads value of status parameter. 
# If status is pending, it keeps monitoring the status until max_retries. If timeout happens, the message is forwarded to the CM, which should restart the deploy task.
# If status is executing, it keeps monitoring until status changes to Error or Completed
# If status is error or completed, the message is forwarded to CM which does appropriate handling.
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
