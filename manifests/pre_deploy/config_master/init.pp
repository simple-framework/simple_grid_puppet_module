class simple_grid::pre_deploy::config_master::init(
  $mode = lookup('simple_grid::mode')
){
  
  include simple_grid::ccm_function::aggregate_repository_lifecycle_scripts
  if $mode == lookup('simple_grid::mode::docker') or $mode == lookup('simple_grid::mode::dev') {
    exec{"Set up docker swarm on the entire cluster":
      command => "bolt task run simple_grid::swarm augmented_site_level_config_file=/etc/simple_grid/site_config/augmented_site_level_config_file.yaml modulepath=/etc/puppetlabs/code/environments/simple/modules --modulepath /etc/puppetlabs/code/environments/simple/site/ --nodes localhost > /etc/simple_grid/.swarm_status",
      path    => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
      user    => 'root',
      logoutput => 'on_failure',
      environment => ["HOME=/root"]
    }
  }
  elsif $mode == lookup('simple_grid::mode::release') {
    exec{"Set up docker swarm on the entire cluster":
      command => "bolt task run simple_grid::swarm augmented_site_level_config_file='/etc/simple_grid/site_config/augmented_site_level_config_file.yaml' modulepath='/etc/puppetlabs/code/environments/simple/modules' --nodes localhost",
      path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
      user    => 'root',
    }
  }
}
