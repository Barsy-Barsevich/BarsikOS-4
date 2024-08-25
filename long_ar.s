; Long Arithmetic


; INT32ADD - сложение 32-р чисел
;
; Входные данные: (HL) - адрес СЛ1, (DE) - адрес СЛ2
; Выходные данные: (HL) - адрес суммы (вместо СЛ1)
;
; Используются регистры: AF,DE,HL. Cохраняются (HL) и (DE)
; Оценка: длина - , время - 

INT32ADD:
    PUSH    D   ;сохранение адресов слагаемых
    PUSH    H
    LDAX    D   ;чтение 0-го байта СЛ2
    ADD     M   ;складываем с СЛ1
    MOV     M,A
    INX     D   ;переходим к следующим байтам
    INX     H
    LDAX    D   ;чтение 1-го байта СЛ2
    ADC     M   ;складываем с СЛ1
    MOV     M,A
    INX     D   ;переходим к следующим байтам
    INX     H
    LDAX    D   ;чтение 2-го байта СЛ2
    ADC     M   ;складываем с СЛ1
    MOV     M,A
    INX     D   ;переходим к следующим байтам
    INX     H
    LDAX    D   ;чтение 3-го байта СЛ2
    ADC     M   ;складываем с СЛ1
    MOV     M,A
    POP     H   ;выгружаем адреса слагаемых
    POP     D
    RET
  

; INT32INV - дополнение 32-р числа
;
; Входные данные: (HL) - адрес числа
; Выходные данные: (HL) - адрес дополненного числа
;
; Используются регистры: AF,BC,HL. Cохраняется (HL)
; Оценка: длина - , время - 

INT32INV:
    PUSH    H
    mvi     c,$03   ;задаем количество повторений цикла
    MOV     A,M     ;загрузка байта
    CMA             ;инверсия
    ADI     $01     ;инкремент
    MOV     M,A     ;сохранение
int32inv_cycle:
    MVI     A,$00
    RAL
    MOV     B,A     ;сохраняем флаг переноса в (В)
    INX     H       ;переходим к следующему байту
    MOV     A,M     ;загрузка байта
    CMA             ;инверсия
    ADD     B       ;сложение с флагом переноса
    MOV     M,A     ;сохранение
    DCR     C
    JNZ     int32inv_cycle
    POP     H
    RET


; INT32SUB - вычитание 32-р чисел
;
; Входные данные: (HL) - адрес уменьшаемого, (DE) - адрес вычитаемого
; Выходные данные: (HL) - адрес разности (вместо уменьшаемого)
;
; Используются регистры: все, сохраняются (HL) и (DE)
; Глубина стека - 2
; Оценка: длина - , время - 

INT32SUB:
    PUSH    D      ;сохраняем адреса УМ и ВЧ
    PUSH    H
    LDAX    D      ;чтение 0-го байта ВЧ
    CMA            ;инверсия
    ADI     $01    ;дополнение
    MOV     C,A    ;сохранить в (С)
    MVI     A,$00
    RAL
    MOV     B,A    ;сохраняем CY в (В)
    MOV     A,C    ;достаем дополненный 0-й байт ВЧ
    ADD     M      ;складываем с 0-м байтом УМ
    MOV     M,A    ;сохраняем
    MVI     A,$00
    ADC     B      ;сохраняем CY, а также перенос от дополнения 0-го байта ВЧ в (В)
    MOV     B,A
    INX     D      ;переходим к 1-м байтам ВЧ и УМ
    INX     H
    LDAX    D      ;читаем 1 байт ВЧ
    CMA            ;инверсия
    ADD     B      ;добавляем флаги
    MOV     C,A    ;сохраняем в (С)
    MVI     A,$00
    RAL
    MOV     B,A    ;сохраняем CY в (В)
    MOV     A,C    ;достаем дополненный 1 байт ВЧ
    ADD     M      ;складываем со 1 байтом УМ
    MOV     M,A    ;сохраняем
    MVI     A,$00
    ADC     B      ;сохраняем CY, а также перенос от дополнения 1 байта ВЧ в (В)
    MOV     B,A
    INX     D      ;переходим ко 2 байтам ВЧ и УМ
    INX     H
    LDAX    D      ;читаем 2 байт ВЧ
    CMA            ;инверсия
    ADD     B      ;добавляем флаги
    MOV     C,A    ;сохраняем в (С)
    MVI     A,$00
    RAL
    MOV     B,A    ;сохраняем CY в (В)
    MOV     A,C    ;достаем дополненный 2 байт ВЧ
    ADD     M      ;складываем со 2 байтом УМ
    MOV     M,A    ;сохраняем
    MVI     A,$00
    ADC     B      ;сохраняем CY, а также перенос от дополнения 2 байта ВЧ в (В)
    MOV     B,A
    INX     D      ;переходим к 3 байтам ВЧ и УМ
    INX     H
    LDAX    D      ;читаем 3 байт ВЧ
    CMA            ;инверсия
    ADD     B      ;добавляем флаги
    MOV     C,A    ;сохраняем в (С)
    MVI     A,$00
    RAL
    MOV     B,A    ;сохраняем CY в (В)
    MOV     A,C    ;достаем дополненный 3 байт ВЧ
    ADD     M      ;складываем со 3 байтом УМ
    MOV     M,A    ;сохраняем
    POP     H      ;выгружаем адреса УМ и ВЧ
    POP     D
    RET


