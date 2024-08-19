
;        .DEF        SYSCELL_DISKBUF_ADDR =     $FF1E
;        .DEF        SYSCELL_STRBUF8 =          $FF20
;        .DEF        SYSCELL_STRBUF8P1 =        $FF21

        .DEF        DISK_CLUSTER_ERASE =   W25_SECTOR_ERASE
        .DEF        DISK_CLUSTER_WRITE =   W25_SECTOR_WRITE
        .DEF        DISK_CLUSTER_READ =    W25_SECTOR_READ


;===============================================================================
;---<Имя корневого каталога>----------------------------------------------------
;Имя и расширение
        .DEF        FAT_DESCR_NAME =           $00
        .DEF        FAT_DESCR_NAME_0 =         $00
        .DEF        FAT_DESCR_NAME_1 =         $01
        .DEF        FAT_DESCR_NAME_2 =         $02
        .DEF        FAT_DESCR_NAME_3 =         $03
        .DEF        FAT_DESCR_NAME_4 =         $04
        .DEF        FAT_DESCR_NAME_5 =         $05
        .DEF        FAT_DESCR_NAME_6 =         $06
        .DEF        FAT_DESCR_NAME_7 =         $07
        .DEF        FAT_DESCR_FORM =           $08
        .DEF        FAT_DESCR_FORM_0 =         $08
        .DEF        FAT_DESCR_FORM_1 =         $09
        .DEF        FAT_DESCR_FORM_2 =         $0A
;Статус 
        .DEF        FAT_DESCR_STATUS =         $0B
;Зарезервировано
        .DEF        FAT_DESCR_RES_0 =          $0C
        .DEF        FAT_DESCR_RES_1 =          $0D
        .DEF        FAT_DESCR_RES_2 =          $0E
        .DEF        FAT_DESCR_RES_3 =          $0F
        .DEF        FAT_DESCR_RES_4 =          $10
        .DEF        FAT_DESCR_RES_5 =          $11
        .DEF        FAT_DESCR_RES_6 =          $12
        .DEF        FAT_DESCR_RES_7 =          $13
        .DEF        FAT_DESCR_RES_8 =          $14
        .DEF        FAT_DESCR_RES_9 =          $15
;Дата последнего изменения
        .DEF        FAT_DESCR_DATE_0 =         $16
        .DEF        FAT_DESCR_DATE_1 =         $17
        .DEF        FAT_DESCR_DATE_2 =         $18
        .DEF        FAT_DESCR_DATE_3 =         $19
;Указатель на первый кластер файла или субдиректории
        .DEF        FAT_DESCR_FSTCLUST =       $1A
        .DEF        FAT_DESCR_FSTCLUST_L =     $1A
        .DEF        FAT_DESCR_FSTCLUST_H =     $1B
;Размер файла или субдиректории
        .DEF        FAT_DESCR_SIZE =           $1C
        .DEF        FAT_DESCR_SIZE_0 =         $1C
        .DEF        FAT_DESCR_SIZE_1 =         $1D
        .DEF        FAT_DESCR_SIZE_2 =         $1E
        .DEF        FAT_DESCR_SIZE_3 =         $1F
;===============================================================================
;--<Аттрибуры директории>-------------------------------------------------------
;|n/u|n/u|Archive|Subdir|???|System|Hidden|ReadOnly|
;|0  |0  |0      |1     |0  |1     |0     |0       |
        .DEF        FAT_STATUS_ARCHIVE_MASK =  $20
        .DEF        FAT_STATUS_ARCHIVE_NMASK = $DF
        .DEF        FAT_STATUS_SUBDIR_MASK =   $10
        .DEF        FAT_STATUS_SUBDIR_NMASK =  $EF
        .DEF        FAT_STATUS_SYSTEM_MASK =   $04
        .DEF        FAT_STATUS_SYSTEM_NMASK =  $FB
        .DEF        FAT_STATUS_HIDDEN_MASK =   $02
        .DEF        FAT_STATUS_HIDDEN_NMASK =  $FD
        .DEF        FAT_STATUS_RONLY_MASK =    $01
        .DEF        FAT_STATUS_RONLY_NMASK =   $FE
