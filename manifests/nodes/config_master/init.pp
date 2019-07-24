class simple_grid::nodes::config_master::init{
  if $simple_stage == lookup('simple_grid::stage::config'){
    simple_grid::components::execution_stage_manager::set_stage { 'Setting stage to pre_deploy':
     simple_stage => lookup('simple_grid::stage::pre_deploy')
    }
  }
  elsif $simple_stage == lookup('simple_grid::stage::pre_deploy'){
    # aggregate lifecycle scripts on CM
    # set up container orchestrator
    # run pre_deploy_step_1 and pre_deploy_step_2 on LC nodes.
    # change LC stage to deploy
    include simple_grid::pre_deploy::config_master::init

    ## prep for deploy stage
    $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output')
    $simple_log_dir = lookup('simple_grid::simple_log_dir')

    $site_level_config = loadyaml("${augmented_site_level_config_file}")
    $lightweight_components = $site_level_config["lightweight_components"]
    $lightweight_components.each |Hash $lightweight_component| {
      $filename = "${simple_log_dir}/${lightweight_component['execution_id']}/deploy_status.yaml"
      file{"${filename}":
        ensure  => "present",
        recurse => true
      }
    }
    simple_grid::components::execution_stage_manager::set_stage {'Setting stage to deploy':
    simple_stage => lookup('simple_grid::stage::deploy')
    }
  }
  elsif $simple_stage == lookup('simple_grid::stage::deploy'){
    #deployment for CM, run 'THE LOOP' here
    #for each entry in loop, do a task to execute puppet apply -e 'class{"simple_grid::deploy::lightweight_component::init": execution_id => "{value from loop}"}
    include simple_grid::deploy::config_master::init
    # class {"simple_grid::components::execution_stage_manager::set_stage":
    #  simple_stage => lookup('simple_grid::stage::final')
    # }
  }
  elsif $simple_stage == lookup('simple_grid::stage::final'){
    #for each execution id on this LC node, make sure firewall rules are correct, containers are running, perform any tests to check the status of containers.
  }
}
