class simple_grid::components::bolt::install (
  $bolt_dir= lookup('simple_grid::components::bolt::bolt_dir')
)
{
  notify {"Creating bolt directory":}

  file {"/root/.puppetlabs/":
    # path    => "/root/.puppetlabs/bolt/",
    path   => "${$bolt_dir}",
    ensure => directory,
  } ~>
  file { "Bolt config file from template":
    # path    => "/root/.puppetlabs/bolt/bolt.yaml",
    path    => "${$bolt_dir}/bolt.yaml",
    ensure  => present,
    content => epp('simple_grid/bolt.yaml')
  } ~>
  notify{"Bolt configuration file avaliable on $bolt_dir":
  }
}
