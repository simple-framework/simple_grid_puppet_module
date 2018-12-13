class simple_grid::components::execution_stage_manager::install(
  $config_file   = lookup('simple_grid::components::execution_stage_manager::config_file'),
  $initial_stage = lookup('simple_grid::stage::init'),
){
  file{"Creating file for storing execution stage information":
    path    => "${config_file}",
    ensure  => present,
    content => "${initial_stage}",
  }
}
class simple_grid::components::execution_stage_manager::set_stage(
  $new_stage,
  $config_file = lookup('simple_grid::components::execution_stage_manager::config_file'),
){
  file{"":
    path    => "${config_file}",
    ensure  => present,
    content => "${new_stage}"
  }
}
