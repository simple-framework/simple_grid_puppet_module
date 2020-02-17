define simple_grid::components::docker::build_image(
  $image_name,
  $dockerfile,
  $log_flag = 'docker build',
  $wrapper_dir = lookup('simple_grid::scripts::wrapper_dir'),
  $retry_wrapper = lookup('simple_grid::scripts::wrapper::retry'),
){
  $build_command = "${wrapper_dir}/${retry_wrapper} --command='docker image build -t ${image_name} ${dockerfile}' --recovery-command='systemctl restart docker' --reattempt-command='sleep 10' --flag='${log_flag}'"
  notify{"Executing ${build_command}":}
  exec { "Building ${image_name} image":
    command     => $build_command,
    path        => '/usr/local/bin:/usr/bin/:/bin/:/opt/puppetlabs/bin/:/usr/sue/sbin',
    user        => 'root',
    logoutput   => true,
    environment => ['HOME=/root'],
    provider    => shell,
  }
}

define simple_grid::components::docker::pull_image(
  $image_name,
  $log_flag = 'docker pull image',
  $wrapper_dir = lookup('simple_grid::scripts::wrapper_dir'),
  $retry_wrapper = lookup('simple_grid::scripts::wrapper::retry')
){
  $pull_command = "${wrapper_dir}/${retry_wrapper} --command='docker pull ${image_name}' --recovery-command='sleep systemctl restart docker' --reattempt-command='sleep 10' --flag='${log_flag}'"
  notify{"Executing ${pull_command}":}
  exec { "Pulling ${image_name} image":
    command     => $pull_command,
    path        => '/usr/local/bin:/usr/bin/:/bin/:/opt/puppetlabs/bin/:/usr/sue/sbin',
    user        => 'root',
    logoutput   => true,
    environment => ['HOME=/root'],
    timeout     => 0,
    provider    => shell,
  }
}

define simple_grid::components::docker::run(
  $command,
  $container_description,
  $log_flag = 'docker run',
  $wrapper_dir = lookup('simple_grid::scripts::wrapper_dir'),
  $retry_wrapper = lookup('simple_grid::scripts::wrapper::retry')
){
  $run_command = "${wrapper_dir}/${retry_wrapper} --command='${command}' --recovery-command='systemctl restart docker' --reattempt-command='sleep 10' --flag='${log_flag}'"
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
  $log_flag = 'docker exec',
  $wrapper_dir = lookup('simple_grid::scripts::wrapper_dir'),
  $retry_wrapper = lookup('simple_grid::scripts::wrapper::retry')
){
  $docker_exec = "${wrapper_dir}/${retry_wrapper} --command='docker exec -t /bin/bash -c \"${container_name} ${command}\"' --recovery-command='sleep 10' --flag='${log_flag}'"
  exec{"Executing ${command} inside container ${container_name}":
    command     => $docker_exec,
    path        => '/usr/local/bin:/usr/bin/:/bin/:/opt/puppetlabs/bin/:/usr/sue/sbin',
    user        => 'root',
    logoutput   => true,
    environment => ['HOME=/root'],
    provider    => shell
  }
}
