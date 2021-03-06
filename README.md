# _Unmaintained_

I no longer use Puppet actively and this software has not been maintained for some time.

# puppet-activemq

Puppet module to install Apache ActiveMQ and run instances as Runit services
under one or more users.

The recommended usage is to place the configuration in hiera and just:

    include activemq

Example hiera config:

    activemq::config:
      hostname: 'localhost'

    activemq::config_file: 'xbean:conf/activemq.xml'

    activemq::cpu_affinity: '0,1'

    activemq::files:
      conf/activemq.xml:
        mode:     '0440'
        source:   'puppet:///files/activemq/myapp/activemq.xml'

    activemq::filestore: 'puppet:///files/activemq'

    activemq::templates:
      conf/activemq-users.xml:
        mode:     '0440'
        template: '/var/lib/puppet/files/activemq/myapp/activemq-users.xml.erb'
    
    activemq::group:     'activemq'
    
    activemq::java_home: '/usr/java/jdk1.7.0_09'
    
    activemq::java_opts: '-Xms1536m -Xmx1536m -XX:MaxPermSize=512m'

    activemq::jolokia_version: '1.1.1'
    
    activemq::version:   '5.8.0'
    
    activemq::instances:
      activemq1:
        basedir:      '/apps/activemq1'
        config:
          hostname:   %{ipaddress_eth0_1}
        logdir:       '/apps/activemq1/logs'
        jolokia:         'true'
        jolokia_address: %{ipaddress_eth0_1}
        jolokia_port:    '8778'
      activemq2:
        basedir:      '/apps/activemq2'
        logdir:       '/apps/activemq2/logs'

## activemq parameters

*basedir*: The base installation directory. Default: '/opt/activemq'

*config*: A hash of additional configuration variables that will be set
when templates are processed.

*config_file*: The configuration file to use. Default: 'xbean:conf/activemq.xml'

*cpu_affinity*: Enable CPU affinity to be set to only run processes on specific
CPU cores - for example '0,1' to only run processes on the first two cores.

*files*: A hash of configuration files to install - see below

*filestore*: The Puppet filestore location where the ActiveMQ tarball and Jolokia
agent jar file are downloaded from. Default: 'puppet:///files/activemq'

*group*: The user''s primary group. Default: 'activemq',

*java_home*: The base directory of the JDK installation to be used. Default:
'/usr/java/latest',

*java_opts*: Additional java command-line options to pass to the startup script

*jolokia*: Whether or not to install the jolokia war file and configure a
separate service to run it. Default: false

*jolokia_address*: The address that the jolokia HTTP service listens on.
Default: 'localhost'

*jolokia_cron*: Whether or not to install cron jobs to run the Jolokia JMX
monitoring scripts every minute writing to local log files. Default: 'true'

*jolokia_port*: The port that the jolokia HTTP service listens on. Default:
'8778'

*logdir*: The base log directory. Default: '/var/logs/activemq'

*min_mem*: The minimum heap size allocated by the JVM. Default: 1024m

*max_mem*: The maximum heap size allocated by the JVM. Default: 2048m

*mode*: The permissions to create files with (eg. 0444).

*templates*: A hash of configuration templates to process and install - see below

*ulimit_nofile*: The maximum number of open file descriptors the java process
is allowed.  Default is '$(ulimit -H -n)' which sets the value to the hard
limit in /etc/security/limits.conf (or equivalent) for the user.

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
with the 'files' parameter can also be placed in this directory, as can the
Jolokia agent jar file.

This location can be changed by setting the 'filestore' parameter.

## Monitoring

The jolokia parameters enable JMX statistics to be queried over HTTP - for example:

    $ curl http://localhost:8778/jolokia/read/java.lang:type=Memory/HeapMemoryUsage
    {"timestamp":1363883323,"status":200,"request":{"mbean":"java.lang:type=Memory"
    ," attribute":"HeapMemoryUsage","type":"read"},"value":{"max":1908932608,"commi
    tted":1029046272,"init":1073741824,"used":155889168}}

To limit what what can be accessed a jolokia-access.xml can be included in the
war file.  This is what I do to ensure read-only access:

    $ cd /var/lib/puppet/files/activemq
    $ wget http://labs.consol.de/maven/repository/org/jolokia/jolokia-jvm/1.1.1/jolokia-jvm-1.1.1-agent.jar
    $ vim jolokia-access.xml
    <?xml version="1.0" encoding="utf-8"?>
    <restrict>
      <commands>
        <command>read</command>
        <command>list</command>
        <command>version</command>
        <command>search</command>
      </commands>
      <http>
        <method>get</method>
        <method>post</method>
      </http>
    </restrict>
    $ zip -u jolokia-jvm-1.1.1-agent.jar jolokia-access.xml

To make the ActiveMQ JMX MBeans available it is not necessary to create a JMX
connector (and not recommended either) but JMX must be enabled - for example:

    <broker ... useJmx="true" ...>
      ...
      <managementContext>
        <managementContext createConnector="false"/>
      </managementContext>
      ...
    </broker>

Note that the elements inside broker must be in alphabetical order - for
example managementContext must be after destinationPolicy but before
systemUsage.

If jolokia support is enabled then connection and queue monitoring scripts are
run from cron every minute writing to local log files.

## Support

License: Apache License, Version 2.0

GitHub URL: https://github.com/erwbgy/puppet-activemq
