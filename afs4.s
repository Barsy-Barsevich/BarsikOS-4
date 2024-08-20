; Advanced Function Set 4


; Функция BITSET - установка разряда
; Ввод:  H([SP+2]) - (исходное число)
;        L([SP+2]) - (номер разряда 2-1-0)
; Вывод: H([SP+2])
; Используемые регистры: AF,BС,HL
; Используемая память: нет
; Длина: 20 байт
; Время выполнения: 59 тактов
;
; Функция REG_BITSET - установка разряда
; Ввод: B (исходное число), A (номер разряда 2-1-0)
; Вывод: A (B с установленным разрядом)
; Используемые регистры: AF,BС,HL
; Используемая память: нет
; Длина: 20 байт
; Время выполнения: 59 тактов

BITSET:
        POP         H   ;RETaddr
        POP         B
        MOV         A,C
        PUSH        H
        CALL        REG_BITSET
        POP         H
        PUSH        PSW
        PCHL
REG_BITSET:
        ANI         $07
        MOV         C,A
        MOV         A,B
        LXI         H,bitset_msk
        MVI         B,$00
        DAD         B
        ORA         M
        RET
bitset_msk:
        .DB         $01
        .DB         $02
        .DB         $04
        .DB         $08
        .DB         $10
        .DB         $20
        .DB         $40
        .DB         $80



; Функция BITCLR - очистка разряда
; Ввод:  H([SP+2]) - (исходное число)
;        L([SP+2]) - (номер разряда 2-1-0)
; Вывод: H([SP+2])
; Используемые регистры: AF,BС,HL
; Используемая память: нет
; Длина: 20 байт
; Время выполнения: 59 тактов
;
; Функция REG_BITCLR - очистка разряда
; Ввод: B (исходное число), A (номер разряда 2-1-0)
; Вывод: A (B с отчищенным разрядом)
; Используемые регистры: AF,BС,HL
; Используемая память: нет
; Длина: 20 байт
; Время выполнения: 59 тактов

BITCLR:
        POP         H   ;RETaddr
        POP         B
        MOV         A,C
        PUSH        H
        CALL        REG_BITCLR
        POP         H
        PUSH        PSW
        PCHL
BITCLR:
        ANI         $07
        MOV         C,A
        MOV         A,B
        LXI         H,bitclr_msk
        MVI         B,$00
        DAD         B
        ANA         M
        RET
bitclr_msk:
        .DB         $FE
        .DB         $FD
        .DB         $FB
        .DB         $F7
        .DB         $EF
        .DB         $DF
        .DB         $BF
        .DB         $7F



; Функция BITTST - проверка разряда
; Ввод:  H([SP+2]) - (исходное число)
;        L([SP+2]) - (номер разряда 2-1-0)
; Вывод: [SP+2] - слово PSW с установленными флагами:
;        Z=1 - разряд очищен
;        Z=0 - разряд установлен
; Используемые регистры: AF,BС,HL
; Используемая память: нет
; Длина: 20 байт
; Время выполнения: 59 тактов
;
; Функция REG_BITTST - проверка разряда
; Ввод: B (исходное число), A (номер разряда 2-1-0)
; Вывод: Z=1 - разряд очищен
;        Z=0 - разряд установлен
; Используемые регистры: AF,BС,HL
; Используемая память: нет
; Длина: 20 байт
; Время выполнения: 59 тактов

BITTST:
        POP         H   ;RETaddr
        POP         B
        MOV         A,C
        PUSH        H
        CALL        REG_BITTST
        POP         H
        PUSH        PSW
        PCHL
REG_BITTST:
        ANI         $07
        MOV         C,A
        MOV         A,B
        LXI         H,bitset_msk
        MVI         B,$00
        DAD         B
        ANA         M
        RET



; Функция MFILL - заполнение памяти
; Ввод:  [SP+2] - Адрес начала (word)
;        [SP+4] - Размер области (word)
;        [SP+7] - Значение, помещаемое в память (byte)
; Вывод: нет
; Используемые регистры: все
; Используемая память: нет
; Длина: 23 байта
; Время выполнения: DE*37+133
;
; Функция REG_MFILL - заполнение памяти
; Ввод:  Адрес начала - HL
;        Размер области - DE
;        Значение, помещаемое в память - A
; Вывод: нет
; Используемые регистры: AF,С,DE,HL
; Используемая память: нет
; Длина: 10 байт
; Время выполнения: DE*37+11

MFILL:
        POP         B   ;retaddr
        POP         H
        POP         D
        POP         PSW
        PUSH        B
        CALL        REG_MFILL
        POP         H
        PUSH        D
        PUSH        D
        PUSH        D
        PCHL
REG_MFILL:
        mov         c,a
mfill-loop:
        mov         m,c
        inx         h
        dcx         d
        mov         a,e
        ora         d
        jnz         mfill-loop
        ret

;
; Функция COPCOUNT - копирование массивов памяти
; Ввод: HL - адрес "куда копируем"
;       DE - адрес "откуда копируем"
;       BC - количество копируемых ячеек памяти
; Вывод: нет
; Используемые регистры: все
; Длина: 15 байт
; Время выполнения: -
COPCOUNT:
    inr     b
    inr     c
str_copcount_1:
    dcr     c
    jnz     str_copcount_2
    dcr     b
    rz
str_copcount_2:
    ldax    d
    mov     m,a
    inx     h
    inx     d
    jmp     str_copcount_1
