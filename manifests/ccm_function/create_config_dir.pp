class simple_grid::ccm_function::create_config_dir(
  $simple_config_dir = lookup('simple_grid::simple_config_dir'),
  $simple_log_dir    = lookup('simple_grid::simple_log_dir')
){
  file{"ccm_function_create_config_dir at $simple_config_dir":
    ensure => directory,
    mode   => "0777",
    path   => "$simple_config_dir"
  }
  file{"ccm_function_create_log_dir":
    ensure => directory,
    recurse => true,
    mode   => "0777",
    path   => "$simple_log_dir"
  }
}
