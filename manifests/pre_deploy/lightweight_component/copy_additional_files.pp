class simple_grid::pre_deploy::lightweight_component::copy_additional_files(
  $augmented_site_level_config_file = lookup("simple_grid::components::yaml_compiler::output"),
  $preferred_tech_stack_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack"),
  $container_orchestration_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration"),
  $swarm_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::swarm"),
  $kubernetes_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::kubernetes"),
){
  $augmented_site_level_config = loadyaml($augmented_site_level_config_file)
  if has_key($augmented_site_level_config, $preferred_tech_stack_key){
    $preferred_tech_stack = $augmented_site_level_config[$preferred_tech_stack_key]
    if has_key($preferred_tech_stack, $container_orchestration_key){
      $container_orchestrator = $preferred_tech_stack[$container_orchestration_key]
    }
  }
  if $container_orchestrator == $swarm_key {
    $swarm_status_file_name = lookup('simple_grid::components::swarm::status_file_name')
    $swarm_status_file = lookup('simple_grid::components::swarm::status_file')
    file{'Copy Docker Swarm Status file':
      source => "puppet:///simple_grid/${swarm_status_file_name}",
      path   => $swarm_status_file,
      ensure => present
    }
  }
}
