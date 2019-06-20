class simple_grid::deploy::config_master::init(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $simple_config_dir = lookup('simple_grid::simple_config_dir'),
  $deploy_status_file = lookup("simple_grid::nodes::lightweight_component::deploy_status_file"),
  $deploy_status_success = lookup("simple_grid::stage::deploy::status::success"),
  $deploy_status_failure = lookup("simple_grid::stage::deploy::status::failure"),
  $unit_deployment_timeout = lookup("simple_grid::components::component_repository::unit_deployment_timeout"),
  $dns_key = lookup('simple_grid::components::site_level_config_file::objects:dns_parent')
 ){
    $modulepath = "/etc/puppetlabs/code/environments/production/modules"
    $augmented_site_level_config = loadyaml($augmented_site_level_config_file)
    $no_lightweight_components = length($augmented_site_level_config['lightweight_components'])
    $timeout = $no_lightweight_components * $unit_deployment_timeout
    $timeout_minutes = $timeout/60
    Notify{"Starting Deployment. This may take a while!. Setting timeout to: ${timeout_minutes} minutes. Don't worry you'll be done waayyy sooner. This is just a worst case condition.":}
    exec{"Executing deploy master":
      command => "bolt task run simple_grid::deploy_master \
        simple_config_dir=${simple_config_dir} \
        augmented_site_level_config_file=${augmented_site_level_config_file} \
        dns_key=${dns_key} \
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
      environment => ["HOME=/root"],
      timeout => $timeout
      }
 }
