 class simple_grid::deploy::lightweight_component::init(
  $execution_id,
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $deploy_status_file = lookup('simple_grid::nodes::lightweight_component::deploy_status_file'),
  $component_repository_dir = lookup('simple_grid::nodes::lightweight_component::component_repository_dir'),
  $meta_info_file_name = lookup('simple_grid::components::component_repository::meta_info_file')
){
    #execution happens using puppet apply through the deploy task during the deploy stage   
    notify{"Incoming request for execution id ${execution_id}":} 
    simple_grid::update_execution_request_history($deploy_status_file, $execution_id)
    #$execute_now = simple_grid::execute_now($deploy_status_file, $execution_id)
    #if True {
        #simple_grid::set_execution_status('/etc/simple_grid/.deploy_status.yaml', $execution_id, "deploying")
        $current_lightweight_component = simple_grid::get_lightweight_component($augmented_site_level_config_file, $execution_id)
        $repository_name = $current_lightweight_component['name']
        $repository_path = "${component_repository_dir}/${repository_name}"
        notify{"Deploying execution_id ${execution_id} with name ${repository_path} now!!!!":}
        $meta_info_file = "${repository_path}/${meta_info_file_name}"
        $meta_info = loadyaml($meta_info_file)
        $firewall_rules = $meta_info['host_requirements']['firewall']
        $cvmfs = $meta_info['host_requirements']['cvmfs']
        $firewall_rules.each |Integer $index, Hash $firewall_rule| {
            firewall { 'Setting rule number $index':
                        dport  => $firewall_rule[ports],
                        action => $firewall_rule[action],
                        proto  => $firewall_rule[protocol],
                }
            notify{"Meta Info: ${firewall_rule}":}
        }
        #$repo_meta_info = loadyaml("/etc/simple_grid/repositories/meta-info.yaml")
        #file {'/etc/simple_grid/.deploy_status.yaml':
        #    content => to_yaml($post_execution_deploy_status)
        #}
    #}else {
    #    fail("The execution id ${execution_id} is either not supposed to be executed on the host or has already been deployed during this deployment cycle.")
    #}
    # $execution_ids = simple_grid::get_execution_ids($augmented_site_level_config_file, $fqdn)
    # $execution_ids.each |execution_id| {
    # file{"Copying lifecycle callback scripts for execution_id's corresponding to ${fqdn}":
    #   source => "puppet:///simple_grid/${site_config_dir_name}/${augmented_site_level_config_file_name}",
    #   path   => "${augmented_site_level_config_file}",
    #   mode   => "744"
    # }
  #}
    file{"/Chala":
        content => "BCBCBCBC"
    }
}
