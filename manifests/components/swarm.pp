class simple_grid::components::swarm::install::generate_dns_info_and_swarm_status(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $subnet = lookup('simple_grid::components::swarm::subnet'),
  $meta_info_prefix = lookup('simple_grid::components::site_level_config_file::objects:meta_info_prefix'),
  $dns_file = lookup('simple_grid::components::swarm::dns'),
  $dns_parent_name = lookup('simple_grid::components::site_level_config_file::objects:dns_parent'),
  $swarm_status_file = lookup('simple_grid::components::swarm::status_file')
){
  $dns_file_content = simple_grid::generate_dns_file_content($augmented_site_level_config_file, $subnet, $meta_info_prefix, $dns_parent_name)
  if length($dns_file_content['string']) > 1 {
    notify{"Writing DNS data to ${dns_file}":}
    file{'Creating DNS data file':
      ensure  => present,
      path    => $dns_file,
      content => $dns_file_content['string'],
    }
    notify{"Appending DNS data to ${augmented_site_level_config_file}":}
    file{"${augmented_site_level_config_file}":
      ensure  => present,
      content => epp('simple_grid/dns_augmented_site_level_config_file.yaml', {'augmented_site_level_config' => file($augmented_site_level_config_file), 'dns_parent_name' => $dns_parent_name,'dns_file_content' => $dns_file_content['string']})
    }
    notify{"${dns_file_content}":}
    $swarm_status_content = simple_grid::init_swarm_status_file_content($dns_file_content['hash'])
    file{'Initializing swarm status file':
      path    => $swarm_status_file,
      ensure  => present,
      content => $swarm_status_content
    }
  }
}

class simple_grid::components::swarm::configure::firewall{
  notify {"Configuring Docker Swarm FW rules":}
  # TCP port 2376 for secure Docker client communication. This port is required for Docker Machine to work. Docker Machine is used to orchestrate Docker hosts.
  # TCP port 2377. This port is used for communication between the nodes of a Docker Swarm or cluster. It only needs to be opened on manager nodes.
  # TCP and UDP port 7946 for communication among nodes (container network discovery).
  # UDP port 4789 for overlay network traffic (container ingress networking).
  firewall {'01 TCP SIMPLE Framework Firewall rule for Docker Swarm':
      dport  => [2376, 2377, 7946],
      action => accept,
      proto  => tcp,
    }
  firewall {'02 UDP SIMPLE Framework Firewall rule for Docker Swarm':
      dport  => [7946, 4789],
      action => accept,
      proto  => udp,
    }
}

#Executes on CM
class simple_grid::components::swarm::init(
  $main_manager,
  $swarm_status_file = lookup('simple_grid::components::swarm::status_file')
){
  $bolt_cmd = "bolt task run docker::swarm_init --nodes ${main_manager}"
  $bolt_token_cmd = "bolt task run simple_grid::swarm_prep_tokens main_manager=${main_manager} swarm_status_file=${swarm_status_file} --nodes localhost"
  exec { 'Initialize Docker Swarm':
    command   => $bolt_cmd,
    user      => 'root',
    logoutput => true,
    path      => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
    environment       => ["HOME=/root"]
  } ~>
  exec { 'Save tokens for Docker Swarm':
    command           => $bolt_token_cmd,
    user              => 'root',
    logoutput         => true,
    path              => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
    environment       => ["HOME=/root"]
  }
}

# Executes on LC
class simple_grid::components::swarm::join(
  $swarm_status_file = lookup("simple_grid::components::swarm::status_file"),
  $modulepath = lookup("simple_grid::components::ccm::install::modules_dir"),
  $token,
  $main_manager
){
  $join_cmd = "docker swarm join --token=${token}  ${main_manager}"
  exec { "Join swarm cluster as ${role}":
    command   => $join_cmd,
    user      => 'root',
    logoutput => true,
    path      => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
  }
}
#Executes on CM
class simple_grid::components::swarm::create_network(
  $main_manager,
  $network = lookup('simple_grid::components::swarm::network'),
  $subnet = lookup('simple_grid::components::swarm::subnet')
){
  $network_cmd = "docker network create --attachable --driver=overlay --subnet=${subnet} ${network}"
  $bolt_cmd    = "bolt command run '${network_cmd}' --node ${main_manager}"
  exec { 'Create Docker Swarm Network':
    command   => $bolt_cmd,
    user      => 'root',
    logoutput => true,
    path      => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
    environment => ['HOME=/root']
  }
}
## TODO DNS info
