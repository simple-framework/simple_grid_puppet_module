# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include simple
class simple_grid(
	$config_dir
){
	simple_grid::yaml_parser()
	Class[simple_grid::pre_conf] -> Class[simple_grid::orchestrator_conf]
	class{"simple_grid::pre_conf":
		config_dir => $config_dir,
	}
	class{"simple_grid::orchestrator_conf":}
}
