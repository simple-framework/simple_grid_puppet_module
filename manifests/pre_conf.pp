class simple_grid::pre_conf(
  $config_dir
) {
  notify{"Running State: Pre Conf":}
  #create config directory
  file {"main config directory":
    ensure => directory,
    path   => "${config_dir}", 
  }
  #site-level-config-file
  #run the yaml compiler
}
