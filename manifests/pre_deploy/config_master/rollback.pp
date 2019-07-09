class simple_grid::pre_deploy::config_master::rollback(
  $dns_file = lookup('simple_grid::components::swarm::dns'),
  $dns_parent_name = lookup('simple_grid::components::site_level_config_file::objects:dns_parent'),
  $meta_info_prefix = lookup('simple_grid::components::site_level_config_file::objects:meta_info_prefix'),
  $mode = lookup('simple_grid::mode'),
  $subnet = lookup('simple_grid::components::swarm::subnet'),
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $network = lookup('simple_grid::components::swarm::network'),
  $env_name = lookup('simple_grid::components::ccm::install::env_name'),
  $modulepath = "${puppet_environmentpath}/${env_name}/modules/",
  $swarm_status_file = lookup('simple_grid::components::swarm::status_file')
){
  notify{"Rolling back lifecycle callback scripts for all lightweight components":}
  include simple_grid::ccm_function::rollback_aggregate_repository_lifecycle_scripts

  file{'Removing swarm status file, if present':
    ensure => absent,
    force  => true,
    path   => "${swarm_status_file}",
  }

  notify{"Rolling back Docker Swarm as the container orchestrator for the entire cluster":}
  if $mode == lookup('simple_grid::mode::docker') or $mode == lookup('simple_grid::mode::dev') {
    exec{"ROlling back docker swarm on the entire cluster":
      command => "bolt task run simple_grid::rollback_swarm augmented_site_level_config_file=${augmented_site_level_config_file} network=${network} modulepath= ${modulepath} --nodes localhost > /etc/simple_grid/.swarm_status",
      path    => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
      user    => 'root',
      logoutput => true,
      environment => ["HOME=/root"]
    }
  }
  elsif $mode == lookup('simple_grid::mode::release') {
    exec{"Rolling back docker swarm on the entire cluster":
      command => "bolt task run simple_grid::rollback_swarm augmented_site_level_config_file=${augmented_site_level_config_file} network=${network} modulepath=${modulepath}  --modulepath ${modulepath} --nodes localhost > /etc/simple_grid/.swarm_status",
      path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
      user    => 'root',
      logoutput => true,
    }
  }
  $augmented_site_level_config_content = simple_grid::rollback_dns_in_augmented_site_level_config($augmented_site_level_config_file, $dns_parent_name)
  notify{"Removing dns file at ${dns_file}":}
  file{"Removing DNS data file":
      ensure => absent,
      force  => true,
      path => "${dns_file}",
  }
  notify{"Removing DNS data from ${augmented_site_level_config_file}":}
  file{"${augmented_site_level_config_file}":
      ensure => present,
      content => $augmented_site_level_config_content,
  }
  
  $augmented_site_level_config = loadyaml($augmented_site_level_config_file)
  $lightweight_components = $augmented_site_level_config['lightweight_components']
  $lightweight_components.each |Integer $index, Hash $lightweight_component| {
    $node_fqdn = $lightweight_component['deploy']['node']
    exec{"Rolling back pre_deploy stage on ${node_fqdn}":
      command => "bolt task run simple_grid::rollback_pre_deploy --modulepath ${modulepath} --nodes ${node_fqdn}",
      path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
      user    => 'root',
      logoutput => true,
      environment => ["HOME=/root"]
    }
  }

  ## Set stage
  simple_grid::components::execution_stage_manager::set_stage { 'Setting stage to pre_deploy':
    simple_stage => lookup('simple_grid::stage::pre_deploy')
  }
}
