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
  
  notify{"Deploying execution_id ${execution_id} with name ${repository_name} now!!!!":}      
  class{"simple_grid::ccm_function::prep_host":
    current_lightweight_component => $current_lightweight_component,
    meta_info                     => $meta_info
  }

  simple_grid::ccm_function::exec_repository_lifecycle_hook{'Pre_Config Hooks':
    hook => lookup('simple_grid::components::component_repository::lifecycle::hook::pre_config'),
    current_lightweight_component => $current_lightweight_component,
    execution_id => $execution_id
  }

  simple_grid::ccm_function::exec_repository_lifecycle_event{'Pre_config Event':
    event => lookup('simple_grid::components::component_repository::lifecycle::event::pre_config'),
    current_lightweight_component => $current_lightweight_component,
    execution_id => $execution_id,
    meta_info => $meta_info
  }
  simple_grid::ccm_function::exec_repository_lifecycle_event{'Boot Event':
    event => lookup('simple_grid::components::component_repository::lifecycle::event::boot'),
    current_lightweight_component => $current_lightweight_component,
    execution_id => $execution_id,
    meta_info => $meta_info
  }
  simple_grid::ccm_function::exec_repository_lifecycle_hook{"Pre_Init hook":
    hook => lookup('simple_grid::components::component_repository::lifecycle::hook::pre_init'),
    current_lightweight_component => $current_lightweight_component,
    execution_id => $execution_id
  }
  simple_grid::ccm_function::exec_repository_lifecycle_event{"Init event":
    event => lookup('simple_grid::components::component_repository::lifecycle::event::init'),
    current_lightweight_component => $current_lightweight_component,
    execution_id => $execution_id,
    meta_info => $meta_info
  }
}
class simple_grid::component::component_repository::lifecycle::hook::pre_config(
  $scripts,
  $mode = lookup('simple_grid::mode'),
  
){
  $scripts.each |Hash $script|{
    $actual_script = $script['actual_script']
    if $mode == lookup('simple_grid::mode::docker') or $mode == lookup('simple_grid::mode::dev') {
      exec{"Executing Pre-Config Script $script":
        command => "${actual_script}",
        path => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
        user => 'root',
        logoutput => true,
        environment => ["HOME=/root"]
      }
    }
    elsif $mode == lookup('simple_grid::mode::release') {
      exec{"Executing Pre-Config Script $script":
        command => "${actual_script}",
        path => '/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
        user => 'root',
        logoutput => true
      }
    }
  }
}

