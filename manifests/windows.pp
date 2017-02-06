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

  exec { 'Enable Powershell Remoting':
    command   => 'Enable-PSRemoting -force',
    provider  => powershell,
    onlyif    => "if((Get-ChildItem WSMan:\\localhost\\Listener -recurse | where {\$_.pschildname -contains 'Enabled'}).Value.CompareTo('${$base::powershell_remote_enabled}') -eq 0) { exit 1 } else { exit 0 }",
    require   => Exec['Enable PowerShell in x64'],
    logoutput => true,
  }

  exec {'Set Remoting on Port':
    command   => "Set-Item WSMan:\\localhost\\listener\\*\\Port $powershell_remote_port -force",
    onlyif    => "if((dir WSMan:\\localhost\\listener\\*\\Port).value.CompareTo('${$base::powershell_remote_port}') -eq 0) { exit 1 } else { exit 0 }",
    provider  => powershell,
    require   => Exec['Enable Powershell Remoting'],
    notify    => Exec['Restart Service'],
    logoutput => true,
  }

  exec {'Enable trusted hosts':
    command   => "set-item wsman:localhost\\client\\trustedhosts -value $powershell_trusted_hosts -force",
    onlyif    => "if((Get-Item wsman:localhost\\client\\trustedhosts).Value.CompareTo('${$base::powershell_trusted_hosts}') -eq 0) { exit 1 } else { exit 0 }",
    provider  => powershell,
    require   => Exec['Enable Powershell Remoting'],
    notify    => Exec['Restart Service'],
    logoutput => true,
  }

  exec { 'Restart Service':
    command     => 'restart-Service winrm',
    provider    => powershell,
    refreshonly => true,
  }


  class { windows::chocolatey :  }

  class { octopus:
    server_url => $base::octopus_server_url,
    ensure      => 'present',
    require     => Class[windows::chocolatey],
  }

}
