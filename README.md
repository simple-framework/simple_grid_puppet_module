
# SIMPLE - Solution for Intallation Management and Provisioning of Lightweight Elements

The Central Configuration Manager for the SIMPLE Grid Framework, a private PaaS for orchestrating containerized services on demand.

# Usage
The usage of the module is described in the Docs available at [SIMPLE Framework's website](https://simple-framework.github.io/docs/deployment_guide_htcondor).

# Release Notes

## Fixed bugs
This release includes the following bug fixes. It fixes the following issue:
- [Issue 101: Fix permissions on host-certificates to allow them to be copied using the Puppet Fileserver](https://github.com/WLCG-Lightweight-Sites/simple_grid_puppet_module/issues/101)
- [Issue 118: pre_deploy rollback works when multiple containers are to be deployed on the same node](https://github.com/WLCG-Lightweight-Sites/simple_grid_puppet_module/issues/118)
- [Issue 128: Fix swarm overlay network's ip range clash with swarm ingress network](https://github.com/WLCG-Lightweight-Sites/simple_grid_puppet_module/issues/128)

## New features
This release includes the following new features:
- [Issue 112: Delete simple puppet environment in config stage rollback](https://github.com/WLCG-Lightweight-Sites/simple_grid_puppet_module/issues/112)
- [Issue 114: Add a remove_images parameter to simple_grid::deploy::config_master::rollback](https://github.com/WLCG-Lightweight-Sites/simple_grid_puppet_module/issues/114)
- [Issue 122: Open port 8140 during Install stage to ease puppet cert sign process](https://github.com/WLCG-Lightweight-Sites/simple_grid_puppet_module/issues/122)
- [Issue 123: Delete augmented_site_level_config_file and augmented_site_level_config_file_schema on config stage rollback on CM](https://github.com/WLCG-Lightweight-Sites/simple_grid_puppet_module/issues/123)
- [Issue 127: Bump docker version to 19.03.5](https://github.com/WLCG-Lightweight-Sites/simple_grid_puppet_module/issues/127)
- [Issue 137: Remove default timeout in Deploy Stage](https://github.com/WLCG-Lightweight-Sites/simple_grid_puppet_module/issues/137)
- [Issue 140: Add template for HTCondor site_level_config_file](https://github.com/WLCG-Lightweight-Sites/simple_grid_puppet_module/issues/140)




