# puppet-activemq

Puppet module to install Apache ActiveMQ and run instances as Runit services
under one or more users.

The recommended usage is to place the configuration in hiera and just:

    include activemq

Example hiera config:

    activemq::config:
      hostname: 'localhost'

    activemq::config_file: 'xbean:conf/activemq.xml'

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
        config:
          hostname:   %{ipaddress_eth0_1}
        logdir:       '/apps/activemq1/logs'
      activemq2:
        basedir:      '/apps/activemq2'
        logdir:       '/apps/activemq2/logs'

## activemq parameters

*basedir*: The base installation directory. Default: '/opt/activemq'

*config*: A hash of additional configuration variables that will be set
when templates are processed.

*config_file*: The configuration file to use. Default: 'xbean:conf/activemq.xml'

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

*title*: The user the ActiveMQ instance runs as

Plus all of the parameters specified in 'activemq parameters' above

## Config files and templates

Files or templates for each of the ActiveMQ instances can be delivered via
Puppet.  The former are delivered as-is while the latter are processed as ERB
templates before being delivered.

For example configuration could be delivered using for instances running as the
activemq1 and activemq2 users with:

    activemq::config:
      hostname: 'localhost'

    activemq::files:
      conf/activemq-users.xml:
        source: 'puppet:///files/activemq/dev/activemq-users.xml'
      
    activemq:
      activemq1:
        templates:
          conf/activemq.xml:
            template: '/etc/puppet/templates/activemq/dev1/activemq.xml.erb'
      activemq2:
        templates:
          conf/activemq.xml:
            template: '/etc/puppet/templates/activemq/dev2/activemq.xml.erb'

Values set at the activemq level as set for all instances so both the activemq1
and activemq2 instance would get the same activemq-users.xml file.  Each
instance would get their own activemq.xml file based on the template specified
with instance variables (like basedir and logdir) and config variables (like
hostname above) substituted.

For example:

    <broker ... dataDirectory="<%= @basedir %>/data" persistent="false" ...
    ...
    <transportConnectors>
      <transportConnector name="nio" uri="nio://<%= @config['hostname'] %>:61618"/>
    </transportConnectors>
    ...

All files and templates are relative to the product installation.  For example
if the product installation is '/opt/activemq/apache-activemq-5.8.0' then the
full path to the 'activemq-users.xml' file would be
'/opt/activemq/apache-activemq-5.8.0/conf/activemq-users.xml'.

Note that the path specified by the 'template' parameter is on the Puppet
master.

## Product zip files

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
