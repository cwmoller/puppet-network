# == Definition: network::bond::bridge
#
# Creates a bonded, bridge interface and enables the bonding driver.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $bridge       - required
#   $mtu          - optional
#   $ethtool_opts - optional
#   $bonding_opts - optional
#   $restart      - optional - defaults to true
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
# Updates /etc/modprobe.conf with bonding driver parameters.
#
# === Sample Usage:
#
#   network::bond::bridge { 'bond2':
#     ensure => 'up',
#     bridge => 'br0',
#   }
#
# === Authors:
#
# David Cote
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 David Cote, unless otherwise noted.
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
define network::bond::bridge (
  Enum['up', 'down'] $ensure,
  String $bridge,
  Optional[String] $mtu = undef,
  Optional[String] $ethtool_opts = undef,
  String $bonding_opts = 'miimon=100',
  Boolean $restart = true,
) {

  network_if_base { $title:
    ensure       => $ensure,
    bootproto    => 'none',
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    bonding_opts => $bonding_opts,
    bridge       => $bridge,
    restart      => $restart,
  }

  # Only install "alias bondN bonding" on old OSs that support
  # /etc/modprobe.conf.
  case $::os['name'] {
    /^(RedHat|CentOS|OEL|OracleLinux|SLC|Scientific)$/: {
      case $::os['release']['major'] {
        /^[45]$/: {
          augeas { "modprobe.conf_${title}":
            context => '/files/etc/modprobe.conf',
            changes => [
              "set alias[last()+1] ${title}",
              'set alias[last()]/modulename bonding',
            ],
            onlyif  => "match alias[*][. = '${title}'] size == 0",
            before  => Network_if_base[$title],
          }
        }
        default: {}
      }
    }
    'Fedora': {
      case $::os['release']['major'] {
        /^(1|2|3|4|5|6|7|8|9|10|11)$/: {
          augeas { "modprobe.conf_${title}":
            context => '/files/etc/modprobe.conf',
            changes => [
              "set alias[last()+1] ${title}",
              'set alias[last()]/modulename bonding',
            ],
            onlyif  => "match alias[*][. = '${title}'] size == 0",
            before  => Network_if_base[$title],
          }
        }
        default: {}
      }
    }
    default: {}
  }
} # define network::bond::bridge
