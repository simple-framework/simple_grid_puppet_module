class simple_grid::components::ccm::install(
  $env_install_repository_url,
  $env_install_revision,
  $env_install_dir,
  $env_config_repository_url,
  $env_config_revision,
  $env_config_dir,
  $env_pre_deploy_repository_url,
  $env_pre_deploy_revision,
  $env_pre_deploy_dir,
  $env_deploy_repository_url,
  $env_deploy_revision,
  $env_deploy_dir,
  $env_test_repository_url,
  $env_test_revision,
  $env_test_dir,
  $env_cleanup_repository_url,
  $env_cleanup_revision,
  $env_cleanup_dir,
){
    notify {"Downloading Install environment":}
    vcsrepo {"${env_install_dir}":
    ensure   => present,
    provider => git,
    revision => $env_install_revision,
    source   => $env_install_repository_url,
    }

    notify {"Downloading Config environment":}
    vcsrepo {"${env_config_dir}":
    ensure   => present,
    provider => git,
    revision => $env_config_revision,
    source   => $env_config_repository_url,
    }

    notify {"Downloading Pre_Deploy environment":}
    vcsrepo {"${env_pre_deploy_dir}":
    ensure   => present,
    provider => git,
    revision => $env_pre_deploy_revision,
    source   => $env_pre_deploy_repository_url,
    }

    notify {"Downloading Deploy environment":}
    vcsrepo {"${env_deploy_dir}":
    ensure   => present,
    provider => git,
    revision => $env_deploy_revision,
    source   => $env_deploy_repository_url,
    }

    notify {"Downloading Test environment":}
    vcsrepo {"${env_test_dir}":
    ensure   => present,
    provider => git,
    revision => $env_test_revision,
    source   => $env_test_repository_url,
    }

    notify {"Downloading Cleanup environment":}
    vcsrepo {"${env_cleanup_dir}":
    ensure   => present,
    provider => git,
    revision => $env_cleanup_revision,
    source   => $env_cleanup_repository_url,
    }
}
