class simple_grid::yaml_compiler(
  $config_dir,
  $yaml_compiler_dir_name,
  $yaml_compiler_repo_url,
  $yaml_compiler_revision,
  $site_config_dir,
  $site_config_file
) {
  #4. download simple grid yaml compiler
  vcsrepo {"${config_dir}/${yaml_compiler_dir_name}":
    ensure   => present,
    provider => git,
    revision => $yaml_compiler_revision,
    source   => $yaml_compiler_repo_url,
    before   => File["create temp directory for compiler"],
  }
  #5. create virtual environment
  python::virtualenv { "virtual environment for yaml compiler": 
    ensure       => present,
    version      => 'system',
    #  requirements => "${config_dir}/${yaml_compiler_dir_name}/requirements.txt",
    systempkgs   => true,
    venv_dir     => "${config_dir}/${yaml_compiler_dir_name}/.env",
    cwd          => "${config_dir}/${yaml_compiler_dir_name}",
  }~>
  #6. install required libs
  python::pip {"pyyaml":
    virtualenv => "${config_dir}/${yaml_compiler_dir_name}/.env",
  }~>
  #6. install required libs
  python::pip {"ruamel.ordereddict": 
    virtualenv => "${config_dir}/${yaml_compiler_dir_name}/.env",
  }~>
  #6. install required libs
  python::pip {"ruamel.yaml":
    virtualenv => "${config_dir}/${yaml_compiler_dir_name}/.env",
  }~>
  #7. create tem directory
  file {"create temp directory for compiler":
    ensure => directory,
    path   => "$config_dir/$yaml_compiler_dir_name/.temp",
    owner  => 'puppet',
    mode   => '766',
  }~>
  #8. activate virtual environment
  exec {"source virtualenv":
    command => "bash -c 'source ${config_dir}/${yaml_compiler_dir_name}/.env/bin/activate'",
    path    => "/usr/local/bin/:/usr/bin/:/bin/",
    #before  => Exec["execute compiler"],
  }~>
  #9. execute the compiler
  exec {"execute compiler":
    command => "bash -c 'source ${config_dir}/${yaml_compiler_dir_name}/.env/bin/activate && python $config_dir/$yaml_compiler_dir_name/simple_grid_yaml_compiler.py $site_config_dir/$site_config_file  -o $config_dir/$yaml_compiler_dir_name/output.yaml'",
    path    => '/usr/local/bin/:/usr/bin/:/bin/',
    cwd     => "${config_dir}/${yaml_compiler_dir_name}",
    }
}
