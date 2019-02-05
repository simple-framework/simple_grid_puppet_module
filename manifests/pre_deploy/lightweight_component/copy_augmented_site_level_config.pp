class simple_grid::pre_deploy::lightweight_component::copy_augmented_site_level_config(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $site_config_dir = lookup('simple_grid::site_config_dir'),
  $site_config_dir_name = lookup('simple_grid::site_config_dir_name'),
  $augmented_site_level_config_file_name = lookup('simple_grid::components::yaml_compiler::output_file_name'),
  $initial_deploy_status = lookup('simple_grid::stage::deploy::status::initial')
){
  file{"Creating directory ${site_config_dir}":
    ensure => directory,
    path   => "${site_config_dir}",
  }
  file{"Copying augmented site level configuration file from CM to ${augmented_site_level_config_file}":
    ensure => present,
    source => "puppet:///simple_grid/${site_config_dir_name}/${augmented_site_level_config_file_name}",
    path => "${augmented_site_level_config_file}",
    mode => "0644",
  }
}
