# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include simple
class simple_grid(
	$config_dir
){
  $output = simple_grid::site_config_parser('/etc/simple_grid/simple_grid_yaml_compiler/output.yaml','site')
  $output.each|Integer $index, Hash $value| {
    $fqdn = $value['fqdn']
    notify{"${fqdn}":}
  }
	Class[simple_grid::pre_conf] -> Class[simple_grid::orchestrator_conf]
	class{"simple_grid::pre_conf":
		config_dir => $config_dir,
	}
	class{"simple_grid::orchestrator_conf":}
}
