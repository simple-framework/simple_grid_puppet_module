class simple_grid::components::ccm::install(
  $env_repository_url,
  $env_revision,
  $env_dir,
  $env_name,
  $module_dir,
  $simple_module_name,
  $mode                 = lookup('simple_grid::mode'),
  $dev_mode_repository  = lookup('simple_grid::components::ccm::install::mode::dev::repository_url'),
  $dev_mode_revision    = lookup('simple_grid::components::ccm::install::mode::dev::revision'),
  $forge_module_name    = lookup('simple_grid::components::ccm::install::mode::release::forge_module_name'),
  $forge_module_version = lookup('simple_grid::components::ccm::install::mode::release::forge_module_version'),
){
    notify {"Downloading puppet environment for SIMPLE at ${env_dir}":}
    vcsrepo {"${env_dir}":
      ensure   => present,
      provider => git,
      revision => $env_revision,
      source   => $env_repository_url,
    }
    notify{"Mode is $mode $module_dir":}
    if $mode == lookup('simple_grid::mode::dev') {
      notify {"Installing CCM in DEV MODE. The value for simple_grid::mode is : ${mode}":}
      # class {"simple_grid::components::ccm::installation_helper::r10k::install":} ## Deprecated in #80
      class {"simple_grid::components::ccm::installation_helper::simple_env_modules":}

      notify {"Installing SIMPLE Grid Puppet Module from Github at $module_dir":}
      vcsrepo {"${module_dir}":
        ensure   => present,
        provider => git,
        revision => $dev_mode_revision,
        source   => $dev_mode_repository,
      }
    }
    elsif $mode == lookup('simple_grid::mode::docker') {
      notify {"Installing CCM in Docker Dev MODE. The value for simple_grid::mode is : ${mode}":}
      # class {"simple_grid::components::ccm::installation_helper::r10k::install":} # Deprecated in #80
      class {"simple_grid::components::ccm::installation_helper::simple_env_modules":}

      file{'Creating a directory for simple grid puppet module in $env_dir':
        ensure => directory,
        path   => "${module_dir}",
      } ~>
      exec{"Mounting Simple Grid Puppet Module to ${module_dir}/${simple_module_name}":
        command => "mount --bind /${simple_module_name} ${module_dir}",
        path    => "/usr/local/bin/:/usr/bin/:/bin/",
      }
    }
    elsif $mode == lookup('simple_grid::mode::release'){
      notify {"Installing CCM in Release MODE. The value for simple_grid::mode is : ${mode}":}
      exec {'Installing Simple Grid Puppet Module from Puppet Forge':
        command => "puppet module install --version ${forge_module_version} --environment ${env_name} --target-dir ${env_dir}/modules ${forge_module_name}",
        path    => "/usr/local/bin/:/usr/bin/:/bin/::/opt/puppetlabs/bin/"
      }
    } 
}

class simple_grid::components::ccm::config(
  $node_type,
){
  if ($node_type == "CM") {
    class{"simple_grid::components::ccm::installation_helper::fileserver":}
    class{"simple_grid::components::ccm::installation_helper::ssh_config::config_master":}
    class{"simple_grid::components::ccm::installation_helper::generate_site_manifest":}
    class{"simple_grid::components::ccm::installation_helper::puppet_agent":}
    class{"simple_grid::components::ccm::installation_helper::puppet_server":}
  }elsif ($node_type == "LC") {
    class{"simple_grid::components::ccm::installation_helper::ssh_config::lightweight_component":}
    class{"simple_grid::components::ccm::installation_helper::reset_agent":}
  }
}

##################################################################
# Installation Helpers for site.pp, r10k, SSH and Fileserver on CM
##################################################################
class simple_grid::components::ccm::installation_helper::generate_site_manifest(
  $site_manifest_path
){
  file{"Creating site.pp":
    path    => "${site_manifest_path}",
    ensure  => present,
    content => epp("simple_grid/site.pp")
  }
}
class simple_grid::components::ccm::installation_helper::simple_env_modules(
  $env_name = lookup('simple_grid::components::ccm::install::env_name'),
  $env_dir = lookup('simple_grid::components::ccm::install::env_dir')
){
  $module_dependencies = simple_grid::list_module_dependencies()
  notify{"Installation dependencies for simple module in ${env_dir}":}
  $module_dependencies.each |Integer $index, Hash $dependency| {
    $module_name = $dependency["name"]
    $version = $dependency["version_requirement"]
    notify {"puppet module install --version ${version} --environment ${env_name} ${module_name}":}
    exec {"Installing ${module_name} ${version}":
      command => "puppet module install --version ${version} --environment ${env_name} --target-dir ${env_dir}/modules ${module_name}",
      path    => "/usr/sue/sbin:/usr/sue/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin",    
    } 
  }
}
## Deprecated in #80
class simple_grid::components::ccm::installation_helper::r10k::install(
  $env_dir = lookup('simple_grid::components::ccm::install::env_dir')
){
  notify {"Installing r10k":}
  class {'r10k':}
    
  notify {"Installing modules for simple environment.":}
  exec{'Install modules in the deploy environment':
    command => "r10k puppetfile install .",
    cwd     => "$env_dir",
    path    => "/usr/local/bin/:/usr/bin/:/bin/",
  }
}

