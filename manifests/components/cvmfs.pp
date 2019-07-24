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
      cvmfs_http_proxy      => 'http://ca-proxy-meyrin.cern.ch:3128;http://ca-proxy.cern.ch:3128',
      cvmfs_quota_limit     => 40000,
      cvmfs_timeout         =>  5,
      cvmfs_timeout_direct  => 10,
      }
    cvmfs::domain{'cms.cern.ch': 
      cvmfs_server_url  => 'cms.cern.ch',
    }
    cvmfs::domain{'lhcb.cern.ch':
      cvmfs_server_url  => 'lhcb.cern.ch',
    }
    cvmfs::domain{'alice.cern.ch':
     cvmfs_server_url  => 'alice.cern.ch',
    }
    cvmfs::domain{'lhcb-condb.cern.ch':
      cvmfs_server_url  => 'lhcb-condb.cern.ch',
    }
}
