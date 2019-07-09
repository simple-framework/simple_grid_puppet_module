class simple_grid::pre_deploy::lightweight_component::copy_host_certificates(
  $host_certificates_dir = lookup('simple_grid::host_certificates_dir'),
  $host_certificates_dir_name = lookup('simple_grid::host_certificates_dir_name'),
){
  $copy_host_certificates = simple_grid::check_presence_host_certificates($host_certificates_dir, $fqdn)
  notify{"Copy host certificates? ${copy_host_certificates}":}
  if $copy_host_certificates {
    notify{'Copying host certificates for ${fqdn}':}
    file{"Copying host copy_host_certificates from CM to ${host_certificates_dir}":
      ensure => directory,
      recurse => 'remote',
      source => "puppet:///simple_grid/${host_certificates_dir_name}/${fqdn}",
      path => "${host_certificates_dir}",
      mode => "0644",
    }  
  }
}
