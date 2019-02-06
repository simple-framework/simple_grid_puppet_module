class simple_grid::components::component_repository::deploy(
  $execution_id,  
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $deploy_status_file = lookup('simple_grid::nodes::lightweight_component::deploy_status_file'),
  $component_repository_dir = lookup('simple_grid::nodes::lightweight_component::component_repository_dir'),
  $meta_info_prefix = lookup('simple_grid::components::site_level_config_file::objects:meta_info_prefix')
){
  $data = loadyaml($augmented_site_level_config_file)
  $current_lightweight_component = simple_grid::get_lightweight_component($augmented_site_level_config_file, $execution_id)
  $repository_name = $current_lightweight_component['name']
  $meta_info_parent = "${meta_info_prefix}${downcase($repository_name)}"
  $meta_info = $data["${meta_info_parent}"]
  $repository_path = "${component_repository_dir}/${repository_name}"
  
  # notify{"Deploying execution_id ${execution_id} with name ${repository_name} now!!!!":}      
  # class{"simple_grid::ccm_function::prep_host":
  #   current_lightweight_component => $current_lightweight_component,
  #   meta_info                     => $meta_info
  # }

  class{"simple_grid::ccm_function::exec_repository_lifecycle_hook":
    hook => lookup('simple_grid::components::component_repository::lifecycle::hook::pre_config'),
    current_lightweight_component => $current_lightweight_component,
    execution_id => $execution_id
  }

}
class simple_grid::component::component_repository::lifecycle::hook::pre_config(
  $scripts,
  $mode = lookup('simple_grid::mode'),
  
){
  $scripts.each |$script|{
    $file = split($script, '/')
    $real_script_path = "${}"
    #TODO extract script path assigned by framework
    if $mode == lookup('simple_grid::mode::docker') or $mode == lookup('simple_grid::mode::dev') {
      exec{"Executing Pre-Config Script $script":
        command => "${script}",
        path => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
        user => 'root',
        logoutput => true,
        environment => ["HOME=/root"]
      }
    }
    elsif $mode == lookup('simple_grid::mode::release') {
      exec{"Executing Pre-Config Script $script":
        command => "${script}",
        path => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
        user => 'root',
        logoutput => true,
      }
    }
  }
}
class simple_grid::component::component_repository::lifecycle::hook::pre_init(
  
){
  
}
class simple_grid::component::component_repository::lifecycle::hook::post_init(
  
){
  
}

