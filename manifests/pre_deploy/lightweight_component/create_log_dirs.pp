class simple_grid::pre_deploy::lightweight_component::create_log_dirs(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
){
  $execution_id_master_id_pairs = simple_grid::get_execution_ids($augmented_site_level_config_file, $fqdn)
  $execution_id_master_id_pairs.each |Integer $index, Hash $execution_id_master_id_pair| {
    file{"Create log_dir for execution id ${execution_id_master_id_pair['execution_id']}":
      ensure  => directory,
      recurse => 'remote',
      path    => "${simple_log_dir}/${execution_id_master_id_pair['execution_id']}",
      mode    => "0766"
    }
  }
}
