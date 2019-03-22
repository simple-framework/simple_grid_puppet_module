class simple_grid::ccm_function::prep_host(
  $current_lightweight_component,
  $meta_info,
){
  if has_key($meta_info, 'host_requirements'){
    if has_key($meta_info['host_requirements'], 'firewall'){
      $firewall_rules = $meta_info['host_requirements']['firewall']
      class{"simple_grid::ccm_function::prep_host::firewall::config":
        firewall_rules  => $firewall_rules,
        repository_name => $current_lightweight_component['name'],
        execution_id    => $current_lightweight_component['execution_id']
      }
    }
  }

  if has_key($meta_info, 'host_requirements'){
    if has_key($meta_info['host_requirements'], 'cvmfs'){
      $cvmfs = strip("${meta_info['host_requirements']['cvmfs']}")
      if $cvmfs == "true" {
        class {"simple_grid::ccm_function::prep_host::cvmfs::configure":}
      }
    }
  }

  if has_key($meta_info, 'host_requirements'){
    if has_key($meta_info['host_requirements'], 'host_certificates'){
      if $meta_info['host_requirements']['host_certificates'] == true {
        class{"simple_grid::ccm_function::prep_host::host_certificates::copy_to_repository":
          current_lightweight_component => $current_lightweight_component
        }
      }
    }
  }

  class{"simple_grid::ccm_function::prep_host::augmented_site_level_config_file::copy_to_repository":
    current_lightweight_component => $current_lightweight_component
  }
  
}
class simple_grid::ccm_function::prep_host::firewall::config(
  $firewall_rules,
  $repository_name,
  $execution_id,
){
  notify{"Configuring Firewall Rules":}
  $firewall_rules.each |Integer $index, Hash $firewall_rule| {
    firewall { "${index} SIMPLE Framework Firewall rule for ${repository_name} container with execution id ${execution_id}":
      dport  => "${firewall_rule[ports]}",
      action => "${firewall_rule[action]}",
      proto  => "${firewall_rule[protocol]}",
    }
  }
}

class simple_grid::ccm_function::prep_host::cvmfs::configure
{
  notify {"Configuring CVMFS module":}
    file{"/cvmfs":
      ensure => directory
    }
    # class{'::cvmfs':
    #   mount_method          => 'mount',
    #   cvmfs_http_proxy      => 'http://cvmfs.cat.cbpf.br:3128',
    #   cvmfs_quota_limit     => 40000,
    #   cvmfs_timeout         =>  15,
    #   cvmfs_timeout_direct  => 15,
    #   cvmfs_mount_rw        => yes,
    #   }
    # cvmfs::mount{'cms.cern.ch': 
    #   cvmfs_server_url  => 'cms.cern.ch',
    # }
    # cvmfs::mount{'lhcb.cern.ch':
    #   cvmfs_server_url  => 'lhcb.cern.ch',
    # }
    # cvmfs::mount{'alice.cern.ch':
    #  cvmfs_server_url  => 'alice.cern.ch',
    # }
    # cvmfs::mount{'lhcb-condb.cern.ch':
    #   cvmfs_server_url  => 'lhcb-condb.cern.ch',
    # }
}

class simple_grid::ccm_function::prep_host::host_certificates::copy_to_repository(
  $current_lightweight_component,
  $component_repository_dir = lookup('simple_grid::nodes::lightweight_component::component_repository_dir'),
  $host_certificates_master_dir = lookup("simple_grid::host_certificates_dir"),
  $repository_host_certificates_relative_dir = lookup('simple_grid::components::component_repository::relative_host_certificates_dir')
){
  $repository_name = $current_lightweight_component['name']
  $execution_id = $current_lightweight_component['execution_id']
  $repository_path = "${component_repository_dir}/${repository_name}_${execution_id}"
  $host_certificates_target_dir = "${repository_path}/${repository_host_certificates_relative_dir}"
  file{"Copy host certificates from ${host_certificates_master_dir} to ${host_certificates_target_dir}":
    ensure => directory,
    path   => "${host_certificates_target_dir}",
    source => "${host_certificates_master_dir}",
    recurse => true
  }
}

class simple_grid::ccm_function::prep_host::augmented_site_level_config_file::copy_to_repository(
  $current_lightweight_component,
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $component_repository_dir = lookup('simple_grid::nodes::lightweight_component::component_repository_dir'),
  $repository_relative_augmented_site_level_config_file = lookup('simple_grid::components::component_repository::relative_augmented_site_level_config_file')
){
  $repository_name = $current_lightweight_component['name']
  $execution_id = $current_lightweight_component['execution_id']
  $repository_path = "${component_repository_dir}/${repository_name}_${execution_id}"
  file{"Copying augmented_site_level_config_file to repository root":
    ensure => present,
    source => $augmented_site_level_config_file,
    path   => "${repository_path}/${repository_relative_augmented_site_level_config_file}",
  }
}