class simple_grid::components::ccm::installation_helper::puppet_agent(
  $puppet_conf = lookup("simple_grid::config_master::puppet_conf"),
  $env_name = lookup("simple_grid::components::ccm::install::env_name"),
  #$runinterval = lookup("simple_grid::components::ccm::installation_helper::puppet_agent::runinterval")
){
  notify{"Adding [agent] config to ${puppet_conf}":}
  $puppet_conf_data = simple_grid::deserialize_puppet_conf("${puppet_conf}")
  $puppet_conf_updates = {
    "agent" => {
      "environment" => "${env_name}",
      "server"      => "${fqdn}",
      #"runinterval" => "${runinterval}"
    }
  }
  $puppet_conf_content_hash = simple_grid::puppet_conf_editor($puppet_conf_data, $puppet_conf_updates)
  $puppet_conf_content = simple_grid::serialize_puppet_conf($puppet_conf_content_hash)
  file {"Update puppet conf":
    path => "${puppet_conf}",
    content => $puppet_conf_content
  }
  service{"puppet":
    ensure    => running,
    subscribe => File["$puppet_conf"]
  }
}
class simple_grid::components::ccm::installation_helper::puppet_server
{
  notify{"Starting PuppetServer":}
  service{"puppetserver":
    ensure => running
  }
}
class simple_grid::components::ccm::installation_helper::fileserver(
  $fileserver_conf_path,
){
  file {"Creating fileserver.conf":
    ensure  => present,
    path    => "${fileserver_conf_path}",
    content => template('simple_grid/fileserver.conf.erb')
  }
}

class simple_grid::components::ccm::installation_helper::ssh_config::config_master(
  $simple_config_dir = lookup('simple_grid::simple_config_dir'),
  $ssh_host_key      = lookup('simple_grid::nodes::config_master::installation_helper::ssh_config::ssh_host_key'),
  $ssh_dir           = lookup('simple_grid::nodes::config_master::installation_helper::ssh_config::ssh_dir'),
){
  ssh_keygen{'root':
    filename => "${ssh_dir}/${ssh_host_key}"
  } ~> 
  exec {'Copying ssh host public key to fileserver':
    command => "cp ${ssh_dir}/${ssh_host_key}.pub ${simple_config_dir}/",
    path    => "/usr/local/bin/:/usr/bin/:/bin/"
  }

}

#####################################################
#     Installation Helpers for SSH on LC
#####################################################

class simple_grid::components::ccm::installation_helper::ssh_config::lightweight_component (
  $ssh_dir = lookup('simple_grid::nodes::lightweight_component::ssh_config::dir'),
  $ssh_authorized_keys_path = lookup("simple_grid::nodes::lightweight_component::ssh_config::ssh_authorized_keys_path"),
  $ssh_host_key = lookup('simple_grid::nodes::config_master::installation_helper::ssh_config::ssh_host_key'),
  $simple_config_dir = lookup('simple_grid::simple_config_dir')
){
    file {"Copy public key of master to config dir":
      source => "puppet:///simple_grid/${ssh_host_key}.pub",
      path   => "${simple_config_dir}/${ssh_host_key}.pub",
      mode   => "644"
    }
    file {"Checking presence of .ssh directory":
      path   => "${ssh_dir}",
      ensure => directory
    }
    file {"${ssh_authorized_keys_path}":
      ensure => present
    }
    $newkey = split(file("${simple_config_dir}/${ssh_host_key}.pub"), " ")[1]
    ssh_authorized_key { 'append ssh public key':
      type   => 'ssh-rsa',
      ensure => present,
      user   => "root",
      key    => $newkey,
    }
    sshd_config {'Permit Root Login for Puppet Bolt to run Tasks':
      key    => "PermitRootLogin",
      ensure => present,
      value  => 'yes'
    }
}
#####################################################
#     Generic Installation Helpers
#####################################################
class simple_grid::components::ccm::installation_helper::init_agent(
  $puppet_master,
  $puppet_conf = lookup('simple_grid::nodes::lightweight_component::puppet_conf'),
  $runinterval,
){
  notify{"Configuring Puppet Agent":}
  notify{"Puppet master is $puppet_master":}
  $puppet_conf_data = simple_grid::deserialize_puppet_conf("${puppet_conf}")
  $puppet_conf_updates = {
    "agent" => {
      "server"       => $puppet_master,
      "runinterval"  => "${runinterval}",
      "environment"  => "simple"
      }
    }
  $puppet_conf_content_hash = simple_grid::puppet_conf_editor($puppet_conf_data, $puppet_conf_updates)
  $puppet_conf_content = simple_grid::serialize_puppet_conf($puppet_conf_content_hash)

  notify{"Restarting Puppet":}
  file {"Writing data to puppet conf":
    path => "${puppet_conf}",
    content => "$puppet_conf_content",
  } 
  service {'puppet':
    ensure    => running,
    subscribe => File["$puppet_conf"]
  }
}
class simple_grid::components::ccm::installation_helper::reset_agent(
  $runinterval,
  $env_name = lookup("simple_grid::components::ccm::install::env_name"),
  $puppet_conf = lookup('simple_grid::nodes::lightweight_component::puppet_conf'),
) {

  $puppet_conf_data = simple_grid::puppet_conf_from_fact($facts["puppet_conf"])
  notify{"data was ${puppet_conf_data}":}
  $puppet_conf_updates = {
    "agent" => {
      "environment" => "${env_name}",
      "runinterval" => "${runinterval}"
    }
  }
  $puppet_conf_content_hash = simple_grid::puppet_conf_editor($puppet_conf_data, $puppet_conf_updates)
  $puppet_conf_content = simple_grid::serialize_puppet_conf($puppet_conf_content_hash)
  notify{"Restarting Puppet":}
  file{'Updating puppet.conf': 
    path    => "$puppet_conf",
    content => "$puppet_conf_content"

  }
  service {"puppet":
    ensure    => running,
    subscribe => File["$puppet_conf"]
  }
}
