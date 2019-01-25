 class simple_grid::deploy::lightweight_component::init(
  $execution_id
){
    #execution happens using puppet apply through the deploy task during the deploy stage   
    notify{"Incoming request for exeuction id ${execution_id}":} 
    $int_execution_id = 0 + $execution_id
    simple_grid::update_execution_request_history('/etc/simple_grid/.deploy_status.yaml', $int_execution_id)
    $execute_now = simple_grid::execute_now('/etc/simple_grid/.deploy_status.yaml', $int_execution_id)
    if $execute_now {
        #simple_grid::set_execution_status('/etc/simple_grid/.deploy_status.yaml', $execution_id, "deploying")
        notify{"EXECUTING ${execution_id} NOW!!!!":}
        #file {'/etc/simple_grid/.deploy_status.yaml':
        #    content => to_yaml($post_execution_deploy_status)
        #}
    }
    # $execution_ids = simple_grid::get_execution_ids($augmented_site_level_config_file, $fqdn)
    # $execution_ids.each |execution_id| {
    # file{"Copying lifecycle callback scripts for execution_id's corresponding to ${fqdn}":
    #   source => "puppet:///simple_grid/${site_config_dir_name}/${augmented_site_level_config_file_name}",
    #   path   => "${augmented_site_level_config_file}",
    #   mode   => "744"
    # }
  }
    file{"/Chala":
        content => "BCBCBCBC"
    }
}
