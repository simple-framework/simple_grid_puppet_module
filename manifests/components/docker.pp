define simple_grid::components::docker::build_image(
  $image_name,
  $dockerfile,
  $wrapper_dir = lookup('simple_grid::scripts::wrapper_dir'),
  $retry_wrapper = lookup('simple_grid::scripts::wrapper::retry')
){
  $build_command = "${wrapper_dir}/${retry_wrapper} --command='docker image build -t ${image_name} ${dockerfile}' --recovery-command='systemctl restart docker' --reattempt-command='sleep 10'"
  notify{"Executing ${build_command}":}
  exec { "Building ${image_name} image":
    command     => $build_command,
    path        => '/usr/local/bin:/usr/bin/:/bin/:/opt/puppetlabs/bin/:/usr/sue/sbin',
    user        => 'root',
    logoutput   => true,
    environment => ['HOME=/root'],
  }
}

define simple_grid::components::docker::pull_image(
  $image_name,
  $wrapper_dir = lookup('simple_grid::scripts::wrapper_dir'),
  $retry_wrapper = lookup('simple_grid::scripts::wrapper::retry')
){
  $pull_command = "${wrapper_dir}/${retry_wrapper} --command='docker pull ${image_name}' --recovery-command='sleep systemctl restart docker' --reattempt-command='sleep 10'"
  notify{"Executing ${pull_command}":}
  exec { "Pulling ${image_name} image":
    command     => $pull_command,
    path        => '/usr/local/bin:/usr/bin/:/bin/:/opt/puppetlabs/bin/:/usr/sue/sbin',
    user        => 'root',
    logoutput   => true,
    environment => ['HOME=/root'],
    timeout     => 0,
  }
}

define simple_grid::components::docker::run(
  $command,
  $container_description,
  $wrapper_dir = lookup('simple_grid::scripts::wrapper_dir'),
  $retry_wrapper = lookup('simple_grid::scripts::wrapper::retry')
){
  $run_command = "${wrapper_dir}/${retry_wrapper} --command='${command}' --recovery-command='systemctl restart docker' --reattempt-command='sleep 10'"
  notify{"Executing ${run_command}":}
  exec{"Starting container: ${container_description}":
    command     => $run_command,
    path        => '/usr/local/bin:/usr/bin/:/bin/:/opt/puppetlabs/bin/:/usr/sue/sbin',
    user        => 'root',
    logoutput   => true,
    environment => ['HOME=/root'],
    timeout     => 0,
    provider    => shell
  }
}

define simple_grid::components::docker::exec(
  $container_name,
  $command,
  $wrapper_dir = lookup('simple_grid::scripts::wrapper_dir'),
  $retry_wrapper = lookup('simple_grid::scripts::wrapper::retry')
){
  $docker_exec = "${wrapper_dir}/${retry_wrapper} --command='docker exec -t /bin/bash -c \"${container_name} ${command}\"' --recovery-command='sleep 10'"
  exec{"Executing ${command} inside container ${container_name}":
    command     => $docker_exec,
    path        => '/usr/local/bin:/usr/bin/:/bin/:/opt/puppetlabs/bin/:/usr/sue/sbin',
    user        => 'root',
    logoutput   => true,
    environment => ['HOME=/root'],
  }
}