; INT64ADD - сложение 64-р чисел
;
; Входные данные: (HL) - адрес СЛ1, (DE) - адрес СЛ2
; Выходные данные: (HL) - адрес суммы (вместо СЛ1)
;
; Используются регистры: AF,B,DE,HL. Cохраняются (HL) и (DE)
; Оценка: длина - , время - 

INT64ADD:
    PUSH    D       ;сохранение адресов слагаемых
    PUSH    H
    MVI     B,$07   ;устанавливаем кол-во повторений цикла
    LDAX    D       ;чтение 0-го байта СЛ2
    ADD     M       ;складываем с СЛ1
    MOV     M,A
int64add_cycle:
    INX     D       ;переходим к следующим байтам
    INX     H
    LDAX    D       ;чтение байта СЛ2
    ADC     M       ;складываем с СЛ1
    MOV     M,A
    DCR     B
    JNZ     int64add_cycle
    POP     H       ;выгружаем адреса слагаемых
    POP     D
    RET


; INT64INV - дополнение 64-р числа
;
; Входные данные: (HL) - адрес числа
; Выходные данные: (HL) - адрес дополненного числа
;
; Используются регистры: AF,BC,HL. Cохраняется (HL)
; Оценка: длина - , время - 

INT32INV:
    PUSH    H
    mvi     c,$07   ;задаем количество повторений цикла
    MOV     A,M     ;загрузка байта
    CMA             ;инверсия
    ADI     $01     ;инкремент
    MOV     M,A     ;сохранение
int64inv_cycle:
    MVI     A,$00
    RAL
    MOV     B,A     ;сохраняем флаг переноса в (В)
    INX     H       ;переходим к следующему байту
    MOV     A,M     ;загрузка байта
    CMA             ;инверсия
    ADD     B       ;сложение с флагом переноса
    MOV     M,A     ;сохранение
    DCR     C
    JNZ     int64inv_cycle
    POP     H
    RET


; INT64SUB - вычитание 64-р чисел
;
; Входные данные: (HL) - адрес уменьшаемого, (DE) - адрес вычитаемого
; Выходные данные: (HL) - адрес разности (вместо уменьшаемого)
;
; Используются регистры: все, сохраняются (HL) и (DE)
; Глубина стека - 3
; Оценка: длина - , время - 

INT64SUB:
    PUSH    D       ;сохраняем адреса УМ и ВЧ
    PUSH    H
    LDAX    D       ;чтение 0-го байта ВЧ
    CMA             ;инверсия
    ADI     $01     ;дополнение
    MOV     C,A     ;сохранить в (С)
    MVI     A,$00
    RAL
    MOV     B,A     ;сохраняем CY в (В)
    MOV     A,C     ;достаем дополненный 0-й байт ВЧ
    ADD     M       ;складываем с 0-м байтом УМ
    MOV     M,A     ;сохраняем
    MVI     A,$00
    ADC     B       ;сохраняем CY, а также перенос от дополнения 0-го байта ВЧ в (В)
    MOV     B,A
    INX     D       ;переходим к 1-м байтам ВЧ и УМ
    INX     H
    MVI     A,$06   ;устанавливаем количество повторений цикла
int64sub_cycle:
    PUSH    PSW
    LDAX    D       ;читаем байт ВЧ
    CMA             ;инверсия
    ADD     B       ;добавляем флаги
    MOV     C,A     ;сохраняем в (С)
    MVI     A,$00
    RAL
    MOV     B,A     ;сохраняем CY в (В)
    MOV     A,C     ;достаем дополненный байт ВЧ
    ADD     M       ;складываем с байтом УМ
    MOV     M,A     ;сохраняем
    MVI     A,$00
    ADC     B       ;сохраняем CY, а также перенос от дополнения байта ВЧ в (В)
    MOV     B,A
    INX     D       ;переходим к следующим байтам ВЧ и УМ
    INX     H
    pop     psw
    DCR     A
    JNZ     int64sub_cycle
    LDAX    D       ;читаем 7 байт ВЧ
    CMA             ;инверсия
    ADD     B       ;добавляем флаги
    MOV     C,A     ;сохраняем в (С)
    MVI     A,$00
    RAL
    MOV     B,A     ;сохраняем CY в (В)
    MOV     A,C     ;достаем дополненный 7 байт ВЧ
    ADD     M       ;складываем с 7 байтом УМ
    MOV     M,A     ;сохраняем
    POP     H       ;выгружаем адреса УМ и ВЧ
    POP     D
    RET



