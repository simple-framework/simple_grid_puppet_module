class simple_grid::pre_deploy::lightweight_component::rollback(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $host_certificates_dir = lookup('simple_grid::host_certificates_dir'),
  $host_certificates_dir_name = lookup('simple_grid::host_certificates_dir_name'),
  $lifecycle_callbacks_dir_name = lookup('simple_grid::scripts_dir_name'),
  $simple_config_dir = lookup('simple_grid::simple_config_dir'),
  $component_repository_dir = lookup('simple_grid::nodes::lightweight_component::component_repository_dir'),
  $swarm_status_file = lookup('simple_grid::components::swarm::status_file'),
  $simple_log_dir = lookup('simple_grid::simple_log_dir')
){

  file{"Removing augmented site level configuration file from LC":
    ensure => absent,
    force  => true,
    path   => "${augmented_site_level_config_file}",
  }

  file{'Removing swarm status file, if present':
    ensure => absent,
    force  => true,
    path   => "${swarm_status_file}",
  }
  
  $copy_host_certificates = simple_grid::check_presence_host_certificates($host_certificates_dir, $fqdn)
  notify{"Were host certificates copied for this node at ${copy_host_certificates}?":}
  if $copy_host_certificates {
    file{"Removing host copy_host_certificates from ${host_certificates_dir}":
        ensure => absent,
        force  => true,
        path => "${host_certificates_dir}",
    }  
  }
  
  file{"Removing directory for lifecycle callback scripts":
   ensure => absent,
   force  => true,
   path => "${simple_config_dir}/${lifecycle_callbacks_dir_name}"
  }
  tidy {"Removing log dir":
    rmdirs => true,
    path   => "${simple_log_dir}",
    recurse => true,
    matches => "*"
  }
  
  file{"Creating log directories":
   ensure => directory,
   force  => true,
   path => "${simple_log_dir}"
  }

  file{"Removing directory for component repositories":
    ensure => absent,
    force  => true,
    path   => "${component_repository_dir}",
  }

  #### TODO: Remove deploy status file?? ####

  simple_grid::components::execution_stage_manager::set_stage {"Setting stage to pre_deploy_step_1":
    simple_stage => lookup('simple_grid::stage::pre_deploy::step_1')
  }
}
