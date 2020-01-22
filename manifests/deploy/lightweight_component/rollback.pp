class simple_grid::deploy::lightweight_component::rollback(
  $execution_id,
  $remove_images = false,
  $augmented_site_level_config_file = lookup("simple_grid::components::yaml_compiler::output"),
  $deploy_status_file = lookup("simple_grid::nodes::lightweight_component::deploy_status_file")
){
  notify{"Rollback Deploy stage for execution_id ${execution_id}":}
  class{'simple_grid::components::component_repository::rollback':
    execution_id  => $execution_id,
    remove_images => $remove_images
  }~>
  class{'simple_grid::components::ccm::installation_helper::reset_agent':}
}
