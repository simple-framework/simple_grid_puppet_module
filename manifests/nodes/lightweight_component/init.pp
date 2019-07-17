class simple_grid::nodes::lightweight_component::init(
  $mode = lookup('simple_grid::mode'),
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $preferred_tech_stack_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack"),
  $container_orchestration_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration"),
  $swarm_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::swarm"),
  $kubernetes_key = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::kubernetes"),
  $default_orchestrator = lookup("simple_grid::components::site_level_config_file::objects::preferred_tech_stack::container_orchestration::default"),
  $cm_node_type = lookup("simple_grid::node_type:config_master"),
  $lc_node_type = lookup("simple_grid::node_type:lightweight_component"),
)
{
  if $simple_stage == lookup('simple_grid::stage::install'){
    class{"simple_grid::install::lightweight_component::init":}
    class{"docker":
        version => '18.09.2'
    }
    simple_grid::components::execution_stage_manager::set_stage { "Setting stage to pre_deploy_step_1":
      simple_stage => lookup('simple_grid::stage::pre_deploy::step_1') #handled by tasks executed by CM
    }
  }
  elsif $simple_stage == lookup('simple_grid::stage::pre_deploy::step_1') {
    simple_grid::components::execution_stage_manager::set_stage {"Setting stage to pre_deploy_step_2":
       simple_stage => lookup('simple_grid::stage::pre_deploy::step_2') 
    }
  }
  elsif $simple_stage == lookup('simple_grid::stage::pre_deploy::step_2'){
    class{"simple_grid::pre_deploy::lightweight_component::generate_deploy_status_file":}
    class{"simple_grid::pre_deploy::lightweight_component::copy_augmented_site_level_config":}
    class{"simple_grid::pre_deploy::lightweight_component::copy_additional_files":}
    class{"simple_grid::pre_deploy::lightweight_component::copy_lifecycle_callbacks":}
    class{"simple_grid::pre_deploy::lightweight_component::copy_host_certificates":}
    simple_grid::components::execution_stage_manager::set_stage {"Setting stage to pre_deploy_step_3":
      simple_stage => lookup('simple_grid::stage::pre_deploy::step_3')
    }
  }
  elsif $simple_stage == lookup('simple_grid::stage::pre_deploy::step_3') {
    include 'git'
    class{'simple_grid::ccm_function::config_orchestrator':}
    class{'simple_grid::pre_deploy::lightweight_component::download_component_repository':}
    simple_grid::components::execution_stage_manager::set_stage {"Setting stage to deploy step 1":
      simple_stage => lookup('simple_grid::stage::deploy::step_1') #handled by tasks executed by CM
    }
  }
  elsif $simple_stage == lookup('simple_grid::stage::deploy::step_1')  {
    #handled by tasks from puppet master, which do a puppet apply simple_grid::deploy_step_1::lightweight_component::init($execution_id)
    #start container here for the first entry in $facts['execution_pending']
    # class {"simple_grid::components::execution_stage_manager::set_stage":
    #    simple_stage => lookup('simple_grid::stage::final') #handled by tasks executed by CM
    #  }
  }
  elsif $simple_stage == lookup('simple_grid::stage::deploy::step_2')  {
    #handled by tasks from puppet master, which do a puppet apply simple_grid::deploy_step_2::lightweight_component::init($execution_id)
    #start container here for the first entry in $facts['execution_pending']
    # class {"simple_grid::components::execution_stage_manager::set_stage":
    #    simple_stage => lookup('simple_grid::stage::final') #handled by tasks executed by CM
    #  }
  }
  elsif $simple_stage == lookup('simple_grid::stage::final'){
    #for each execution id on this LC node, make sure firewall rules are correct, containers are running, perform any tests to check the status of containers.
  }
}
