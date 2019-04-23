class simple_grid::deploy::lightweight_component::rollback(
  $execution_id,
  $augmented_site_level_config_file = lookup("simple_grid::components::yaml_compiler::output"),
  $deploy_status_file = lookup("simple_grid::nodes::lightweight_component::deploy_status_file")
){
  notify{"Rollback DEPLOY stage for execution_id ${execution_id}":}
  simple_grid::update_execution_request_history($deploy_status_file, $execution_id)
  class{"simple_grid::components::component_repository::rollback":
    execution_id => $execution_id
  }
}
