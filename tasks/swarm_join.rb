#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def swarm_join(advertise_addr, listen_addr, tokenfile, manager_ip)
  cmd_string = "docker swarm join"
  cmd_string << " --advertise-addr=#{advertise_addr}" unless advertise_addr.nil?
  cmd_string << " --listen-addr=#{listen_addr}" unless listen_addr.nil?
  cmd_string << " --tokenfile=#{tokenfile}" unless tokenfile.nil?
  cmd_string << " #{manager_ip}" unless manager_ip.nil?


  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, ("stderr: '#{stderr}'") if status != 0
  stdout.strip
end
params = JSON.parse(STDIN.read)
tokenfile = IO.readlines(params['tokenfile'])[2]
advertise_addr = params['advertise_addr']
listen_addr = params['listen_addr']
manager_ip = params['manager_ip']

begin
  result = swarm_join(advertise_addr, listen_addr, tokenfile, manager_ip)
  puts result
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message })
  exit 1
end
