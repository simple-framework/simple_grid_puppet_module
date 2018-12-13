# Execution command
# puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e 'class{"simple_grid::install::config_master::simple_installer":}'

class simple_grid::install::config_master::simple_installer{
  
  notify{"Creating simple config directory":}
  include 'simple_grid::ccm_function::create_config_dir'

  notify{"***** Stage:Install; Node: CM *****":}

  notify {"Installing Git":}
  include 'git'
  
  notify{"Installing Puppet CCM":}
  class {"simple_grid::components::ccm::install":}
  
  notify{"Installation Stage has ended":}
  
  notify{"Configuring CCM on Config Master":}
  class{"simple_grid::components::ccm::config":
    node_type => "CM"
  }
  
  # Config stage
  class{"simple_grid::config::config_master::init":}
  
  notify{"Configuration Stage has ended":}
  class {"simple_grid::components::execution_stage_manager::set_stage":
    simple_stage => lookup('simple_grid::stage::config')
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
