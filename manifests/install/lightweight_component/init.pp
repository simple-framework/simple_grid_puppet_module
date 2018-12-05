class simple_grid::pre_config::lightweight_component::init{
  Class['simple_grid::pre_config::create_config_dir'] -> Class['simple_grid::pre_config::lightweight_component::ssh_config'] -> Class['simple_grid::pre_config::lightweight_component::reset_agent']
  class {'simple_grid::pre_config::create_config_dir':}
  class { 'simple_grid::pre_config::lightweight_component::ssh_config': }
  class {'simple_grid::pre_config::lightweight_component::reset_agent':}
}
