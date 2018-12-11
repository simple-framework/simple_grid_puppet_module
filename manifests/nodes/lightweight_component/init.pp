class simple_grid::nodes::lightweight_component::init(
  $node
){
  class {"simple_grid::components::ccm::config":
    node_type => "LC"
  }
}
