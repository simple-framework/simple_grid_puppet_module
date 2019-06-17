class simple_grid::pre_deploy::config_master::init(
  $dns_file = lookup('simple_grid::components::ccm::container_orchestrator::swarm::dns'),
  $dns_parent_name = lookup('simple_grid::components::site_level_config_file::objects:dns_parent'),
  $meta_info_prefix = lookup('simple_grid::components::site_level_config_file::objects:meta_info_prefix'),
  $mode = lookup('simple_grid::mode'),
  $subnet = lookup('simple_grid::components::ccm::container_orchestrator::swarm::subnet'),
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $network = lookup('simple_grid::components::ccm::container_orchestrator::swarm::network'),
){
  notify{"Aggregating lifecycle callback scripts for all lightweight components":}
  include simple_grid::ccm_function::aggregate_repository_lifecycle_scripts
  
  notify{"Configuring container orchestrator":}
  class{"simple_grid::ccm_function::config_orchestrator":}
  #notify{"Setting up Docker Swarm as the container orchestrator for the entire cluster":}
  # class{'simple_grid::components::swarm::configure::network':}
  # notify{"Setting up Docker Swarm as the container orchestrator for the entire cluster":}
  # if $mode == lookup('simple_grid::mode::docker') or $mode == lookup('simple_grid::mode::dev') {
  #   exec{"Set up docker swarm on the entire cluster":
  #     command => "bolt task run simple_grid::swarm augmented_site_level_config_file=${augmented_site_level_config_file} network=${network} subnet=${subnet} modulepath=/etc/puppetlabs/code/environments/simple/modules:/etc/puppetlabs/code/environments/simple/site --modulepath /etc/puppetlabs/code/environments/simple/site/ --nodes localhost > /etc/simple_grid/.swarm_status",
  #     path    => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
  #     user    => 'root',
  #     logoutput => true,
  #     environment => ["HOME=/root"]
  #   }
  # }
  # elsif $mode == lookup('simple_grid::mode::release') {
  #   exec{"Set up docker swarm on the entire cluster":
  #     command => "bolt task run simple_grid::swarm augmented_site_level_config_file=${augmented_site_level_config_file} network=${network} subnet=${subnet} modulepath=/etc/puppetlabs/code/environments/simple/modules:/etc/puppetlabs/code/environments/simple/site --modulepath /etc/puppetlabs/code/environments/simple/site/ --nodes localhost > /etc/simple_grid/.swarm_status",
  #     path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
  #     user    => 'root',
  #     logoutput => true,
  #   }
  # }
  # $dns_file_content = simple_grid::generate_dns_file_content($augmented_site_level_config_file, $subnet, $meta_info_prefix, $dns_parent_name)
  # if length($dns_file_content) > 1 {
  #   notify{"Writing DNS data to ${dns_file}":}
  #   file{"Creating DNS data file":
  #     ensure => present,
  #     path => "${dns_file}",
  #     content => "${dns_file_content}",
  #   }
  #   notify{"Appending DNS data to ${augmented_site_level_config_file}":}
  #   file{"${augmented_site_level_config_file}":
  #     ensure => present,
  #     content => epp('simple_grid/dns_augmented_site_level_config_file.yaml', {'augmented_site_level_config' => file($augmented_site_level_config_file), 'dns_parent_name' => $dns_parent_name,'dns_file_content' => $dns_file_content})
  #   }
  # }
  
  
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
          --nodes ${node_fqdn} \
          --modulepath /etc/puppetlabs/code/environments/simple/site/",
        path    => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
        user    => 'root',
        logoutput => true,
        environment => ["HOME=/root"]
      }
      exec{"Running puppet agent on ${node_fqdn} to initiate step 2 of pre_deploy stage ":
        command => "bolt task run simple_grid::run_puppet_agent \
          ipv4_address=${node['ip_address']} \
          hostname=${node_fqdn} \
          --nodes ${node_fqdn} \
          --modulepath /etc/puppetlabs/code/environments/simple/site/",
        path    => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
        user    => 'root',
        logoutput => true,
        environment => ["HOME=/root"]
      }

      exec{"Running puppet agent on ${node_fqdn} to initiate step 3 of pre_deploy stage ":
        command => "bolt task run simple_grid::run_puppet_agent \
          ipv4_address=${node['ip_address']} \
          hostname=${node_fqdn} \
          --nodes ${node_fqdn} \
          --modulepath /etc/puppetlabs/code/environments/simple/site/",
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
          --nodes ${node_fqdn} \
          --modulepath /etc/puppetlabs/code/environments/simple/site/",
        path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
        user    => 'root',
        logoutput => true
      }
      exec{"Running puppet agent on ${node_fqdn} to initiate step 2 of pre_deploy stage ":
        command => "bolt task run simple_grid::run_puppet_agent \
          ipv4_address=${node['ip_address']} \
          hostname=${node_fqdn} \
          --nodes ${node_fqdn} \
          --modulepath /etc/puppetlabs/code/environments/simple/site/",
        path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
        user    => 'root',
        logoutput => true
      }
      exec{"Running puppet agent on ${node_fqdn} to initiate step 3 of pre_deploy stage ":
        command => "bolt task run simple_grid::run_puppet_agent \
          ipv4_address=${node['ip_address']} \
          hostname=${node_fqdn} \
          --nodes ${node_fqdn} \
          --modulepath /etc/puppetlabs/code/environments/simple/site/",
        path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
        user    => 'root',
        logoutput => true
      }
    }
  }
}
