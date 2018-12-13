
# Configure Swarm on hosts
class simple_grid::pre_deploy::config_master::swarm(
  $site_level_config_dir = lookup('simple_grid::config::config_master::pre_deploy::site_level_config_dir'),
  $site_level_config_file = lookup('simple_grid::config::config_master::pre_deploy::site_level_config_file'),
){
notify{'Running Stage: Docker Swarm':}

exec{"swarm init for ${ip_ce}":
                  command => "bolt task run simple_grid::swarm --modulepath /etc/puppetlabs/code/environments/pre_deploy/site/ --nodes localhost",
                  path    => '/usr/local/bin/:/usr/bin/:/bin/:/opt/puppetlabs/bin/',
                  user    => 'root',
                  }
}
