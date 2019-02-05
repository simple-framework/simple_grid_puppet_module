class simple_grid::components::component_repository::deploy(
  $execution_id,  
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $deploy_status_file = lookup('simple_grid::nodes::lightweight_component::deploy_status_file'),
  $component_repository_dir = lookup('simple_grid::nodes::lightweight_component::component_repository_dir'),
  $meta_info_prefix = lookup('simple_grid::components::site_level_config_file::objects:meta_info_prefix')
){
  $data = loadyaml($augmented_site_level_config_file)
  $current_lightweight_component = simple_grid::get_lightweight_component($augmented_site_level_config_file, $execution_id)
  $repository_name = $current_lightweight_component['name']
  $meta_info_parent = "${meta_info_prefix}${downcase($repository_name)}"
  $meta_info = $data["${meta_info_parent}"]
  $repository_path = "${component_repository_dir}/${repository_name}"
  notify{"Deploying execution_id ${execution_id} with name ${repository_path} now!!!!":}      
  $firewall_rules = $meta_info['host_requirements']['firewall']

  $firewall_rules.each |Integer $index, Hash $firewall_rule| {
    firewall { "${index} SIMPLE Framework Firewall rule for ${repository_name} container with execution id ${execution_id}":
      dport  => "${firewall_rule[ports]}",
      action => "${firewall_rule[action]}",
      proto  => "${firewall_rule[protocol]}",
    }
  }

  $cvmfs = strip("${meta_info['host_requirements']['cvmfs']}")
  notify{"CVFMS Needed: $cvmfs":}
  if $cvmfs == "true" {
    notify{"CVMFS time!!*********":}
      class {"simple_grid::components::component_repository::cvmfs::install":}
      class {"simple_grid::components::cvmfs::configure":}
  }

}

class simple_grid::components::component_repository::cvmfs::install
{
  notify {"Installing CVMFS module":}

    exec {'Installing Simple Grid Puppet Module from Puppet Forge ':
      command => "puppet module install CERNOps-cvmfs --version '6.1.0' --environment ${env_name}",
      path    => "/usr/local/bin/:/usr/bin/:/bin/::/opt/puppetlabs/bin/",
    }

}
class simple_grid::components::component_repository::cvmfs::configure
{
  notify {"Configuring CVMFS module":}
    class{'::cvmfs':
      mount_method          => 'mount',
      cvmfs_http_proxy      => 'http://cvmfs.cat.cbpf.br:3128',
      cvmfs_quota_limit     => 40000,
      cvmfs_timeout         =>  15,
      cvmfs_timeout_direct  => 15,
      cvmfs_mount_rw        => yes,
      }
    cvmfs::mount{'cms.cern.ch': 
      cvmfs_server_url  => 'cms.cern.ch',
    }
    cvmfs::mount{'lhcb.cern.ch':
      cvmfs_server_url  => 'lhcb.cern.ch',
    }
    cvmfs::mount{'alice.cern.ch':
     cvmfs_server_url  => 'alice.cern.ch',
    }
    cvmfs::mount{'lhcb-condb.cern.ch':
      cvmfs_server_url  => 'lhcb-condb.cern.ch',
    }
}


