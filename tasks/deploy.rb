#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'open3'
require 'puppet'

def init_deploy(execution_id)
    puppet_apply = "puppet apply -e \"class{'simple_grid::deploy::lightweight_component::init':execution_id =>#{execution_id}}\" > /etc/simple_grid/.deploy.log"
    stdout, stderr, status = Open3.capture3(puppet_apply)
    raise Puppet::Error, ("stderr: '#{stderr}'") if status !=0
    puts "Output",stdout
    stdout.strip
end

params = JSON.parse(STDIN.read)
execution_id = params['execution_id']
begin
    result = init_deploy(execution_id)
    puts result
    exit 0
rescue Puppet::Error => e
    puts({status: 'failure', error: e.message})
    exit 1
end
