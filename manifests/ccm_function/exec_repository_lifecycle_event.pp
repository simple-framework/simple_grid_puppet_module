class simple_grid::ccm_function::exec_repository_lifeycle_event(
  $event,
  $current_lightweight_element,
  $execution_id,
  $component_repository_dir = lookup('simple_grid::nodes::lightweight_component::component_repository_dir'),
  $pre_config_script = lookup('')
){
  $repository_name = current_lightweight_element['name']
  $repository_path = "${component_repository_dir}/${repository_name}"
  $repository_pre_conf_script = "${repository_path}/${pre_config_script}"
  if $mode == lookup('simple_grid::mode::docker') or $mode == lookup('simple_grid::mode::dev') {
      exec{"Executing Pre-Config Script $script":
        command => "${repository_pre_conf_script}",
        path => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
        user => 'root',
        logoutput => true,
        environment => ["HOME=/root"]
      }
    }
    elsif $mode == lookup('simple_grid::mode::release') {
      exec{"Executing Pre-Config Script $script":
        command => "${repository_pre_conf_script}",
        path => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
        user => 'root',
        logoutput => true
      }
    }
}
