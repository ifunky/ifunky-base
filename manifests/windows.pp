# Windows base class that every Windows server will apply
#
# @author Dan
class base::windows () inherits base {

  include profile::windows::timezone

   notify { "PROXY: ${base::proxy_server}": }


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

}
