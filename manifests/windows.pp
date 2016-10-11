# Windows base class that every Windows server will apply
#
# @author Dan
class base::windows () inherits base {

  include profile::windows::timezone

  notify { "PROXY: ${base::proxy_server}": }

  ini_setting { 'report':
    ensure   => present,
    path     => 'C:/ProgramData/PuppetLabs/puppet/etc/puppet.conf',
    section  => 'main',
    setting  => 'report',
    value    => 'true',
  }

  windows_env {'http_proxy':
    ensure    => present,
    variable  => 'http_proxy',
    value     => $base::proxy_server,
    mergemode => clobber,
  }

  windows_env {'https_proxy':
    ensure    => present,
    variable  => 'https_proxy',
    value     => $base::proxy_server,
    mergemode => clobber,
  }

  if (!empty($base::proxy_exclusions)){
    windows_env { 'no_proxy':
      ensure    => present,
      value     => $base::proxy_exclusions,
      mergemode => clobber,
    }

  }

  class { windows::chocolatey :  }

  class { octopus:
    server_url => $base::octopus_server_url,
    ensure      => 'present',
    require     => Class[windows::chocolatey],
  }

}
