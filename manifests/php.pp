# == Class: hosting::php
# Install PHP-FPM with the most common modules.

class hosting::php {

  $required_packages=[
    'php5-fpm',
    'php5-mysql',
    'php-apc',
    'php5-gd',
    'php5-curl',
  ]

  package { $required_packages:
    ensure => present,
  }

  service { 'php5-fpm':
    ensure => running,
  }
}
