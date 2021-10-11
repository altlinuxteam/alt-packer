# vi: ts=4 expandtab
#
#    Copyright (C) 2015 ALTLinux
#
#    Author: Alexey Shabalin <shaba@altlinux.org>
#
#    Leaning very heavily on the RHEL and Debian implementation
#
# This file is part of cloud-init. See LICENSE file for license information.

from cloudinit import distros
from cloudinit import helpers
from cloudinit import log as logging
from cloudinit import util

from cloudinit.distros import net_util
from cloudinit.distros import rhel_util
from cloudinit.settings import PER_INSTANCE

LOG = logging.getLogger(__name__)

def _make_sysconfig_bool(val):
    if val:
        return 'yes'
    else:
        return 'no'

def ipv4mask2cidr(mask):
    if '.' not in mask:
        return mask
    return sum([bin(int(x)).count('1') for x in mask.split('.')])


def ipv6mask2cidr(mask):
    if ':' not in mask:
        return mask

    bitCount = [0, 0x8000, 0xc000, 0xe000, 0xf000, 0xf800, 0xfc00, 0xfe00,
                0xff00, 0xff80, 0xffc0, 0xffe0, 0xfff0, 0xfff8, 0xfffc,
                0xfffe, 0xffff]
    cidr = 0
    for word in mask.split(':'):
        if not word or int(word, 16) == 0:
            break
        cidr += bitCount.index(int(word, 16))

    return cidr

def mask2cidr(mask):
    if ':' in mask:
        return ipv6mask2cidr(mask)
    elif '.' in mask:
        return ipv4mask2cidr(mask)
    else:
        return mask

