class simple_grid::components::enc::install(
  $repository_url,
  $revision,
  $enc_dir = lookup('simple_grid::components::enc::enc_dir'),
){
  notify{"Installing ENC at $enc_dir": }
  
  vcsrepo {"${enc_dir}":
    ensure   => present,
    provider => git,
    revision => $revision,
    source   => $repository_url,
  }

}

class simple_grid::components::enc::configure(
  $enc_dir = lookup('simple_grid::components::enc::enc_dir'),
  $enc_executable = lookup('simple_grid::components::enc::enc_executable'),
  $puppet_conf = lookup('simple_grid::config_master::puppet_conf')
){
  notify{"Configuring ENC":}
  
  simple_grid::puppet_conf_editor("$puppet_conf",'master','node_terminus','execute', true)
  
  simple_grid::puppet_conf_editor("$puppet_conf",'master','external_nodes', "${enc_executable}", true)
}

