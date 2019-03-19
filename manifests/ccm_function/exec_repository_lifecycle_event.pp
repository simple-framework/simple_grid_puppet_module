define simple_grid::ccm_function::exec_repository_lifecycle_event(
  $event,
  $current_lightweight_component,
  $execution_id,
  $meta_info,
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output')
)
{
  $augmented_site_level_config = loadyaml($augmented_site_level_config_file)
  $all_dns_info = $augmented_site_level_config['dns']
  if $event == lookup('simple_grid::components::component_repository::lifecycle::event::pre_config') {
    class{"simple_grid::component::component_repository::lifecycle::event::pre_config":
      current_lightweight_component => $current_lightweight_component,
      execution_id => $execution_id, 
    }
  }elsif $event == lookup('simple_grid::components::component_repository::lifecycle::event::boot') {
    class{"simple_grid::component::component_repository::lifecycle::event::boot":
      current_lightweight_component => $current_lightweight_component,
      execution_id => $execution_id, 
      meta_info => $meta_info
    }
  }elsif $event == lookup('simple_grid::components::component_repository::lifecycle::event::init') {
    $all_dns_info.each |Hash $dns_info| {
      if $dns_info['execution_id'] == $execution_id {
        class{"simple_grid::component::component_repository::lifecycle::event::init":
          current_lightweight_component => $current_lightweight_component,
          execution_id => $execution_id, 
          container_name => $dns_info['container_fqdn']
        }
      }
    }
  }
}
