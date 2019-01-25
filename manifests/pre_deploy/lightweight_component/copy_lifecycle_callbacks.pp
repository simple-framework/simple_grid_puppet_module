class simple_grid::pre_deploy::lightweight_component::copy_lifecycle_callbacks(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $lifecycle_callbacks_dir_name = lookup('simple_grid::scripts_dir_name'),
  $simple_config_dir = lookup('simple_grid::simple_config_dir')
){
  $execution_ids = simple_grid::get_execution_ids($augmented_site_level_config_file, $fqdn)
  file{"Creating directory for lifecycle callback scripts":
   ensure => "directory",
   path => "${simple_config_dir}/${lifecycle_callbacks_dir_name}"
  }
  notify{"Copying Lifecycle Callbacks for $execution_ids on $fqdn":}
  $execution_ids.each |Integer $index, Integer $execution_id| {
    file{"Copying lifecycle callback scripts for execution id ${execution_id}":
      ensure => directory,
      recurse => 'remote',
      source => "puppet:///simple_grid/${lifecycle_callbacks_dir_name}/${execution_id}",
      path => "${simple_config_dir}/${lifecycle_callbacks_dir_name}/${execution_id}",
      mode => "0766"
    }
  }
}
