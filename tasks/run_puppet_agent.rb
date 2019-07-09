#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'
require_relative "../../ruby_task_helper/files/task_helper.rb"

# This task is run on the LC node. 
class RunPuppetAgent < TaskHelper
    def puppet_agent_command(ipv4_address, hostname)
        puppet_agent = "puppet agent -t"
        stdout, stderr, status = Open3.capture3(puppet_agent)    
        if !status.success?
            # TODO exit code is 2 despite a desirable execution. figure out how to handle in future
            # raise Puppet::Error, ("stderr: '#{stderr}'") 
        end
        puts stdout
        status
    end
    def task(ipv4_address:nil, hostname:nil, **kwargs)
        result = puppet_agent_command(ipv4_address, hostname)
        {puppet_agent_exit_status: result}
    end
end

if __FILE__ == $0
    RunPuppetAgent.run
end