puppet-module-observium
=======================

Puppet module to manage Obversvium

===

Example Hiera definitions:
<pre>
observium::devices:
  - device1.example.com
  - device2.example.com

observium::users:
  admin:
    password: 'secret'
    level: '10'
  user:
    password: 'secret1'
    level: '1'
</pre>

===

Dependencies
------------

Some functionality is dependent on other modules:

- [stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)
- [apache](https://github.com/ghoneycutt/puppetlabs-apache)

# Parameters

base_path
---------
Base installation path for Observium

- *Default*: '/opt/observium'

config_path
-----------
Full path to Observium config file

- *Default*: '/opt/observium/config.php'

config_mode
-----------
Config file mode

- *Default*: 0755

config_owner
------------
Config file owner

- *Default*: root

config_group
------------
Config file group

- *Default*: root

communities
-----------
SNMP communities

- *Default*: ['public']

devices
-------
List of devices to poll

- *Default*: undef

http_port
---------
HTTP port for vhost

- *Default*: undef

mysql_host
----------
Mysql server to connect to

- *Default*: undef

mysql_db
--------
Mysql database name to use

- *Default*: undef

mysql_user
----------
Mysql database user

- *Default*: undef

mysql_password
--------------
Mysql database password

- *Default*: undef

poller_threads
--------------
Number of threads to use in poller script

- *Default*: 1

rrd_path
--------
Path where to store RRDs

- *Default*: '/opt/observium/rrd'

rrd_mode
--------
RRD directory mode

- *Default*: 0755

rrd_owner
---------
RRD directory owner

- *Default*: root

rrd_group
---------
RRD directory group

- *Default*: root

servername
----------
ServerName for Apache vhost

- *Default*: $::fqdn

snmp_version
------------
SNMP version

- *Default*: 'v2c'

standalone
----------
Setup standalone server and database

- *Default*: false

svn_http_proxy_host
-------------------
HTTP Proxy host for Subversion checkout

- *Default*: undef

svn_http_proxy_port
-------------------
HTTP Proxy port for Subversion checkout

- *Default*: undef

svn_url
-------
URL to Subsversion repository to checkout

- *Default*: 'http://www.observium.org/svn/observer/trunk'

users
-----
List of users to add

- *Default*: undef

