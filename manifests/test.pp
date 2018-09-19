class simple_grid::test (
  String $config   = 'from class',
  String $os_param =  'from class',
){
  notify {"Test Results":
    name => "${::config} and ${::os_param}"
  }
}
