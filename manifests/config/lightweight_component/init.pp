#not part for specification, exists only to add puppet fact specific configuration on LC
class simple_grid::config::lightweight_component::init(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output')
){
  notify{"**** Node LC; Stage Config; Not part of project specification, this stage only does puppet specific edits on LC":}
  $deploy_status_file = lookup('simple_grid::nodes::lightweight_component::deploy_status_file')
  $content = loadyaml("${augmented_site_level_config_file}")
  $deploy_statuses = simple_grid::generate_deploy_status($content, $fqdn)
  notify{"Deploy status for $fqdn are $deploy_status":}
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
