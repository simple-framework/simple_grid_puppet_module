class simple_grid::pre_deploy::config_master::rollback(
  $dns_file = lookup('simple_grid::components::ccm::container_orchestrator::swarm::dns'),
  $dns_parent_name = lookup('simple_grid::components::site_level_config_file::objects:dns_parent'),
  $meta_info_prefix = lookup('simple_grid::components::site_level_config_file::objects:meta_info_prefix'),
  $mode = lookup('simple_grid::mode'),
  $subnet = lookup('simple_grid::components::ccm::container_orchestrator::swarm::subnet'),
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $network = lookup('simple_grid::components::ccm::container_orchestrator::swarm::network'),
){
  notify{"Rolling back lifecycle callback scripts for all lightweight components":}
  include simple_grid::ccm_function::rollback_aggregate_repository_lifecycle_scripts

  notify{"Rolling back Docker Swarm as the container orchestrator for the entire cluster":}
  if $mode == lookup('simple_grid::mode::docker') or $mode == lookup('simple_grid::mode::dev') {
    exec{"ROlling back docker swarm on the entire cluster":
      command => "bolt task run simple_grid::rollback_swarm augmented_site_level_config_file=${augmented_site_level_config_file} network=${network} modulepath=/etc/puppetlabs/code/environments/simple/modules:/etc/puppetlabs/code/environments/simple/site --modulepath /etc/puppetlabs/code/environments/simple/site/ --nodes localhost > /etc/simple_grid/.swarm_status",
      path    => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
      user    => 'root',
      logoutput => true,
      environment => ["HOME=/root"]
    }
  }
  elsif $mode == lookup('simple_grid::mode::release') {
    exec{"Rolling back docker swarm on the entire cluster":
      command => "bolt task run simple_grid::rollback_swarm augmented_site_level_config_file=${augmented_site_level_config_file} network=${network} modulepath=/etc/puppetlabs/code/environments/simple/modules:/etc/puppetlabs/code/environments/simple/site --modulepath /etc/puppetlabs/code/environments/simple/site/ --nodes localhost > /etc/simple_grid/.swarm_status",
      path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
      user    => 'root',
      logoutput => true,
    }
  }
}
