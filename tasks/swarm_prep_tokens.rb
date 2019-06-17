#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: false

require 'json'
require 'open3'
require 'puppet'
require 'yaml'

def swarm_prep_tokens(file)
  manager_token = swarm_token("manager")
  worker_token = swarm_token("worker")
  token_hash = {
      "worker"  => worker_token,
      "manager" => manager_token
  }
  swarm_data = YAML.load(File.read(file))
  swarm_data["tokens"] => token_hash
  File.open(file, 'w') { |f|
    f.write(swarm_data.to_yaml)
  }
end

def swarm_token(node_role)
  
    cmd_string = 'docker swarm join-token -q'
    cmd_string << " #{node_role}" unless node_role.nil?
  
    stdout, stderr, status = Open3.capture3(cmd_string)
    raise Puppet::Error, "stderr: '#{stderr}'" if status != 0
    stdout.strip
  end
params = JSON.parse(STDIN.read)
file = params['swarm_status_file']
begin
  result = swarm_prep_tokens(file)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end