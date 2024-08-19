; OS's hot start -- hotstart.s
; BarsikOS-4.01

;===============================================================================
;---<Подпрограмма "Горячий старт ОС">-------------------------------------------
Hot_Start_OS:
;Стек ОС по умолчанию - $0FFF
        LXI         H,$0FFF
        SHLD        SYSCELL_SYSTEMSP
        SPHL
;Инициализировать системное время
        CALL        BIOS_SysTime_Init
;Установить бит CLKE
        IN          SYSPORT_CLKE_PORT
        ORI         SYS_CLKE_BITMASK
        OUT         SYSPORT_CLKE_PORT
;Загрузка указателя на очередь дескрипторов процессов (QSAP)
        LXI         H,SAP_STARTADDR
        SHLD        SYSCELL_SAP_STARTADDR
;Копируем заголовки процессов
        MVI         B,$00
        MVI         A,ONE_SAP_LEN
        ADD         A
        MOV         C,A
        LXI         D,SAP_STARTADDR_ROM
        ;LXI         H,SAP_STARTADDR
        LHLD        SYSCELL_SAP_STARTADDR
        CALL        COPCOUNT
;Предзагрузка переменных диспетчера задач
;Количество первоначальных процессов: 2
        MVI         A,$02
        STA         SYSCELL_NUM_OF_PROC
;Начальный процесс - 0, но поскольку начинаем с планнера, даем другой номер
        MVI         A,$01
        STA         SYSCELL_TEMP_PROC_NUM
;Включаем запись в банк регистров
        ;LXI         H,SAP_STARTADDR
        LHLD        SYSCELL_SAP_STARTADDR
        CALL        SYS_TA_write
;Передать управление диспетчеру задач
        JMP         TRAP_Planner
;-------------------------------------------------------------------------------
;~~
;---<System_process_attributes>-------------------------------------------------
;SAP_STARTADDR:
SAP_STARTADDR_ROM:
;--<1st process>----------------------------------------------------------------
        .DB     $00     ;SYSPA_ID =         $00
        .DB     $27     ;SYSPA_STATUS_0 =   $01
        .DB     $00     ;SYSPA_STATUS_1 =   $02
;Table of Assotiations
        .DB     $01     ;SYSPA_TA_01 =      $03
        .DB     $23     ;SYSPA_TA_23 =      $04
        .DB     $45     ;SYSPA_TA_45 =      $05
        .DB     $67     ;SYSPA_TA_67 =      $06
        .DB     $89     ;SYSPA_TA_89 =      $07
        .DB     $AB     ;SYSPA_TA_AB =      $08
        .DB     $CD     ;SYSPA_TA_CD =      $09
        .DB     $EF     ;SYSPA_TA_EF =      $0A
;Contains of stack
        .DW     $0000   ;SYSPA_STACK_HL =   $0B
        .DW     $0000   ;SYSPA_STACK_DE =   $0D
        .DW     $0000   ;SYSPA_STACK_BC =   $0F
        .DW     $0000   ;SYSPA_STACK_PSW =  $11
;Return address
        .DW     process0   ;SYSPA_RETADDR =    $13
;Stack Pointer value
        .DW     $1FFF   ;SYSPA_SP_REG
;Зарезервированные байты
        .DB     $00     ;SYSPA_RES0 =       $17
        .DB     $00     ;SYSPA_RES1 =       $18
        .DB     $00     ;SYSPA_RES2 =       $19
        .DB     $00     ;SYSPA_RES3 =       $1A
        .DB     $00     ;SYSPA_RES4 =       $1B
        .DB     $00     ;SYSPA_RES5 =       $1C
        .DB     $00     ;SYSPA_RES6 =       $1D
        .DB     $00     ;SYSPA_RES7 =       $1E
        .DB     $00     ;SYSPA_RES8 =       $1F
;--<2nd process>----------------------------------------------------------------
        .DB     $01     ;SYSPA_ID =         $00
        .DB     $87     ;SYSPA_STATUS =     $01
        .DB     $00     ;SYSPA_STATUS2 =    $02
;Table of Assotiations
        .DB     $33     ;SYSPA_TA_01 =      $03
        .DB     $33     ;SYSPA_TA_23 =      $04
        .DB     $33     ;SYSPA_TA_45 =      $05
        .DB     $33     ;SYSPA_TA_67 =      $06
        .DB     $33     ;SYSPA_TA_89 =      $07
        .DB     $33     ;SYSPA_TA_AB =      $08
        .DB     $33     ;SYSPA_TA_CD =      $09
        .DB     $EF     ;SYSPA_TA_EF =      $0A
;Contains of stack
        .DW     $0000   ;SYSPA_STACK_HL =   $0B
        .DW     $0000   ;SYSPA_STACK_DE =   $0D
        .DW     $0000   ;SYSPA_STACK_BC =   $0F
        .DW     $0000   ;SYSPA_STACK_PSW =  $11
;Return address
        .DW     $3000   ;process1   ;SYSPA_RETADDR =    $13
;Stack Pointer value
        .DW     $3FFF   ;SYSPA_SP_REG
;Зарезервированные байты
        .DB     $00     ;SYSPA_RES0 =       $17
        .DB     $00     ;SYSPA_RES1 =       $18
        .DB     $00     ;SYSPA_RES2 =       $19
        .DB     $00     ;SYSPA_RES3 =       $1A
        .DB     $00     ;SYSPA_RES4 =       $1B
        .DB     $00     ;SYSPA_RES5 =       $1C
        .DB     $00     ;SYSPA_RES6 =       $1D
        .DB     $00     ;SYSPA_RES7 =       $1E
        .DB     $00     ;SYSPA_RES8 =       $1F
;-------------------------------------------------------------------------------
