class simple_grid::pre_config::create_config_dir (
  $simple_config_dir = lookup('simple_grid::simple_config_dir')
){
  file {'Create config dir':
    ensure => 'directory',
    path   => "$simple_config_dir",
    mode   => "0777",
  }
}
