
class simple_grid::pre_deploy::config_master::swarm(
  $site_level_config_dir = lookup('simple_grid::config::config_master::pre_deploy::site_level_config_dir'),
  $site_level_config_file = lookup('simple_grid::config::config_master::pre_deploy::site_level_config_file')

){
  notify{"Running Stage: Docker Swarm":}

notify{"Test ${site_level_config_dir}/${site_level_config_file}":}

# Get nodes hostname and ip address
$output =  simple_grid::site_config_parser("$site_level_config_dir/$site_level_config_file")
  notify {"result: ${$output}":}
  $output.each |Integer $index, Hash $value| {
      $ip = $value[ip_address]
      notify{"IP address is ${ip}":}
      exec{"swarm init for $ip":
        command => "bolt task run docker::swarm_init --node $ip",
        path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
        user    => 'root',
      }
  }


/*
#swarm_token
bolt task show docker::swarm_init --nodes ce-simple 

#swarm_token
bolt task run docker::swarm_token node_role=worker --nodes ce-simple

#swarm_join
bolt task run docker::swarm_join listen_addr=10.0.1.10  token=SWMTKN-1-28mzroiuuqlmw3xam8npb14wqyrh9er82qjmyw5rr1rccw9gzq-ba098vsi6w4vfmxen6kn5r53b manager_ip=188.184.29.186:2377 --nodes puppetclient

docker_network { 'simple':
  ensure   => present,
  driver   => 'overlay',
  subnet   => '10.0.1.0/24',
  gateway  => '10.0.1.1',
  ip_range => '10.0.1.4/32',
}
*/
}
