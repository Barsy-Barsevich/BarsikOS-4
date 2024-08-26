


;Создать новый процесс
SYS_CreateNewProcess:    
;(1) Инкремент количества процессов
        LDA         SYSCELL_NUM_OF_PROC
        MOV         E,A
        INR         A
        STA         SYSCELL_NUM_OF_PROC
;(2) Получение начального адреса дескриптора нового процесса
        XRA         A
        MOV         D,A
        RDEL
        RDEL
        RDEL
        RDEL
        RDEL
        LHLD        SYSCELL_SAP_STARTADDR
        DAD         D
        PUSH        H
;(3) Вычислить ID как max(IDs)+1
        MVI         M,$03
;(4) Установка статуса
        POP         H
        PUSH        H
        LDHI        SYSPA_STATUS_0
        MVI         A,$85
        STAX        D
        INX         D
        MVI         A,$00
        STAX        D
;(5) Установка таблицы ассоциаций
        MVI         A,$03   ;здесь должна быть система выбора свободного сектора
        ;
        MOV         B,A
        RLC
        RLC
        RLC
        RLC
        ADD         B
        POP         H
        PUSH        H
        LDHI        SYSPA_TA_01
;Все виртуальные сектора кроме E и F заполнить одним значением
        MVI         C,$08
sys_cnp_cycle:
        STAX        D
        INX         D
        DCR         C
        JNZ         sys_cnp_cycle
;Виртуальный F должен совпадать с реальным
        DCX         D
        ORI         $0F
        STAX        D
;(6) Установка PC, SP
        POP         H
        PUSH        H
        LDHI        SYSPA_RETADDR
        ;
        MVI         A,$03   ;здесь должна быть система выбора свободного сектора
        ;
        RLC
        RLC
        RLC
        RLC
        MOV         H,A
        MVI         L,$00
        SHLX
        POP         H
        PUSH        H
        LDHI        SYSPA_SP_REG
        ORI         $0F
        MOV         H,A
        MVI         L,$FF
        SHLX
;(7) Preparing register set
        POP         H
        PUSH        H
        LDHI        SYSPA_STACK_HL
        LXI         H,$0000
        SHLX
        INX         D
        INX         D
        SHLX
        INX         D
        INX         D
        SHLX
        INX         D
        INX         D
        SHLX
    
        MVI     a,$CD
        STA         $3000
        MVI         a,$67
        STA         $3001
        MVI         a,$F0
        STA         $3002
        MVI         a,$C3
        STA         $3003
        MVI         a,$00
        STA         $3004
        MVI         a,$30
        STA         $3005
    
;(7) Возврат
        POP         h
        RET
