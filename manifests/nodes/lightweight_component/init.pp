class simple_grid::nodes::lightweight_component::init(
  $node
){
  notify{"Running on node $node":}
    exec{'Install modules in the deploy environment':
      command => "whoami > /temp_data",
      cwd     => "/",
      path    => "/usr/local/bin/:/usr/bin/:/bin/",
    }
  class {"simple_grid::components::ccm::config":
    node_type => "LC" 
  }
}
