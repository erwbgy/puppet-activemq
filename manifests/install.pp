define activemq::install (
  $basedir,
  $group,
  $jolokia,
  $jolokia_address,
  $jolokia_port,
  $jolokia_version,
  $user,
  $version,
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
      source  => "puppet:///files/activemq/${tarball}",
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
      source  => "puppet:///files/activemq/jolokia-jvm-${jolokia_version}-agent.jar",
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
}