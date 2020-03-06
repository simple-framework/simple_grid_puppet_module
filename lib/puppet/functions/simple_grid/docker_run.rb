Puppet::Functions.create_function(:'simple_grid::docker_run') do
    dispatch :docker_run do
        param 'Hash', :augmented_site_level_config
        param 'Hash', :current_lightweight_component
        param 'Hash', :meta_info
        param 'String', :image_name
        param 'String', :augmented_site_level_config_file
        param 'String', :container_augmented_site_level_config_file
        param 'String', :config_dir
        param 'String', :container_config_dir
        param 'String', :scripts_dir
        param 'String', :container_scripts_dir
        param 'String', :wrapper_dir
        param 'String', :container_script_wrappers_dir
        param 'String', :logs_dir
        param 'String', :container_logs_dir
        param 'String', :host_certificates_dir
        param 'String', :container_host_certificates_dir
        param 'String', :container_host_certificates_dir
        param 'String', :level_2_configurator

    end
    def docker_run(augmented_site_level_config, current_lightweight_component, meta_info, image_name, augmented_site_level_config_file, container_augmented_site_level_config_file, config_dir, container_config_dir,  scripts_dir, container_scripts_dir, wrapper_dir, container_script_wrappers_dir, logs_dir, container_logs_dir, host_certificates_dir, container_host_certificates_dir, network, level_2_configurator)
        docker_run_parameters = meta_info['level_2_configurators'][level_2_configurator]['docker_run_parameters']
        execution_id = current_lightweight_component['execution_id']
        
        ############### 
        # Volume Mounts
        ###############
        
        # Config Dir
        docker_run = "docker run" << " "
        docker_run << "-v #{config_dir}:#{container_config_dir}" << " "
        
        #CVMFS
        if meta_info.key?("host_requirements") and meta_info['host_requirements'].key?("cvmfs") and meta_info['host_requirements']['cvmfs'] == true
            docker_run << "--mount type=bind,source=/cvmfs,target=/cvmfs,bind-propagation=shared" << " "
        end

        # Lifecycle Hooks
        
        docker_run << "-v #{scripts_dir}/#{execution_id}/:#{container_scripts_dir}" << " "
        
        # Wrappers
        docker_run << "-v #{wrapper_dir}/:#{container_script_wrappers_dir}" << " "

        # Augmented Site Level Config File
        docker_run << "-v #{augmented_site_level_config_file}:#{container_augmented_site_level_config_file}" << " "
        # Lifecycle event/script Logs
        docker_run << "-v #{logs_dir}:#{container_logs_dir}" << " "
        #
        if meta_info.key?('host_requirements') and meta_info['host_requirements'].key?('host_certificates') and meta_info['host_requirements']['host_certificates'] == true
            docker_run << "-v #{host_certificates_dir}:#{container_host_certificates_dir}" << " "
        end

        ##############
        # Network
        ##############
        dns = find_dns_info(augmented_site_level_config, execution_id)
        docker_run << "--hostname #{dns['container_fqdn']} --ip #{dns['container_ip']} --net #{network}" << " "
        # Ports
        if docker_run_parameters.key?('ports') 
            docker_run_parameters['ports'].each do |port|
                docker_run << "-p #{port}" << " "
            end
        end

        # Add All Hosts
        all_dns_info = augmented_site_level_config['dns']
        all_dns_info.each do |dns_info|
            if dns_info['execution_id'] != dns['execution_id']
                docker_run << "--add-host #{dns_info['container_fqdn']}:#{dns_info['container_ip']}" << " "
            end
        end

        ################
        # Generic Info
        ###############
        # name
        docker_run << "--name #{dns['container_fqdn']}" << " "
        # interfactive/tty/detach
        if docker_run_parameters.key?('interactive') and docker_run_parameters['interactive'] == true
            docker_run << "-i" << " "
        end
        if docker_run_parameters.key?('tty') and docker_run_parameters['tty'] == true
            docker_run << "-t" << " "
        end
        if docker_run_parameters.key?('detached')
            docker_run << "-d" << " "
        end

        ###############
        # privileged
        ###############
        if docker_run_parameters.key?('privileged') and docker_run_parameters['privileged'] == true
            docker_run << " --privileged" << " "
        end

        #################
        # restart policy
        #################

        docker_run << "--restart always" << " "

        ###############
        # Image name and command
        ###############
        docker_run << "#{image_name}" << " "
        if docker_run_parameters.key?('command')
            docker_run << "#{docker_run_parameters['command']}"
        end
        #{docker_run_parameters['com']}"
        docker_run
    end
    def find_dns_info(augmented_site_level_config, execution_id)
        dns_info = augmented_site_level_config['dns']
        dns_info.each do |dns|
            if dns['execution_id'] == execution_id
                return dns
            end
        end
    end
end