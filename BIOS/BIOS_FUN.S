; BIOS functions -- only for RedStar computer


BIOS_SysTime_Init:
;Инициализация TIMER1 в режим 3, коэффициент - CLT_Ticks_Per_Ms
        MVI         A,$76
        OUT         TIMER_MODEREG
        LXI         h,CLT_Ticks_Per_Ms
        MOV         A,L
        OUT         TIMER_COUNTER_1
        MOV         A,H
        OUT         TIMER_COUNTER_1
;Инициализация TIMER0 в режим 0
        MVI         A,$30
        OUT         TIMER_MODEREG
        MVI         A,$10
        OUT         TIMER_COUNTER_0
        MVI         A,$00
        OUT         TIMER_COUNTER_0
;Возврат
        RET


; SYStemFS
; Функция BIOS_Millis - чтение системного времени (в миллисекундах)
; Ввод: нет
; Вывод: (HL) - время в микросекундах
; Используемые регистры: AF,HL
; Оценка: длина - байт, время -  тактов
BIOS_Millis:
;Send code to latch counting
        MVI         A,$00
        OUT         TIMER_MODEREG
        IN          TIMER_COUNTER_0
        CMA
        MOV         L,A
        IN          TIMER_COUNTER_0
        CMA
        MOV         H,A
        RET


; SYStemFS
; Функция BIOS_TA_Write - запись таблицы ассоциаций из аттрибутов процесса
; Ввод: (HL)-указатель на структуру аттрибутов процесса
; Вывод: нет
; Используемые регистры: все
; Оценка: длина - , время - 
BIOS_TA_Write:
        PUSH        H
;Сохранение значений ячеек по адресам X000H
        LXI         H,$0000
        LXI         D,SYSCELL_WB_MEMORY_SAVE
        MVI         C,$10
BIOS_TA_Write_1:
        MOV         A,M
        STAX        D
        INX         D
        MVI         A,$10
        ADD         H
        MOV         H,A
        DCR         C
        JNZ         BIOS_TA_Write_1
        POP         H
;Запись в банк
        IN          SYSPORT_C
        ORI         SYS_WB_BITMASK
        ORI         SYS_CLKE_BITMASK
        OUT         SYSPORT_C
        LDHI        SYSPA_TA_01
        MVI         c,$08
        LXI         h,$0000
BIOS_TA_Write_cycle:
        LDAX        d
        CMA
        MOV         b,a
        ANI         $F0
        RRC
        RRC
        RRC
        RRC
        MOV         M,A
        MVI         A,$10
        ADD         H
        MOV         H,A
        MOV         A,B
        ANI         $0F
        MOV         M,A
        MVI         A,$10
        ADD         H
        MOV         H,A
        INX         D
        DCR         C
        JNZ         BIOS_TA_Write_cycle
;Выключение режима записи в банк
        IN          SYSPORT_C
        ANI         SYS_WB_BITMASK_INV
        ORI         SYS_CLKE_BITMASK
        OUT         SYSPORT_C
;Выгрузка сохраненных значений ячеек помяти по адресам X000H
        LXI         H,$0000
        LXI         D,SYSCELL_WB_MEMORY_SAVE
        MVI         C,$10
BIOS_TA_Write_2:
        LDAX        D
        MOV         M,A
        INX         D
        MVI         A,$10
        ADD         H
        MOV         H,A
        DCR         C
        JNZ         BIOS_TA_Write_2
        RET


; SYStemFS
; SYS_PIC_INIT - Инициализация контроллера прерываний КР1810ВН59А
; Ввод: нет
; Вывод: нет
; Используемые регистры: AF,HL
; Используемые порты: PIC_REG_A0,PIC_REG_A1
; Используемая память: нет
; Использование функций:
;  - COPCOUNT
; Оценка: длина - , время - 
SYS_PIC_INIT:
        LXI         h,PIC_INT_STARTADDR
;(1) Отправка команды СКИ1и или СКИ1к (D3=0 - по фронту, иначе по уровню)
;ПКП в системе единственный, смещение адресов векторов 4.
;|A7|A6|A5|1|0|1|1|1|
        MOV         a,l
        ANI         $E0
        ORI         PIC_ICW1
        OUT         PIC_REG_A0
;(2) Отправка команды СКИ2
;|A15|A14|A13|A12|A11|A10|A9|A8|
        MOV         a,h
        OUT         PIC_REG_A1
;Команды СКИ3 и СКИ4 пропустить
;(3) Отправка команды СКО1
        MVI         a,PIC_DEFAULT_INTMASK
        OUT         PIC_REG_A1
;(4) Отправка команды СКО2д
        MVI         a,$80
        OUT         PIC_REG_A0
;(5) Загрузка таблицы векторов прерываний
        LXI         b,$0032
        LXI         d,SYS_Interrupt_Table_Default
        LXI         h,PIC_INT_STARTADDR
        CALL        COPCOUNT
;Возврат
        RET

SYS_Interrupt_Table_Default:
        .DB         $C3
        .DW         INT_VECT_0
        .DB         $00
        .DB         $C3
        .DW         INT_VECT_1
        .DB         $00
        .DB         $C3
        .DW         INT_VECT_2
        .DB         $00
        .DB         $C3
        .DW         INT_VECT_3
        .DB         $00
        .DB         $C3
        .DW         INT_VECT_4
        .DB         $00
        .DB         $C3
        .DW         INT_VECT_5
        .DB         $00
        .DB         $C3
        .DW         INT_VECT_6
        .DB         $00
        .DB         $C3
        .DW         INT_VECT_7
        .DB         $00
