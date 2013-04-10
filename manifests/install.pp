define activemq::install (
  $basedir,
  $filestore,
  $group,
  $java_home,
  $jolokia,
  $jolokia_address,
  $jolokia_cron,
  $jolokia_port,
  $jolokia_version,
  $logdir,
  $user,
  $version,
  $ulimit_nofile,
  $workspace,
) {
  $tarball = "apache-activemq-${version}-bin.tar.gz"
  $subdir  = "apache-activemq-${version}"
  if ! defined(Package['tar']) {
    package { 'tar': ensure => installed }
  }
  if ! defined(Package['gzip']) {
    package { 'gzip': ensure => installed }
  }
  # defaults
  File {
    owner => $user,
    group => $group,
  }
  if ! defined(File[$basedir]) {
    file { $basedir: ensure => directory, mode => '0755' }
  }
  if ! defined(File["${workspace}/${tarball}"]) {
    file { "${workspace}/${tarball}":
      ensure  => present,
      mode    => '0444',
      source  => "${filestore}/${tarball}",
      require => File[$workspace],
    }
  }
  exec { "activemq-unpack-${user}":
    cwd         => $basedir,
    command     => "/bin/tar -zxf '${workspace}/${tarball}'",
    creates     => "${basedir}/${subdir}",
    notify      => Exec["activemq-fix-ownership-${user}"],
    require     => [ File[$basedir], File["${workspace}/${tarball}"] ],
  }
  if $jolokia {
    file { "${basedir}/${subdir}/lib/jolokia-jvm-${jolokia_version}-agent.jar":
      ensure  => present,
      mode    => '0444',
      source  => "${filestore}/jolokia-jvm-${jolokia_version}-agent.jar",
      require => Exec["activemq-unpack-${user}"],
    }
    case $::operatingsystem {
      'RedHat', 'CentOS', 'OracleLinux': {
        if ! defined(Package['perl-libwww-perl']) {
          package { 'perl-libwww-perl':  ensure => installed }
        }
        if versioncmp($::operatingsystemrelease, '6.0') > 0 {
          if ! defined(Package['perl-JSON']) {
            package { 'perl-JSON':  ensure => installed }
          }
        }
        else {
          warning('Install the Perl JSON module manually')
        }
      }
      default: {
        warning('Install the Perl libwww and JSON modules manually')
      }
    }
    file { "${basedir}/${subdir}/bin/connection-monitor":
      ensure  => present,
      mode    => '0555',
      content => template('activemq/connection-monitor.erb'),
      require => Exec["activemq-unpack-${user}"],
    }
    file { "${basedir}/${subdir}/bin/queue-monitor":
      ensure  => present,
      mode    => '0555',
      content => template('activemq/queue-monitor.erb'),
      require => Exec["activemq-unpack-${user}"],
    }
  }
  exec { "activemq-fix-ownership-${user}":
    command     => "/bin/chown -R ${user}:${group} ${basedir}/${subdir}",
    refreshonly => true,
  }
  file { "${basedir}/activemq":
    ensure  => link,
    target  => $subdir,
    require => File[$basedir],
  }
  file { "${product_dir}/bin/thread_dump":
    ensure  => present,
    mode    => '0555',
    owner   => $user,
    group   => $group,
    content => template('activemq/thread_dump.erb'),
    require => Exec["activemq-unpack-${user}"],
  }
}
