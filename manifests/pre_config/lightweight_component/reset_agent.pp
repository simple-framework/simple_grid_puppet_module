class simple_grid::pre_config::lightweight_component::reset_agent(
  $puppet_conf_path,
  $runinterval,
) {
  file_line { 'change env to master':
    path  => "$puppet_conf_path",
    line  => 'environment = master',
    match => 'environment = pre_config',#TODO regec
  }

  file_line { "change runtime to $runinterval min":
    path  => '/etc/puppetlabs/puppet/puppet.conf',
    line  => "runinterval = $runinterval",
    match => 'runinterval = 0', #TODO regex
  }
}
