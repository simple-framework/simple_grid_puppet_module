class simple_grid::ccm_function::aggregate_repository_lifecycle_scripts(
$augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
$simple_grid_scripts_dir = lookup('simple_grid::scripts_dir')
)
{
  
  notify {'Creating and copying script structure':}
  file{"${simple_grid_scripts_dir}/":
    ensure => directory,
    mode   => '0777',
    owner  =>  root,
    group  =>  root,
  }
  $scripts_hash = simple_grid::generate_lifecycle_script_directory_structure("${augmented_site_level_config_file}", $simple_grid_scripts_dir)

  notify {"XXXX ${scripts_hash}":} 
  $scripts_hash.each |Integer $exec_id, Hash $modified_hooks|
  {
    file{"${simple_grid_scripts_dir}/${exec_id}/":
      ensure => directory,
      mode   => '0777',
      owner  =>  root,
      group  =>  root,
    }
    $modified_hooks.each| String $lifecycle_hook, Array $modified_hook|
    {
      file{ "${simple_grid_scripts_dir}/${exec_id}/${lifecycle_hook}/":
        ensure => directory,
        mode   => '0777',
        owner  =>  root,
        group  =>  root,
      }
      $modified_hook.each |Hash $script|
      {
        file{"Copy $script['actual_script']":
            ensure => present,
            mode   => '0777',
            owner  =>  root,
            group  =>  root,
            source => "${script['original_script']}",
            path   =>  "${script['actual_script']}",
        }
      }
    }
  }
}

