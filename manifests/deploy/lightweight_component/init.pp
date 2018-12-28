class simple_grid::deploy::lightweight_component::init(
  $execution_id
){
    #execution happens using puppet agent -t through a bolt task during the deploy stage   
    notify{"Incoming request for exeuction id ${execution_id}":} 
    $int_execution_id = 0 + $execution_id
    $execute_now = simple_grid::check_current_execution_id('/etc/simple_grid/.deploy_status.yaml', $int_execution_id)
    $post_execution_deploy_status = simple_grid::post_execution_deploy_status('/etc/simple_grid/.deploy_status.yaml', $int_execution_id)
    if $execute_now {
        notify{"EXECUTING ${execution_id} NOW!!!! $post_execution_deploy_status":}
        file {'/etc/simple_grid/.deploy_status.yaml':
            content => to_yaml($post_execution_deploy_status)
        }
    }

    file{"/Chala":
        content => "BCBCBCBC"
    }
}