;===============================================================================


; FAT_Disk_Init - Инициализация диска
; Ввод: нет
; Вывод: нет
; Оценка: длина - , время - 
FAT_DISK_INIT:
;Установить указатель на дескриптор диска
        LXI         H,W25_Handle_TypeDef
        PUSH        H
        CALL        W25_SET_BASE_ADDRESS
;Установить бит SS диска
        MVI         A,$04
        PUSH        PSW
        CALL        W25_SET_SS_BIT
;Установить начальный адрес 4кБ буфера диска
        LXI         H,FAT_DISKBUF_ADDR
        SHLD        SYSCELL_DISKBUF_ADDR
        RET


; FAT_Set_Pointer_To_Root - установка указателя директории на root-директорию
; Ввод: нет
; Вывод: нет
; Используемая память: SYSCELL_FAT_POINTER (word)
; Оценка: длина - , время - 
FAT_SET_POINTER_TO_ROOT:
FAT_SPR:
        LXI         H,FAT_START_POINTER
        SHLD        SYSCELL_FAT_POINTER
        RET


; FAT_FIND_NEXT_CLUSTER - поиск номера следующего кластера файла/субдиректории
; Ввод:  (SP+2) - номер текущего кластера
; Вывод: (SP+2) - номер следующего кластера
;        Флаг C - если равен 0, то успешно, если 1, то следующего кластера нет
; Используемые регистры: все
; Читаемая память: SYSCELL_DISKBUF_ADDR
; Используемая память:
;  - массив DISKBUF (длины $1000)
; Используемые функции:
;  - DISK_CLUSTER_READ
;  - CMP16
; Оценка: длина - , время - 

FAT_FIND_NEXT_CLUSTER:
;Копируем кластер FAT в буфер
        LXI         H,FAT_CLUSTER
        PUSH        H
        LHLD        SYSCELL_DISKBUF_ADDR
        PUSH        H
        CALL        DISK_CLUSTER_READ
;По адресу (SYSCELL_DISKBUF_ADDR+CLUST_NUM) считываем значение NEXT
        POP         B
        POP         D   ;Помни об адресе возврата!!!!!!!!!!!
        PUSH        B
        LHLD        SYSCELL_DISKBUF_ADDR
        DAD         D   ;Потому что на 1 кластер 2 байта в таблице FAT!!!!!!!!!!
        DAD         D
        ;MOV         E,M
        ;INX         H
        ;MOV         D,M
        ;XCHG        ;(HL)-NEXT
        XCHG
        LHLX
;Сравниваем NEXT C $FFF0
        LXI         D,$FFF0
        CALL        CMP16   ;если C==0, то ошибка
        CMC                 ;если С==1, то ошибка
        XCHG
        POP         H
        PUSH        D
        PCHL



; FAT_FIND_BY_NAME - поиск номера первого кластера файла/субдиректории по имени
; Ввод:  (SP+4) - начальный адрес строки, сод имя искомого файла
;        (SP+2) - номер начального кластера директории, в которой ведем поиск
; Вывод: (SP+4) - номер первого кластера найденного файла/субдиректории
;        (SP+2) - статус найденного файла/субдиректории
;        Флаг С - если равен 0, то успешно, если 1, то не удалось найти
; Используемые регистры: все
; Используемая память:
;  - массив DISKBUF (длины $1000)
;  - SYSCELL_FAT_SF_STATUS (byte)
;  - SYSCELL_FAT_SF_LEN (uint32_t)
; Используемые функции:
;  - DISK_CLUSTER_READ
;  - CMP16
;  - COPCOUNT
;  - FAT_FIND_NEXT_CLUSTER
;  - STRCMP
; Оценка: длина - , время - 

