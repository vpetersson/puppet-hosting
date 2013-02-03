# == Class: hosting
# A class to manage a hosting environment using Puppet.
# In addition to this main module, there are two other modules ('hosting::php' and 'hosting::mysql').
#
# === Examples
#  include hosting
#  include hosting::mysql
#  include hosting::php
#
# === Authors
# Viktor Petersson <vpetersson@wireload.net>
#
# === Copyright
# Copyright 2013 Viktor Petersson.
#

class hosting {

  package { 'nginx':
    ensure => present,
  }

  service { 'nginx':
    ensure  => running,
    require => Package['nginx'],
  }

  file { 'www':
    ensure => directory,
    path   => '/www',
  }

  file { 'w3tc.inc':
    ensure => file,
    path   => '/etc/nginx/sites-available/w3tc.inc',
    source => 'puppet:///modules/hosting/w3tc.inc',
  }

  file { 'cloudflare.inc':
    ensure => file,
    path   => '/etc/nginx/sites-available/cloudflare.inc',
    source => 'puppet:///modules/hosting/cloudflare.inc',
  }

  # == Define: site
  #
  # A fully automated system to setup a web-site.
  # The template automatically creates all folders,
  # configures Nginx and creates all required folders.
  #
  # If you need to put any custom Nginx-code, such as
  # redirects, please use the file:
  # /etc/nginx/sites-available/${url}_custom.inc
  # which is included in the config-file.
  #
  # === Parameters
  #
  # [*url*]
  #  URL is the primary URL used for the site.
  #
  # [*url_aliases*]
  # List all URL alias in an array. All aliases will be
  # forwarded to the main URL with a 301 redirect.
  # Provide as strings in an array.
  #
  # [*type*]
  # The type of site. Valid options are:
  # 'mediawiki', 'php', 'wordpress', 'static', 'custom' and 'proxy'.
  #
  # When using 'proxy', the variable 'upstream' must be passed (eg.
  # 'localhost:8080'). If you have a setup that doesn't fit any
  # of the other options, use 'custom'. This will setup the
  # structure, but not populate the Nginx-config file.
  #
  # [*contact*]
  # The contact information for the website. Use syntax
  # Full Name <fname@domain.com>
  #
  # [*database*]
  # Optional value, but will print the database name
  # inside the Nginx-config file to simply maintenance.
  #
  # [*ip*]
  # Optional value for documenting what IP the DNS points to.
  #
  # [*cloudflare*]
  # Include CloudFlare snippet. Set to 'true' to enable,
  # defaults to 'false'.
  #
  # [*custom_document_root*]
  # Set a custom document root. Will not create the folder.
  #
  # === Examples
  #
  #   hosting::site { 'WireLoad':
  #     type        => 'wordpress',
  #     url         => 'wireload.net',
  #     url_aliases => ['wireload.*', 'www.wireload.net'],
  #     ip          => $ipaddress_eth0
  #     contact     => 'Viktor Petersson <vpetersson@wireload.net>'
  #   }
  #
  define site(
        $type, $url, $url_aliases, $contact, $ip='NONE',
        $custom_document_root=false, $database='NONE',
        $cloudflare=false, $upstream='NONE'
        ) {

    $www_root = "/www/${url}"

    if $custom_document_root == false {
      file { $www_root:
        ensure => directory,
        path   => $www_root,
      }
    }

    if $type == 'custom' {
      file { "vhost_${url}":
        ensure  => file,
        path    => "/etc/nginx/sites-available/${url}.conf",
      }
    }
    else {
      file { "vhost_${url}":
        ensure  => file,
        path    => "/etc/nginx/sites-available/${url}.conf",
        content => template("hosting/${type}.erb"),
        require => File['w3tc.inc'],
      }
    }

    file { "activate_${url}":
      ensure  => link,
      path    => "/etc/nginx/sites-enabled/${url}.conf",
      target  => "/etc/nginx/sites-available/${url}.conf",
      require => File["vhost_${url}"],
    }

    file { "custom_${url}":
      ensure  => file,
      path    => "/etc/nginx/sites-available/${url}_custom.inc",
    }

  }
}