class Distro(distros.Distro):
    clock_conf_fn = '/etc/sysconfig/clock'
    locale_conf_fn = '/etc/sysconfig/i18n'
    systemd_locale_conf_fn = '/etc/locale.conf'
    network_conf_fn = "/etc/sysconfig/network"
    hostname_conf_fn = "/etc/sysconfig/network"
    systemd_hostname_conf_fn = "/etc/hostname"
    ifaces_options_tpl = '/etc/net/ifaces/%s/options'
    ifaces_ipv4addres_tpl = '/etc/net/ifaces/%s/ipv4address'
    ifaces_ipv4route_tpl = '/etc/net/ifaces/%s/ipv4route'
    ifaces_ipv6address_tpl = '/etc/net/ifaces/%s/ipv6address'
    ifaces_ipv6route_tpl = '/etc/net/ifaces/%s/ipv6route'
    resolve_conf_fn = '/etc/net/ifaces/%s/resolv.conf'
    tz_local_fn = '/etc/localtime'
    init_cmd = ['service']

    def __init__(self, name, cfg, paths):
        distros.Distro.__init__(self, name, cfg, paths)
        # This will be used to restrict certain
        # calls from repeatly happening (when they
        # should only happen say once per instance...)
        self._runner = helpers.Runners(paths)
        self.osfamily = 'altlinux'
        cfg['ssh_svcname'] = 'sshd'
        self.network_conf_fn = {
            "netplan": "/etc/netplan/50-cloud-init.yaml"
        }
        self.renderer_configs = {
            "netplan": {"netplan_path": self.network_conf_fn["netplan"],
                        "postcmds": True}
        }

    def create_user(self, name, **kwargs):
        groups = kwargs.get('groups')
        if groups:
            if isinstance(groups, str):
                groups = groups.split(",")

            # remove any white spaces in group names, most likely
            # that came in as a string like: groups: group1, group2
            groups = [g.strip() for g in groups]

            # Add wheel group. Fix sudoers
            groups.append('wheel')

            # kwargs.items loop below wants a comma delimeted string
            # that can go right through to the command.
            kwargs['groups'] = ",".join(groups)
        else:
            kwargs['groups'] = "wheel"
        return super().create_user(name, **kwargs)

    def install_packages(self, pkglist):
        self.package_command('install', pkgs=pkglist)

    def _write_network_config(self, netconfig):
        return self._supported_write_network_config(netconfig)

    def _write_network(self, settings):
        # Convert debian settings to ifcfg format
        entries = net_util.translate_network(settings)
        LOG.debug("Translated ubuntu style network settings %s into %s",
                  settings, entries)
        dev_names = entries.keys()
        # Make the intermediate format as the suse format...
        nameservers = []
        searchservers = []
        dev_names = entries.keys()
        use_ipv6 = False
        for (dev, info) in entries.items():
            ifaces_options_fn = self.ifaces_options_tpl % (dev)
            ifaces_options_cfg = {
                'BOOTPROTO': info.get('bootproto'),
                'ONBOOT': _make_sysconfig_bool(info.get('auto')),
            }
            ifaces_ipv4addres_fn = self.ifaces_ipv4addres_tpl % (dev)
            ifaces_ipv4addres_cfg = {
                '%s/%s' % (info.get('address'), mask2cidr(info.get('netmask'))),
            }
            ifaces_ipv4route_fn = self.ifaces_ipv4route_tpl % (dev)
            ifaces_ipv4route_cfg = {
                'default via ' + info.get('gateway'),
            }
            if info.get('inet6'):
                use_ipv6 = True
                ifaces_options_cfg.update({
                    'CONFIG_IPV6': _make_sysconfig_bool(True),
                })
                ifaces_ipv6address_fn = self.ifaces_ipv6address_tpl % (dev)
                ifaces_ipv6address_cfg = {
                     '%s' % info.get('ipv6').get('address'),
                }
                ifaces_ipv6route_fn = self.ifaces_ipv6route_tpl % (dev)
                ifaces_ipv6route_cfg = {
                     'default via ' + info.get('ipv6').get('gateway'),
                }
            rhel_util.update_sysconfig_file(ifaces_ipv4addres_fn, ifaces_options_cfg, True)
            util.write_file(ifaces_ipv4addres_fn, ifaces_ipv4addres_cfg)
            util.write_file(ifaces_ipv4route_fn, ifaces_ipv4route_cfg)
            rhel_util.update_sysconfig_file(ifaces_ipv6address_fn, ifaces_ipv6address_cfg)
            util.write_file(ifaces_ipv6route_fn, ifaces_ipv6route_cfg)
            if 'dns-nameservers' in info:
                nameservers.extend(info['dns-nameservers'])
            if 'dns-search' in info:
                searchservers.extend(info['dns-search'])
        if nameservers or searchservers:
            rhel_util.update_resolve_conf_file(self.resolve_conf_fn,
                                               nameservers, searchservers)

        return dev_names

    def apply_locale(self, locale, out_fn=None):
        if self.uses_systemd():
            if not out_fn:
                out_fn = self.systemd_locale_conf_fn
            out_fn = self.systemd_locale_conf_fn
        else:
            if not out_fn:
                out_fn = self.locale_conf_fn
        locale_cfg = {
            'LANG': locale,
        }
        rhel_util.update_sysconfig_file(out_fn, locale_cfg)

    def _write_hostname(self, hostname, out_fn):
        # systemd will never update previous-hostname for us, so
        # we need to do it ourselves
        if self.uses_systemd() and out_fn.endswith('/previous-hostname'):
            util.write_file(out_fn, hostname)
        elif self.uses_systemd():
            util.subp(['hostnamectl', 'set-hostname', str(hostname)])
        else:
            host_cfg = {
                'HOSTNAME': hostname,
            }
            rhel_util.update_sysconfig_file(out_fn, host_cfg)


    def _read_system_hostname(self):
        if self.uses_systemd():
            host_fn = self.systemd_hostname_conf_fn
        else:
            host_fn = self.hostname_conf_fn
        return (host_fn, self._read_hostname(host_fn))

    def _read_hostname(self, filename, default=None):
        if self.uses_systemd() and filename.endswith('/previous-hostname'):
            return util.load_file(filename).strip()
        elif self.uses_systemd():
            (out, _err) = util.subp(['hostname'])
            if len(out):
                return out
            else:
                return default
        else:
            (_exists, contents) = rhel_util.read_sysconfig_file(filename)
            if 'HOSTNAME' in contents:
                return contents['HOSTNAME']
            else:
                return default

    def _bring_up_interfaces(self, device_names):
        if device_names and 'all' in device_names:
            raise RuntimeError(('Distro %s can not translate '
                                'the device name "all"') % (self.name))
        return distros.Distro._bring_up_interfaces(self, device_names)

    def set_timezone(self, tz):
        tz_file = self._find_tz_file(tz)
        if self.uses_systemd():
            # Currently, timedatectl complains if invoked during startup
            # so for compatibility, create the link manually.
            util.del_file(self.tz_local_fn)
            util.sym_link(tz_file, self.tz_local_fn)
        else:
            # Adjust the sysconfig clock zone setting
            clock_cfg = {
                'ZONE': str(tz),
            }
            rhel_util.update_sysconfig_file(self.clock_conf_fn, clock_cfg)
            # This ensures that the correct tz will be used for the system
            util.copy(tz_file, self.tz_local_fn)

    def package_command(self, command, args=None, pkgs=None):
        if pkgs is None:
            pkgs = []

        cmd = ['apt-get']
        # No user interaction possible, enable non-interactive mode
        cmd.append("--quiet")
        cmd.append("--assume-yes")

        if command == "upgrade":
            command = "dist-upgrade"

        # Comand is the operation, such as install
        cmd.append(command)

        # args are the arguments to the command, not global options
        if args and isinstance(args, str):
            cmd.append(args)
        elif args and isinstance(args, list):
            cmd.extend(args)

        pkglist = util.expand_package_list('%s-%s', pkgs)
        cmd.extend(pkglist)

        # Allow the output of this to flow outwards (ie not be captured)
        util.subp(cmd, capture=False)

    def update_package_sources(self):
        self._runner.run("update-sources", self.package_command,
                         ["update"], freq=PER_INSTANCE)


