class nova::compute::libvirt (
  $libvirt_type = 'kvm',
  $vncserver_listen = '127.0.0.1',
  $block_migration = true,
) {

  include nova::params

  Service['libvirt'] -> Service['nova-compute']

  if($::nova::params::compute_package_name) {
    package { "nova-compute-${libvirt_type}":
      ensure => present,
      before => Package['nova-compute'],
    }
  }

  if($block_migration) {
    File {
      owner   => 'root',
      group   => 'root',
      mode    => '644',
      require => Package["nova-compute-${libvirt_type}"],
      notify  => Service['libvirt'],
    }
    file { '/etc/libvirt/libvirtd.conf':
      source => 'puppet:///modules/nova/libvirtd.conf',
    }

    file { '/etc/init/libvirt-bin.conf':
      source => 'puppet:///modules/nova/libvirt-bin.conf',
    }

    file { '/etc/default/libvirt-bin':
      source => 'puppet:///modules/nova/libvirt-bin',
    }
  }

  package { 'libvirt':
    name   => $::nova::params::libvirt_package_name,
    ensure => present,
  }

  service { 'libvirt' :
    name     => $::nova::params::libvirt_service_name,
    ensure   => running,
    provider => $::nova::params::special_service_provider,
    require  => Package['libvirt'],
  }

  nova_config { 'libvirt_type': value => $libvirt_type }
  nova_config { 'connection_type': value => 'libvirt' }
  nova_config { 'vncserver_listen': value => $vncserver_listen }
}
