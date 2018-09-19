class simple_grid::params(
  Hash                  $options,
  Puppet::LookupContext $context,
) {
  $base_params = {
    'simple_grid::test::test_param'  => 'from the module'
  }

  $os_params = case $facts['os']['family'] {
    default : {
      { 'simple_grid::test::os_param'  => 'from the module'}
    }
  }

  $base_params + $os_params
}
