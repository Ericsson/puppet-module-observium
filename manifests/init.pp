# == Class: observium
#
# This module manages Observium
#
class observium(
  $base_path           = '/opt/observium',
  $config_path         = '/opt/observium/config.php',
  $config_mode         = '0755',
  $config_owner        = 'root',
  $config_group        = 'root',
  $communities         = ['public'],
  $devices             = undef,
  $http_port           = '80',
  $mysql_host          = undef,
  $mysql_db            = undef,
  $mysql_user          = undef,
  $mysql_password      = undef,
  $poller_threads      = '1',
  $rrd_path            = '/opt/observium/rrd',
  $rrd_mode            = '0755',
  $rrd_owner           = 'root',
  $rrd_group           = 'root',
  $servername          = $::fqdn,
  $snmp_version        = 'v2c',
  $standalone          = false,
  $svn_http_proxy_host = undef,
  $svn_http_proxy_port = undef,
  $svn_url             = 'http://www.observium.org/svn/observer/trunk',
  $users               = undef,
) {

  case $::osfamily {
    'Debian': {
      $default_packages = ['libapache2-mod-php5','php5-cli','php5-mysql',
                            'php5-gd','php5-snmp','php-pear','snmp',
                            'graphviz','php5-mcrypt','subversion',
                            'mysql-client','rrdtool','fping',
                            'imagemagick','whois','mtr-tiny','nmap','ipmitool',
                            'python-mysqldb']
      $default_packages_standalone = ['mysql-server']
    }
    default: {
      fail("Module observium is supported on osfamily Debian. Your osfamily is identified as ${::osfamily}")
    }
  }

  if $packages == undef {
    $my_packages = $default_packages
  } else {
    $my_packages = $packages
  }

  if $svn_http_proxy_host {
    $svn_http_proxy_host_opt = "--config-option servers:global:http-proxy-host=${svn_http_proxy_host}"
  } else {
    $svn_http_proxy_host_opt = ""
  }
  if $svn_http_proxy_port {
    $svn_http_proxy_port_opt = "--config-option servers:global:http-proxy-port=${svn_http_proxy_port}"
  } else {
    $svn_http_proxy_port_opt = ""
  }

  include observium::apache

  if $users {
    validate_hash($users)
    create_resources('observium::adduser', $users)
  }

  if $devices {
    validate_array($devices)
    observium::add_device { $devices: }
  }

  package { 'observium_packages':
    ensure => installed,
    name   => $my_packages,
  }

  if $standalone == true {
    package { 'observium_standalone_pkgs':
      ensure => installed,
      name   => $default_packages_standalone,
    }
  }

  exec { 'observium-svn-co':
    path    => '/usr/bin:/bin',
    command => "svn co ${svn_http_proxy_host_opt} ${svn_http_proxy_port_opt} ${svn_url} observium",
    cwd     => '/opt',
    creates => "${base_path}/poller.php",
    require => File['observium_path'],
  }

  file { 'observium_path':
    ensure => directory,
    mode   => 0755,
    owner  => 'root',
    group  => 'root',
    name   => $base_path,
  }

  file { 'observium_config':
    ensure  => present,
    path    => $config_path,
    mode    => $config_mode,
    owner   => $config_owner,
    group   => $config_group,
    content => template('observium/config.php.erb'),
    require => File['observium_path'],
    notify  => Exec['update_db'],
  }

  file { 'observium_rrd_base':
    ensure  => directory,
    path    => $rrd_path,
    mode    => $rrd_mode,
    owner   => $rrd_owner,
    group   => $rrd_group,
    require => File['observium_path'],
  }

  exec { 'update_db':
    path        => '/usr/bin:/bin',
    command     => 'php includes/update/update.php',
    cwd         => $base_path,
    refreshonly => true,
  }

  cron { 'discovery-all':
    command => "${base_path}/discovery.php -h all >> /dev/null 2>&1",
    user    => 'root',
    minute  => '33',
    hour    => '*/6',
  }

  cron { 'discovery-new':
    command => "${base_path}/discovery.php -h new >> /dev/null 2>&1",
    user    => 'root',
    minute  => '*/5',
  }

  cron { 'poller':
    command => "${base_path}/poller-wrapper.py ${poller_threads} >> /dev/null 2>&1",
    user    => 'root',
    minute  => '*/5',
  }

#  svn::checkout { "observium-${svn_branch}":
#    reposerver      => 'www.observium.org',
#    method          => 'http',
#    repopath        => 'svn/observer',
#    branch          => $svn_branch,
#    workingdir      => $base_path,
#    localuser       => 'puppet',
#    http_proxy_host => 'www-proxy.ericsson.se',
#    http_proxy_p'rt => '8080',
#    refreshonly     => true,
#  }

}
