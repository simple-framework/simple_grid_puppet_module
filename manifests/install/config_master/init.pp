include 'simple_grid::ccm_function::create_config_dir'

info("Installing git")
package {"Install git":
  name   => 'git',
  ensure => present,
}

info("Installing External Node Classifier")
class {'simple_grid::components::enc::install':}

notice("Configuring External Node Classifier")
class {'simple_grid::components::enc::configure':}

notify{"Configuring Puppet Agent":}
$puppet_conf = lookup('simple_grid::config_master::puppet_conf')
simple_grid::puppet_conf_editor("$puppet_conf",'agent','server',"$fqdn", true)
simple_grid::puppet_conf_editor("$puppet_conf",'agent','runinterval',"0", true)
$puppet_conf_content = simple_grid::puppet_conf_editor("$puppet_conf",'agent','environment',"config", false)

notify{"Restarting Puppet":}
file {"Writing data to puppet conf":
  path => "${puppet_conf}",
  content => "$puppet_conf_content",
} 
service {'puppetserver':
  ensure    => running,
  subscribe => File["$puppet_conf"]
}

notify{"Creating a sample site level configuration file":}
class {"simple_grid::components::site_level_config_file::install":}

notify{"Installing Puppet CCM":}
class {"simple_grid::components::ccm::install":}
