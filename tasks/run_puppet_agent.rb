#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'open3'
require 'puppet'
require_relative "../../ruby_task_helper/files/task_helper.rb"

# This task is run on the LC node. 
class RunPuppetAgent < TaskHelper
    def puppet_agent_command(ipv4_address, hostname)
        puppet_agent = "puppet agent -t > /puppet_agent_tmp"
        # puppet_agent = "echo $PATH"
        stdout, stderr, status = Open3.capture3(puppet_agent)
        if status !=0
            raise Puppet::Error, ("stderr: '#{stderr}'") 
            puts "YOYO Status is #{status}"
        end
        stdout
    end
    def task(ipv4_address:nil, hostname:nil, **kwargs)
        result = puppet_agent_command(ipv4_address, hostname)
        {status: result}
    end
end

if __FILE__ == $0
    RunPuppetAgent.run
end