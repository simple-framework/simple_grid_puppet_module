class simple_grid::nodes::config_master::init{
  if $simple_stage == lookup('simple_grid::stage::config'){
    include simple_grid::pre_deploy::config_master::init
    class {"simple_grid::components::execution_stage_manager::set_stage":
      simple_stage => lookup('simple_grid::stage::pre_deploy')
    }
  }
  elsif $simple_stage == lookup('simple_grid::stage::pre_deploy'){
    #deployment for CM, run 'THE LOOP' here
  }
}
