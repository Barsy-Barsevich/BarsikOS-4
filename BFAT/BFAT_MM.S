; BFAT memory management

;Переменная для хранения начального адреса буфера диска (4кБ)
        .DEF    SYSCELL_DISKBUF_ADDR =     $xxxx   ;word
;Буфер 11 байт, используется файловой системой
        .DEF    SYSCELL_FBN11 =            $xxxx
        .DEF    SYSCELL_FBN11P1 =          $xxxx
;Буфер 11 байт, используется файловой системой
        .DEF    SYSCELL_FBP11 =            $xxxx
        .DEF    SYSCELL_FBP11P1 =          $xxxx
        .DEF    SYSCELL_FBP11P9 =          $xxxx
;Переменная, в которую записывается длина файла/кат, в который спускаемся
        .DEF    SYSCELL_FAT_SF_LEN =       $xxxx   ;unsigned longint
        .DEF    SYSCELL_FAT_SF_LEN_XLSB =  $xxxx
        .DEF    SYSCELL_FAT_SF_LEN_LSB =   $xxxx
        .DEF    SYSCELL_FAT_SF_LEN_MSB =   $xxxx
        .DEF    SYSCELL_FAT_SF_LEN_XMSB =  $xxxx
;Переменная, в которую записывается статус файла/кат, в который спускаемся
        .DEF    SYSCELL_FAT_SF_STATUS =    $xxxx   ;byte
;Переменная для хранения номера текущего указателя на 1 кластер файла/субдир
        .DEF    SYSCELL_FAT_POINTER =      $xxxx   ;word
