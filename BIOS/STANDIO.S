; Standart I/O

; (E)  Barsotion KY;
; Стандартный SPI обмен v1.2 (проверено 11.07.23)
; Функция реализует протокол SPI программно. ЭВМ в данном случае выступает
; в роли master'a.
; Выводы порта:
; Порт SSPI_PORT (тип 'С' ИС 8255), инициализирован так, что старшая тетрада
; на ввод, младшая на вывод.
; С(0) -- MOSI
; С(1) -- CLK
; С(7) -- MISO
; Ввод:    А (передаваемые данные)
; Вывод:   А (принимаемые данные)
; Используемые регистры: А, B, C
; Используемая память: нет
; Длина: 31 байт
; Время выполнения: 812 (+-4) тактов.

BIOS_SPI_EX:
;регистр С - счетчик
        MVI         C,08H
spi_1:
;сдвиг data влево, сдвинутый бит в 0й разряд B (это будет MOSI)
        ADD         A
        PUSH        PSW
        MVI         A,00H
        RAL
        MOV         B,A
;выводим MOSI в порт SSPI_PORT, CLK равен 0
        IN          MOSI_SCK_PORT
        ANI         FDH             ;очистка CLK
        OUT         MOSI_SCK_PORT
        ANI         FCH             ;очистка CLK и MOSI
        ORA         B               ;загрузка MOSI
        OUT         MOSI_SCK_PORT
;поднимаем CLK и выводим вместе с ним
        ORI         02H
        OUT         MOSI_SCK_PORT
;байт данных в B
        POP         PSW
        MOV         B,A
;читаем порт SSPI_PORT, бит MISO во флаг переноса
        IN          MISO_PORT
        ADD         A
;добавляем MISO к data, заместо пустого старшего бита
        MOV         A,B
        ACI         00H
;счетчик
        DCR         C
        JNZ         spi_1
        MOV         B,A
;опускаем CLK и поднимаем MOSI
        IN          MOSI_SCK_PORT
        ANI         FDH
        ORI         01H
        OUT         MOSI_SCK_PORT
        MOV         A,B
        RET



; (E) Barsotion KY
; Функция MacroDelay (добавлена для совместимости с ПО BarsikOS1.1)
; Используется для организации программных задержек.
; Время задержки рассчитывается по формуле: t = (20*A+25)/fтакт мкс
; Ввод: А
; Вывод: нет
; Используемые регистры: АF
; Используемая память: нет
; Длина: 5 байт
; Время выполнения: 20*A+25 тактов
BIOS_MacroDelay:
; в А - операнд
        SUI         01H
        JNZ         MacroDelay
        RET



; (E) Barsotion KY
; Функция DELAY_MS - программная задержка
; t = (5009*HL+7)*1000/fтакт мс
; t = HL миллисекунд при fтакт = 5.0 МГц
; Ввод:    HL (время в мс)
; Вывод:   нет
; Используемые регистры: АF,DE,HL
; Используемая память: нет
; Длина: 16 байт
; Время выполнения: ~HL мкс при тактовой частоте 
BIOS_DelayMs:
        LXI         D,$00B2
delay_1:
        DCX         D
        MOV         A,D
        ORA         E
        JNZ         delay_1
        DCX         H
        MOV         A,H
        ORA         L
        JNZ         DELAY_MS
        RET
