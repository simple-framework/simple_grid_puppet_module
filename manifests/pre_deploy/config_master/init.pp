class simple_grid::pre_deploy::config_master::init(
  $dns_file = lookup('simple_grid::components::swarm::dns'),
  $dns_parent_name = lookup('simple_grid::components::site_level_config_file::objects:dns_parent'),
  $meta_info_prefix = lookup('simple_grid::components::site_level_config_file::objects:meta_info_prefix'),
  $mode = lookup('simple_grid::mode'),
  $subnet = lookup('simple_grid::components::swarm::subnet'),
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $network = lookup('simple_grid::components::swarm::network'),
  $env_name = lookup('simple_grid::components::ccm::install::env_name'),
  $host_certificates_dir = lookup('simple_grid::host_certificates_dir')
){
  notify{"Aggregating lifecycle callback scripts for all lightweight components":}
  include simple_grid::ccm_function::aggregate_repository_lifecycle_scripts

  notify{'Configuring container orchestrator':}
  class{'simple_grid::ccm_function::config_orchestrator':}

  file{"Changing owner of ${host_certificates_dir} to puppet. This is required by puppet fileserver.":
    ensure  => directory,
    path    => $host_certificates_dir,
    owner   => 'puppet',
    mode    => '0555', 
    recurse => true 
  }

  $augmented_site_level_config = loadyaml("${augmented_site_level_config_file}")
  $site_infrastructure = $augmented_site_level_config['site_infrastructure']
  $site_infrastructure.each |Integer $index, Hash $node| {
    $node_fqdn = $node['fqdn']
    notify{"Running Pre-Deploy stage for Lightweight Component ${node_fqdn}":}
    if $mode == lookup('simple_grid::mode::docker') or $mode == lookup('simple_grid::mode::dev') {

      exec{"Running puppet agent on ${node_fqdn} to initiate step 1 of pre_deploy stage":
        command => "bolt task run simple_grid::run_puppet_agent \
          ipv4_address=${node['ip_address']} \
          hostname=${node_fqdn} \
          --targets ${node_fqdn} \
          --modulepath ${puppet_environmentpath}/${env_name}/modules:${puppet_environmentpath}/${env_name}/site",
        path    => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
        user    => 'root',
        logoutput => true,
        environment => ["HOME=/root"]
      }
      exec{"Running puppet agent on ${node_fqdn} to initiate step 2 of pre_deploy stage ":
        command => "bolt task run simple_grid::run_puppet_agent \
          ipv4_address=${node['ip_address']} \
          hostname=${node_fqdn} \
          --targets ${node_fqdn} \
          --modulepath ${puppet_environmentpath}/${env_name}/modules:${puppet_environmentpath}/${env_name}/site",
        path    => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
        user    => 'root',
        logoutput => true,
        environment => ["HOME=/root"]
      }

      exec{"Running puppet agent on ${node_fqdn} to initiate step 3 of pre_deploy stage ":
        command => "bolt task run simple_grid::run_puppet_agent \
          ipv4_address=${node['ip_address']} \
          hostname=${node_fqdn} \
          --targets ${node_fqdn} \
          --modulepath ${puppet_environmentpath}/${env_name}/modules:${puppet_environmentpath}/${env_name}/site",
        path    => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
        user    => 'root',
        logoutput => true,
        environment => ["HOME=/root"]
      }
    }
    elsif $mode == lookup('simple_grid::mode::release') {
      exec{"Running puppet agent on ${node_fqdn} to initiate step 1 of pre_deploy stage":
        command => "bolt task run simple_grid::run_puppet_agent \
          ipv4_address=${node['ip_address']} \
          hostname=${node_fqdn} \
          --targets ${node_fqdn} \
          --modulepath ${puppet_environmentpath}/${env_name}/modules:${puppet_environmentpath}/${env_name}/site",
        path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
        user    => 'root',
        logoutput => true
      }
      exec{"Running puppet agent on ${node_fqdn} to initiate step 2 of pre_deploy stage ":
        command => "bolt task run simple_grid::run_puppet_agent \
          ipv4_address=${node['ip_address']} \
          hostname=${node_fqdn} \
          --targets ${node_fqdn} \
          --modulepath ${puppet_environmentpath}/${env_name}/modules:${puppet_environmentpath}/${env_name}/site",
        path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
        user    => 'root',
        logoutput => true
      }
      exec{"Running puppet agent on ${node_fqdn} to initiate step 3 of pre_deploy stage ":
        command => "bolt task run simple_grid::run_puppet_agent \
          ipv4_address=${node['ip_address']} \
          hostname=${node_fqdn} \
          --targets ${node_fqdn} \
          --modulepath ${puppet_environmentpath}/${env_name}/modules:${puppet_environmentpath}/${env_name}/site",
        path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
        user    => 'root',
        logoutput => true
      }
    }
  }
}
