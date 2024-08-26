; STAndart Arithmetic


; Функция REG_MUL16 - умножение 16р чисел
; Ввод: HL (множимое)
;       DE (множитель)
; Вывод: HL (младшее слово произведения)
; Используемые регистры: все
; Используемая память: нет
; Длина: 26 байт
; Время выполнения: 1001..1065 тактов

MUL16:
        MOV         C,L
        MOV         B,H
        LXI         H,0000H
        MVI         A,0FH
mul16_1:
        PUSH        PSW
        ORA         D
        JP          mul16_2
        DAD         B
mul16_2:
        DAD         H
        XCHG
        DAD         H
        XCHG
        POP         PSW
        DCR         A
        JNZ         mul16_1
        ORA         D
        RP
        DAD         B
        RET



; Функция CMP16 - 16р сравнение
; Ввод: HL (уменьшаемое)
;       DE (вычитаемое)
; Вывод: Z=1 - HL=DE
;        Z=0 - HL!=DE
;        С=1 - HL<DE   для чисел без знаков
;        C=0 - HL>=DE
;        S=1 - HL<DE   для чисел со знаками
;        S=0 - HL>=DE
; Используемые регистры: AF
; Используемая память: нет
; Длина: 36 байт
; Время выполнения: 51..69 тактов

CMP16:
        mov         a,d
        xra         h
        jm          cmp16_diff
; переполнение невозмжно - выполнить сравнение без знака
        mov         a,l
        sub         e
        jz          cmp16_equal
; мл байты не равны, сравнить старшие биты
; запомним, что флаг С позднее должен быть очищен
        mov         a,h
        sbb         d
        jc          cmp16_cyset
        jnc         cmp16_cyclr
; мл байты равны
cmp16_equal:
        mov         a,h
        sbb         d
        ret
cmp16_diff:
        mov         a,l
        sub         e
        mov         a,h
        sbb         d
        mov         a,h
        jnc         cmp16_cyclr
cmp16_cyset:
        ori         01H
        stc
        ret
cmp16_cyclr:
        ori         01H
        ret


; Функция ABS - модуль 16р числа
; Ввод: HL (int)
; Вывод: HL (int)
; Используемые регистры: AF,HL
; Используемая память: нет
; Длина: 10 байт
; Время выполнения: 20/51 такта

ABS:
        mov         A,H
        ora         A
        rp                  ;выйти, если положительно
        cma                 ;иначе дополнение HL
        mov         H,A
        mov         A,L
        cma
        mov         L,A
        inx         H
        ret


; Функция DOPHL - дополнение 16р числа
; Ввод: HL (int)
; Вывод: HL (int)
; Используемые регистры: AF,HL
; Используемая память: нет
; Длина: 8 байт
; Время выполнения: 41 такт

DOPHL:
        POP         H   ;retaddr
        XTHL
        CALL        REG_DOPHL
        XCHG
        POP         H
        PUSH        D
        PCHL
REG_DOPHL:
        mov         A,H
        cma
        mov         H,A
        mov         A,L
        cma
        mov         L,A
        inx         H
        ret


;TODO: найти нормальную реализацию деления, без выделенной памяти



