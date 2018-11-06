class simple_grid::pre_orchestration{
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
  #$output = generate("/bin/bash", "/test.sh") #"cert", "list", "-a" ) #simple_grid::node_parser()  
  #notify{"OUTPUT is : $output":}
  #$output.each|Integer $index, String $value| {
  #    $node = $value
  #    notify{"$node}":}
  #  }
    #notify {"result: ${nodes}":}
}
