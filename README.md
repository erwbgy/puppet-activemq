# puppet-activemq

Puppet module to install Apache Tomcat and run instances as Runit services
under one or more users.

The recommended usage is to place the configuration is hiera and just:

    include activemq

Example hiera config:

    activemq::files:
      conf/activemq.xml:
        mode:     '0440'
        source:   'puppet:///files/activemq/myapp/activemq.xml'

    activemq::templates:
      conf/activemq-users.xml:
        mode:     '0440'
        template: '/var/lib/puppet/files/activemq/myapp/activemq-users.xml.erb'
    
    activemq::group:     'activemq'
    
    activemq::java_home: '/usr/java/jdk1.7.0_09'
    
    activemq::java_opts: '-Xms1536m -Xmx1536m -XX:MaxPermSize=512m'
    
    activemq::version:   '5.8.0'
    
    activemq::instances:
      activemq1:
        basedir:      '/apps/activemq1'
        bind_address: %{ipaddress_eth0_1}
        logdir:       '/apps/activemq1/logs'
      activemq2:
        basedir:      '/apps/activemq2'
        bind_address: %{ipaddress_eth0_2}
        logdir:       '/apps/activemq2/logs'

## activemq parameters

*basedir*: The base installation directory. Default: '/opt/activemq'

*bind_address*: The IP address listen sockets are bound to. Default: $::fqdn

*files*: A hash of configuration files to install - see below

*group*: The user''s primary group. Default: 'activemq',

*java_home*: The base directory of the JDK installation to be used. Default:
'/usr/java/latest',

*java_opts*: Additional java command-line options to pass to the startup script

*logdir*: The base log directory. Default: '/var/logs/activemq'

*min_mem*: The minimum heap size allocated by the JVM. Default: 1024m

*max_mem*: The maximum heap size allocated by the JVM. Default: 2048m

*mode*: The permissions to create files with (eg. 0444).

*templates*: A hash of configuration templates to process and install - see below

*version*: The version of the product to install (eg. 5.8.0). **Required**.

*workspace*: A temporary directory to unpack install tarballs into. Default:
'/root/activemq'

## activemq::instance parameters

*title*: The user the Tomcat instance runs as

Plus all of the parameters specified in 'activemq parameters' above

## Config files

Files or templates for each of the Tomcat instances can be delivered via
Puppet.  The former are delivered as-is while the latter are processed as ERB
templates before being delivered.

For example configuration could be delivered using for instances running as the
activemq1 and activemq2 users with:

    activemq::files:
      conf/activemq-users.xml:
        source: 'puppet:///files/activemq/dev/activemq-users.xml'
      
    activemq:
      activemq1:
        templates:
          conf/activemq.xml:
            template: 'puppet:///files/activemq/dev1/activemq.xml.erb'
      activemq2:
        templates:
          conf/activemq.xml:
            template: 'puppet:///files/activemq/dev2/activemq.xml.erb'

Values set at the activemq level as set for all instances so both the activemq1 and
activemq2 instance would get the same activemq-users.xml file.  Each instance would
get their own activemq.xml file based on the template specified with instance
variables (like basedir and logdir) substituted.

All files are relative to the product installation.  For example if the product
installation is '/opt/activemq/apache-activemq-5.8.0' then the full path to the
'activemq-users.xml' file would be
'/opt/activemq/apache-activemq-5.8.0/conf/activemq-users.xml'.

Note that the path specified by the 'template' parameter is on the Puppet
master.

## Product files

Place the product zip files (eg. 'apache-activemq-5.8.0.tar.gz') under a
'activemq' directory of the 'files' file store.  For example if
/etc/puppet/fileserver.conf has:

    [files]
    path /var/lib/puppet/files

then put the zip files in /var/lib/puppet/files/activemq.  Any files specified
with the 'files' parameter can also be placed in this directory.

## Support

License: Apache License, Version 2.0

GitHub URL: https://github.com/erwbgy/puppet-activemq
