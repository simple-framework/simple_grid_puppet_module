class simple_grid::components::yaml_compiler::download(
  $repository_url,
  $revision,
  $dir,
){
  if lookup('simple_grid::mode') != lookup('simple_grid::mode::release') {
    vcsrepo {"${dir}":
      ensure   => present,
      provider => git,
      revision => $revision,
      source   => $repository_url,
    }
  }
  else {
    file {"Creating yaml_compiler virtual env directory ${$dir}":
      ensure => directory,
      path   => $dir
    }
  }
}

class simple_grid::components::yaml_compiler::install(
  $yaml_compiler_dir = lookup('simple_grid::components::yaml_compiler::download::dir'),
  $virtual_env_dir,
  $temp_dir,
  $pypi_revision = lookup('simple_grid::components::yaml_compiler::download::pypy::revision')
){
  if lookup('simple_grid::mode') != lookup('simple_grid::mode::release') {
    #create virtual environment
    python::virtualenv { "virtual environment for yaml compiler": 
      ensure       => present,
      version      => 'system',
      systempkgs   => false,
      venv_dir     => "${virtual_env_dir}",
      cwd          => "${yaml_compiler_dir}",
    } ->
    exec {"Install requirements using exec becuase puppet module is dumb":
      command => "bash -c 'source ${virtual_env_dir}/bin/activate && pip install -r requirements.txt'",
      path => '/usr/local/bin:/usr/bin:/bin/',
      cwd  => "${yaml_compiler_dir}"

    } ->

    # 7. create temp directory
    file {"create temp directory for compiler":
      ensure => directory,
      path   => "${temp_dir}",
      owner  => 'puppet',
      mode   => '766',
    }
  }
  elsif lookup('simple_grid::mode') == lookup('simple_grid::mode::release')
  {
    python::virtualenv { "virtual environment for yaml compiler":
      ensure       => present,
      version      => 'system',
      systempkgs   => false,
      venv_dir     => "${virtual_env_dir}",
      cwd          => "${yaml_compiler_dir}"
    } ->
    if $pypi_revision != '' {
      exec{'Installing yaml_compiler from PyPI':
        command => "bash -c 'source ${virtual_env_dir}/bin/activate && pip install simple_grid_yaml_compiler==${pypi_revision}'",
        path    => "/usr/local/bin/:/usr/bin/:/bin/",
      }
    }else {
      exec{'Installing yaml_compiler from PyPI':
        command => "bash -c 'source ${virtual_env_dir}/bin/activate && pip install simple_grid_yaml_compiler",
        path    => "/usr/local/bin/:/usr/bin/:/bin/",
        cwd     => "${yaml_compiler_dir}",
      }
    }
  }
}

class simple_grid::components::yaml_compiler::execute(
  $yaml_compiler_dir = lookup('simple_grid::components::yaml_compiler::download::dir'),
  $virtual_env_dir = lookup('simple_grid::components::yaml_compiler::install::virtual_env_dir'),
  $site_level_config_file = lookup('simple_grid::components::site_level_config_file'),
  $output_file = lookup('simple_grid::components::yaml_compiler::output'),
  $schema_output_file = lookup('simple_grid::components::yaml_compiler::schema_output'),
){
  if lookup('simple_grid::mode') != lookup('simple_grid::mode::release'){
    #8. activate virtual environment
    exec {"execute compiler":
      command => "bash -c 'source ${virtual_env_dir}/bin/activate && python ${yaml_compiler_dir}/simple_grid_yaml_compiler/yaml_compiler.py ${site_level_config_file}  -o ${output_file} -s ${schema_output_file}'",
      path    => "/usr/local/bin/:/usr/bin/:/bin/",
      cwd     => "${yaml_compiler_dir}",
      environment => ["PYTHONPATH=${yaml_compiler_dir}"]
    }
  }
  elsif lookup('simple_grid::mode') == lookup('simple_grid::mode::release'){
    exec {"execute compiler":
      command => "bash -c 'source ${virtual_env_dir}/bin/activate && simple_grid_yaml_compiler ${site_level_config_file}  -o ${output_file} -s ${schema_output_file}'",
      path    => "/usr/local/bin/:/usr/bin/:/bin/",
      cwd     => "${yaml_compiler_dir}",
    }
  }
}

class simple_grid::components::yaml_compiler::rollback(
  $yaml_compiler_dir = lookup('simple_grid::components::yaml_compiler::download::dir'),
  $augmented_site_level_config_file = lookup('simple_grid::components::yaml_compiler::output'),
  $virtual_env_dir = lookup('simple_grid::components::yaml_compiler::install::virtual_env_dir')
){
  if lookup('simple_grid::mode') != lookup('simple_grid::mode::release') {
    file{'Removing yaml compiler':
      path   => "${yaml_compiler_dir}",
      ensure => absent,
      force  => true
    }
    file{'Removing augmented site level config file':
      path   => "${augmented_site_level_config_file}",
      ensure => absent,
      force  => true,
    }
  }
  elsif lookup('simple_grid::mode') == lookup('simple_grid::mode::release') {
    notify{'Uninstalling simple_grid_yaml_compiler':}
    file {'Removing yaml_compiler installation dir':
      ensure => absent,
      path   => $yaml_compiler_dir,
      force  => true
    }
  }
}

