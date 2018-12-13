class simple_grid::nodes::lightweight_component::init(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output')
){

  if $simple_stage == lookup('simple_grid::stage::install') {
    notify{"**** Node LC; Stage Pre_Deploy":}
    $deploy_status_file = lookup('simple_grid::nodes::lightweight_component::deploy_status_file')
    $content = loadyaml("${augmented_site_level_config_file}")
    $execution_ids = simple_grid::generate_execution_ids($content, $fqdn)
    notify{"Execution id for $fqdn are $execution_ids":}
    $deploy_status = {
      "execution_pending"    => $execution_ids,
      "execution_completed"  => []
    }
    file{"Write execution ID's to ${deploy_status_file}":
      path    => "${deploy_status_file}",
      content => to_yaml($deploy_status),
      ensure  => present,
    }
  }else{
    class {"simple_grid::components::ccm::config":
      node_type => "LC"
    }
    class {"simple_grid::components::execution_stage_manager::set_stage":
      simple_stage => lookup('simple_grid::stage::install')
    }
  }
}
