# Run command 
#puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e 'class {"simple_grid::install::lightweight_component::simple_installer":puppet_master => "basic_config_master.cern.ch"}'

class simple_grid::install::lightweight_component::simple_installer(  
  $puppet_master,
  $puppet_conf = lookup('simple_grid::nodes::lightweight_component::puppet_conf')
)
{
  notify{'Creating SIMPLE config directory':}
  class {'simple_grid::ccm_function::create_config_dir':}
  
  notify{"Configuring Puppet Agent":}
  simple_grid::puppet_conf_editor("$puppet_conf",'agent','server',"$puppet_master", true)
  simple_grid::puppet_conf_editor("$puppet_conf",'agent','runinterval',"0", true)
  $puppet_conf_content = simple_grid::puppet_conf_editor("$puppet_conf",'agent','environment',"install", false)
  
  notify{"Restarting Puppet":}
  file {"Writing data to puppet conf":
    path => "${puppet_conf}",
    content => "$puppet_conf_content",
  } 
  service {'puppet':
    ensure    => running,
    subscribe => File["$puppet_conf"]
  }
}
