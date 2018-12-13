class simple_grid::pre_deploy::config_master::init{
  
  include simple_grid::ccm_function::aggregate_repository_lifecycle_scripts

  exec{"Set up docker swarm on the entire cluster":
    command => "bolt task run simple_grid::swarm --modulepath /etc/puppetlabs/code/environments/pre_deploy/site/ --nodes localhost",
    path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
    user    => 'root',
  }
}
