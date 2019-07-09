class simple_grid::config::config_master::init(

)
{
  notify{"***** Stage:Config; Node: CM *****":}
  notify{"Installing Python and virtualenv":}
  class {'python':
    version    => 'system',
    pip        => 'present',
    virtualenv => 'present'
  }

  Class[simple_grid::components::yaml_compiler::download] -> Class[simple_grid::components::yaml_compiler::install] -> Class[simple_grid::components::yaml_compiler::execute]
  notify{"Downloading YAML Compiler":}
  class{"simple_grid::components::yaml_compiler::download":}
  notify{"Installing YAML Compiler":}
  class{"simple_grid::components::yaml_compiler::install":}
  notify{"Executing YAML Compiler":}
  class{"simple_grid::components::yaml_compiler::execute":}
  # notify{"Aggregate lifecycle callback scripts":}
  # class{"simple_grid::ccm_function::aggregate_repository_lifecycle_scripts":}
}
