# Run command 
# puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e "class {'simple_grid::install::lightweight_component::simple_installer':puppet_master => 'basic_config_master.cern.ch'}"

class simple_grid::install::lightweight_component::simple_installer(
  $puppet_master,
  $simple_node_type_file = lookup('simple_grid::node_type:file'),
  $node_type = lookup('simple_grid::node_type:lightweight_component'),
  $docker_version = lookup('simple_grid::components::docker::version'),
)
{
  notify{'Creating SIMPLE config directory':}
  class {'simple_grid::ccm_function::create_config_dir':}

  notify{"Setting node type":}
  file{"${simple_node_type_file}":
    ensure  => present,
    content => "${node_type}"
  }

  class{"simple_grid::components::ccm::installation_helper::init_agent":
    puppet_master => "${puppet_master}",
  }

  notify{'Installing Docker':}
  class {'docker':
        version => $docker_version
  }

  notify {"Installing Git":}
  include 'git'

  simple_grid::components::execution_stage_manager::set_stage {'Setting stage to install':
      simple_stage => lookup('simple_grid::stage::install')
  }
}
