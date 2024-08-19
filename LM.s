;Muutokset for sector F


; SYSTEMFS
; Функция SYS_OS_MUUTOS - переход в режим ОС
; Ввод: нет
; Вывод: нет
; Используемые регистры: A,I
; Оценка: длина - 12 байт, время - ~29 тактов
SYS_OS_MUUTOS:
        MVI         A,$40
        SIM
        MVI         A,$C0
        SIM
        NOP
        NOP
        NOP
        NOP
        NOP
        RET


;Подстава лютейшая, как же долго я ее искал
;Эта функция должна быть в секторе F
; SYSTEMFS
; Функция SYS_USR_MUUTOS - переход в режим пользователя
; Ввод: нет
; Вывод: нет
; Используемые регистры: все
; Используемые порты: таймер номер 2
; Оценка: длина - 23 байта, время - 123 такта
SYS_USR_MUUTOS:
;Настройка таймера
        MVI         A,$B0
        OUT         TIMER_MODEREG
        LHLD        SYSCELL_QUANT_TIME
        LXI         D,CLT_Ticks_Per_Ms
        CALL        REG_MUL16
        MOV         A,L
        OUT         TIMER_COUNTER_2
        MOV         A,H
        OUT         TIMER_COUNTER_2
;Сохранить состояние стека ОС
        LXI         H,$0000
        DAD         SP
        SHLD        SYSCELL_SYSTEMSP
;Включаем режим пользователя
        MVI         A,$40
        SIM 
        MVI         A,$C0
        SIM
;Переключение стека на стек пользователя
        LHLD        SYSCELL_PROCTORUN
        LDHI        SYSPA_SP_REG
        LHLX
        SPHL
;Загрузка в стек RETADDR, HL, DE, BC, PSW
        DCX         D
        DCX         D
        LHLX
        PUSH        H   ;RETADDR
        LHLD        SYSCELL_PROCTORUN
        LDHI        SYSPA_STACK_HL
        LHLX
        PUSH        H   ;HL
        INX         D
        INX         D
        LHLX
        PUSH        H   ;DE
        INX         D
        INX         D
        LHLX
        PUSH        H   ;BC
        INX         D
        INX         D
        LHLX
        PUSH        H   ;PSW
;Возврат
        POP         PSW
        POP         BC
        POP         DE
        POP         HL
        RET
