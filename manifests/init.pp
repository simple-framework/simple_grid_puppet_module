# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include simple
class simple_grid(
	$test_param,
	$os_param
	)
	{
	file { '/root/test':
		ensure => present,
		content => "r10k check configuration",
	}
	notify {"aag laga di ${test_param} and ${os_param}":}
	#include simple_grid::test
	#notify {"config was ${test_param} and param was ${os_param}":}	
	Class[simple::pre_conf] -> Class[simple::orchestrator_conf]
	
	class{"simple::pre_conf":}
	class{"simple::handle_repos":}
}
