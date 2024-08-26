; BFAT defines

;Кластер FAT
        .DEF    FAT_CLUSTER =          $0001
;Первый кластер рут-директории диска
        .DEF    FAT_START_POINTER =    $0002
;Указатель на буфер диска (4кБ)
        .DEF    FAT_DISKBUF_ADDR =     $A000