FAT_FIND_BY_NAME:
FAT_FBN:
        MVI         A,$0B
        STA         SYSCELL_FBN11
fat_fbn_clust_process:
;Копируем кластер адреса LOCAL_CLUST_POINTER в буфер диска
;(SP+4) - начальный адрес строки, сод имя искомого файла
;(SP+2) - номер начального кластера директории, в которой ведем поиск
;(SP+0) - адрес возврата
        LDSI        $02
        LHLX
        PUSH        H
        LHLD        SYSCELL_DISKBUF_ADDR
        PUSH        H
        CALL        DISK_CLUSTER_READ
;Подготовка переменной счетчика и указателя на дескрипторы файлов
        LHLD        SYSCELL_DISKBUF_ADDR
        XCHG
        MVI         C,$80
fat_fbn_cycle:
        PUSH        B           ;счетчик в С
        PUSH        D           ;указатель на дескриптор файла/субдиректории
;Копируем имя в строку SYSCELL_FBN11 (строка должна иметь впереди байт длины)
        LXI         B,$000B
        LXI         H,SYSCELL_FBN11P1
        CALL        COPCOUNT
;(SP+8) - начальный адрес строки, сод имя искомого файла
;(SP+6) - номер начального кластера директории, в которой ведем поиск
;(SP+4) - адрес возврата
;(SP+2) - счетчик в С
;(SP+0) - указатель на дескриптор файла/субдиректории
        LDSI        $08         ;DE <- SP+8
        LHLX
        LXI         D,SYSCELL_FBN11
        CALL        STRCMP ;Z==1 -> str1==str2
        POP         D           ;указатель на дескриптор файла/субдиректории
        POP         B           ;счетчик в С
        JZ          fat_fbn_equal
;Строки не равны. Переходим к следующему дескриптору
        LXI         H,$0020
        DAD         D
        XCHG
        DCR         C
        JNZ         fat_fbn_cycle
;В текущем кластере не найдено подходящих дескрипторов. Переход к след. кластеру
;(SP+4) - начальный адрес строки, сод имя искомого файла
;(SP+2) - номер начального кластера директории, в которой ведем поиск
;(SP+0) - адрес возврата
        LDSI        $02         ;DE <- SP+2
        LHLX
        PUSH        D           ;SP+2
        PUSH        H           ;(SP+4) LOCAL_CLUSTER_NUMBER
        CALL        FAT_FIND_NEXT_CLUSTER
        POP         H           ;NEXT_CLUSTER_NUMBER
        POP         D           ;SP+2
;Возврат, если следующего кластера нет
        JC          fat_fbn_RETurn   ;DISK_ERROR_VECT    ;fat_fbn_RETurn
        SHLX                ;сохранить
        JMP         fat_fbn_clust_process
fat_fbn_equal:
;Строки равны. Передаем на вывод номер первого кластера файла/субдиректории
;DE - указатель на дескриптор файла/субдиректории
        PUSH        D       ;сохранить указатель
        LXI         H,FAT_DESCR_FSTCLUST   ;смещение номера 1го кластера в дескрипторе
        DAD         D
;BC <- Первый кластер файла или субдиректории
        MOV         C,M
        INX         H
        MOV         B,M
;A <- STAtus, SYSCELL_FAT_SF_STATUS <- STAtus
        POP         H
        PUSH        H
        LDHI        FAT_DESCR_STATUS
        LDAX        D
        STA         SYSCELL_FAT_SF_STATUS
;SYSCELL_FAT_SF_LEN <- Len
        POP         H
        LDHI        FAT_DESCR_SIZE
        LHLX
        SHLD        SYSCELL_FAT_SF_LEN_XLSB
        INX         D
        INX         D
        LHLX
        SHLD        SYSCELL_FAT_SF_LEN_MSB
        ORA         A
fat_fbn_RETurn:
;(SP+4) - начальный адрес строки, сод имя искомого файла
;(SP+2) - номер начального кластера директории, в которой ведем поиск
;(SP+0) - адрес возврата
        POP         H
        POP         D
        POP         D
        PUSH        B
        PUSH        PSW
        PCHL




