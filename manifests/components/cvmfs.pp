class simple_grid::components::cvmfs::install(
  $env_name = lookup('simple_grid::components::ccm::install::env_name')
)
{
  notify {" CVMFS module should have been installed during installation of SIMPLE. Doing nothing":}

}
class simple_grid::components::cvmfs::configure
{
  notify {"Configuring CVMFS module":}
    class{'::cvmfs':
      mount_method          => 'mount',
      cvmfs_http_proxy      => 'http://cvmfs.cat.cbpf.br:3128',
      cvmfs_quota_limit     => 40000,
      cvmfs_timeout         =>  15,
      cvmfs_timeout_direct  => 15,
      cvmfs_mount_rw        => yes,
      }
    cvmfs::mount{'cms.cern.ch': 
      cvmfs_server_url  => 'cms.cern.ch',
    }
    cvmfs::mount{'lhcb.cern.ch':
      cvmfs_server_url  => 'lhcb.cern.ch',
    }
    cvmfs::mount{'alice.cern.ch':
     cvmfs_server_url  => 'alice.cern.ch',
    }
    cvmfs::mount{'lhcb-condb.cern.ch':
      cvmfs_server_url  => 'lhcb-condb.cern.ch',
    }
}
