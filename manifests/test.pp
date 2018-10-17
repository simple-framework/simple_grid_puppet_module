class simple_grid::test (
  $config_param,
  $os_param,
){
  notify {"Test Results":
    name => "${config_param} and ${os_param}"
  }
}
