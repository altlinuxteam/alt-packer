# This file is part of cloud-init. See LICENSE file for license information.

import os

from cloudinit.distros.parsers import resolv_conf
from cloudinit import util

from . import renderer


class Renderer(renderer.Renderer):
    """Renders network information in a /etc/net format."""

    iface_defaults = tuple([
        ('ONBOOT', True),
        ('DISABLED', False),
        ('NM_CONTROLLED', False),
        ('BOOTPROTO', 'dhcp'),
    ])

    def __init__(self, config=None):
        if not config:
            config = {}
        self.etcnet_dir = config.get('etcnet_dir', 'etc/net/ifaces/')
        self.netrules_path = config.get(
            'netrules_path', 'etc/udev/rules.d/70-persistent-net.rules')
        self.dns_path = config.get('dns_path', 'etc/net/ifaces/lo/resolv.conf')

    @classmethod
    def _render_etcnet(cls, base_etcnet_dir, network_state):
        '''Given state, return /etc/net files + contents'''
        options_path = "%(base)s/%(name)s/options"
        ipv4_path    = "%(base)s/%(name)s/ipv4address"
        ipv4r_path   = "%(base)s/%(name)s/ipv4route"
        resolv_path  = "%(base)s/eth0/resolv.conf"

        nameservers = network_state.dns_nameservers
        searchdomains = network_state.dns_searchdomains
        resolvconf = []
        for sd in searchdomains:
            resolvconf.append("search\t%s" % sd)

        for ns in nameservers:
            resolvconf.append("nameserver\t%s" % ns)

        content = {}

        path = resolv_path % ({'base': base_etcnet_dir})
        content[path] = '\n'.join(resolvconf)

        for iface in network_state.iter_interfaces():
            if iface['type'] == "loopback":
                continue
            print(iface)
            iface_name = iface['name']
            subnets = iface.get('subnets', [])
            res = {}
            dhcp = False
            for s in subnets:
                if s['type'] == 'dhcp4':
                    dhcp = True
                    continue
                o = res.get('address', [])
                o.append("%s/%s" % (s['address'], s['prefix']))
                res['address'] = o
                if 'gateway' in s:
                    res['gateway'] = "default via %s" % s['gateway']

            if 'address' in res:
                path = ipv4_path % ({'base': base_etcnet_dir, 'name': iface_name})
                content[path] = '\n'.join(res['address'])

            if 'gateway' in res:
                path = ipv4r_path % ({'base': base_etcnet_dir, 'name': iface_name})
                content[path] = res['gateway']

            opts = [
              "ONBOOT=yes",
              "DISABLED=no",
              "CONFIG_IPV4=yes",
              "CONFIG_WIRELESS=no",
              "TYPE=eth",
              "NM_CONTROLLED=no"]
            dhcp_opts = ["BOOTPROTO=dhcp\n"]
            static_opts = ["BOOTPROTO=static\n"]
            if dhcp:
                opts += dhcp_opts
            else:
                opts += static_opts
            opts_path = options_path % ({'base': base_etcnet_dir, 'name': iface_name})
            content[opts_path] = '\n'.join(opts)

        return content

    def render_network_state(self, network_state, templates=None, target=None):
        base_etcnet_dir = util.target_path(target, self.etcnet_dir)
        for path, data in self._render_etcnet(base_etcnet_dir,
                                              network_state).items():
            util.write_file(path, data)


def available(target=None):
    expected = ['ifup', 'ifdown']
    search = ['/sbin', '/usr/sbin']
    for p in expected:
        if not util.which(p, search=search, target=target):
            return False

    expected_paths = [
        'etc/net/scripts/functions',
        'etc/net/scripts/functions-eth',
        'etc/net/scripts/functions-ip',
        'etc/net/scripts/functions-ipv4',
        'etc/net/scripts/functions-ipv6',
        'etc/net/scripts/functions-vlan',
        'etc/net/scripts/ifdown']
    for p in expected_paths:
        if not os.path.isfile(util.target_path(target, p)):
            return False
    return True


# vi: ts=4 expandtab
