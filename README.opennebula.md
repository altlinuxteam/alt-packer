# OpenNebula instructions

## Custom OpenNebula context variables

Provision script uses the file scripts/loc-10-network-disable-NetworkManager as an additional context and puts it in the folder /etc/one-context.d/

### NetworkManager

By default, NetworkManager is disabled in the OpenNebula image. To enable it, you need to explicitly specify the USE_NETWORK_MANAGER variable in the VM context
```
USE_NETWORK_MANAGER = "YES"
```

Use this mode only if you know what you are doing. NetworkManager conflicts with opennebula-context scripts and requires manual configuration
