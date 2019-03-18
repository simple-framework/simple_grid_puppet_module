define simple_grid::ccm_function::exec_repository_lifecycle_event(
  $event,
  $current_lightweight_component,
  $execution_id,
  $meta_info,
)
{
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
    class{"simple_grid::component::component_repository::lifecycle::event::init":
      current_lightweight_component => $current_lightweight_component,
      execution_id => $execution_id, 
    }
  }
}
