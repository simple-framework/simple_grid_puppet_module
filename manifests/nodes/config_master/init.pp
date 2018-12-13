class simple_grid::nodes::config_master::init{
  if $simple_stage == lookup('simple_grid::stage::pre_deploy'){
    # aggregate lifecycle scripts on CM, set up container orchestrator, change LC stage to deploy
    include simple_grid::pre_deploy::config_master::init
    #class {"simple_grid::components::execution_stage_manager::set_stage":
    #  simple_stage => lookup('simple_grid::stage::pre_deploy')
    #}
  }
  elsif $simple_stage == lookup('simple_grid::stage::deploy'){
    #deployment for CM, run 'THE LOOP' here
    #for each entry in loop, do a task to execute puppet apply -e 'class{"simple_grid::deploy::lightweight_component::init": execution_id => "{value from loop}"}
  }
}
