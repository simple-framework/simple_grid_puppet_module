class simple_grid::install::config_master::init(
  
){
  include 'simple_grid::ccm_function::create_config_dir'
  class {'simple_grid::components::enc::install':}
  class {'simple_grid::components::enc::configure':}
}
