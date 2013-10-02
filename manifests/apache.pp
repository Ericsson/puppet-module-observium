class observium::apache {

  include apache
  include apache::params
  apache::mod { 'rewrite': }

  apache::vhost { 'observium':
    priority           => '10',
    port               => $observium::http_port,
    docroot            => "${observium::base_path}/html",
    logroot            => "${observium::base_path}/logs",
    servername         => $observium::servername,
    configure_firewall => false,
    override           => 'All',
  }

}
