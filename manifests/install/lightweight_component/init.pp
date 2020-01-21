class simple_grid::install::lightweight_component::init{
  notify{'**** Node LC; Stage Install':}
  class{'simple_grid::components::ccm::config':
    node_type => 'LC'
  }
}
