#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'yaml'
require_relative "../../ruby_task_helper/files/task_helper.rb"

class DeployStatus <TaskHelper
    def get_last_successful_deployment()
        deploy_status_file = "/etc/simple_grid/.deploy_status.yaml"
        deploy_status = YAML.load(File.read(deploy_status_file))
        last_successful_deployment = deploy_status['execution_completed'][0]
        return last_successful_deployment
    end
    def task(execution_id:nil, **kwargs)
        result = false
        retry_interval = 10
        max_retries = 1
        trial = 0
        begin
            last_successful_deployment = get_last_successful_deployment()
            result = (execution_id.to_i == last_successful_deployment)
            sleep(retry_interval)
            trial += 1
        end until result == false or trial <= max_retries 
        {status: result}
    end
end

if __FILE__ == $0
    DeployStatus.run
end
