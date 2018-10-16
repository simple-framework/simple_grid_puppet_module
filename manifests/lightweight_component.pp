class simple_grid::lightweight_component{
  file { "/etc/simple_grid":
    ensure => directory,
    mode   => "0644",
    owner  => "puppet",
  }
   file { "copy site level config file to agent":
        mode   => "0644",
        owner  => "puppet",
        source => 'puppet:///simple_grid/${site_config_dir}/${site_config_file}',
        path   => "/etc/simple_grid/simple_grid_site_config_blah"
    }

}
