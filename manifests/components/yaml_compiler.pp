class simple_grid::components::yaml_compiler::download(
  $repository_url,
  $revision,
  $dir,
){
  
  vcsrepo {"${dir}":
    ensure   => present,
    provider => git,
    revision => $revision,
    source   => $repository_url,
  }
}
class simple_grid::components::yaml_compiler::install(
  $yaml_compiler_dir = lookup('simple_grid::components::yaml_compiler::download::dir'),
  $virtual_env_dir,
  $temp_dir,
){
  #create virtual environment
  python::virtualenv { "virtual environment for yaml compiler": 
    ensure       => present,
    version      => 'system',
    systempkgs   => false,
    venv_dir     => "${virtual_env_dir}",
    cwd          => "${yaml_compiler_dir}",
  }
  python::requirements {'/etc/simple_grid/yaml_compiler/requirements.txt':
    virtualenv => '/etc/simple_grid/yaml_compiler/.env',
  }
  # 7. create temp directory
  file {"create temp directory for compiler":
    ensure => directory,
    path   => "${temp_dir}",
    owner  => 'puppet',
    mode   => '766',
  }
}

class simple_grid::components::yaml_compiler::execute(
  $yaml_compiler_dir = "/etc/simple_grid/yaml_compiler",
  $virtual_env_dir = lookup('simple_grid::components::yaml_compiler::install::virtual_env_dir'),
  $site_level_config_file = lookup('simple_grid::components::site_level_config_file'),
  $output_file = lookup('simple_grid::components::yaml_compiler::output'),
){
  #8. activate virtual environment
  exec {"execute compiler":
    command => "bash -c 'source ${virtual_env_dir}/bin/activate && python ${yaml_compiler_dir}/simple_grid_yaml_compiler.py ${site_level_config_file}  -o ${output_file}'",
    path    => "/usr/local/bin/:/usr/bin/:/bin/",
    cwd     => "${yaml_compiler_dir}",
    }
}

