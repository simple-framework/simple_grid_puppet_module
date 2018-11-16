
class simple_grid::config::config_master::swarm(
){
  notify{"Running Stage: Docker Swarm":}
# Get nodes hostname and ip address
$output =  simple_grid::nodes_list()
  notify {"result: ${$output}":}
  $output.each |Integer $index, String $value| {
    notify{"${$index} = ${value}":}
  }


docker::swarm {'cluster_manager':
  init           => true,
  advertise_addr => '192.168.1.1',
  listen_addr    => '192.168.1.1',
}

docker::swarm {'cluster_worker':
join           => true,
advertise_addr => '192.168.1.2',
listen_addr    => '192.168.1.2,
manager_ip     => '192.168.1.1',
token          => 'your_join_token'
}
}