class simple_grid::component::component_repository::lifecycle::event::pre_config(
  $current_lightweight_component,
  $execution_id,
  $component_repository_dir = lookup('simple_grid::nodes::lightweight_component::component_repository_dir'),
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $mode = lookup("simple_grid::mode"),
  $pre_config_image_tag = lookup('simple_grid::components::component_repository::pre_config_image_tag'),
  $l2_relative_config_dir = lookup('simple_grid::components::component_repository::l2_relative_config_dir'),
  $l2_relative_pre_config_dir = lookup('simple_grid::components::component_repository::l2_relative_pre_config_dir'),
)
{
  $augmented_site_level_config = loadyaml("${augmented_site_level_config_file}")
  $repository_name = $current_lightweight_component['name']
  $repository_path = "${component_repository_dir}/${repository_name}"
  $level_2_configurator = simple_grid::get_level_2_configurator($augmented_site_level_config, $current_lightweight_component)
  $pre_config_dir = "${repository_path}/${level_2_configurator}/${l2_relative_pre_config_dir}"
  $config_dir = "${repository_path}/${level_2_configurator}/${l2_relative_config_dir}/"
  $repository_name_lowercase = downcase($repository_name)
  $pre_config_image_name = "${repository_name_lowercase}_${pre_config_image_tag}"
  notify{"Building Dockerfile at: ${pre_config_container_path}":}
  class {'docker':}
    docker::image {"${pre_config_image_name}":
      docker_file => "${pre_config_dir}/Dockerfile"
  }
  
  file{"$config_dir":
    ensure => directory,
    mode   => "0766",
  }
  notify{"docker run -i -v ${repository_path}:/component_repository -e 'EXECUTION_ID=${execution_id}' ${pre_config_image_name}":}
  exec{"Generate Level-2 configuration files":
    command => "docker run --rm -i -v ${repository_path}:/component_repository -e 'EXECUTION_ID=${execution_id}' ${pre_config_image_name}",
    path => "/usr/local/bin:/usr/bin/:/bin/:/opt/puppetlabs/bin/:/usr/sue/sbin",
    user => 'root',
    logoutput => true,
    environment => ["HOME=/root"]
  }
  
}
class simple_grid::component::component_repository::lifecycle::event::boot(
  $current_lightweight_component,
  $execution_id,
  $meta_info,
  ## Host directories ##
  $component_repository_dir = lookup('simple_grid::nodes::lightweight_component::component_repository_dir'),
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $scripts_dir = lookup('simple_grid::scripts_dir'),
  ## params for Container Bootup ###
  $network = lookup('simple_grid::components::ccm::container_orchestrator::swarm::network'),
  $component_image_tag = lookup('simple_grid::components::component_repository::component_image_tag'),
  ## Component Repository Directory Structure ##
  $repository_relative_host_certificates_dir = lookup('simple_grid::components::component_repository::relative_host_certificates_dir'),
  $l2_repository_relative_config_dir = lookup('simple_grid::components::component_repository::l2_relative_config_dir'),
  ### Container Directory Structure ###
  $container_scripts_dir = lookup('simple_grid::components::component_repository::container::scripts_dir'),
  $container_host_certificates_dir = lookup('simple_grid::components::component_repository::container::host_certificates_dir'),
  $container_augmented_site_level_config_file = lookup('simple_grid::components::component_repository::container::augmented_site_level_config_file'),
  $container_config_dir = lookup('simple_grid::components::component_repository::container::config_dir')
){
  $augmented_site_level_config = loadyaml($augmented_site_level_config_file)
  $level_2_configurator = simple_grid::get_level_2_configurator($augmented_site_level_config, $current_lightweight_component)
  $repository_name = $current_lightweight_component['name']
  $repository_path = "${component_repository_dir}/${repository_name}"
  $config_dir = "${repository_path}/${level_2_configurator}/${l2_repository_relative_config_dir}"
  if length($meta_info['docker_hub_tag'])> 0 {
    $image_name = $meta_info['docker_hub_tag']
  }else {
    $repository_name_lowercase = downcase($repository_name)
    $image_name = "${repository_name_lowercase}_${component_image_tag}"
    notify{"Building image: ${image_name}":}
    docker::image{"${image_name}":
      docker_file => "${repository_path}/${level_2_configurator}/Dockerfile"
    }
  }
  $host_certificates_dir = "${repository_path}/${repository_relative_host_certificates_dir}"
  $docker_run_command = simple_grid::docker_run($augmented_site_level_config, $current_lightweight_component, $meta_info, $image_name, $augmented_site_level_config_file, $container_augmented_site_level_config_file, $config_dir, $container_config_dir, $scripts_dir, $container_scripts_dir, $host_certificates_dir, $container_host_certificates_dir, $network )
  notify{"Docker run command":}
  notify{"${docker_run_command}":}
  exec{"Booting container for ${current_lightweight_component['name']}":
    command => $docker_run_command,
    path => "/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin",
    user => "root",
    logoutput => true,
    environment => ["HOME=/root"]
  }
}
class simple_grid::component::component_repository::lifecycle::hook::pre_init(
  $current_lightweight_component,
  $execution_id,
  $scripts,
  $container_name,
  $pre_init_hook = lookup('simple_grid::components::component_repository::lifecycle::hook::pre_init'),
  $container_scripts_dir = lookup("simple_grid::components::component_repository::container::scripts_dir"),
){
  $scripts.each |Hash $script|{
    $script_name = split($script['actual_script'], '/')[-1]
    $script_path = "${container_scripts_dir}/${pre_init_hook}/${script_name}"
    $command = "docker exec -t ${container_name} ${script_path}"
    notify{"We about to execute ${command}":}
    exec{"Running pre_init hook for Execution ID ${execution_id}":
      command => $command,
      path    => "/usr/local/bin:/usr/bin/:/bin:/opt/puppetlabs/bin",
      user    => "root",
      logoutput => true,
      environment => ["HOME=/root"]
    }
  }
}
class simple_grid::component::component_repository::lifecycle::event::init(
  $current_lightweight_component,
  $execution_id,
  $container_name,
  $config_dir = lookup('simple_grid::components::component_repository::container::config_dir')
){
  $command = "docker exec -t ${container_name} /${config_dir}/init.sh"
  exec{"Running init event for Execution ID ${execution_id}":
      command => $command,
      path    => "/usr/local/bin:/usr/bin/:/bin:/opt/puppetlabs/bin",
      user    => "root",
      logoutput => true,
      environment => ["HOME=/root"]
  }

}
class simple_grid::component::component_repository::lifecycle::hook::post_init(
  $current_lightweight_component,
  $execution_id,
  $scripts,
  $container_name,
  $post_init_hook = lookup('simple_grid::components::component_repository::lifecycle::hook::post_init'),
  $container_scripts_dir = lookup("simple_grid::components::component_repository::container::scripts_dir"),
){
  $scripts.each |Hash $script|{
    $script_name = split($script['actual_script'], '/')[-1]
    $script_path = "${container_scripts_dir}/${post_init_hook}/${script_name}"
    $command = "docker exec -t ${container_name} ${script_path}"
    notify{"We about to execute ${command}":}
    exec{"Running pre_init hook for Execution ID ${execution_id}":
      command => $command,
      path    => "/usr/local/bin:/usr/bin/:/bin:/opt/puppetlabs/bin",
      user    => "root",
      logoutput => true,
      environment => ["HOME=/root"]
    }
  }
}

