# class simple_grid::pre_deploy::lightweight_component::copy_lifecycle_callbacks(
#   $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
#   $scripts_dir = lookup('simple_grid::scripts_dir'),
# ){
#   $execution_id_master_id_pairs = simple_grid::get_execution_ids($augmented_site_level_config_file, $fqdn)
#   file{'Creating directory for scripts':
#     ensure => directory,
#     path   => $scripts_dir
#   }
#   notify{"Copying Lifecycle Callbacks on ${fqdn}":}
#   $execution_id_master_id_pairs.each |Integer $index, Hash $execution_id_master_id_pair| {
#     file{"Copying lifecycle callback scripts for execution id ${execution_id_master_id_pair['execution_id']}":
#       ensure  => directory,
#       recurse => 'remote',
#       source  => "puppet:///simple_grid/${scripts_dir}/${execution_id_master_id_pair['id']}",
#       path    => "${scripts_dir}/${execution_id_master_id_pair['execution_id']}",
#       mode    => '0766'
#     }
#   }
# }
