class simple_grid::pre_config::config_master::ssh_config(
  $simple_config_dir = lookup('simple_grid::simple_config_dir'),
  $ssh_host_key,
  $ssh_dir,
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
