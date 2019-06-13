class simple_grid::components::swarm::configure(
){}
class simple_grid::components::swarm::configure::network($dns_file = lookup('simple_grid::components::ccm::container_orchestrator::swarm::dns'),
  $dns_parent_name = lookup('simple_grid::components::site_level_config_file::objects:dns_parent'),
  $meta_info_prefix = lookup('simple_grid::components::site_level_config_file::objects:meta_info_prefix'),
  $mode = lookup('simple_grid::mode'),
  $subnet = lookup('simple_grid::components::ccm::container_orchestrator::swarm::subnet'),
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $network = lookup('simple_grid::components::ccm::container_orchestrator::swarm::network'),
){
  if $mode == lookup('simple_grid::mode::docker') or $mode == lookup('simple_grid::mode::dev') {
    exec{"Set up docker swarm on the entire cluster":
      command => "bolt task run simple_grid::swarm augmented_site_level_config_file=${augmented_site_level_config_file} network=${network} subnet=${subnet} modulepath=/etc/puppetlabs/code/environments/simple/modules:/etc/puppetlabs/code/environments/simple/site --modulepath /etc/puppetlabs/code/environments/simple/site/ --nodes localhost > /etc/simple_grid/.swarm_status",
      path    => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
      user    => 'root',
      logoutput => true,
      environment => ["HOME=/root"]
    }
  }
    elsif $mode == lookup('simple_grid::mode::release') {
      exec{"Set up docker swarm on the entire cluster":
        command => "bolt task run simple_grid::swarm augmented_site_level_config_file=${augmented_site_level_config_file} network=${network} subnet=${subnet} modulepath=/etc/puppetlabs/code/environments/simple/modules:/etc/puppetlabs/code/environments/simple/site --modulepath /etc/puppetlabs/code/environments/simple/site/ --nodes localhost > /etc/simple_grid/.swarm_status",
        path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
        user    => 'root',
        logoutput => true,
      }
    }
    $dns_file_content = simple_grid::generate_dns_file_content($augmented_site_level_config_file, $subnet, $meta_info_prefix, $dns_parent_name)
    if length($dns_file_content) > 1 {
      notify{"Writing DNS data to ${dns_file}":}
      file{"Creating DNS data file":
        ensure => present,
        path => "${dns_file}",
        content => "${dns_file_content}",
      }
      notify{"Appending DNS data to ${augmented_site_level_config_file}":}
      file{"${augmented_site_level_config_file}":
        ensure => present,
        content => epp('simple_grid/dns_augmented_site_level_config_file.yaml', {'augmented_site_level_config' => file($augmented_site_level_config_file), 'dns_parent_name' => $dns_parent_name,'dns_file_content' => $dns_file_content})
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
