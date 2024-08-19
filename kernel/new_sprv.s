; NEW_SPRV - SUPERVISOR, START AT $0000
; BarsikOS-4.01

;.INCLUDE /home/victor/Desktop/BarsikOS-2/core/systemdef.def
;.INCLUDE /home/victor/Desktop/BarsikOS-2/core/smm.def
;.INCLUDE /home/victor/Desktop/BarsikOS-2/core/libraries.h
        .INCLUDE    /home/victor/Desktop/BarsikOS-4/kernel/systemdf.s

;===============================================================================
;-<Вектора обработчиков ошибок>-------------------------------------------------
;Вектор $0000 - фатальная ошибка
        .ORG        $0000
        JMP         FATAL_ERROR_HANDLER
;Вектор $0003 - ошибка диска
        .ORG        $0003
        JMP         DISK_ERROR_HANDLER
;Вектор $21 - Горячий старт ОС
        .ORG        $0021
        JMP         Hot_Start_OS

;Вектор 24Н - Инквизитор
;===============================================================================
;-<Инквизитор>------------------------------------------------------------------
        .ORG        $0024
TRAP_main:
;Сохранить HL. Сейчас SP содержит виртуальный адрес пользователя
        SHLD        SYSCELL_HL_SAVE
;Чтение маски прерываний
        MOV         H,A
        RIM
        STA         SYSCELL_RIM
        MOV         A,H
;Сохранить DE, BC
        XCHG
        SHLD        SYSCELL_DE_SAVE
        LHLD        SYSCELL_PROCTORUN
        LDHI        SYSPA_STACK_HL
        LHLD        SYSCELL_HL_SAVE
        SHLX
        INX         D
        INX         D
        LHLD        SYSCELL_DE_SAVE
        SHLX
        INX         D
        INX         D
        MOV         H,B
        MOV         L,C
        SHLX
;Сохранить SP
        LXI         H,$0006
        DAD         D
        XCHG
        LXI         H,$0000
        DAD         SP
        SHLX
;Задать SP значение стека операционной системы
        LHLD        SYSCELL_SYSTEMSP
        SPHL
;Теперь надо сохранить PSW
        DCX         D
        DCX         D
        DCX         D
        DCX         D
        PUSH        PSW
        POP         H
        SHLX
;Сохранить адрес возврата (виртуальный)
        INX         D
        INX         D
        INX         D
        INX         D
        LHLX
        MOV         C,M
        INX         H
        MOV         B,M
        INX         H
        SHLX
        DCX         D
        DCX         D
        MOV         H,B
        MOV         L,C
        SHLX
;Сбросить флаг RST7.5
        MVI         A,$10
        SIM
;Определить, кто являлся источником прерывания
        LDA         SYSCELL_RIM
        ANI         $40     ;Выделяем RST7.5
        JZ          TRAP_source_proc
;===============================================================================
;-<(1a) Источник прерывания - таймер>-------------------------------------------
;-<Диспетчер задач>-------------------------------------------------------------
TRAP_source_timer:
TRAP_Planner:
;--<Откладываем текущий процесс>------------------------------------------------
;~~
;--<Поиск нового процесса для запуска>------------------------------------------
;Сейчас SP содержит адрес стека ОС
planner_change_proc:
;(1) Инкремент номера текущего процесса, если >= числа процессов, придаем 0
        LDA         SYSCELL_NUM_OF_PROC
        MOV         B,A
        LDA         SYSCELL_TEMP_PROC_NUM
        INR         A
        CMP         B
        JC          planner_m1
        XRA         A
planner_m1:
        STA         SYSCELL_TEMP_PROC_NUM
;(2) Указатель на САП = SAP_START + (TEMP_PROC_NUM * 32)
        MOV         E,A
        XRA         A
        MOV         D,A
        RDEL                ;DE <- TEMP_PROC_NUM*32
        RDEL
        RDEL
        RDEL
        RDEL
        ;lxi         h,SAP_STARTADDR
        LXI         SYSCELL_QSAP
        DAD         D           ;HL - указатель на САП
        SHLD        SYSCELL_PROCTORUN ;указатель на САП процесса, который надо запустить
;(3) Проверка статуса.
; - Если 00, то запуск
; - Если 01, то выбор новой САП
; - Если 10, то поиск процесса-условия, выполнен - запуск, нет - выбор новой САП
; - Если 11, то выбор новой САП
        LDHI        SYSPA_STATUS_0
        LDAX        D
        ANI         SYSPA_STATUS_STATUS_MASK
        CPI         SYSPA_PROC_LAUNCHED
        JZ          planner_run_proc
        CPI         SYSPA_PROC_WAITING
        JNZ         planner_change_proc ;SYSPA_PROC_STOPPED & SYSPA_PROC_COMPLETED
