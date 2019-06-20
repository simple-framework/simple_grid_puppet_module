# Execution command
# puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e 'class{"simple_grid::install::config_master::simple_installer":}'

class simple_grid::install::config_master::simple_installer(
  $simple_node_type_file = lookup('simple_grid::node_type:file'),
  $node_type = lookup("simple_grid::node_type:config_master"),
){

  notify{"Creating simple config directory":}
  include 'simple_grid::ccm_function::create_config_dir'

  notify{"Setting node type via file ${simple_node_type_file}":}
  file{"${simple_node_type_file}":
    ensure  => present,
    content => "${node_type}"
  }

  notify{"***** Stage:Install; Node: CM *****":}

  notify {"Installing Git":}
  include 'git'

  notify{"Installing Docker":}
  class{"docker":
      version => '18.09.2'
  }
  notify{"Installing Puppet CCM":}
  class {"simple_grid::components::ccm::install":}

  notify{"Installation Stage has ended":}

  notify{"Configuring CCM on Config Master":}
  class{"simple_grid::components::ccm::config":
    node_type => "CM"
  }

  notify{"Installing Bolt on Config Master":}
  class{"simple_grid::components::bolt::install":}

  # Config stage
  class{"simple_grid::config::config_master::init":}

  notify{"Configuration Stage has ended":}
  simple_grid::components::execution_stage_manager::set_stage {"Setting stage to config":
    simple_stage => lookup('simple_grid::stage::config') #deliberately set to config, so that the following stages are triggered by puppet agent -t
  }
}

# Execution command
# puppet apply -e 'class{"simple_grid::install::config_master::simple_installer::create_sample_site_level_config_file":}'

class simple_grid::install::config_master::simple_installer::create_sample_site_level_config_file
{
  notify{"Creating simple config directory":}
  include 'simple_grid::ccm_function::create_config_dir'

  notify{"Creating a sample site level configuration file":}
  class {"simple_grid::components::site_level_config_file::install":}
}
