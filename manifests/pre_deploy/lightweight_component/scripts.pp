class simple_grid::pre_deploy::lightweight_component::scripts::generate_script_dir(
  $scripts_dir = lookup('simple_grid::scripts_dir'),
  $wrapper_dir = lookup('simple_grid::scripts::wrapper_dir'),
){
  file{'Creating directory for scripts':
    ensure => directory,
    path   => $scripts_dir
  }->
  file{'Create directory for wrapper scripts':
    ensure => directory,
    path   => $wrapper_dir
  }
}

class simple_grid::pre_deploy::lightweight_component::scripts::generate_script_wrappers(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $wrapper_dir = lookup('simple_grid::scripts::wrapper_dir'),
  $retry_command_wrapper = lookup('simple_grid::scripts::wrapper::retry'),
  $lifecycle_wrapper = lookup('simple_grid::scripts::wrapper::lifecycle'),
){
  file { "Generate ${retry_command_wrapper}.sh":
    ensure  => 'present',
    path    => "${wrapper_dir}/${retry_command_wrapper}",
    mode    => '0555',
    content => epp("simple_grid/${retry_command_wrapper}")
  }
  file { "Generate ${lifecycle_wrapper}":
    ensure  => 'present',
    path    => "${wrapper_dir}/${lifecycle_wrapper}",
    mode    => '0555',
    content => epp("simple_grid/${retry_command_wrapper}")
  }
}

class simple_grid::pre_deploy::lightweight_component::scripts::copy_lifecycle_callbacks(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $scripts_dir = lookup('simple_grid::scripts_dir'),
){
  $execution_id_master_id_pairs = simple_grid::get_execution_ids($augmented_site_level_config_file, $fqdn)
  notify{"Copying Lifecycle Callbacks on ${fqdn}":}
  $execution_id_master_id_pairs.each |Integer $index, Hash $execution_id_master_id_pair| {
    file{"Copying lifecycle callback scripts for execution id ${execution_id_master_id_pair['execution_id']}":
      ensure  => directory,
      recurse => 'remote',
      source  => "puppet:///simple_grid/${scripts_dir}/${execution_id_master_id_pair['id']}",
      path    => "${scripts_dir}/${execution_id_master_id_pair['execution_id']}",
      mode    => '0766'
    }
  }
}
