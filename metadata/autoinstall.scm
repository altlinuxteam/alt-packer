; установка языка операционной системы (ru_RU)
("/sysconfig-base/language" action "write" lang ("ru_RU"))
; установка переключателя расладки клавиатуры на Ctrl+Shift
("/sysconfig-base/kbd" action "write" layout "ctrl_shift_toggle")
; установка часового пояса в Europe/Moscow, время в BIOS будет храниться в UTC
("/datetime-installer" action "write" commit #t name "RU" zone "Europe/Moscow" utc #t)
; автоматическая разбивка жёсткого диска
("/evms/control" action "write" control open installer #t)
("/evms/control" action "write" control update)
("/evms/profiles/workstation" action apply commit #f clearall #t exclude ())
("/evms/control" action "write" control commit)
("/evms/control" action "write" control close)
; установка пакетов операционной системы
("pkg-init" action "write")
; установка только базовой системы (дополнительные группы пакетов из pkg-groups.tar указываются по именам через пробел)
("/pkg-install" action "write" lists "" auto #t)
("/preinstall" action "write")
; установка загрузчика GRUB в MBR на первый жёсткий диск
("/grub" action "write" device "/dev/vda" passwd #f passwd_1 "*" passwd_2 "*")

; настройка сетевого интерфейса на получение адреса по DHCP
("/net-eth" action "write" reset #t)
("/net-eth" action "write" name "ens3" ipv "4" configuration "dhcp" search "" dns "" computer_name "c245" ipv_enabled #t)
;("/net-eth" action "write" name "ens3" ipv "4" configuration "dhcp" search "" dns "" computer_name "c245" )

; настройка сетевого интерфейса на статический IPv4
; ("/net-eth" action "write" name "eth0" configuration "static" default "192.168.1.1" search "localhost.com" dns "192.168.1.1" computer_name "c245" ipv "4" ipv_enabled #t)
; ("/net-eth" action "add_iface_address" name "eth0" addip "192.168.1.2" addmask "24" ipv "4")
("/net-eth" action "write" commit #t)
; установка пароля суперпользователя root '123'
("/root/change_password" language ("ru_RU") passwd_2 "123" passwd_1 "123")
; задание первого пользователя 'test' с паролем '123'
("/users/create_account" new_name "test" gecos "" allow_su #t auto #f passwd_1 "123" passwd_2 "123")
("/console" action "execute" command "sed -i 's|^.*\(WHEEL_USERS ALL=(ALL) NOPASSWD: ALL\)$|\1|' /etc/sudoers")
("/sshd" action "write" key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPB/fDgbIsFTjSDUOSEofAUfblqF8NaIfpxzZMWSzqLD scor@snb")
