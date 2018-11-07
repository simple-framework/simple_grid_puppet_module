class simple_grid::config::config_master::init(
  $simple_config_dir = lookup('simple_grid::simple_site_config_dir')
)
{
  Class[simple_grid::pre_conf] -> Class[simple_grid::orchestrator_conf]   
  class{"simple_grid::pre_conf":
    config_dir =>  $simple_config_dir,
  }
  class{"simple_grid::orchestrator_conf":}
}
