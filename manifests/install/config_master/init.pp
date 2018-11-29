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

