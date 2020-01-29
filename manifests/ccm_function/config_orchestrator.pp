class simple_grid::ccm_function::config_orchestrator(
  $augmented_site_level_config_file = lookup("simple_grid::components::yaml_compiler::output"),
  $preferred_tech_stack_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack"),
  $container_orchestration_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration"),
  $swarm_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::swarm"),
  $kubernetes_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::kubernetes"),
  $default_orchestrator = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::default"),
  $cm_node_type = lookup("simple_grid::node_type:config_master"),
  $lc_node_type = lookup("simple_grid::node_type:lightweight_component"),
  $swarm_status_file = lookup('simple_grid::components::swarm::status_file')
){
  $augmented_site_level_config = loadyaml($augmented_site_level_config_file)
  if has_key($augmented_site_level_config, $preferred_tech_stack_key){
    $preferred_tech_stack = $augmented_site_level_config[$preferred_tech_stack_key]
    if has_key($preferred_tech_stack, $container_orchestration_key){
      $container_orchestrator = $preferred_tech_stack[$container_orchestration_key]
    }
  }
  if length($container_orchestrator) <1 {
    $container_orchestrator  = $default_orchestrator
  }

  if $container_orchestrator == $swarm_key {
    if $facts['simple_node_type'] == $cm_node_type {
      class{'simple_grid::components::swarm::install::generate_dns_info_and_swarm_status':}
      $lightweight_components = $augmented_site_level_config['lightweight_components']
      $lightweight_components.each |Integer $index, Hash $lightweight_component| {
        if $lightweight_component['execution_id'] == 0 {
          $main_manager = $lightweight_component['deploy']['node']
          class{'simple_grid::components::swarm::init':
            main_manager => $main_manager
          }
          class{'simple_grid::components::swarm::recreate_ingress':
            main_manager => $main_manager,
          }
          class{'simple_grid::components::swarm::create_network':
            main_manager => $main_manager,
          }
          break()
        }
      }
    }
    elsif $facts['simple_node_type'] == $lc_node_type{
      $swarm_status = loadyaml("${swarm_status_file}")
      $main_manager = $swarm_status["main_manager"]
      $managers = $swarm_status["managers"]
      $manager_token = $swarm_status["tokens"]["manager"]
      $worker_token = $swarm_status["tokens"]["worker"]
      class{'simple_grid::components::swarm::configure::firewall':}
      if $fqdn in $managers {
        class {'simple_grid::components::swarm::join':
          token        => $manager_token,
          main_manager => $main_manager,
        }
      } elsif $fqdn == $main_manager{
          notify{'Not executing docker swarm join command as the node is the main swarm manager':}
      }else {
        class {'simple_grid::components::swarm::join':
          token        => $worker_token,
          main_manager => $main_manager
        }
      }
    }
  }
  elsif $container_orchestrator == $kuberentes_key {
    fail('Oops!!! Kubernetes is not supported by the version of SIMPLE. Try using Docker Swarm instead.')
  }
}
