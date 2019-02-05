class simple_grid::deploy::config_master::init(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $simple_config_dir = lookup('simple_grid::simple_config_dir'),
  $deploy_status_file = lookup("simple_grid::nodes::lightweight_component::deploy_status_file"),
  $deploy_status_success = lookup("simple_grid::stage::deploy::status::success"),
  $deploy_status_failure = lookup("simple_grid::stage::deploy::status::failure")
 ){
    $modulepath = "/etc/puppetlabs/code/environments/production/modules"
    exec{"Executing deploy master":
      command => "bolt task run simple_grid::deploy_master \
        simple_config_dir=${simple_config_dir} \
        augmented_site_level_config_file=${augmented_site_level_config_file} \
        deploy_status_file=${deploy_status_file} \
        deploy_status_output_dir=${simple_config_dir} \
        deploy_status_success=${deploy_status_success} \
        deploy_status_failure=${deploy_status_failure} \
        modulepath=${modulepath} \
        --modulepath /etc/puppetlabs/code/environments/simple/site/ \
        --nodes localhost",
      path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
      user    => 'root',
      logoutput => true,
      environment => ["HOME=/root"]
      }
 }
