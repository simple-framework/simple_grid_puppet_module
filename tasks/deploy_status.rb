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
    def send_probe(node_fqdn, deploy_status_file, execution_id, modulepath)
        send_probe = "bolt task run simple_grid::deploy_probe deploy_status_file=#{deploy_status_file} execution_id=#{execution_id} --modulepath=#{modulepath} --nodes #{node_fqdn}"
        stdout, stderr, status = Open3.capture3(send_probe)
        raise Puppet::Error, ("stderr: '#{stderr}'") if status !=0
        puts "Output",stdout
        stdout.strip
    end
    def task(node_fqdn:nil, deploy_status_file:nil, execution_id:nil, retry_interval:nil, max_retries:nil, modulepath:nil, **kwargs)
        retry_interval = retry_interval.to_i #10
        max_retries = max_retries.to_i #6
        trial = 0
        result = send_probe(node_fqdn, deploy_status_file, execution_id, modulepath)
        while result['status'] == "pending" and trial <= max_retries do 
            result = send_probe(node_fqdn, deploy_status_file, execution_id, modulepath)
            trial = trial + 1
            sleep(retry_interval)
        end
        if trial == max_retries
            return {status: "timeout", logs: result['logs']}
        end
        # result !=pending
        trial = 0
        if result['status'] == "deploying"
            begin
                result = send_probe(node_fqdn, deploy_status_file, execution_id, modulepath)
            rescue => exception
                puts exception.message
            end until result['status'] == "error" or result['status'] == "completed"
        end
        if result == "error" or result == "completed"
            return result
        end
    end
end

if __FILE__ == $0
    DeployStatus.run
end
