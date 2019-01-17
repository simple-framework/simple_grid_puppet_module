class simple_grid::pre_deploy::lightweight_component::copy_lifecycle_callbacks(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output')
){
  $execution_ids = simple_grid::get_execution_ids($augmented_site_level_config_file, $fqdn)
  notify{"Copying Lifecycle Callbacks for $execution_ids on $fqdn":}
  class{"simple_grid::ccm_function::copy":
    message => "",
    source => "",
    destination => "",
    mode => ""
  }
}
