class simple_grid::pre_conf(
  $config_dir,
  $yaml_compiler_dir_name,
  $yaml_compiler_repo_url,
  $yaml_compiler_revision,
  $site_config_dir,
  $site_config_file
) {
  notify{"Running State: Pre Conf":}
  #create config directory
  file {"main config directory":
    ensure => directory,
    path   => "${config_dir}", 
    mode   => "0777",
  }
  #create fileserver.conf
  file {"add fileserver.conf":
    ensure  => present,
    path    => "/etc/puppetlabs/puppet/fileserver.conf",
    content => template('simple_grid/fileserver.conf.erb')
  }
  #check if site-level-config-file is present
  file {"Check presence of site_config file":
    ensure => present,
    path   => "${site_config_dir}/${site_config_file}"
  }
  #download simple grid yaml compiler
  vcsrepo { "${config_dir}/${yaml_compiler_dir_name}":
    ensure   => present,
    provider => git,
    revision => $yaml_compiler_revision,
    source   => $yaml_compiler_repo_url,
  }
}
