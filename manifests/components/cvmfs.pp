class simple_grid::components::cvmfs::install(
  $env_name = lookup('simple_grid::components::ccm::install::env_name')
)
{
  notify {" CVMFS module should have been installed during installation of SIMPLE. Doing nothing":}

}
class simple_grid::components::cvmfs::configure(
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output')
)
{
  $augmented_site_level_config = loadyaml($augmented_site_level_config_file)
  $cvmfs_http_proxy_list = $augmented_site_level_config['site']['cvmfs_http_proxy_list']
  $cvmfs_http_proxy = join($cvmfs_http_proxy_list, ";")
  notify {"Configuring CVMFS module":}
    class{'::cvmfs':
      mount_method          => 'mount',
      cvmfs_http_proxy      => "${cvmfs_http_proxy}",
      cvmfs_quota_limit     => 40000,
      cvmfs_timeout         =>  5,
      cvmfs_timeout_direct  => 10,
      }
  exec { 'Running cvmfs setup':
    command => "cvmfs_config setup",
    path    => "/usr/local/bin/:/usr/bin/:/bin/::/opt/puppetlabs/bin/"
    }
  exec { 'Running cvmfs probe':
    command => "cvmfs_config probe",
    path    => "/usr/local/bin/:/usr/bin/:/bin/::/opt/puppetlabs/bin/"
    }
}
