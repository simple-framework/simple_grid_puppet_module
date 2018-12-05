class simple_grid::pre_config::lightweight_component::ssh_config (
  $ssh_authorized_keys_path,
  $ssh_host_key = lookup('simple_grid::pre_config::config_master::ssh_config::ssh_host_key'),
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
