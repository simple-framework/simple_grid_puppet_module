class simple_grid::pre_deploy::config_master::orchestrator_conf {
  notify{"Running Stage: Orchestrator Conf":}
  class{"simple_grid::pre_deploy::config_master::swarm":}
}
