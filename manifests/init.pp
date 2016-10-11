# Base classes for the system, primariliy for OS setup and core params
#
# @author Dan
class base (
  $proxy_server       = $base::params::proxy_server,
  $proxy_exclusions   = $base::params::proxy_exclusions,
  $octopus_server_url = $base::params::octopus_server_url
) inherits base::params {}
