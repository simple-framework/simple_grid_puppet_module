#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'yaml'
require_relative "../../ruby_task_helper/files/task_helper.rb"

class DeployProbe < TaskHelper

    def task(deploy_status_file:nil, execution_id:nil, **kwargs)
        deploy_status_hash = YAML.load(File.read(deploy_status_file))
        deploy_statuses = deploy_status_hash['deploy_status']
        deploy_status = deploy_statuses.select {|current_deployment| execution_id == deploy_statuses['execution_id']}
        if deploy_status == nil
            return {status: "error", logs: "Oops! there is an execution_id mismatch. #{execution_id} was not found in #{deploy_status_file}"}
        end
        return {status: deploy_status['status'], logs: deploy_status['logs']}
    end
end

if __FILE__ == $0
    DeployProbe.run
end
