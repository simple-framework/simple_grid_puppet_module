class simple_grid::deploy::config_master::init(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output')
){
  $augmented_site_level_config = loadyaml("${augmented_site_level_config_file}")
  $lightweight_components = $augmented_site_level_config['lightweight_components']
  $lightweight_components.each |Integer $index, Hash $lightweight_component| {
    $node_fqdn = $lightweight_component['deploy']['node']
    notify{"Deploying ${lightweight_component['name']} on ${node_fqdn} with execution_id ${index}":}
    exec{"Executing puppet agent on  ${node_fqdn} to deploy ${lightweight_component['name']} with execution_id ${index}":
     command => "bolt task run simple_grid::deploy execution_id=${index} --modulepath /etc/puppetlabs/code/environments/simple/site/ --nodes ${node_fqdn}",
     path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
     user    => 'root',
    }
    #task > /tmp/status
    #if status is completed
      #execution for the current node
    #if not completed, try again
    wait_for {"waiting for deployment of ${index} to end':
      query => "bolt task run simple_grid::deploy execution_id=${index} --modulepath /etc/puppetlabs/code/environments/simple/site/ --nodes ${node_fqdn}",
      
    }
  }

}
