class simple_grid::ccm_function::prep_host(
  $current_lightweight_component,
  $meta_info
){

  $firewall_rules = $meta_info['host_requirements']['firewall']
  class{"simple_grid::ccm_function::prep_host::firewall::config":
    firewall_rules  => $firewall_rules,
    repository_name => $current_lightweight_component['name']
  }

  $cvmfs = strip("${meta_info['host_requirements']['cvmfs']}")
  if $cvmfs == "true" {
    class {"simple_grid::ccm_function::prep_host::cvmfs::configure":}
  }
  
}
class simple_grid::ccm_function::prep_host::firewall::config(
  $firewall_rules,
  $repository_name,
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
