class simple_grid::components::site_level_config_file::install(
  $site_level_config_file = lookup('simple_grid::components::site_level_config_file'),
  $cream_torque_sample_file,
  $site_config_dir = lookup('simple_grid::site_config_dir'),

){
  file {"Creating Site Config Directory":
    path   => "${site_config_dir}",
    ensure => directory,
  } ~>
  file { "Creating Site Level Configutaion File from template":
    path    => "${$site_level_config_file}",
    ensure  => present,
    content => epp('simple_grid/site_level_config_file.yaml') 
  } ~>
  file {"Creating a sample site level configuration file":
    path    => "$cream_torque_sample_file",
    ensure  => present,
    content => epp('simple_grid/cream_torque_sample_site_level_config_file.yaml'),
  } ~>
  notify{"Sample site level configuration files available at $site_level_config_file":}

}
