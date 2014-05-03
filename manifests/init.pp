# == Class: observium
#
# This module manages Observium
#
class observium (
  $base_path                 = '/opt/observium',
  $config_path               = '/opt/observium/config.php',
  $config_mode               = '0755',
  $config_owner              = 'root',
  $config_group              = 'root',
  $communities               = ['public'],
  $autodiscovery_ips         = ["127.0.0.0/8", "192.168.0.0/16", "10.0.0.0/8", "172.16.0.0/12"],
  $devices                   = undef,
  $http_port                 = '80',
  $mysql_host                = undef,
  $mysql_db                  = undef,
  $mysql_user                = undef,
  $mysql_password            = undef,
  $packages                  = 'USE_DEFAULTS',
  $poller_threads            = '1',
  $rrd_path                  = '/opt/observium/rrd',
  $rrd_mode                  = '0755',
  $rrd_owner                 = 'root',
  $rrd_group                 = 'root',
  $smokeping_directory       = undef,
  $servername                = $::fqdn,
  $snmp_version              = 'v2c',
  $users                     = undef,
  $cron_discovery_all_hour   = '*/6',
  $cron_discovery_all_minute = '33',
  $cron_discovery_all_user   = 'root',
  $cron_discovery_new_minute = '*/5',
  $cron_discovery_new_user   = 'root',
  $cron_poller_minute        = '*/5',
  $cron_poller_user          = 'root',
  $api_enabled               = 0,
  $api_modules               = [],
  $refresh_time              = undef,
  $frontpage_order = ['device_status', 'eventlog', 'eventlog'],
  $frontpage_eventlog = '15',
) {

  include observium::apache

  case $::osfamily {
    'Debian': {
      $default_packages = 'observium'
    }
    default: {
      fail("Module observium is supported on osfamily Debian. Your osfamily is identified as ${::osfamily}")
    }
  }

  if $packages == 'USE_DEFAULTS' {
    $my_packages = $default_packages
  } else if $packages == undef {
    $my_packages = undef
  } else {
    $my_packages = $packages
  }

  if $users {
    validate_hash($users)
    create_resources('observium::user', $users)
  }

  if $devices {
    validate_array($devices)
    observium::device { $devices: }
  }

  if $my_packages {
    package { 'observium_packages':
      ensure  => installed,
      name    => $my_packages,
    }
  }

  file { 'observium_path':
    ensure => directory,
    name   => $base_path,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { 'observium_config':
    ensure  => present,
    path    => $config_path,
    mode    => $config_mode,
    owner   => $config_owner,
    group   => $config_group,
    content => template('observium/config.php.erb'),
    if $my_packages {
    require => Package['observium_packages'],
    }
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
    path        => '/bin:/usr/bin:/usr/local/bin',
    command     => 'php includes/update/update.php',
    cwd         => $base_path,
    refreshonly => true,
  }

  cron { 'discovery-all':
    command => "${base_path}/discovery.php -h all >> /dev/null 2>&1",
    user    => $cron_discovery_all_user,
    minute  => $cron_discovery_all_minute,
    hour    => $cron_discovery_all_hour,
  }

  cron { 'discovery-new':
    command => "${base_path}/discovery.php -h new >> /dev/null 2>&1",
    user    => $cron_discovery_new_user,
    minute  => $cron_discovery_new_minute,
  }

  cron { 'poller':
    command => "${base_path}/poller-wrapper.py ${poller_threads} >> /dev/null 2>&1",
    user    => $cron_poller_user,
    minute  => $cron_poller_minute,
  }
}
