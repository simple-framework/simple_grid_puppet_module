class simple_grid::config::config_master::rollback(){
  notify{"Rolling back Config state for YAML compiler":}
  class {"simple_grid::components::yaml_compiler::rollback":}
  class {"simple_grid::components::ccm::rollback":}
  ## Set stage
  simple_grid::components::execution_stage_manager::set_stage { 'Setting stage to config':
    simple_stage => lookup('simple_grid::stage::config')
  }
  notify{"NOTE:: Run simple_installer again to proceed with deployment":}
}
