class simple_grid::deploy::config_master::init(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $simple_config_dir = lookup('simple_grid::simple_config_dir'),
  $deploy_status_file = lookup("simple_grid::nodes::lightweight_component::deploy_status_file"),
  $deploy_status_success = lookup("simple_grid::stage::deploy::status::success"),
  $deploy_status_failure = lookup("simple_grid::stage::deploy::status::failure")
){
  $augmented_site_level_config = loadyaml("${augmented_site_level_config_file}")
  $lightweight_components = $augmented_site_level_config['lightweight_components']
  # Append a dummy lightweight_component in the end.
  $dummy_final_lightweight_component = {
    "name" => "Dummy LC", 
    "description" => "Required to ensure processing of return codes of the final lightweight_component"
  }
  $lightweight_components_augmented = concat($lightweight_components, $dummy_final_lightweight_component)
  $final_index = length($lightweight_components_augmented) - 1
  $lightweight_components_augmented.each |Integer $index, Hash $lightweight_component| {
    if $index > 0 { 
      $last_index = $index - 1
      $execution_status_file = "${simple_config_dir}/.${last_index}.status" 
      $execution_data = simple_grid::process_deploy_status("${execution_status_file}")
      notify{"Execution Status of ${last_index} was ${execution_data['status']}":}
      #if $execution_data['status'] == $deploy_status_failure {
      #  fail("Terminating deployment of Lightweight Components. Execution of Lightweight Component with execution_id ${last_index} failed. Please see /etc/simple_grid/.${last_index}.status for more details.")
      #}
    }
    #if index is last element (dummy component, exit here), else do the following
    if($index == $final_index){
        notify{"*** Reached end of Deployment Stage ****":}
    }
    else {
      $node_fqdn = $lightweight_component['deploy']['node']
      notify{"Deploying ${lightweight_component['name']} on ${node_fqdn} with execution_id ${index}":}
      exec{"Executing puppet agent on ${node_fqdn} to deploy ${lightweight_component['name']} with execution_id ${index}":
      command => "bolt task run simple_grid::deploy \
        execution_id=${index} \
        deploy_status_file=${deploy_status_file} \
        deploy_status_success=${deploy_status_success} \
        deploy_status_failure=${deploy_status_failure} \
        --modulepath /etc/puppetlabs/code/environments/simple/site/ \
        --nodes ${node_fqdn}",
      path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
      user    => 'root',
      logoutput => 'on_failure',
      environment => ["HOME=/root"]
      }
    
      exec{"Writing deployment status to /etc/simple_grid/.${index}.status":
        command => "bolt task run simple_grid::deploy_status \
        deploy_status_file=${deploy_status_file} \
        execution_id=${index} \
        --modulepath /etc/puppetlabs/code/environments/simple/site/:/etc/puppetlabs/code/environments/simple/modules/ \
        --nodes ${node_fqdn} \
        > /etc/simple_grid/.${index}.status",
        path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
        user    => root,
        logoutput => 'on_failure',
        environment => ["HOME=/root"]
      }
    }
  }
}
