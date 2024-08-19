;SYStemFS - a set of OS functions


; SYS_OS_MUUTOS
; SYS_USR_MUUTOS
; BIOS_Millis
; BIOS_TA_Write
; SYS_QuantTime_Set
; SYS_UsrAddr_to_OSAddr
; SYS_PIC_INIT


; SYStemFS
; Функция SYS_OS_MUUTOS - переход в режим ОС
; Ввод: нет
; Вывод: нет
; Используемые регистры: A,I
; Оценка: длина - 12 байт, время - ~29 тактов
SYS_OS_muutos:
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
;; SYStemFS
;; Функция SYS_User_muutos - переход в режим пользователя




