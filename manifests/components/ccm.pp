class simple_grid::components::ccm::install(
  $env_install_repository_url,
  $env_install_revision,
  $env_install_dir,
  $env_config_repository_url,
  $env_config_revision,
  $env_config_dir,
  $env_pre_deploy_repository_url,
  $env_pre_deploy_revision,
  $env_pre_deploy_dir,
  $env_deploy_repository_url,
  $env_deploy_revision,
  $env_deploy_dir,
  $env_test_repository_url,
  $env_test_revision,
  $env_test_dir,
  $env_cleanup_repository_url,
  $env_cleanup_revision,
  $env_cleanup_dir,
){
    notify {"Downloading Install environment at ${env_install_dir}":}
    vcsrepo {"${env_install_dir}":
    ensure   => present,
    provider => git,
    revision => $env_install_revision,
    source   => $env_install_repository_url,
    }

    notify {"Downloading Config environment":}
    vcsrepo {"${env_config_dir}":
    ensure   => present,
    provider => git,
    revision => $env_config_revision,
    source   => $env_config_repository_url,
    }

    notify {"Downloading Pre_Deploy environment":}
    vcsrepo {"${env_pre_deploy_dir}":
    ensure   => present,
    provider => git,
    revision => $env_pre_deploy_revision,
    source   => $env_pre_deploy_repository_url,
    }

    notify {"Downloading Deploy environment":}
    vcsrepo {"${env_deploy_dir}":
    ensure   => present,
    provider => git,
    revision => $env_deploy_revision,
    source   => $env_deploy_repository_url,
    }

    notify {"Downloading Test environment":}
    vcsrepo {"${env_test_dir}":
    ensure   => present,
    provider => git,
    revision => $env_test_revision,
    source   => $env_test_repository_url,
    }

    notify {"Downloading Cleanup environment":}
    vcsrepo {"${env_cleanup_dir}":
    ensure   => present,
    provider => git,
    revision => $env_cleanup_revision,
    source   => $env_cleanup_repository_url,
    }
}

class simple_grid::components::ccm::config(
  $node_type,
){
  if ($node_type == "CM") {
    class{"simple_grid::components::ccm::installation_helper::fileserver":}
    class{"simple_grid::components::ccm::installation_helper::ssh_config::config_master":}
  }elsif ($node_type == "LC") {
    notify{"Code for LC":}
    class{"simple_grid::components::ccm::installation_helper::ssh_config::lightweight_component":}
    class{"simple_grid::components::ccm::installation_helper::reset_agent":}
  }
}

####################################################
# Installation Helpers for SSH and Fileserver on CM
####################################################
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
  $ssh_authorized_keys_path,
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

class simple_grid::components::ccm::installation_helper::reset_agent(
  $puppet_conf_path,
  $runinterval,
  $puppet_conf = lookup('simple_grid::nodes::lightweight_component::puppet_conf'),
) {
  
  simple_grid::puppet_conf_editor("$puppet_conf",'agent','environment','config', true)
  $puppet_conf_data = simple_grid::puppet_conf_editor("$puppet_conf",'agent','runinterval',"$runinterval", false)
  
  file{'Updating puppet.conf': 
    path    => "$puppet_conf_path",
    content => "$puppet_conf_data"
  }
  service {"puppet":
    ensure    => running,
    subscribe => File["$puppet_conf_path"]
  }
}
