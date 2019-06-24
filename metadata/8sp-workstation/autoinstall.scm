("/sysconfig-base/language" action "write" lang ("ru_RU"))
("/sysconfig-base/kbd" action "write" layout "ctrl_shift_toggle")
("/datetime-installer" action "write" commit #t name "RU" zone "UTC" utc #t)

("/evms/control" action "write" control open installer #t)
("/evms/control" action "write" control update)
; Choices other than "workstation" are not really working somehow.
("/evms/profiles/workstation" action apply commit #f clearall #t exclude ())
("/evms/control" action "write" control commit)
("/evms/control" action "write" control close)

("pkg-init" action "write")
; Package lists for installation are taken from 'pkg-groups.tar' file
; which originally resides in 'Metadata' directory inside installation
; image/ISO. You may get the idea about necessary packages by
; running installation process with 'instdebug' option passed as
; kernel argument and then looking at '/tmp/wizard.log' script.
;
; Please note that in this case the package group called 'alterator'
; is unavoidable otherwise the '/preinstall' step will go into
; inifinite loop waiting for non-existent 'alteratord' to start in
; chrooted environment. Other package groups may be optional.
;
; It's also advised to avoid installing 'selinux-altlinux' package
; group in SELinux-enabled distros because SELinux must be disabled to
; perform 'apt-get dist-upgrade' which you will eventually try to
; perform when VM is up.
("/pkg-install" action "write" lists "alterator centaurus-mate zero xorg signal-client" auto #t)
("/preinstall" action "write")

; It should be noted that 'virtio' block device driver will render
; device file names as '/dev/vda', not '/dev/sda' under QEMU. Alterator
; is unable to handle errors returned by applications it calls
; internally so you will get unbootable VM in case of device name
; mismatch without any errors.
;
; In this case the driver 'virtio-scsi' is used when building box under
; QEMU which makes devices to look like classic '/dev/sda'. It allows
; to have one 'autoinstall.scm' file for both QEMU and VirtualBox
; reducing duplication, errors and differences.
("/grub" action "write" device "/dev/sda" passwd #f passwd_1 "*" passwd_2 "*")

("/net-eth" action "write" reset #t)
("/net-eth" action "write" name "eth0" ipv "4" configuration "dhcp" search "" dns "" computer_name "c245" ipv_enabled #t)
("/net-eth" action "write" commit #t)

("/root/change_password" language ("ru_RU") passwd_2 "123" passwd_1 "123")
; The 'test' user is created for testing purposes and 'vagrant' user is
; created for Vagrant users. In case you use Vagrant to manage VMs -
; disable the 'test' user. Otherwise disable 'vagrant' user to secure
; your VM.
("/users/create_account" new_name "test" gecos "" allow_su #t auto #f passwd_1 "123" passwd_2 "123")
("/users/create_account" new_name "vagrant" gecos "" allow_su #t auto #f passwd_1 "vagrant" passwd_2 "vagrant")

