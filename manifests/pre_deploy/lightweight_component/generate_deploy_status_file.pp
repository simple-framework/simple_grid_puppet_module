class simple_grid::pre_deploy::lightweight_component::generate_deploy_status_file(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $deploy_status_file = lookup('simple_grid::nodes::lightweight_component::deploy_status_file'),
  $initial_deploy_status = lookup('simple_grid::stage::deploy::status::initial')
){
  notify{"**** Node LC; Stage Pre_Deploy; ":}
  $content = loadyaml("${augmented_site_level_config_file}")
  $deploy_statuses = simple_grid::generate_deploy_status($content, $fqdn, $initial_deploy_status)
  notify{"Deploy status for $fqdn are $deploy_statuses":}
  $deploy_status = {
    "deploy_status"             => $deploy_statuses,
    "execution_request_history" => [],
  }
  file{"Write execution ID's to ${deploy_status_file}":
    path    => "${deploy_status_file}",
    content => to_yaml($deploy_status),
    ensure  => present,
  }
}