;(4) Поиск САП с нужным ID
;Байт ID - 0й байт САП (дескриптора процесса)
;В цикле NUM_OF_PROC раз перебираем САП, если совпадение - смотрим биты статуса
;SYSPA_STATUS_STATUS_MASK. Если равны SYSPA_PROC_COMPLETED, то начальный
;процесс завершен, а значит, вторичный может начинать работу. Если не равен
;SYSPA_PROC_COMPLETED, переход к planner_change_proc. Если процесс с нужным ID
;не найден, запуск ждущего процесса(v2.20) /переход к planner_change_proc(v2.19)
;Выделение байта ID первичного процесса
        LDA         SYSCELL_NUM_OF_PROC
        MOV         C,A                     ;C <- NUM_OF_PROC
        LHLD        SYSCELL_PROCTORUN
        LDHI        SYSPA_STATUS_1
        LDAX        D                       ;A <- ID
        LXI         SYSCELL_QSAP   ;HL <- SAP_STARTADDR
        LXI         D,ONE_SAP_LEN           ;DE <- 32
;(5) Цикл-пробежка по очереди САП
planner_cycle:
        CMP         M
        JZ          planner_m2
        DAD         D
        DCR         C
        JNZ         planner_cycle
;В версии v2.20 изменяется условие запуска ждущего процесса: если дескриптор
;ожидаемого процесса не найден, то запуск ждущего процесса
;        JMP         planner_change_proc  ;v2.19
        JMP         planner_run_proc
;(6) Определить, выполнен первичный процесс или еще выполняется
;HL - указатель на САП первичного процесса
planner_m2:
        LDHI        SYSPA_STATUS_0
        LDAX        D
        ANI         SYSPA_STATUS_STATUS_MASK
        CPI         SYSPA_PROC_COMPLETED
        JZ          planner_run_proc
        JMP         planner_change_proc
;--<Запуск нового процесса>-----------------------------------------------------
planner_run_proc:
;(1) Загружаем таблицу ассоциаций для нового процесса
        LHLD        SYSCELL_PROCTORUN
        CALL        BIOS_TA_Write
;(2) Загружаем размер кванта времени для нового процесса
        LHLD        SYSCELL_PROCTORUN
        CALL        SYS_QuantTime_Set
;(3) Фиксируем текущее машинное время в микросекундах
        CALL        BIOS_Millis
        SHLD        SYSCELL_TIME_PROC_MARK
        ;
        JMP         TRAP_source_end
;===============================================================================
;-<(1b) Источник прерывания - процесс>------------------------------------------
TRAP_source_proc:
;Достать адрес возврата, если FXXX, то системная ф, иначе удалить
        LHLD        SYSCELL_PROCTORUN
        LDHI        SYSPA_RETADDR
        LHLX
        MOV         A,H
        ANI         $F0
        CPI         $F0         ;проверка на сектор 'F'
        ;CPI         $00         ;проверка на сектор '0'
        JZ          TRAP_stack_form
;===============================================================================
;-<(1ba) Убийца процессов>------------------------------------------------------
;Смотрим SYSCELL_STARTPASS (Если не равен 0, то не убиваем. Установ в 0)
        LDA         SYSCELL_STARTPASS
        MOV         B,A
        XRA         A
        STA         SYSCELL_STARTPASS
        MOV         A,B
        ORA         A
        JNZ         TRAP_source_end     ;переход к стандартному выходу
;--<Таки убить>-----------------------------------------------------------------
;--<Проверка на ожидаемость>----------------------------------------------------
        LHLD        SYSCELL_PROCTORUN
        LDHI        SYSPA_STATUS_0
        LDAX        D
        ANI         SYSPA_STATUS_WAITED_MASK
;Если 0 - убрать процесс из QSAP
;Если 1 - пометить как завершенный
        JZ          killer_from_qsap
;--<Пометить процесс как завершенный>-------------------------------------------
        LDHI        SYSPA_STATUS_0
        LDAX        D
        ORI         SYSPA_PROC_COMPLETED
        STAX        D
;Переход к выбору следующей задачи
        JMP         planner_change_proc
