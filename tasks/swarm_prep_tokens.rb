#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: false

require 'json'
require 'open3'
require 'puppet'
require 'yaml'

def swarm_prep_tokens(main_manager, file)
  manager_token = swarm_token(main_manager, "manager")
  worker_token = swarm_token(main_manager, "worker")
  token_hash = {
      "worker"  => worker_token,
      "manager" => manager_token
  }
  swarm_data = YAML.load(File.read(file))
  swarm_data["tokens"] = token_hash
  File.open(file, 'w') { |f|
    f.write(swarm_data.to_yaml)
  }
end

def swarm_token(main_manager,node_role)
    cmd_string = 'docker swarm join-token -q'
    cmd_string << " #{node_role}" unless node_role.nil?
    bolt_cmd = "bolt command run '#{cmd_string}' --targets #{main_manager}"
    stdout, stderr, status = Open3.capture3(bolt_cmd)
    raise Puppet::Error, "stderr: '#{stderr}'" if status != 0
    lines = stdout.split("\n")
    lines.each_with_index do |line, index|
        if line.include? "STDOUT"
            return lines[index + 1 ].strip
        end
    end
end

params = JSON.parse(STDIN.read)
file = params['swarm_status_file']
main_manager = params['main_manager']
begin
  result = swarm_prep_tokens(main_manager, file)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end