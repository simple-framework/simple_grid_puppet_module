class simple_grid::components::ccm::install(
  $env_repository_url,
  $env_revision,
  $env_dir,
){
    notify {"Downloading puppet environment for SIMPLE at ${env_dir}":}
    vcsrepo {"${env_dir}":
    ensure   => present,
    provider => git,
    revision => $env_revision,
    source   => $env_repository_url,
    }

    notify {"Installing r10k":}
    class {'r10k':}
    
    notify {"Installing modules for simple environment.":}
    exec{'Install modules in the deploy environment':
      command => "r10k puppetfile install .",
      cwd     => "$env_dir",
      path    => "/usr/local/bin/:/usr/bin/:/bin/",
    }
}

class simple_grid::components::ccm::config(
  $node_type,
){
  if ($node_type == "CM") {
    class{"simple_grid::components::ccm::installation_helper::fileserver":}
    class{"simple_grid::components::ccm::installation_helper::ssh_config::config_master":}
    class{"simple_grid::components::ccm::installation_helper::generate_site_manifest":}
    class{"simple_grid::components::ccm::installation_helper::puppet_agent":}
    class{"simple_grid::components::ccm::installation_helper::puppet_server":}
  }elsif ($node_type == "LC") {
    class{"simple_grid::components::ccm::installation_helper::ssh_config::lightweight_component":}
    class{"simple_grid::components::ccm::installation_helper::reset_agent":}
  }
}

####################################################
# Installation Helpers for SSH and Fileserver on CM
####################################################
class simple_grid::components::ccm::installation_helper::generate_site_manifest(
  $site_manifest_path
){
  file{"Creating site.pp":
    path    => '/etc/puppetlabs/code/environments/simple/manifests/site.pp',
    ensure  => present,
    content => epp("simple_grid/site.pp")
  }
}
class simple_grid::components::ccm::installation_helper::puppet_agent(
  $puppet_conf = lookup("simple_grid::config_master::puppet_conf"),
  $env_name = lookup("simple_grid::components::ccm::install::env_name"),
){
  notify{"Adding [agent] config to ${puppet_conf}":}
  $puppet_conf_data = simple_grid::deserialize_puppet_conf("${puppet_conf}")
  $puppet_conf_updates = {
    "agent" => {
      "environment" => "${env_name}",
      "server"      => "${fqdn}"
    }
  }
  $puppet_conf_content_hash = simple_grid::puppet_conf_editor($puppet_conf_data, $puppet_conf_updates)
  $puppet_conf_content = simple_grid::serialize_puppet_conf($puppet_conf_content_hash)
  file {"Update puppet conf":
    path => "${puppet_conf}",
    content => $puppet_conf_content
  }
}
class simple_grid::components::ccm::installation_helper::puppet_server
{
  notify{"Starting PuppetServer":}
  service{"puppetserver":
    ensure => running
  }
}
class simple_grid::components::ccm::installation_helper::fileserver(
  $fileserver_conf_path,
){
  file {"Creating fileserver.conf":
    ensure  => present,
    path    => "${fileserver_conf_path}",
    content => template('simple_grid/fileserver.conf.erb')
  }
}

class simple_grid::components::ccm::installation_helper::ssh_config::config_master(
  $simple_config_dir = lookup('simple_grid::simple_config_dir'),
  $ssh_host_key      = lookup('simple_grid::nodes::config_master::installation_helper::ssh_config::ssh_host_key'),
  $ssh_dir           = lookup('simple_grid::nodes::config_master::installation_helper::ssh_config::ssh_dir'),
){
  ssh_keygen{'root':
    filename => "${ssh_dir}/${ssh_host_key}"
  }
  file {'Checking presence of ssh host private key for config master':
    ensure => present,
    path   => "${ssh_dir}/${ssh_host_key}",
    mode   => "600",
  }
  file {'Checking presence of ssh host public key for config dir':
    ensure => present,
    path   => "${ssh_dir}/${ssh_host_key}.pub",
    mode   => "644"
  }
  file {'Copy ssh host public key to simple config dir':
    ensure => present,
    source => "${ssh_dir}/${ssh_host_key}.pub",
    path   => "${simple_config_dir}/${ssh_host_key}.pub"
  }
}

#####################################################
#     Installation Helpers for SSH on LC
#####################################################

class simple_grid::components::ccm::installation_helper::ssh_config::lightweight_component (
  $ssh_authorized_keys_path = lookup("simple_grid::nodes::lightweight_component::ssh_config::ssh_authorized_keys_path"),
  $ssh_host_key = lookup('simple_grid::nodes::config_master::installation_helper::ssh_config::ssh_host_key'),
  $simple_config_dir = lookup('simple_grid::simple_config_dir')
){
    file {"Copy public key of master to config dir":
      source => "puppet:///simple_grid/${ssh_host_key}.pub",
      path   => "${simple_config_dir}/${ssh_host_key}.pub",
      mode   => "644"
    }
    # TODO ensure you do not keep adding keys on each run
    file_line {'append public key':
      path => "${ssh_authorized_keys_path}",
      line => file("${simple_config_dir}/${ssh_host_key}.pub"),
    }
    sshd_config {'Permit Root Login for Puppet Bolt to run Tasks':
      key    => "PermitRootLogin",
      ensure => present,
      value  => 'yes'
    }
}
#####################################################
#     Generic Installation Helpers
#####################################################
class simple_grid::components::ccm::installation_helper::init_agent(
  $puppet_master,
  $puppet_conf = lookup('simple_grid::nodes::lightweight_component::puppet_conf'),
  $runinterval,
){
  notify{"Configuring Puppet Agent":}
  notify{"Puppet master is $puppet_master":}
  #simple_grid::puppet_conf_editor("$puppet_conf",'agent','server',"$puppet_master", true)
  #simple_grid::puppet_conf_editor("$puppet_conf",'agent','runinterval',"$runinterval", true)
  $puppet_conf_data = simple_grid::deserialize_puppet_conf("${puppet_conf}")
  $puppet_conf_updates = {
    "agent" => {
      "server"       => $puppet_master,
      "runinterval"  => "${runinterval}",
      "environment"  => "simple"
      }
    }
  $puppet_conf_content_hash = simple_grid::puppet_conf_editor($puppet_conf_data, $puppet_conf_updates)
  $puppet_conf_content = simple_grid::serialize_puppet_conf($puppet_conf_content_hash)
  notify{"Restarting Puppet":}
  file {"Writing data to puppet conf":
    path => "${puppet_conf}",
    content => "$puppet_conf_content",
  } 
  service {'puppet':
    ensure    => running,
    subscribe => File["$puppet_conf"]
  }
}
class simple_grid::components::ccm::installation_helper::reset_agent(
  $runinterval,
  $puppet_conf = lookup('simple_grid::nodes::lightweight_component::puppet_conf'),
) {
  $puppet_conf_data = simple_grid::puppet_conf_from_fact($facts["puppet_conf"])
  notify{"data was ${puppet_conf_data}":}
  $puppet_conf_updates = {
    "agent" => {
      "environment" => "simple",
      "runinterval" => "$runinterval"
    }
  }
  $puppet_conf_content_hash = simple_grid::puppet_conf_editor($puppet_conf_data, $puppet_conf_updates)
  $puppet_conf_content = simple_grid::serialize_puppet_conf($puppet_conf_content_hash)
  notify{"Restarting Puppet":}
  file{'Updating puppet.conf': 
    path    => "$puppet_conf",
    content => "$puppet_conf_content"
  }
  service {"puppet":
    ensure    => running,
    subscribe => File["$puppet_conf"]
  }
}
