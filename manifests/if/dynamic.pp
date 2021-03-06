# == Definition: network::if::dynamic
#
# Creates a normal interface with dynamic IP information.
#
# === Parameters:
#
#   $ensure          - required - up|down
#   $macaddress      - optional - defaults to $::networking['interfaces'][$title]['mac']
#   $manage_hwaddr   - optional - defaults to true
#   $bootproto       - optional - defaults to "dhcp"
#   $userctl         - optional - defaults to false
#   $mtu             - optional
#   $dhcp_hostname   - optional
#   $ethtool_opts    - optional
#   $peerdns         - optional
#   $dns1            - optional - only used when peerdns is true
#   $dns2            - optional - only used when peerdns is true
#   $nm_controlled   - optional - defaults to false
#   $linkdelay       - optional
#   $check_link_down - optional
#   $zone            - optional
#   $metric          - optional
#   $defroute        - optional
#   $restart         - optional - defaults to true
#   $vlan            - optional - defaults to false
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::if::dynamic { 'eth2':
#     ensure     => 'up',
#     macaddress => $::networking['interfaces']['eth2']['mac'],
#   }
#
#   network::if::dynamic { 'eth3':
#     ensure     => 'up',
#     macaddress => 'fe:fe:fe:fe:fe:fe',
#     bootproto  => 'bootp',
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
define network::if::dynamic (
  Enum['up', 'down'] $ensure,
  Optional[Stdlib::MAC] $macaddress = undef,
  Boolean $manage_hwaddr = true,
  Network::If::Bootproto $bootproto = 'dhcp',
  Boolean $userctl = false,
  Optional[String] $mtu = undef,
  Optional[String] $dhcp_hostname = undef,
  Boolean $persistent_dhclient = false,
  Optional[String] $ethtool_opts = undef,
  Boolean $peerdns = false,
  Boolean $nm_controlled = false,
  Optional[Stdlib::IP::Address::Nosubnet] $dns1 = undef,
  Optional[Stdlib::IP::Address::Nosubnet] $dns2 = undef,
  Optional[String] $linkdelay = undef,
  Boolean $check_link_down = false,
  Optional[Enum['yes', 'no']] $defroute = undef,
  Optional[String] $zone = undef,
  Optional[String] $metric = undef,
  Boolean $restart = true,
  Boolean $vlan = false,
) {

  if $macaddress {
    $macaddy = $macaddress
  } else {
    # Strip off any tailing VLAN (ie eth5.90 -> eth5).
    $title_clean = regsubst($title,'^(\w+)\.\d+$','\1')
    $macaddy = $::networking['interfaces'][$title_clean]['mac']
  }

  if !$peerdns and ($dns1 or $dns2) {
    fail('$peerdns must be true when $dns1 or $dns2 are specified')
  }

  network_if_base { $title:
    ensure              => $ensure,
    macaddress          => $macaddy,
    manage_hwaddr       => $manage_hwaddr,
    bootproto           => $bootproto,
    userctl             => $userctl,
    mtu                 => $mtu,
    dhcp_hostname       => $dhcp_hostname,
    persistent_dhclient => $persistent_dhclient,
    ethtool_opts        => $ethtool_opts,
    peerdns             => $peerdns,
    nm_controlled       => $nm_controlled,
    dns1                => $dns1,
    dns2                => $dns2,
    linkdelay           => $linkdelay,
    check_link_down     => $check_link_down,
    defroute            => $defroute,
    zone                => $zone,
    metric              => $metric,
    restart             => $restart,
    vlan                => $vlan,
  }
} # define network::if::dynamic
