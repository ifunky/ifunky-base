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

  exec { 'Enable Powershell Remoting':
    command   => 'Enable-PSRemoting -force',
    provider  => powershell,
    onlyif    => "if((Get-ChildItem WSMan:\\localhost\\Listener -recurse | where {\$_.pschildname -contains 'Enabled'}).Value.CompareTo('${$base::powershell_remote_enabled}') -eq 0) { exit 1 } else { exit 0 }",
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

  class { windows::proxysettings :
    proxy_server      => $base::proxy_server,
    proxy_exclusions  => $base::proxy_exclusions
  }

  class { windows::chocolatey :  }
  class { windows::machineconfig :  }

  include profile::windows::software::nsclient
  include ::profile::windows::software::filebeat

  class { octopus:
    server_url => $base::octopus_server_url,
    ensure      => 'present',
    require     => Class[windows::chocolatey],
  }

}
