((workstation
  (title . "Setup for workstation")
  (action . trivial)
  (actiondata 
               ; Disk size in sectors
	       ; Calculating: disk_size (M) * 1024 * 2 - 4096
               ("/" (size 10235904 . #t ) (fsim . "Ext2/3") (methods plain))
               )))
