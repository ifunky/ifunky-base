# Base params class
#
# @author Dan
class base::params () {
  $proxy_server       = ''
  $proxy_exclusions   = ''
  $octopus_server_url = ''
  $timezone           = "GMT Standard Time"
  $powershell_remote_port = "5985"
  $powershell_remote_enabled = "true"
  $powershell_trusted_hosts = "*"
}