;--<Удаление дескриптора процесса из очереди дескрипторов QSAP>-----------------
killer_from_qsap:
;(1) Найти следующий дескриптор процесса
        LDA         SYSCELL_NUM_OF_PROC
        MOV         C,A
        LDA         SYSCELL_TEMP_PROC_NUM
        INR         A
        CMP         C   ;если temp_proc >= num_of_proc, CY:=0
;Если temp_proc >= num_of_proc, тогда адрес сл САП равен SAP_STARTADDR.
;Тогда ничего не делаем, просто декремент NUM_OF_PROC
        JNC         killer_m1
;NEXT_PROC равен TEMP_PROC+ONE_SAP_LEN. Копировать верхнюю часть QSAP на
;ONE_SAP_LEN вниз, затем декремент NUM_OF_PROC
;(2) DE <- NEXT_PROC := TEMP_PROC + ONE_SAP_LEN
        LXI         D,ONE_SAP_LEN
        LHLD        SYSCELL_PROCTORUN
        DAD         D
        XCHG
;(3) BC <- 'сколько' := SAP_STARTADDR + QSAP_LEN - NEXT_PROC
        LXI         SYSCELL_QSAP
        LXI         b,QSAP_LEN
        DAD         B
        MOV         B,D
        MOV         C,E
        DSUB
        MOV         B,H
        MOV         C,L
;(4) HL <- SYSCELL_PROCTORUN
        LHLD        SYSCELL_PROCTORUN
;(5) Копируем
        CALL        COPCOUNT
;(6) NUM_OF_PROC -= 1
killer_m1:
        LXI         H,SYSCELL_NUM_OF_PROC
        DCR         M
;(7) Переход к выбору следующей задачи
        JMP         planner_change_proc
;===============================================================================
;-<(1bb) Переход к исполнению системной функции>--------------------------------
;В данный момент SP указывает на стек ОС (SYSCELL_SYSTEMSP)
;Стек пользователя:
;[USRSP+4] = [DI]
;[USRSP+2] = [USR]
;[USRSP+0] = [FUN]
;[USRSP-2] = [SYS_OS_MUUTOS]
;THIS->SAP.RETADDR = SYS_OS_MUUTOS
;Чтобы использовать входные данные пользователя и сохранять результат,
;системная функция должна работать в стеке пользователя. Но супервизор работает
;со стеком ОС. Соответственно, необходимо поменять стек ОС на стек пользователя
;в реальном адресном пространстве.
;Алгоритм:
; - (0) Конечно же сохранить надо стек ОС
; - (1) SP <- real(USRSP+0)
; - (2) адрес системной функции ~ [real(USRSP)+0] ~ POP(SP), (<-[SP], SP+=2)
; - (3) THIS->SAP.RETADDR <- [real(USRSP)+2] ~ POP(SP), (<-[SP], SP+=2)
; - (4) [real(USRSP)+2] <- TRAP_SysFun_Return - PUSH(SP) (SP-=2, [SP]<-VAL)
; - (5) THIS->SAP.SP_REG <- USRSP+4
;Надеимся и Верим
TRAP_stack_form:
;(0) Сохранить указатель стека ОС
        LXI         H,$0000
        DAD         SP
        SHLD        SYSCELL_SYSTEMSP
;(5) Полю SP_REG задать значение DI
        LHLD        SYSCELL_PROCTORUN
        PUSH        H
        LDHI        SYSPA_SP_REG
        LHLX                        ;HL <- USRSP
        PUSH        H
        INX         H
        INX         H
        INX         H
        INX         H
        SHLX
;(1) Преобразовать виртуальный указатель стека пользователя в реальный 
        CALL        SYS_USR_ADDR_TO_OS
        POP         H       ;DE <- real(USRSP) ~ FUN
        SPHL
;(2A) В BC сохранить значение [FUN], SP+=2
        POP         B
;(3) Полю RETADDR задать значение [USR], SP+=2
        LHLD        SYSCELL_PROCTORUN
        LDHI        SYSPA_RETADDR
        POP         H
        SHLX
;(4) Как адрес возврата использовать указатель на программу возврата из с.ф.
        LXI         H,TRAP_SysFun_Return
        PUSH        H
;(2B) Перейти к выполнению программы FUN
        MOV         H,B
        MOV         L,C
        PCHL
;===============================================================================
;-<Возврат из системной функции>------------------------------------------------
;Крайне важно помнить, что мы работаем сейчас с реальным стеком пользователя
;Надо поменять его на стек ОС. Поскольку вся работа со стеком пользователя
;была приведена при входе в системную функцию, просто меняем стек
TRAP_SysFun_Return:
;Меняем стек на стек ОС
        LHLD        SYSCELL_SYSTEMSP
        SPHL
