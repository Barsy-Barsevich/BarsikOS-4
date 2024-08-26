; BIOS defines

;Количество тиков таймера за 1 миллисекунду
    .DEF    CLT_Ticks_Per_Ms =     $0258   ;600


;--<System port (parallel)>-----------------------------------------------------
    .DEF    SYSTEM_PORT_INI =       $03
    .DEF    SYSTEM_PORT_A =         $00
    .DEF    SYSTEM_PORT_B =         $02
    .DEF    SYSTEM_PORT_C =         $01
;--<Parallel user port>---------------------------------------------------------
    .DEF    PARALLEL_PORT_INI =     $07
    .DEF    PARALLEL_PORT_A =       $04
    .DEF    PARALLEL_PORT_B =       $06
    .DEF    PARALLEL_PORT_C =       $05
;--<Timer0>---------------------------------------------------------------------
    .DEF    TIMER0_PORT_MODE =      $0B
    .DEF    TIMER0_PORT_0 =         $08
    .DEF    TIMER0_PORT_1 =         $09
    .DEF    TIMER0_PORT_2 =         $0A
;--<Timer1>---------------------------------------------------------------------
    .DEF    TIMER1_PORT_MODE =      $0F
    .DEF    TIMER1_PORT_0 =         $0C
    .DEF    TIMER1_PORT_1 =         $0D
    .DEF    TIMER1_PORT_2 =         $0E
;--<PIC0 (master)>--------------------------------------------------------------
    .DEF    PIC0_PORT_A0 =          $10
    .DEF    PIC0_PORT_A1 =          $11
;--<PIC1 (slave)>---------------------------------------------------------------
    .DEF    PIC1_PORT_A0 =          $14
    .DEF    PIC1_PORT_A1 =          $15
;--<USART0>---------------------------------------------------------------------
    .DEF    USART0_PORT_DATA =      $18
    .DEF    USART0_PORT_COM =       $19
;--<USART1>---------------------------------------------------------------------
    .DEF    USART1_PORT_DATA =      $1C
    .DEF    USART1_PORT_COM =       $1D
;--<Keyboard & Mouse>-----------------------------------------------------------
    .DEF    KM_PORT_0 =             $20
    .DEF    KM_PORT_1 =             $21
    .DEF    KM_PORT_2 =             $22
    .DEF    KM_PORT_3 =             $23
;--<Display RA6963, 8-bit parallel interface>-----------------------------------
    .DEF    DISP_PORT_DATA =        $24
    .DEF    DISP_PORT_COM =         $25
    




;--<System port A>--------------------------------------------------------------
    .DEF    SYSTEM_PORT_A_SY0 =         $01
    .DEF    SYSTEM_PORT_A_NSY0 =        $FE
    .DEF    SYSTEM_PORT_A_SY2 =         $02
    .DEF    SYSTEM_PORT_A_NSY2 =        $FD
    .DEF    SYSTEM_PORT_A_SY3 =         $04
    .DEF    SYSTEM_PORT_A_NSY3 =        $FB
    .DEF    SYSTEM_PORT_A_SY4 =         $08
    .DEF    SYSTEM_PORT_A_NSY4 =        $F7
    .DEF    SYSTEM_PORT_A_SY5 =         $10
    .DEF    SYSTEM_PORT_A_NSY5 =        $EF
    .DEF    SYSTEM_PORT_A_SY6 =         $20
    .DEF    SYSTEM_PORT_A_NSY6 =        $DF
    .DEF    SYSTEM_PORT_A_MS0 =         $40
    .DEF    SYSTEM_PORT_A_NMS0 =        $BF
    .DEF    SYSTEM_PORT_A_MS1 =         $80
    .DEF    SYSTEM_PORT_A_NMS1 =        $7F
;--<System port B>--------------------------------------------------------------
    .DEF    SYSTEM_PORT_B_MOSI =        $01
    .DEF    SYSTEM_PORT_B_NMOSI =       $FE
    .DEF    SYSTEM_PORT_B_SCK =         $02
    .DEF    SYSTEM_PORT_B_NSCK =        $FD
    .DEF    SYSTEM_PORT_B_LEDLINE_CS =  $04
    .DEF    SYSTEM_PORT_B_NLEDLINE_CS = $FB
    .DEF    SYSTEM_PORT_B_PT0 =         $08
    .DEF    SYSTEM_PORT_B_NPT0 =        $F7
    .DEF    SYSTEM_PORT_B_PT1 =         $10
    .DEF    SYSTEM_PORT_B_NPT1 =        $EF
    .DEF    SYSTEM_PORT_B_PT2 =         $20
    .DEF    SYSTEM_PORT_B_NPT2 =        $DF
    .DEF    SYSTEM_PORT_B_AU0 =         $40
    .DEF    SYSTEM_PORT_B_NAU0 =        $BF
    .DEF    SYSTEM_PORT_B_AU1 =         $80
    .DEF    SYSTEM_PORT_B_NAU1 =        $7F
;--<System port C>--------------------------------------------------------------
    .DEF    SYSTEM_PORT_C_TURBO =       $01
    .DEF    SYSTEM_PORT_C_NTURBO =      $FE
    .DEF    SYSTEM_PORT_C_WB =          $02
    .DEF    SYSTEM_PORT_C_NWB =         $FD
    .DEF    SYSTEM_PORT_C_CLKE =        $04
    .DEF    SYSTEM_PORT_C_NCLKE =       $FB
    .DEF    SYSTEM_PORT_C_SY1 =         $08
    .DEF    SYSTEM_PORT_C_NSY1 =        $F7
    .DEF    SYSTEM_PORT_C_REQ =         $10
    .DEF    SYSTEM_PORT_C_NREQ =        $EF
    .DEF    SYSTEM_PORT_C_PRIORITY =    $20
    .DEF    SYSTEM_PORT_C_NPRIORITY =   $DF
    .DEF    SYSTEM_PORT_C_CONF =        $40
    .DEF    SYSTEM_PORT_C_NCONF =       $BF
    .DEF    SYSTEM_PORT_C_MISO =        $80
    .DEF    SYSTEM_PORT_C_NMISO =       $7F
;--<Software SPI>---------------------------------------------------------------
    .DEF    MOSI_PORT =                 SYSTEM_PORT_B
    .DEF    SCK_PORT =                  SYSTEM_PORT_B
    .DEF    MOSI_SCK_PORT =             SYSTEM_PORT_B
    .DEF    MISO_PORT =                 SYSTEM_PORT_C
    
















    
    
