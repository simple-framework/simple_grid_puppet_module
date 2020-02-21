class simple_grid::deploy::config_master::init(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $simple_config_dir = lookup('simple_grid::simple_config_dir'),
  $deploy_status_file = lookup("simple_grid::nodes::lightweight_component::deploy_status_file"),
  $execution_status_file_name = lookup("simple_grid::nodes::config_master::execution_status_file_name"),
  $deploy_status_success = lookup("simple_grid::stage::deploy::status::success"),
  $deploy_status_failure = lookup("simple_grid::stage::deploy::status::failure"),
  $unit_deployment_timeout = lookup("simple_grid::components::component_repository::unit_deployment_timeout"),
  $dns_key = lookup('simple_grid::components::site_level_config_file::objects:dns_parent'),
  $env_name = lookup('simple_grid::components::ccm::install::env_name'),
  $deploy_step_1 = lookup('simple_grid::stage::deploy::step_1'),
  $deploy_step_2 = lookup('simple_grid::stage::deploy::step_2'),
  $stage_final = lookup('simple_grid::stage::final'),
  $stage_config_file = lookup('simple_grid::components::execution_stage_manager::config_file'),
  $log_dir = lookup('simple_grid::simple_log_dir')
 ){
    $modulepath = "/etc/puppetlabs/code/environments/production/modules"
    $augmented_site_level_config = loadyaml($augmented_site_level_config_file)
    $no_lightweight_components = length($augmented_site_level_config['lightweight_components'])
    $timeout = $no_lightweight_components * $unit_deployment_timeout
    $timeout_minutes = $timeout/60
    $timestamp = "${strftime('%Y-%m-%dT%H:%M:%S-%Z')}"
    Notify{"Starting Deployment with identifier: ${timestamp}. This may take a while!. Generally around 15-20 minutes per container \
depending on several factors. Please use the SIMPLE command line utility to probe the details of the deployment. \
You can also create a file called lc.txt containing the ip address of all LC hosts in a new line. \
Then you can run: \"bolt command run '\${some_inspection_command}' --targets @lc.txt\" to inspect all nodes. \
Where, \${some_inspection_command} could be: \n docker image ls \ndocker ps -a\n":}
    exec{"Executing deploy master":
      command => "bolt task run simple_grid::deploy_master \
        simple_config_dir=${simple_config_dir} \
        augmented_site_level_config_file=${augmented_site_level_config_file} \
        dns_key=${dns_key} \
        deploy_step_1=${deploy_step_1} \
        deploy_step_2=${deploy_step_2} \
        deploy_status_file=${deploy_status_file} \
        execution_status_file_name=${execution_status_file_name} \
        deploy_status_success=${deploy_status_success} \
        deploy_status_failure=${deploy_status_failure} \
        modulepath=${modulepath} \
        log_dir=${log_dir} \
        timestamp=${timestamp} \
        stage_final=${stage_final} \
        stage_config_file=${stage_config_file} \
        --modulepath ${puppet_environmentpath}/${env_name}/site/:${puppet_environmentpath}/${env_name}/modules/ \
        --targets localhost",
      path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
      user    => 'root',
      logoutput => true,
      environment => ["HOME=/root"],
      timeout => $timeout
      }
 }
