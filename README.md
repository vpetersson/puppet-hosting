# puppet-hosting
Simple and powerful webhosting engine using Puppet for Nginx and PHP-FPM.


## Overview

After years of hosting a bunch of websites for both [WireLoad](http://wireload.net) as well as friends and family, I finally had enough. It was a huge mess that needed to get organized.

Enter puppet-hosting. It's a Puppet-modules that solves this mess. Puppet-hosting allows you to easily manage your hosting environment. The idea is to build in best-practices for the most common setups, while also making the administration painless and straight forward. No more typos in config-files and no more copying and pasting.

Here's a example of how puppet-hosting work:

    hosting::site { 'My Website':
      type        => 'wordpress',
      url         => 'mysite.net',
      url_aliases => ['mysite.*', 'www.mysite.net'],
      ip          => $ipaddress_eth0,
      contact     => 'Viktor Petersson <vpetersson@wireload.net>',
    }

The above snippet is all you need to setup a hosting environment. It will:

 * Create the folder /www/mysite.net.
 * Create the file /etc/nginx/sites-available/mysite.net.conf with the WordPress-template.
 * Create /etc/nginx/sites-available/mysite.net_custom for customizations (such as custom rewrite rules).
 * Symlink  /etc/nginx/sites-enabled/mysite.net.conf to /etc/nginx/sites-available/mysite.net.conf.
 * Make sure rewrites are done properly to your primary domain.

All you need to do is to run:

    $ /etc/init.d/nginx configtest

If everything goes well, you can just run:

    $ /etc/init.d/nginx reload

(Readers familiar with Puppet will notice that the above could be done with directly with Puppet, which is true. I just prefer to do this step by hand.)

## Limitations

Currently, this module is tailored for Ubuntu 12.04. It would probably not be very difficult to rewrite it to support other platforms too, but I have no need for that at the moment.

If it wasn't clear in the above overview, **this module is for Nginx and PHP-FPM**. I gave up on Apache long time ago, so I won't spend any time adding support for that. That said, it probably wouldn't be too difficult to fork the module and rewrite it for Apache, Lighttpd or any other webserver you prefer.


## Installation

Assuming you have Puppet all up and running, all you need to do is to install to clone this repository directly into your Puppet-modules folder with something like:

    $ cd /etc/puppet/modules
    $ git clone git://github.com/vpetersson/puppet-hosting.git hosting

Next you need to enable the module in your site.pp-file by simply including the following (assuming you want all-submodules).

    include hosting
    include hosting::php
    include hosting::mysql

With that done, all you need to do is to add all your sites similar to what is mentioned above.

## Parameters

### url
URL is the primary URL used for the site.

### url_aliases
List all URL alias in an array. All aliases will be forwarded to the main URL with a 301 redirect. Provide as strings in an array.

### type
The type of site.

**mediawiki** - A mediawiki-site.

**php** - A regular PHP-site.


**wordpress** - A wordpress-site. Preconfigured with W3 Total Cache-support.

**static** - A good 'ol static HTML-site.

**proxy** - Proxy to an upstream server. Must be combined with  the variable 'upstream' (eg. 'localhost:8080').

**custom** - If you have a setup that doesn't fit any of the other options, use 'custom'. This will setup the structure, but not populate the Nginx-config file.

### contact
The contact information for the website. Use syntax: Full Name <fname@domain.com>

### database
Optional value, but will print the database name inside the Nginx-config file to simply maintenance.

### ip
Optional value for documenting what IP the DNS points to.

### cloudflare
Include CloudFlare snippet. Set to 'true' to enable, defaults to 'false'.

### custom_document_root
Set a custom document root. Will not create the folder.

