class simple_grid::config::config_master::pre_orchestration{
  notify{"Running Stage: Pre-Orchestrator Conf":}
  file {"Create script file to get list of nodes":
    path    => "/etc/simple_grid/list_nodes.sh",
    mode    => "777",
    owner   => "puppet",
    content => epp('simple_grid/list_nodes.sh.epp',{'output' => '/etc/simple_grid/nodes.list' })
  }~>

  exec {"Get list of nodes":
    command => "/etc/simple_grid/list_nodes.sh",
    cwd     => "/etc/simple_grid",
    path    => ['/usr/bin', '/usr/sbin']
  }
  $output =  simple_grid::nodes_list()
  notify {"result: ${$output}":}
  $output.each |Integer $index, String $value| {
    notify{"${$index} = ${value}":}
  }
  class{"simple_grid::config::config_master::swarm":
  }
  #notify {"result: ${output}":}
  #$output.each|String $line| {
  #    $node = $line
  # }
    #notify {"result: ${nodes}":}
}
