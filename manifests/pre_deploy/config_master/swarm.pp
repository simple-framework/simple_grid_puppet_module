
class simple_grid::pre_deploy::config_master::swarm(
  $site_level_config_dir = lookup('simple_grid::config::config_master::pre_deploy::site_level_config_dir'),
  $site_level_config_file = lookup('simple_grid::config::config_master::pre_deploy::site_level_config_file'),
){
  notify{"Running Stage: Docker Swarm":}

$output_site_infrastructure =  simple_grid::site_config_parser("$site_level_config_dir/$site_level_config_file","site_infrastructure")
$output_lightweight_components =  simple_grid::site_config_parser("$site_level_config_dir/$site_level_config_file","lightweight_components")

#notify {"result Site infrastructure: ${$output_site_infrastructure}":}
#notify {"result Lightweight Components ${$output_lightweight_components}":}

 $output_lightweight_components.each |Integer $index, Hash $value| {
   if $value['type'] == 'compute_element' {
   #$node = $value['node']
      $value['nodes'].each |$key, $nodes|{
           $node=$nodes['node']
           #notify{"AAAAAAAAAAAAAAA $node":}
            $output_site_infrastructure.each |Integer $index, Hash $value|{
                 if $value[hostname] == $node{
                      $ip_ce = $value[ip_address]
                      notify{"CE IP Address ${ip_ce}":}
                       exec{"swarm init for $ip_ce":
                            command => "bolt task run docker::swarm_init --node $ip_ce",
                            path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
                            user    => 'root',
                      }
                      exec{"generate swarm token on $ip_ce":
                            command => "bolt task run docker::swarm_token node_role=worker --nodes $ip_ce > /tmp/$ip_ce.txt",
                            path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
                            user    => 'root',
                      }
                 } 
             }
          }
     }
  }
  $output_lightweight_components.each |Integer $index, Hash $value| {
   if $value['type'] == 'worker_node' {
   #$node = $value['node']
      $value['nodes'].each |$key, $nodes|{
           $node=$nodes['node']
           #notify{"AAAAAAAAAAAAAAA $node":}
            $output_site_infrastructure.each |Integer $index, Hash $value|{
              if $value[hostname] == $node{
                  $ip_wn = $value[ip_address]
                  notify{"WN IP Address ${ip_wn}":}
                      exec{"swarm join for $ip":
                      command => "bolt task run docker::swarm_init --node $ip_ce",
                      path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
                      user    => 'root',
                       }
              }
             }
       }
     }
  }
  
/*  
  
  #swarm_init
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
