class simple_grid::pre_deploy::lightweight_component::download_component_repository(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $component_repository_dir = lookup('simple_grid::nodes::lightweight_component::component_repository_dir'),
  $component_repository_default_revision = lookup('simple_grid::components::component_repository::default_revision')
){
  file{"Creating directory for storing component repositories":
    ensure => directory,
    path => "${component_repository_dir}",
  }
  $execution_id_id_pairs = simple_grid::get_execution_ids($augmented_site_level_config_file, $fqdn)
  $augmented_site_level_config = loadyaml("${augmented_site_level_config_file}")
  $execution_id_id_pairs.each |Integer $index, Hash $execution_id_id_pair|{
    $lightweight_components = $augmented_site_level_config['lightweight_components']
    $lightweight_components.each |Integer $lightweight_index, Hash $lightweight_component|{
      if $lightweight_component['execution_id'] == $execution_id_id_pair['execution_id']{
        $repository_url = $lightweight_component["repository_url"]
        $revision = $lightweight_component["repository_revision"]
        $component_name = $lightweight_component["name"]
        if length($revision) < 1 {
          $revision = $component_repository_default_revision
        }
        notify{"Downloading ${repository_url} for execution_id ${execution_id_id_pair['execution_id']}":}
        vcsrepo {"${component_repository_dir}/${component_name}_${execution_id_id_pair['execution_id']}":
          ensure   => present,
          provider => git,
          revision => $revision,
          source   => $repository_url,
        }
      }
    }
  }
}
