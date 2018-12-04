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

notify{"Agent configuration puppet.conf":}
$puppet_conf = lookup('simple_grid::config_master::puppet_conf')
#simple_grid::puppet_conf_editor("$puppet_conf",'agent','server',"${fqdn}")
simple_grid::puppet_conf_editor("$puppet_conf",'agent','runinterval',"0")
simple_grid::puppet_conf_editor("$puppet_conf",'agent','environment',"config")
