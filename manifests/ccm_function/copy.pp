# Copy data from fileserver on CM to LC
class simple_grid::ccm_function::copy(
  $message,
  $source,
  $destination,
  $mode
){
  file{"$message":
    source => "puppet:///simple_grid/${source}",
    path   => "${destination}",
    mode   => "${mode}",
  }

}
