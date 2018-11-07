class simple_grid::config::config_master::init(
  $simple_config_dir = lookup('simple_grid::simple_config_dir')
)
{
  Class[simple_grid::config::config_master::pre_conf] -> Class[simple_grid::config::config_master::orchestrator_conf]   
  class{"simple_grid::config::config_master::pre_conf":
    config_dir =>  $simple_config_dir,
  }
  class{"simple_grid::config::config_master::orchestrator_conf":}
}
