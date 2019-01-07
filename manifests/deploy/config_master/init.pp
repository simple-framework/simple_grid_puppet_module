class simple_grid::deploy::config_master::init(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $deploy_status_file = "/etc/simple_grid/.deploy_status.yaml",
  $retry_interval = 10,
  $max_retries = 6
){
  $augmented_site_level_config = loadyaml("${augmented_site_level_config_file}")
  $lightweight_components = $augmented_site_level_config['lightweight_components']

  $lightweight_components.each |Integer $index, Hash $lightweight_component| {
    if $index > 0 {
      $last_index = $index -1 
      $execution_status = file("etc/simple_grid/.${last_index}.status")
      notify{"Execution Status of ${last_index} was ${execution_status}":}
      if $execution_status == "error" {
        fail("Error Message will be shown here")
      }
    }
    $node_fqdn = $lightweight_component['deploy']['node']
    notify{"Deploying ${lightweight_component['name']} on ${node_fqdn} with execution_id ${index}":}
    exec{"Executing puppet agent on ${node_fqdn} to deploy ${lightweight_component['name']} with execution_id ${index}":
     command => "bolt task run simple_grid::deploy execution_id=${index} --modulepath /etc/puppetlabs/code/environments/simple/site/ --nodes ${node_fqdn}",
     path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
     user    => 'root',
    }
    file{"etc/simple_grid/.${index}.status":
      ensure => present,
    }
    exec{"Waiting for deployment of ${index} to end":
      command => "bolt task run simple_grid::deploy_status \
      node_fqdn=${node_fqdn} \
      deploy_status_file=${deploy_status_file} \
      execution_id=${index} retry_interval=${retry_interval} \
      max_retries=${max_retries} \
      modulepath= /etc/puppetlabs/code/environments/production/modules/ \
      --modulepath /etc/puppetlabs/code/environments/simple/site/:/etc/puppetlabs/code/environments/simple/modules/ \
      --nodes localhost > /etc/simple_grid/.${index}.status", #${node_fqdn} > /etc/simple_grid/${index}.status",
      path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
      user    => root
    }
  
    #$status_file = file("etc/simple_grid/.${index}.status")
    # exec{"Processing deployment result for ${index}":
    #   command => "bolt task run simple_grid::deploy_status execution_id=${index} --modulepath /etc/puppetlabs/code/environments/simple/site/:/etc/puppetlabs/code/environments/simple/modules/ --nodes localhost >> /etc/simple_grid/.${index}.status", #${node_fqdn} > /etc/simple_grid/${index}.status",
    #   path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
    #   user    => root
    # }
  }
}
