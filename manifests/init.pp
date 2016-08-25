# Base classes for the system, primariliy for OS setup and core params
#
# @author Dan
class base (
  $proxy_server = $base::params::proxy_server,
  $proxy_exclusions = $base::params::proxy_exclusions,
) inherits base::params {


}
