class simple_grid::ccm_function::exec_repository_lifecycle_hook(
  $hook,
  $current_lightweight_component,
  $execution_id,
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
){
  $scripts_dir_structure = simple_grid::generate_lifecycle_script_directory_structure("${augmented_site_level_config_file}")
  $scripts_dir_structure.each |Integer $exec_id, Hash $dir_struct| {
    if $exec_id == $execution_id {
      $scripts = $dir_struct["${hook}"]
      $dir_struct.each |String $lifecycle_hook, Array $scripts|{
        if $lifecycle_hook == $hook {
          if $hook == lookup('simple_grid::components::component_repository::lifecycle::hook::pre_config') {
            class{"simple_grid::component::component_repository::lifecycle::hook::pre_config":
              scripts => $scripts
            }
          }
          elsif $hook == lookup('simple_grid::components::component_repository::lifecycle::hook::pre_init') {
            class{"simple_grid::component::component_repository::lifecycle::hook::pre_init":}
          }
          elsif $hook == lookup('simple_grid::components::component_repository::lifecycle::hook::post_init') {
            class{"simple_grid::component::component_repository::lifecycle::hook::post_init":}
          }
        }
      }
    }
  }
}
