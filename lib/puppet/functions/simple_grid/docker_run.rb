Puppet::Functions.create_function(:'simple_grid::docker_run') do
    dispatch :docker_run do
        param 'Hash', :augmented_site_level_config
        param 'Hash', :current_lightweight_component
        param 'Hash', :meta_info
        param 'String', :config_dir
        param 'String', :network
        param 'String', :image_name
    end
    def docker_run(augmented_site_level_config, current_lightweight_component, meta_info, config_dir, network, image_name)
        docker_run_parameters = meta_info['docker_run_parameters']
        
        #name
        ############### 
        # Volume Mounts
        ###############
        
        # Config Dir
        docker_run = "docker run" << " "
        docker_run << "-v #{config_dir}:/config" << " "
        
        #CVMFS
        if meta_info.key?("host_requirements") and meta_info['host_requirements'].key?("cvmfs") and meta_info['host_requirements']['cvmfs'] == true
            docker_run << "--mount type=bind,source=/cvmfs,target=/cvmfs,bind-propogation=shared" << " "
        end

        ##############
        # Network
        ##############
        dns = find_dns_info(augmented_site_level_config, current_lightweight_component['execution_id'])
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