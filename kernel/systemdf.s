; Systemdef
; BarsikOS-4.01

;===============================================================================
;----<SOFTWARE INTERRUPTS VECTORS>----------------------------------------------
;===============================================================================
        .DEF    FATAL_ERROR_VECT =     $0000
        .DEF    DISK_ERROR_VECT =      $0003
;===============================================================================
;--<QSAP'S (QUEUE OF SYSTEM PROCESS ATTRIBUTES) BIAS>---------------------------
;===============================================================================
        .DEF    SYSPA_ID =             $00
        .DEF    SYSPA_STATUS_0 =       $01
        .DEF    SYSPA_STATUS_1 =       $02
;Table of Assotiations
        .DEF    SYSPA_TA_01 =          $03
        .DEF    SYSPA_TA_23 =          $04
        .DEF    SYSPA_TA_45 =          $05
        .DEF    SYSPA_TA_67 =          $06
        .DEF    SYSPA_TA_89 =          $07
        .DEF    SYSPA_TA_AB =          $08
        .DEF    SYSPA_TA_CD =          $09
        .DEF    SYSPA_TA_EF =          $0A
;Contains of stack
        .DEF    SYSPA_STACK_HL =       $0B
        .DEF    SYSPA_STACK_DE =       $0D
        .DEF    SYSPA_STACK_BC =       $0F
        .DEF    SYSPA_STACK_PSW =      $11
;Return address
        .DEF    SYSPA_RETADDR =        $13
        .DEF    SYSPA_L_RETADDR =      $13
        .DEF    SYSPA_H_RETADDR =      $14
;Contains of SP register
        .DEF    SYSPA_SP_REG =         $15
        .DEF    SYSPA_SP_REG_L =       $15
        .DEF    SYSPA_SP_REG_H =       $16
;Reserved
        .DEF    SYSPA_RES_0 =          $17
        .DEF    SYSPA_RES_1 =          $18
        .DEF    SYSPA_RES_2 =          $19
        .DEF    SYSPA_RES_3 =          $1A
        .DEF    SYSPA_RES_4 =          $1B
        .DEF    SYSPA_RES_5 =          $1C
        .DEF    SYSPA_RES_6 =          $1D
        .DEF    SYSPA_RES_7 =          $1E
        .DEF    SYSPA_RES_8 =          $1F
;===============================================================================
;--<BITS OF PROCESS STATUS>-----------------------------------------------------
;===============================================================================
;Маски байта SYSPA_STATUS_0
        .DEF    SYSPA_STATUS_STATUS_MASK =     $C0
        .DEF    SYSPA_STATUS_PRIORITY_MASK =   $07
        .DEF    SYSPA_STATUS_WAITED_MASK =     $20
;Состояние процесса
        .DEF    SYSPA_PROC_LAUNCHED =          $00 ;процесс запущен и выполняется
        .DEF    SYSPA_PROC_STOPPED =           $40 ;остановлен до освобождения критического ресурса
        .DEF    SYSPA_PROC_WAITING =           $80 ;ждет выполнения другого процесса
        .DEF    SYSPA_PROC_COMPLETED =         $C0 ;исполнение завершено
        .DEF    SYSPA_STATUSBITS_MASK =        $C0
        .DEF    SYSPA_STATUSBITS_NMASK =       $3F
;Если процесс ждет выполнения другого процесса, в байте SYSPA_STATUS_1 должен
;быть ID процесса, чье выполнение ожидается. Процесс не запустится, пока
;ожидаемый процесс не будет выполнен (11) или не будет удален
;===============================================================================
;--<SYSTEM PARAMETERS>----------------------------------------------------------
;===============================================================================
;Константа, обозначающая длину 1 структуры атрибутов процесса (САП)
        .DEF    ONE_SAP_LEN =          $20     ;32
;Длина очереди дескрипторов процессов
        .DEF    QSAP_LEN =             $0100   ;256=32*8
;Константа, максимальное количество процессов
        .DEF    MAX_NUM_OF_PROC =      $08
