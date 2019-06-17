class simple_grid::ccm_function::config_orchestrator(
  $augmented_site_level_config_file = lookup("simple_grid::components::yaml_compiler::output"),
  $preferred_tech_stack_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack"),
  $container_orchestration_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration"),
  $swarm_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::swarm"),
  $kubernetes_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::kuberentes"),
  $default_orchestrator = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::default"),
  $cm_node_type = "config_master",
  $lc_node_type = "lightweight_component"
){
  $container_orchestrator = ""
  if has_key($augmented_site_level_config_file, $preferred_tech_stack_key){
    $preferred_tech_stack = $augmented_site_level_config_file[$preferred_tech_stack_key]
    if has_key($preferred_tech_stack, $container_orchestration_key){
      $container_orchestrator = $preferred_tech_stack[$container_orchestrator]
    }
  }
  if length($container_orchestrator) <1 {
    $container_orchestrator  = $default_orchestrator
  }
  if $container_orchestrator == $swarm_key {
    if $facts['simple_node_type'] == "config_master" {

    }elseif $facts['simple_node_type'] == "lightweight_component"{

    }
  }
  elseif $container_orchestrator == $kuberentes_key {
    fail("Oops!!! Kubernetes is not supported by the version of SIMPLE. Try using Docker Swarm instead.")
  }
}
