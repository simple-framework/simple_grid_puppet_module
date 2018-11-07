class simple_grid::pre_config::config_master::fileserver(
  $fileserver_conf_path
){
  file {"add fileserver.conf":
    ensure  => present,
    path    => "${fileserver_conf_path}",
    content => template('simple_grid/fileserver.conf.erb')
  }
}