;Сравниваем текущее машинное время со временем последнего запуска процесса
        LHLD        SYSCELL_TIME_PROC_MARK
        MOV         B,H
        MOV         C,L
        CALL        BIOS_Millis
;(HL)<-(millis-metka)
        DSUB
;Защита от downflow. Недополнение случается 1 раз в 32.768 сек, что больше
;на порядки максимальных размеров кванта времени, можно использовать модуль
        CALL        ABS
;Сохранить значение
        PUSH        H
;Посчитать размер кванта времени для текущего процесса в мс
;(HL)<-(QuantTime/CLT_Ticks_Per_Ms)
        LHLD        SYSCELL_QUANT_TIME
        LXI         D,CLT_Ticks_Per_Ms
        CALL        UDIV16
;Сравнить значения
        POP         D
        CALL        CMP16   ;C=0 - HL>=DE
;Если C=0, то квант времени не был привышен, возврат в процесс
        JNC         TRAP_source_end
;Иначе переход в диспетчер задач
        JMP         TRAP_Planner
;===============================================================================
;-<(2) Стандартный возврат>-----------------------------------------------------
TRAP_source_end:
        JMP         SYS_USR_MUUTOS
;===============================================================================
;~~
;~~
;-------------------------------------------------------------------------------
; SYStemFS
; Функция SYS_QuantTime_Set - установка величины кванта времени
; Ввод: (HL)-указатель на структуру аттрибутов процесса
; Вывод: SYSCELL_QUANT_TIME - 
; Используемые регистры: все
; Оценка: длина - , время - 
SYS_QuantTime_Set:
        LDHI        SYSPA_STATUS_0
        LDAX        D
        ANI         $07
        ADD         A
        MOV         E,A
        MVI         D,$00
        LXI         H,sys_quanttime_set_1
        DAD         D
        XCHG
        LHLX
        SHLD        SYSCELL_QUANT_TIME
        RET
sys_quanttime_set_1:
        .DW         $0BB8   ;3000  Приоритет 0 (низший)
        .DW         $1388   ;5000  Приоритет 1 (фоновый)
        .DW         $1D4C   ;7500  Приоритет 2 (пользовательский)
        .DW         $2710   ;10000 Приоритет 3 (пользовательский)
        .DW         $4E20   ;20000 Приоритет 4 (пользовательский)
        .DW         $7530   ;30000 Приоритет 5 (пользовательский)
        .DW         $9C40   ;40000 Приоритет 6 (системный)
        .DW         $EA60   ;60000 Приоритет 7 (высший)
        

;Функция SYS_USR_ADDR_TO_OS - преобразование виртуального адреса в реальный
;Ввод:  stack+4 - указатель на дескриптор процесса
;       stack+2 - виртуальный адрес
;Вывод: stack+2 - реальный адрес
;Используемые регистры: все
;Оценка: -, -
SYS_USR_ADDR_TO_OS:
;Имеем AXXX адрес, необходимо сделать BXXX
;Если (A & 1) == 1: $BX = (M[PROCTORUN+SYSPA_TA_01+(A>>1)]) & $F0 | $0X
;Иначе: $BX = ((M[PROCTORUN+SYSPA_TA_01+(A>>1)]) << 4) & $F0 | $0X
        POP         PSW ;RETADDR
        POP         B   ;AXXX
        POP         H   ;POINTER_TO_DESCRIPTOR
        PUSH        PSW
;Get value: DE <- PROCTORUN+SYSPA_TA_01+(A>>1)
        LDHI        SYSPA_TA_01
        MOV         A,B
        RLC
        RLC
        RLC
        ANI         $07
        ADD         E
        MOV         E,A
        MVI         A,$00
        ADC         D
        MOV         D,A
;Проверка А на делимость на 2
        MOV         A,B
        ANI         $10
        LDAX        D   A<-M[DE]
        JNZ         SYS_USR_ADDR_TO_OS_M1
;А делится на 2. $BX = M[DE]<<4 & $F0 | $0X
        RLC
        RLC
        RLC
        RLC
SYS_USR_ADDR_TO_OS_M1:
;А не делится на 2. $BX = M[DE] & $F0 | $0X
        ANI         $F0
        MOV         H,A
        MOV         A,B
        ANI         $0F
        ORA         H
        MOV         B,A
;Возврат
        POP         H
        PUSH        B
        PCHL

;Обработчики программных прерываний
.include    /home/victor/Desktop/BarsikOS-2/core/errorh.asm







