# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include simple
class simple_grid{
	Class[simple::pre_conf] -> Class[simple::orchestrator_conf]
	class{"simple::pre_conf":}
	class{"simple::orchestrator_conf":}
}
