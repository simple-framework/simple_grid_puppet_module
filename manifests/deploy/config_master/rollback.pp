class simple_grid::deploy::config_master::rollback(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $simple_config_dir = lookup('simple_grid::simple_config_dir'),
  $deploy_status_file = lookup("simple_grid::nodes::lightweight_component::deploy_status_file"),
  $deploy_status_pending = lookup("simple_grid::stage::deploy::status::initial"),
  $deploy_status_success = lookup("simple_grid::stage::deploy::status::success"),
  $deploy_status_failure = lookup("simple_grid::stage::deploy::status::failure"),
  $dns_key = lookup('simple_grid::components::site_level_config_file::objects:dns_parent'),
  $env_name = lookup('simple_grid::components::ccm::install::env_name')
){
    $modulepath = "/etc/puppetlabs/code/environments/production/modules"
    $augmented_site_level_config = loadyaml($augmented_site_level_config_file)
    notify{"Rollback for Deploy Stage initiated":}
    $command = "bolt task run simple_grid::rollback_deploy_master \
        simple_config_dir=${simple_config_dir} \
        augmented_site_level_config_file=${augmented_site_level_config_file} \
        deploy_status_output_dir=${simple_config_dir} \
        deploy_status_pending=${deploy_status_pending} \
        deploy_status_file=${deploy_status_file} \
        deploy_status_success=${deploy_status_success} \
        deploy_status_failure=${deploy_status_failure} \
        deploy_status_pending=${deploy_status_pending} \
        dns_key=${dns_key} \
        modulepath=${modulepath} \
        --modulepath ${puppet_environmentpath}/${env_name}/site/ \
        --nodes localhost"
    exec{"Executing deploy master":
      command => $command,
      path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
      user    => 'root',
      logoutput => true,
      environment => ["HOME=/root"]
    }
    simple_grid::components::execution_stage_manager::set_stage {"Setting stage to deploy":
    simple_stage => lookup('simple_grid::stage::deploy')
  }
}
