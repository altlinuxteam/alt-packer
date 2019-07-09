("/sysconfig-base/language" action "write" lang ("ru_RU"))
("/sysconfig-base/kbd" action "write" layout "ctrl_shift_toggle")
("/datetime-installer" action "write" commit #t name "RU" zone "UTC" utc #t)

("/evms/control" action "write" control open installer #t)
("/evms/control" action "write" control update)
("/evms/profiles/workstation" action apply commit #f clearall #t exclude ())
("/evms/control" action "write" control commit)
("/evms/control" action "write" control close)

("pkg-init" action "write")
("/pkg-install" action "write" lists "" auto #t)
("/preinstall" action "write")

("/grub" action "write" device "/dev/sda" passwd #f passwd_1 "*" passwd_2 "*")

("/net-eth" action "write" reset #t)
("/net-eth" action "write" name "eth0" ipv "4" configuration "dhcp" search "" dns "" computer_name "c245" ipv_enabled #t)
("/net-eth" action "write" commit #t)

("/root/change_password" language ("ru_RU") passwd_2 "123" passwd_1 "123")
("/users/create_account" new_name "test" gecos "" allow_su #t auto #f passwd_1 "123" passwd_2 "123")
("/users/create_account" new_name "vagrant" gecos "" allow_su #t auto #f passwd_1 "vagrant" passwd_2 "vagrant")

