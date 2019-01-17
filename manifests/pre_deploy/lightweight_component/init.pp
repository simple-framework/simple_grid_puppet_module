class simple_grid::pre_deploy::lightweight_component::init(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $site_config_dir = lookup('simple_grid::site_config_dir'),
  $site_config_dir_name = lookup('simple_grid::site_config_dir_name'),
  $augmented_site_level_config_file_name = lookup('simple_grid::components::yaml_compiler::output_file_name')
){
  notify{"**** Node LC; Stage Pre_Deploy; ":}
  $deploy_status_file = lookup('simple_grid::nodes::lightweight_component::deploy_status_file')
  $content = loadyaml("${augmented_site_level_config_file}")
  $deploy_statuses = simple_grid::generate_deploy_status($content, $fqdn)
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
  file{"Creating directory ${site_config_dir}":
    ensure => directory,
    path   => "${site_config_dir}",
  }
  class{"simple_grid::ccm_function::copy":
    message => "Copying augmented site level configuration file from CM to ${augmented_site_level_config_file}",
    source => "${site_config_dir_name}/${augmented_site_level_config_file_name}",
    destination => "${augmented_site_level_config_file}",
    mode => "0644",
  }
}
