class simple_grid::config::config_master::pre_conf(
  $config_dir = lookup('simple_grid::simple_config_dir'),
  $yaml_compiler_dir_name,
  $yaml_compiler_repo_url,
  $yaml_compiler_revision,
  $site_level_config_dir,
  $site_level_config_file,
) {
  notify{"Running State: Pre Conf":}
  # 1. create config directory
  file {"main config directory":
    ensure => directory,
    path   => "${config_dir}", 
    mode   => "0777",
  }~>
  #2. create fileserver.conf
  file {"add fileserver.conf":
    ensure  => present,
    path    => "/etc/puppetlabs/puppet/fileserver.conf",
    content => template('simple_grid/fileserver.conf.erb')
  }~>
  #3. check if site-level-config-file is present
  file {"Check presence of site_config file":
    ensure => present,
    path   => "${site_level_config_dir}/${site_level_config_file}"
  }
  class{"simple_grid::config::config_master::yaml_compiler":
    config_dir => $config_dir,
  }
}
