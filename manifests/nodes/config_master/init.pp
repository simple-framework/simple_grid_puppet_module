class simple_grid::nodes::config_master::init{
  if $simple_stage == lookup('simple_grid::stage::pre_deploy'){
    # aggregate lifecycle scripts on CM, set up container orchestrator, change LC stage to deploy, reset agent to 30m
    include simple_grid::pre_deploy::config_master::init

    ## prep for deploy
    $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output')
    $simple_config_dir = lookup('simple_grid::simple_config_dir')

    $site_level_config = loadyaml("${augmented_site_level_config_file}")
    $lightweight_components = $site_level_config["lightweight_components"]
    $lightweight_components.each |Hash $lightweight_component| {
      $filename = "${simple_config_dir}/.${lightweight_component['execution_id']}.status"
      file{"${filename}":
        ensure => "present"
      }
    }
    # class {"simple_grid::components::execution_stage_manager::set_stage":
    #  simple_stage => lookup('simple_grid::stage::deploy')
    # }
  }
  elsif $simple_stage == lookup('simple_grid::stage::deploy'){
    #deployment for CM, run 'THE LOOP' here
    #for each entry in loop, do a task to execute puppet apply -e 'class{"simple_grid::deploy::lightweight_component::init": execution_id => "{value from loop}"}
    include simple_grid::deploy::config_master::init
  }
  elsif $simple_stage == lookup('simple_grid::stage::config'){
    class {"simple_grid::components::execution_stage_manager::set_stage":
     simple_stage => lookup('simple_grid::stage::pre_deploy')
    }
  }
}