; FAT_FBP - поиск указателя на файл по строке-пути
; Ввод:  (STAck+2) - указатель на строку-путь
; Вывод: (STAck+2)H - 0(все хорошо), 1(ошибка тропы), 2(ошибка диска)
; Используемые регистры: все
; Используемая память:
;  - массив DISKBUF (длины $1000)
;  - SYSCELL_FBN11 (строка 11 байт)
;  - SYSCELL_FAT_SF_STATUS (byte)
;  - SYSCELL_FAT_SF_LEN (uint32_t)
;  - SYSCELL_FBP11 (строка 11 байт)fat_fbn_RETurn
; Используемые функции:
;  - DISK_CLUSTER_READ
;  - CMP16
;  - MFILL
;  - COPCOUNT
;  - FAT_FIND_NEXT_CLUSTER
; Оценка: длина - , время - 

FAT_FBP:
;(1) Установка начальной директории
        CALL        FAT_SPR
FAT_FBRP:
;(2) Считаем, сколько субдиректорий в пути
        POP         H
        XTHL
        PUSH        H
        MVI         B,$00
        MVI         A,$2F  ;'/'
        MOV         C,M
        INX         H
fat_fbp_slcount_0:
        CMP         M
        JNZ         fat_fbp_slcount_1
        INR         B
fat_fbp_slcount_1:
        INX         H
        DCR         C
        JNZ         fat_fbp_slcount_0   
;B - число субдиректорий в пути
;(3) DE - PATHSTR_POINTER,  HL - STRBUF_POINTER
;    B - Local_Len,  C - PATHSTR_LEN,  (STAck+1) - SUBDIRNUM
        POP         D
        LDAX        D
        MOV         C,A     ;PATHSTR_LEN
        INX         D       ;PATHSTR_POINTER
        PUSH        B       ;SUBDIRNUM
        LXI         H,SYSCELL_FBP11
        MVI         M,$0B
;(4)--<Повторить SUBDIRNUM раз>-------------------------------------------------
        MOV         A,B
        ORA         A
        JZ          fat_fbp_ilmsubdirnum
fat_fbp_m1:
;(4a) Local_len := 0, STRBUF_POINTER := STRBUF_ADDR+1, Очистка SYSCELL_FBP11
        MVI         B,$00
;STRBUF_POINTER := SYSCELL_FBP11+1
        LXI         H,SYSCELL_FBP11P1
;Очистка SYSCELL_FBP11
        PUSH        B
        PUSH        D
        PUSH        H
        LXI         D,$000B
        MVI         A,$20
        CALL        MFILL
        POP         H
        POP         D
        POP         B
fat_fbp_m3:
;(4b) Читаем строку-путь
        LDAX        D
        CPI         $2F  ;'/'
        JNZ         fat_fbp_if_1
;(4ca) Если =='/':
;Если Local_len == 0, то ошибка
        MOV         A,B
        ORA         A
        JZ          fat_fbp_path_error
;PATHSTR_POINTER+=1, PATHSTR_LEN-=1, Если PATHSTR_LEN==0, то ошибка
        INX         D
        DCR         C
        JZ          fat_fbp_path_error
        JMP         fat_fbp_m2
fat_fbp_if_1:
;(4cb) Иначе
;SYSCELL_FBP11[STRBUF_POINTER] := PATHSTR[PATHSTR_POINTER]
        LDAX        D
        MOV         M,A
;STRBUF_POINTER += 1
        INX         H
;PATHSTR_POINTER+=1, PATHSTR_LEN-=1, Если PATHSTR_LEN==0, то ошибка
        INX         D
        DCR         C
        JZ          fat_fbp_path_error
;Local_len += 1
        INR         B
        JMP         fat_fbp_m3
