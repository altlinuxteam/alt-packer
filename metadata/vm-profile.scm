((workstation
  (title . "Setup for workstation")
  (action . trivial)
  (actiondata  ("swap" (size 1024000 . 1024000) (fsim . "SWAPFS") (methods plain))
               ("/" (size 20971520 . 20971520 ) (fsim . "Ext2/3") (methods plain))
               ("/home" (size 1024000 . #t) (fsim . "Ext2/3") (methods  plain))))
               )
