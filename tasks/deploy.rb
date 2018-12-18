#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'

def init_deploy(execution_id)
    puppet_apply = "puppet apply -e \"class{'simple_grid::deploy::lightweight_component::init':execution_id =>#{execution_id}}\""
    system puppet_apply
end

params = JSON.parse(STDIN.read)
execution_id = params['execution_id']
begin
    init_deploy(execution_id)
rescue Exception => e
    puts({status: 'failure', error: e.message, exception: e.message})
    exit 1
end