fat_fbp_m2:
;(4d) Спуск в субдиректорию (SYSCELL_FBP11)
        PUSH        PSW
        PUSH        B
        PUSH        D
        PUSH        H
        LXI         H,SYSCELL_FBP11
        PUSH        H
        LHLD        SYSCELL_FAT_POINTER
        PUSH        H
        CALL        FAT_FBN  ;Спуск в субдиректорию
        POP         PSW
        POP         H
        JC          fat_fbp_finding_error
        ANI         FAT_STATUS_SUBDIR_MASK
        JZ          fat_fbp_finding_error
        SHLD        SYSCELL_FAT_POINTER
        POP         H
        POP         D
        POP         B
        POP         PSW
;SUBDIRNUM-=1
        XTHL
        DCR         H
        XTHL
        JNZ         fat_fbp_m1
fat_fbp_ilmsubdirnum:
;(5) Local_len:=0, STRBUF_POINTER:=STRBUF_ADDR+1, Очистка STRBUF
        MVI         B,$00
;STRBUF_POINTER := SYSCELL_FBP11+1
        LXI         H,SYSCELL_FBP11P1
;Очистка STRBUF
        PUSH        B
        PUSH        D
        PUSH        H
        LXI         D,$000B
        MVI         A,$20
        CALL        MFILL
        POP         H
        POP         D
        POP         B
;Если PATHSTR_LEN==0, то ошибка
        MOV         A,C
        ORA         A
        JZ          fat_fbp_path_error
fat_fbp_m4:
;(6) Читаем строку-путь
;SYSCELL_FBP11[STRBUF_POINTER] := PATHSTR[PATHSTR_POINTER]
        LDAX        D
        CPI         $2E  ;'.'
        JNZ         fat_fbp_if_4
;(7) Если =='.':
;Если Local_len == 0, то ошибка
        MOV         A,B
        ORA         A
        JZ          fat_fbp_path_error
;STRBUF_POINTER := SYSCELL_FBP11+9
        LXI         H,SYSCELL_FBP11P9
;Local_len := 9
        MVI         B,$09
;PATHSTR_POINTER+=1, PATHSTR_LEN-=1, Если PATHSTR_LEN==0, то ошибка
        INX         D
        DCR         C
        MOV         A,C
        ORA         A
        JZ          fat_fbp_path_error
        JMP         fat_fbp_m4
fat_fbp_if_4:
;(8) Иначе:
        MOV         M,A
;Если Local_len == 8, то ошибка
        MOV         A,B
        CPI         $08
        JZ          fat_fbp_path_error
;Если Local_len > 11, то ошибка
        CPI         $0C
        JNC         fat_fbp_path_error
;Local_len += 1
        INR         B
;STRBUF_POINTER += 1
        INX         H
;PATHSTR_POINTER+=1, PATHSTR_LEN-=1
        INX         D
        DCR         C
;Переход fat_fbp_m4, если PATHSTR_LEN != 0
        JNZ         fat_fbp_m4
;(9) Спуск в файл
        LXI         H,SYSCELL_FBP11
        PUSH        H
        LHLD        SYSCELL_FAT_POINTER
        PUSH        H
        CALL        FAT_FIND_BY_NAME  ;Спуск в файл
        POP         PSW
        POP         H
        JC          fat_fbp_finding_error_1
        ANI         FAT_STATUS_SUBDIR_MASK
        JNZ         fat_fbp_finding_error_1
        SHLD        SYSCELL_FAT_POINTER
;Восстановить баланс стека
        POP         H
;(10) Возврат
        POP         H
        MVI         A,$00
        PUSH        PSW
        PCHL

fat_fbp_finding_error:
        POP         H
        POP         H
        POP         H
        POP         H
fat_fbp_finding_error_1:
        POP         H
        MVI         A,$02
        JMP         fat_fbp_com_error
fat_fbp_path_error:
        POP         H
        MVI         A,$01
fat_fbp_com_error:
        POP         H
        PUSH        PSW
        PCHL
