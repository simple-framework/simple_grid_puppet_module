# Execution command
# puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e 'class{"simple_grid::install::config_master::simple_installer":}'

class simple_grid::install::config_master::simple_installer{
  notify{"***** Stage:Install; Node: CM *****":}
  notify{"Creating simple config directory":}
  include 'simple_grid::ccm_function::create_config_dir'

  notify{"Installing Puppet CCM":}
  class {"simple_grid::components::ccm::install":}

  notify{"Configuring CCM on Config Master":}
  class{"simple_grid::components::ccm::config":
    node_type => "CM"
  }
  # Config stage
  class{"simple_grid::config::config_master::init":}

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
