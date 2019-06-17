class simple_grid::ccm_function::config_orchestrator(
  $augmented_site_level_config_file = lookup("simple_grid::components::yaml_compiler::output"),
  $preferred_tech_stack_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack"),
  $container_orchestration_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration"),
  $swarm_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::swarm"),
  $kubernetes_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::kubernetes"),
  $default_orchestrator = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::default"),
  $cm_node_type = lookup("simple_grid::node_type:config_master"),
  $lc_node_type = lookup("simple_grid::node_type:lightweight_component"),
){
  $container_orchestrator = ""
  if ($augmented_site_level_config_file, $preferred_tech_stack_key) != undef{
    $preferred_tech_stack = $augmented_site_level_config_file[$preferred_tech_stack_key]
    if has_key($preferred_tech_stack, $container_orchestration_key){
      $container_orchestrator = $preferred_tech_stack[$container_orchestrator]
    }
  }
  if length($container_orchestrator) <1 {
    $container_orchestrator  = $default_orchestrator
  }

  # if $container_orchestrator == $swarm_key {
  #   # Setting firewall on all nodes
  #   notify{"Setting FW rules for all Swarm nodes":}
  #   class{"simple_grid::components::swarm::configure::firewall":}

  #   if $facts['simple_node_type'] == $cm_node_type {
  #     class{"simple_grid::components::swarm::configure::network":}
  #     class{"simple_grid::components::swarm::init":} 
  #     class{"simple_grid::components::swarm::create_network":}
  #   }
  #   elseif $facts['simple_node_type'] == $lc_node_type{
  #     class{"simple_grid::components::swarm::join":}
  #   }
  # }
  # elseif $container_orchestrator == $kuberentes_key {
  #   fail("Oops!!! Kubernetes is not supported by the version of SIMPLE. Try using Docker Swarm instead.")
  # }
}
