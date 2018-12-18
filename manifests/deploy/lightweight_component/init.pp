class simple_grid::deploy::lightweight_component::init(
  $execution_id
){
 notify{"Incoming request for exeuction id ${execution_id}":} 
 file{"/Chala":
  content => "BCBCBCBC"
 }
}
