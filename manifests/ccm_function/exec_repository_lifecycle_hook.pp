define simple_grid::ccm_function::exec_repository_lifecycle_hook(
  $hook,
  $current_lightweight_component,
  $execution_id,
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $simple_grid_scripts_dir = lookup('simple_grid::scripts_dir')
){
  $augmented_site_level_config = loadyaml("${augmented_site_level_config_file}")
  $all_dns_info = $augmented_site_level_config['dns']
  $scripts_dir_structure = simple_grid::generate_lifecycle_script_directory_structure($augmented_site_level_config_file, $simple_grid_scripts_dir)
  $scripts_dir_structure.each |Integer $exec_id, Hash $dir_struct| {
    if $exec_id == $execution_id {
      $scripts = $dir_struct["${hook}"]
      if $hook == lookup('simple_grid::components::component_repository::lifecycle::hook::pre_config') {
        class{"simple_grid::component::component_repository::lifecycle::hook::pre_config":
          scripts => $scripts
        }
      }
      elsif $hook == lookup('simple_grid::components::component_repository::lifecycle::hook::pre_init') {          
        $all_dns_info.each |Hash $dns_info| {
          if $dns_info['execution_id'] == $execution_id { 
            class{"simple_grid::component::component_repository::lifecycle::hook::pre_init":
              scripts => $scripts,
              current_lightweight_component => $current_lightweight_component,
              execution_id => $execution_id,
              container_name => $dns_info['container_fqdn']
            }
          }
        }
      }
      elsif $hook == lookup('simple_grid::components::component_repository::lifecycle::hook::post_init') {
        $all_dns_info.each |Hash $dns_info| {
          if $dns_info['execution_id'] == $execution_id{
            class{"simple_grid::component::component_repository::lifecycle::hook::post_init":
              scripts => $scripts,
              current_lightweight_component => $current_lightweight_component,
              execution_id => $execution_id,
              container_name => $dns_info['container_fqdn']
            }
          }
        }
      }  
    }
  }
}
