class simple_grid::components::bolt::install (
  $bolt_dir= lookup('simple_grid::components::bolt::bolt_dir')
)
{

  notify {"Installing bolt package":}
  package {"bolt":
    ensure => installed,
   }

  notify {"Creating bolt directory":}
  # Creating dir recursively 
  file {["/root/","/root/.puppetlabs/","/root/.puppetlabs/bolt"]:
    ensure => directory,
  } ~>
  file { "Bolt config file from template":
    path    => "${$bolt_dir}/bolt.yaml",
    ensure  => present,
    content => epp('simple_grid/bolt.yaml')
  } ~>
  notify{"Bolt configuration file avaliable on $bolt_dir":
  }
}