; INT32MUL - умножение 32-р чисел
;
; Входные данные: (HL) - адрес множимого, (DE) - адрес множителя
; Выходные данные: (HL) - адрес суммы (вместо СЛ1)
;
; Используются регистры: AF,B,DE,HL. Cохраняются (HL) и (DE)
; Оценка: длина - , время - 

INT32MUL:
;сохраняем адрес множителя и множимого в стеке
    PUSH    D
    PUSH    H
;Очистка выходного буфера
    LHLD    out
    MVI     A,$00
    MOV     M,A
    INX     H
    MOV     M,A
    INX     H
    MOV     M,A
    INX     H
    MOV     M,A
    INX     H
    MOV     M,A
    INX     H
    MOV     M,A
    INX     H
    MOV     M,A
    INX     H
    MOV     M,A
;выгружаем адрес множителя и множимого из стека
    POP     H
    POP     D
;Приступаем к главной части
;<Байты_10>----------------------
;D*H
    CALL    int32mul_summon
;<Байты_21>----------------------
    CALL    int32mul_rlbpos
;C*H
    INX     D
    CALL    int32mul_summon
;D*H
    DCX     D
    INX     H
    CALL    int32mul_summon
;<Байты_32>----------------------
    CALL    int32mul_rlbpos
;C*G
    INX     D
    CALL    int32mul_summon
;B*H
    INX     D
    DCX     H
    CALL    int32mul_summon
;D*F
    DCX     D
    DCX     D
    INX     H
    INX     H
    CALL    int32mul_summon
;<Байты_43>----------------------
    CALL    int32mul_rlbpos
;C*F
    INX     D
    CALL    int32mul_summon
;B*G
    INX     D
    DCX     H
    CALL    int32mul_summon
;A*H
    INX     D
    DCX     H
    CALL    int32mul_summon
;D*E
    DCX     D
    DCX     D
    DCX     D
    INX     H
    INX     H
    INX     H
    CALL    int32mul_summon
;<Байты_54>----------------------
    CALL    int32mul_rlbpos
;C*E
    INX     D
    CALL    int32mul_summon
;B*F
    INX     D
    DCX     H
    CALL    int32mul_summon
;A*G
    INX     D
    DCX     H
    CALL    int32mul_summon
;<Байты_65>----------------------
    CALL    int32mul_rlbpos
;A*F
    INX     H
    CALL    int32mul_summon
;B*E
    DCX     D
    INX     H
    CALL    int32mul_summon
;<Байты_76>----------------------
    CALL    int32mul_rlbpos
;A*E
    INX     D
    CALL    int32mul_summon
  
    POP     H    ;выгружаем адрес множителя в (DE)
    POP     D    ;выгружаем адрес множимого в (HL)
    INX     H    ;переходим к СТБ множимого
    INX     H
    INX     H
    MOV     A,M  ;достаем старший байт
    ANI     $80  ;выделяем бит знака
    MOV     C,A  ;сохраняем бит знака множимого в (С)
    MOV     A,M  ;достаем старший байт
    ANI     $7F  ;очищаем бит знака
;    MOV     M,A  
    INX     D
    INX     D
    INX     D
    LDAX    D
    MOV     B,A
    ANI     $7F
    STAX    D
    mov     a,b
    ANI     $80
    XRA     C
    RZ
    LHLD    out
    INX     H
    ora     m
    MOV     M,A
    RET

int32mul_summon:
    LDAX    D
    mov     b,m
    PUSH    D
    PUSH    H
    mov     e,b
;Быстрое умножение: операнды (A) и (E), результат (HL)
    LXI     H,$0000
    MVI     D,$00
    MVI     C,$08   ;кол-во повторений
cycle:
    RAR         ;сдвиг вправо
    JNC     int32mul_1   ;если перенос, добавляем (DE) к (HL)
    DAD     D
int32mul_1:
    XCHG        ;сдвиг (DE) влево
    DAD     H
    XCHG
    DCR     C
    JNZ     cycle   ;зацикливание
    XCHG
    LHLD    out
    mov     a,e
    ADD     M
    MOV     M,A
    INX     H
    mov     a,d
    ADC     M
    MOV     M,A
    POP     H
    POP     D
    RET
int32mul_rlbpos:  ;сдвиг влtdj
    PUSH    H
    LHLD    out
    INX     H
    SHLD    out
    POP     H
    RET

