class simple_grid::components::execution_stage_manager::set_stage(
  $simple_stage,
  $config_file = lookup('simple_grid::components::execution_stage_manager::config_file'),
){
  file{"Updating Stage to $simple_stage":
    path    => "${config_file}",
    ensure  => present,
    content => "${new_stage}"
  }
}
