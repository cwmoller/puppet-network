# == Definition: network::bond::slave
#
# Creates a bonded slave interface.
#
# === Parameters:
#
#   $master        - required
#   $macaddress    - optional
#   $ethtool_opts  - optional
#   $restart       - optional, defaults to true
#   $zone          - optional
#   $defroute      - optional
#   $metric        - optional
#   $userctl       - optional - defaults to false
#   $bootproto     - optional
#   $onboot        - optional
#   $nm_controlled - optional - defaults to false
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Requires:
#
#   Service['NetworkManager']
#
# === Sample Usage:
#
#   network::bond::slave { 'eth1':
#     macaddress => $::networking['interfaces']['eth1']['mac'],
#     master     => 'bond0',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
define network::bond::slave (
  String $master,
  Optional[Stdlib::MAC] $macaddress = undef,
  Optional[String] $ethtool_opts = undef,
  Optional[String] $zone = undef,
  Optional[Enum['yes', 'no']] $defroute = undef,
  Optional[String] $metric = undef,
  Boolean $restart = true,
  Boolean $userctl = false,
  Boolean $nm_controlled = false,
  Optional[Network::If::Bootproto] $bootproto = undef,
  Optional[String] $onboot = undef,
) {

  include '::network'

  $interface = $name

  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
    content => epp("${module_name}/ifcfg-bond.epp", {
      interface     => $interface,
      macaddress    => $macaddress,
      master        => $master,
      ethtool_opts  => $ethtool_opts,
      defroute      => $defroute,
      zone          => $zone,
      metric        => $metric,
      bootproto     => $bootproto,
      onboot        => $onboot,
      userctl       => $userctl,
      nm_controlled => $nm_controlled,
    }),
    before  => File["ifcfg-${master}"],
  }

  if $restart {
    File["ifcfg-${interface}"] {
      notify  => Service['NetworkManager'],
    }
  }
} # define network::bond::slave
