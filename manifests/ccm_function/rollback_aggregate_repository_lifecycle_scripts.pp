class simple_grid::ccm_function::rollback_aggregate_repository_lifecycle_scripts(
$augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
$simple_grid_scripts_dir = lookup('simple_grid::scripts_dir')
)
{
  notify {'Creating and copying script structure':}
  file{"${simple_grid_scripts_dir}/":
    ensure => absent,
    force  => true,
    mode   => '0777',
    owner  =>  root,
    group  =>  root,
  }
}

