class simple_grid::nodes::lightweight_component::init
{
  if $simple_stage == lookup('simple_grid::stage::pre_deploy') {

  }
  elsif $simple_stage == lookup('simple_grid::stage::final'){

  }
  elsif $simple_stage == lookup('simple_grid::stage::install'){
    class{"simple_grid::pre_deploy::lightweight_component::init":}    
    class {"simple_grid::components::execution_stage_manager::set_stage":
     simple_stage => lookup('simple_grid::stage::pre_deploy')
    }
  }
}
