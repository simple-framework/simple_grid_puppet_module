class simple_grid::nodes::lightweight_component::init(
  $mode = lookup('simple_grid::mode')
)
{
  if $simple_stage == lookup('simple_grid::stage::pre_deploy') {
    # Docker Swarm responsibilities delegated to tasks. Rest happens here
    class{"simple_grid::pre_deploy::lightweight_component::init":}
    # class {"simple_grid::components::execution_stage_manager::set_stage":
    #   simple_stage => lookup('simple_grid::stage::deploy') #handled by tasks executed by CM
    # }
  }
  elsif $simple_stage == lookup('simple_grid::stage::deploy') {
    #handled by tasks from puppet master, which do a puppet apply simple_grid::deploy::lightweight_component::init($execution_id)
    #start container here for the first entry in $facts['execution_pending']
  }
  elsif $simple_stage == lookup('simple_grid::stage::final'){
    #for each execution id on this LC node, make sure firewall rules are correct, containers are running, perform any tests to check the status of containers.
  }
  elsif $simple_stage == lookup('simple_grid::stage::install'){
    class{"simple_grid::install::lightweight_component::init":}    
    #class{"simple_grid::config::lightweight_component::init":} #not in specification, added to do puppet specific configuration
    class {"simple_grid::components::execution_stage_manager::set_stage":
      simple_stage => lookup('simple_grid::stage::pre_deploy') #handled by tasks executed by CM
    }
    #TODO should this be in release mode? Check
    if $mode == lookup('simple_grid::mode::release') {
      include docker
    }
    #TODO firewall
    # firewall{'open port ':
    #   dport => 2376
    # }
  }
}
