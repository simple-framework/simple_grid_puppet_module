include 'simple_grid::ccm_function::create_config_dir'
alert("ENC Install?")
class {'simple_grid::components::enc::install':}
class {'simple_grid::components::enc::configure':}

