class simple_grid::pre_deploy::config_master::rollback(
  $dns_file = lookup('simple_grid::components::ccm::container_orchestrator::swarm::dns'),
  $dns_parent_name = lookup('simple_grid::components::site_level_config_file::objects:dns_parent'),
  $meta_info_prefix = lookup('simple_grid::components::site_level_config_file::objects:meta_info_prefix'),
  $mode = lookup('simple_grid::mode'),
  $subnet = lookup('simple_grid::components::ccm::container_orchestrator::swarm::subnet'),
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $network = lookup('simple_grid::components::ccm::container_orchestrator::swarm::network'),
){
  notify{"Rolling back lifecycle callback scripts for all lightweight components":}
  include simple_grid::ccm_function::rollback_aggregate_repository_lifecycle_scripts
}
