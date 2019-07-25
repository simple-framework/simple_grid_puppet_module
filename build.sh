#/bin/bash
puppet module build
cp -irf /simple_grid_mk/pkg/maany-simple_grid-1.0.0.tar.gz /var/lib/puppet-forge-server/modules/
