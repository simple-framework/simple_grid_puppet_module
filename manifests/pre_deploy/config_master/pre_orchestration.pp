class simple_grid::pre_deploy::config_master::pre_orchestration{
  notify{"Running Stage: Pre-Orchestrator Conf":}
  class{"simple_grid::config::config_master::swarm":
  }
}
