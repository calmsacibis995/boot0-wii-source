         ; reset vectors
FFFF0000                 LDR     PC, =_start
FFFF0004                 LDR     PC, =__arm_undefined_handler
FFFF0008                 LDR     PC, =__arm_syscall_handler
FFFF000C                 LDR     PC, =__arm_prefetch_abort_handler
FFFF0010                 LDR     PC, =__arm_data_abort_handler
FFFF0014                 LDR     PC, =__arm_reserved_handler
FFFF0018                 LDR     PC, =__arm_irq_handler
FFFF001C                 LDR     PC, =__arm_fiq_handler
FFFF001C ; ---------------------------------------------------------------------------
FFFF0020 off_FFFF0020    DCD _start               ; DATA XREF: FFFF0000
FFFF0024 off_FFFF0024    DCD __arm_undefined      ; DATA XREF: FFFF0004
FFFF0028 off_FFFF0028    DCD __arm_syscall        ; DATA XREF: FFFF0008
FFFF002C off_FFFF002C    DCD __arm_prefetch_abort ; DATA XREF: FFFF000C
FFFF0030 off_FFFF0030    DCD __arm_data_abort     ; DATA XREF: FFFF0010
FFFF0034 off_FFFF0034    DCD __arm_reserved       ; DATA XREF: FFFF0014
FFFF0038 off_FFFF0038    DCD __arm_irq            ; DATA XREF: FFFF0018
FFFF003C off_FFFF003C    DCD __arm_fiq            ; DATA XREF: FFFF001C
FFFF0040 ; =============== S U B R O U T I N E =======================================
FFFF0040 _start                                  ; CODE XREF: FFFF0000 FFFF001C
FFFF0040                                         ; DATA XREF: off_FFFF0020
FFFF0040                 MOV     R1, #0
FFFF0044                 MOV     R4, #0
FFFF0048                 MOV     R11, #0
FFFF004C                 MOV     R11, #0
FFFF0050                 MOV     LR, #0
FFFF0054                 LDR     SP, =0xD417C00  ; set stack pointer to top of SRAM
FFFF0058                 BL      _main
FFFF005C                 BL      panic           ; should never be reached
FFFF005C ; End of function _start
         ; All of the other vector handlers just hang
FFFF0060 __arm_undefined_handler
FFFF0060                 B       __arm_undefined_handler
FFFF0064 __arm_syscall_handler
FFFF0064                 B       __arm_syscall_handler
FFFF0068 __arm_prefetch_abort_handler
FFFF0068                 B       __arm_prefetch_abort_handler
FFFF006C __arm_data_abort_handler
FFFF006C                 B       __arm_data_abort_handler
FFFF0070 __arm_reserved_handler
FFFF0070                 B       __arm_reserved_handler
FFFF0074 __arm_irq_handler
FFFF0074                 B       __arm_irq_handler
FFFF0078 __arm_fiq_handler
FFFF0078                 B       __arm_fiq_handler
FFFF007C _main                                   ; CODE XREF: _start+18
FFFF007C                 B       main
FFFF0080 boot0_stack     DCD 0xD417C00           ; DATA XREF: _start+14
FFFF0084 ; =============== S U B R O U T I N E =======================================
FFFF0084 debug_port_output                       ; CODE XREF: panic+14 panic+28 main+170 ...
FFFF0084                 MOV     R3, #0xD800000
FFFF0088                 LDR     R2, [R3,#0xE0]
FFFF008C                 MOV     R0, R0,LSL#16
FFFF0090                 BIC     R2, R2, #0xFF0000
FFFF0094                 AND     R0, R0, #0xFF0000
FFFF0098                 ORR     R2, R2, R0
FFFF009C                 STR     R2, [R3,#0xE0]   ; output 8 bits to the 8 GPIOs at 0xD8000E0
FFFF00A0                 BX      LR
FFFF00A0 ; End of function debug_port_output
FFFF00A4 ; =============== S U B R O U T I N E =======================================
FFFF00A4 ; int __stdcall panic(unsigned __int8 error)
FFFF00A4 panic                                   ; CODE XREF: _start+1C main+3B8 main+3D4
FFFF00A4                 MOV     R12, SP
FFFF00A8                 STMFD   SP!, {R4,R11,R12,LR,PC}
FFFF00AC                 SUB     R11, R12, #4
FFFF00B0                 MOV     R4, R0
FFFF00B4 loc_FFFF00B4                            ; CODE XREF: panic+38
FFFF00B4                 MOV     R0, R4          ; alternate between 0 and the error code
FFFF00B8                 BL      debug_port_output
FFFF00BC                 MOVL    R0, 1000000
FFFF00C4                 BL      delay
FFFF00C8                 MOV     R0, #0
FFFF00CC                 BL      debug_port_output
FFFF00D0                 MOVL    R0, 1000000
FFFF00D8                 BL      delay
FFFF00DC                 B       loc_FFFF00B4    ; infinite loop
FFFF00DC ; End of function panic
FFFF00E0 ; =============== S U B R O U T I N E =======================================
FFFF00E0 init_gpio_direction                       ; CODE XREF: main+104
FFFF00E0                 MOV     R3, #0xD800000    ; configure GPIO direction registers
FFFF00E4                 LDR     R2, [R3,#0xDC]
FFFF00E8                 AND     R2, R2, #0xFF000000
FFFF00EC                 ORR     R2, R2, #0xFF0000
FFFF00F0                 STR     R2, [R3,#0xDC]    ; D8000DC = (D8000DC & 0xff000000) | 0x00ff0000
FFFF00F4                 LDR     R2, [R3,#0xE4]
FFFF00F8                 AND     R2, R2, #0xFF000000
FFFF00FC                 ORR     R2, R2, #0xFF0000
FFFF0100                 STR     R2, [R3,#0xE4]    ; D8000E4 = (D8000E4 & 0xff000000) | 0x00ff0000
FFFF0104                 BX      LR
FFFF0104 ; End of function init_gpio_direction
FFFF0108 ; =============== S U B R O U T I N E =======================================
FFFF0108 main                              ; CODE XREF: _main
FFFF0108                 MOV     R12, SP
FFFF010C                 STMFD   SP!, {R4-R12,LR,PC}
FFFF0110                 MOV     R3, #0xD000000
FFFF0114                 SUB     R11, R12, #4
FFFF0118                 ADD     R3, R3, #0x20000 ; R3 = 0D020000 = AES command reg
FFFF011C                 MOV     R9, #0
FFFF0120                 MOV     R1, #7
FFFF0124                 MOV     R2, #0xD800000
FFFF0128                 SUB     SP, SP, #0x2C
FFFF012C                 STR     R1, [R2,#0x60]  ; 0D800060 = 7
FFFF0130                 SUB     R2, R11, #0x54
FFFF0134                 STR     R9, [R3]         ; write 0 to AES command reg
FFFF0138                 LDR     R1, =boot1_key
FFFF013C                 STR     R9, [R2]
FFFF0140                 MOV     R0, R3
FFFF0144                 MOV     LR, #0xD400000
FFFF0148                 MOV     R2, #3
FFFF014C set_AES_key                             ; CODE XREF: main+50
FFFF014C                 LDR     R3, [R1],#4     ; use hardcoded boot1 key
FFFF0150                 SUBS    R2, R2, #1
FFFF0154                 STR     R3, [R0,#0xC]
FFFF0158                 BPL     set_AES_key
FFFF015C                 MOV     R12, #0xD000000
FFFF0160                 LDR     R1, =boot1_iv   ; boot1_iv is all zeroes
FFFF0164                 ADD     R12, R12, #0x20000
FFFF0168                 MOV     R2, #3
FFFF016C set_AES_iv                              ; CODE XREF: main+70
FFFF016C                 LDR     R3, [R1],#4
FFFF0170                 SUBS    R2, R2, #1
FFFF0174                 STR     R3, [R12,#0x10]
FFFF0178                 BPL     set_AES_iv
FFFF017C                 LDR     R3, =0x67452301 ; set initial SHA context
FFFF0180                 MOVL    R1, 0xD030000
FFFF0188                 MOV     R0, #0
FFFF018C                 LDR     R2, =0xEFCDAB89
FFFF0190                 STR     LR, [R12,#4]
FFFF0194                 STR     LR, [R12,#8]
FFFF0198                 STR     R0, [R1]
FFFF019C                 STR     R3, [R1,#8]
FFFF01A0                 LDR     R3, =0x98BADCFE
FFFF01A4                 STR     R2, [R1,#0xC]
FFFF01A8                 LDR     R2, =0x10325476
FFFF01AC                 STR     R3, [R1,#0x10]
FFFF01B0                 LDR     R3, =0xC3D2E1F0
FFFF01B4                 STR     R2, [R1,#0x14]
FFFF01B8                 MOV     R2, #0xD400000
FFFF01BC                 STR     R3, [R1,#0x18]
FFFF01C0                 STR     R2, [R1,#4]
FFFF01C4                 MOVL    R3, 0xD010000
FFFF01CC                 LDR     R2, [R3,#4]
FFFF01D0                 MOVL    R1, 0x80FF0000
FFFF01D8                 ORR     R2, R2, #0x8000000
FFFF01DC                 ADD     R1, R1, #0x8000
FFFF01E0                 STR     R2, [R3,#4]
FFFF01E4                 MOV     R4, #0xD800000
FFFF01E8                 STR     R0, [R3,#0x10]
FFFF01EC                 STR     R0, [R3,#0x14]
FFFF01F0                 STR     R0, [R3,#8]
FFFF01F4                 STR     R0, [R3,#0xC]
FFFF01F8                 STR     R1, [R3]
FFFF01FC                 MOV     R3, #0x80000000
FFFF0200                 MOV     R6, R0
FFFF0204                 STR     R3, [R4,#0x1EC] ; 0D8001EC = 0x80000000
FFFF0208                 SUB     R5, R11, #0x3C
FFFF020C                 BL      init_gpio_direction
FFFF0210                 MOV     R1, R6          ; c
FFFF0214                 MOV     R0, R5          ; dest
FFFF0218                 MOV     R2, #20         ; len
FFFF021C                 BL      memset          ; zero out hash buffer
FFFF0220                 MOV     R1, #16         ; read 20 bytes of OTP data into *R5
FFFF0224 get_otp_hash                            ; CODE XREF: main+138
FFFF0224                 AND     R3, R6, #0x1F
FFFF0228                 ORR     R3, R3, #0x80000000
FFFF022C                 STR     R3, [R4,#0x1EC] ; *starlet_otp_addr = (R6 & 0x1f) | 0x80000000;
FFFF0230                 LDR     R2, [R4,#0x1F0] ; R2 = *starlet_otp_data
FFFF0234                 SUBS    R1, R1, #4
FFFF0238                 STR     R2, [R5],#4
FFFF023C                 ADD     R6, R6, #1      ; R6++
FFFF0240                 BPL     get_otp_hash
FFFF0244                 MOV     R1, #0
FFFF0248                 SUB     R2, R11, #0x28
FFFF024C is_otp_hash_empty?                      ; CODE XREF: main+15C
FFFF024C                 LDR     R3, [R2,#-0x14] ; if OTP hash is all zeroes, then we're still
FFFF0250                 CMP     R3, #0          ; in the factory with a blank OTP, so
FFFF0254                 ADD     R1, R1, #1      ; don't verify the hash against boot1
FFFF0258                 ADD     R2, R2, #4
FFFF025C                 BNE     otp_hash_not_empty
FFFF0260                 CMP     R1, #4
FFFF0264                 BLS     is_otp_hash_empty?
FFFF0268 loc_FFFF0268                              ; CODE XREF: main+3CC
FFFF0268                 MOVL    R8, 0xD010000
FFFF0270                 MOV     R4, #0            ; R4 = flash page number
FFFF0274 boot1_read_loop                           ; CODE XREF: main+2F0
FFFF0274                 MOV     R0, R4            ; as we read in the flash pages, output
FFFF0278                 BL      debug_port_output ; each page number to the debug port
FFFF027C                 ORR     R0, R4, #0x80     ; hi bit is a strobe bit
FFFF0280                 BL      debug_port_output
FFFF0284 loc_FFFF0284                              ; CODE XREF: main+184
FFFF0284                 LDR     R3, [R8]          ; R3 = *0D100000 = NAND status
FFFF0288                 CMP     R3, #0
FFFF028C                 BLT     loc_FFFF0284      ; wait for command to complete
FFFF0290                 CMP     R4, #47           ; pageno > 47?
FFFF0294                 BCS     done_reading_flash
FFFF0298                 MOV     R3, #0x9F000000
FFFF029C                 STR     R4, [R8,#0xC]
FFFF02A0                 STR     R3, [R8]
FFFF02A4                 MOVL    R0, 0xD010000      ; D010000 = NAND Flash HW
FFFF02AC read_flash_page                            ; CODE XREF: main+1AC
FFFF02AC                 LDR     R3, [R0]           ; wait for non-busy status from NAND flash
FFFF02B0                 CMP     R3, #0
FFFF02B4                 BLT     read_flash_page
FFFF02B8                 AND     R3, R4, #1
FFFF02BC                 MOV     R3, R3,LSL#7
FFFF02C0                 MOV     R1, #0x80000000
FFFF02C4                 ADD     R3, R3, #0xD400000 
FFFF02C8                 ADD     R1, R1, #0x308000  ; 0x30 = READ PAGE
FFFF02CC                 MOV     R2, R4,LSL#11
FFFF02D0                 ADD     R2, R2, #0xD400000
FFFF02D4                 ADD     R3, R3, #0x17800   ; read into 0xD417800
FFFF02D8                 ADD     R1, R1, #0x3840 
FFFF02DC                 STR     R2, [R0,#0x10]
FFFF02E0                 STR     R3, [R0,#0x14]
FFFF02E4                 STR     R1, [R0]           ; send flash command
FFFF02E8 done_reading_flash                      ; CODE XREF: main+18C
FFFF02E8                 MOVL    R2, 0xD020000   ; D020000 = AES hw
FFFF02F0 loc_FFFF02F0                            ; CODE XREF: main+1F0
FFFF02F0                 LDR     R3, [R2]
FFFF02F4                 CMP     R3, #0          ; wait for non-busy status from AES
FFFF02F8                 BLT     loc_FFFF02F0
FFFF02FC                 CMP     R4, #0
FFFF0300                 BEQ     loc_FFFF03D0
FFFF0304                 CMP     R4, #47
FFFF0308                 BHI     loc_FFFF03D0
FFFF030C                 SUB     R2, R4, #1
FFFF0310                 AND     R3, R2, #1
FFFF0314                 MOV     R3, R3,LSL#7
FFFF0318                 ADD     R6, R3, #0xD400000
FFFF031C                 MOV     R2, R2,LSL#11
FFFF0320                 MOV     R10, #0xFF0
FFFF0324                 ADD     R6, R6, #0x17800
FFFF0328                 ADD     R10, R10, #0xF
FFFF032C                 ADD     R5, R2, #0xD400000
FFFF0330                 MOV     R7, #0
FFFF0334 calc_ecc                                ; CODE XREF: main+2A4
FFFF0334                 MOV     R2, R7,LSL#2    ; this code takes the hardware-generated ECC syndrome
FFFF0338                 ADD     R3, R6, #0x30   ; from the NAND flash interface, and uses it to try to
FFFF033C                 LDR     R12, [R3,R2]    ; correct single-bit errors in boot1.
FFFF0340                 ADD     R0, R6, R2      ; If we hit more than one error per 512 bytes, we're screwed.
FFFF0344                 AND     R1, R12, #0xFF0000
FFFF0348                 LDR     R2, [R0,#0x40]
FFFF034C                 MOV     R1, R1,LSR#8
FFFF0350                 AND     R3, R12, #0xFF00
FFFF0354                 ORR     R1, R1, R12,LSR#24
FFFF0358                 ORR     R1, R1, R3,LSL#8
FFFF035C                 AND     R3, R2, #0xFF0000
FFFF0360                 MOV     R3, R3,LSR#8
FFFF0364                 ORR     R3, R3, R2,LSR#24
FFFF0368                 AND     R0, R2, #0xFF00
FFFF036C                 ORR     R3, R3, R0,LSL#8
FFFF0370                 CMP     R12, R2
FFFF0374                 ORR     R12, R1, R12,LSL#24
FFFF0378                 ORR     R2, R3, R2,LSL#24
FFFF037C                 EOR     R12, R12, R2
FFFF0380                 SUB     R1, R12, #1
FFFF0384                 BEQ     loc_FFFF03A0
FFFF0388                 MOV     R3, R12,LSL#20
FFFF038C                 MOV     R3, R3,LSR#20
FFFF0390                 MOV     R2, R12,LSR#16
FFFF0394                 TST     R1, R12
FFFF0398                 EOR     R3, R2, R3
FFFF039C                 BNE     uncorrectable_ecc_error
FFFF03A0 loc_FFFF03A0                            ; CODE XREF: main+27C main+3B4 main+3BC
FFFF03A0                 ADD     R7, R7, #1
FFFF03A4                 CMP     R7, #4
FFFF03A8                 ADD     R5, R5, #0x200
FFFF03AC                 BCC     calc_ecc
FFFF03B0                 MOV     R1, #0x98000000
FFFF03B4                 ADD     R2, R1, #0x1040
FFFF03B8                 MOV     R3, #0xD000000
FFFF03BC                 CMP     R4, #1
FFFF03C0                 ADD     R2, R2, #0x3F
FFFF03C4                 ADD     R3, R3, #0x20000
FFFF03C8                 ADDEQ   R2, R1, #0x7F
FFFF03CC                 STR     R2, [R3]
FFFF03D0 loc_FFFF03D0                            ; CODE XREF: main+1F8 main+200
FFFF03D0                 MOVL    R2, 0xD030000   ; D030000 = SHA1 HW
FFFF03D8 loc_FFFF03D8                            ; CODE XREF: main+2D8
FFFF03D8                 LDR     R3, [R2]
FFFF03DC                 CMP     R3, #0          ; wait for SHA1 non-busy status
FFFF03E0                 BLT     loc_FFFF03D8
FFFF03E4                 CMP     R4, #1
FFFF03E8                 MOVHI   R3, #0x8000001F
FFFF03EC                 ADD     R4, R4, #1
FFFF03F0                 STRHI   R3, [R2]         ; update SHA1 context
FFFF03F4                 CMP     R4, #48
FFFF03F8                 BLS     boot1_read_loop
FFFF03FC                 MOVL    R2, 0xD030000
FFFF0404 done_reading_boot1                        ; CODE XREF: main+304
FFFF0404                 LDR     R3, [R2]
FFFF0408                 CMP     R3, #0            ; wait for SHA1 non-busy status
FFFF040C                 BLT     done_reading_boot1
FFFF0410                 SUB     R3, R11, #0x54    ; Was OTP hash zero?
FFFF0414                 LDR     R3, [R3]
FFFF0418                 CMP     R3, #0
FFFF041C                 BEQ     jump_boot1
FFFF0420                 MOVL    R0, 0xD030000
FFFF0428                 ADD     R0, R0, #8
FFFF042C                 MOV     R1, #0
FFFF0430                 SUB     R2, R11, #0x28
FFFF0434 loc_FFFF0434                            ; CODE XREF: main+340
FFFF0434                 LDR     R3, [R0,R1,LSL#2]
FFFF0438                 ADD     R1, R1, #1
FFFF043C                 CMP     R1, #4
FFFF0440                 STR     R3, [R2,#-0x28]
FFFF0444                 ADD     R2, R2, #4
FFFF0448                 BLS     loc_FFFF0434
FFFF044C                 SUB     R0, R11, #0x28
FFFF0450                 MOV     R1, #4
FFFF0454 compare_hashes                          ; CODE XREF: main+364
FFFF0454                 LDR     R2, [R0,#-0x14]
FFFF0458                 LDR     R3, [R0,#-0x28]
FFFF045C                 CMP     R2, R3
FFFF0460                 MOVNE   R9, #1
FFFF0464                 SUBS    R1, R1, #1
FFFF0468                 ADD     R0, R0, #4
FFFF046C                 BPL     compare_hashes
FFFF0470                 CMP     R9, #0
FFFF0474                 BNE     hash_fail
FFFF0478 jump_boot1                              ; CODE XREF: main+314 main+3D8
FFFF0478                 MOV     R0, #0xA
FFFF047C                 BL      debug_port_output ; output 0x0A
FFFF0480                 MOV     R0, #0x88
FFFF0484                 BL      debug_port_output ; output 0x88
FFFF0488                 LDR     PC, =0xFFF00000   ; jump to BOOT1 (this is aliased to 0x0D400000)
FFFF048C ; ---------------------------------------------------------------------------
FFFF048C                 SUB     SP, R11, #0x28    ; return code generated by compiler
FFFF0490                 LDMFD   SP, {R4-R11,SP,PC}; (unreachable)
FFFF0494 ; ---------------------------------------------------------------------------
FFFF0494 uncorrectable_ecc_error                   ; CODE XREF: main+294
FFFF0494                 BIC     R1, R2, #7
FFFF0498                 MOV     R1, R1,LSL#20
FFFF049C                 CMP     R3, R10
FFFF04A0                 MOV     R1, R1,LSR#20
FFFF04A4                 AND     R12, R2, #7
FFFF04A8                 LDREQB  R2, [R5,R1,ASR#3]
FFFF04AC                 MOVEQ   R3, #1
FFFF04B0                 EOREQ   R2, R2, R3,LSL R12
FFFF04B4                 MOV     R0, #0xF1 ; error F1
FFFF04B8                 STREQB  R2, [R5,R1,ASR#3]
FFFF04BC                 BEQ     loc_FFFF03A0
FFFF04C0                 BL      panic            ; panic code F1 = ECC failure
FFFF04C4                 B       loc_FFFF03A0
FFFF04C8 ; ---------------------------------------------------------------------------
FFFF04C8 otp_hash_not_empty                       ; CODE XREF: main+154
FFFF04C8                 MOV     R2, #1
FFFF04CC                 SUB     R3, R11, #0x54
FFFF04D0                 STR     R2, [R3]         ; set a flag indicating that the otp hash is valid
FFFF04D4                 B       loc_FFFF0268
FFFF04D8 ; ---------------------------------------------------------------------------
FFFF04D8 hash_fail                               ; CODE XREF: main+36C
FFFF04D8                 MOV     R0, #0xF2       ; error F2 = OTP mismatch
FFFF04DC                 BL      panic
FFFF04E0                 B       jump_boot1
FFFF04E0 ; ---------------------------------------------------------------------------
FFFF04E4 off_FFFF04E4    DCD boot1_key           ; DATA XREF: main+30
FFFF04E8 off_FFFF04E8    DCD boot1_iv            ; DATA XREF: main+58
FFFF04EC kSHA1_0         DCD 0x67452301          ; DATA XREF: main+74
FFFF04F0 kSHA1_1         DCD 0xEFCDAB89          ; DATA XREF: main+84
FFFF04F4 kSHA1_2         DCD 0x98BADCFE          ; DATA XREF: main+98
FFFF04F8 kSHA1_3         DCD 0x10325476          ; DATA XREF: main+A0
FFFF04FC kSHA1_4         DCD 0xC3D2E1F0          ; DATA XREF: main+A8
FFFF0500 boot1_entrypt   DCD 0xFFF00000          ; DATA XREF: main+380
FFFF0504                 DCB 0
FFFF0505 a_GCCGNU3_4_3   DCB "GCC: (GNU) 3.4.3",0 ; garbage inserted by compiler lol?
FFFF0516                 DCB 0, 0
FFFF0518 ; =============== S U B R O U T I N E =======================================
FFFF0518 unused1
FFFF0518                 BIC     R0, R0, #0x35000000
FFFF051C                 BIC     R0, R0, #0x10000
FFFF0520                 MOVL    R3, 0xFFFFFFC
FFFF0524                 SUB     R3, R3, #0x2BC0000
FFFF0528                 ORR     R0, R0, #0xCA000000
FFFF052C                 SUB     R3, R3, #0x28000
FFFF0530                 ORR     R0, R0, #0xFE0000
FFFF0534                 STR     R0, [R3]
FFFF0538                 MOV     R0, #0
FFFF053C                 B       unused11
FFFF053C ; End of function unused1
FFFF0540 ; =============== S U B R O U T I N E =======================================
FFFF0540 unused2
FFFF0540                 BIC     R0, R0, #0x45000000
FFFF0544                 BIC     R0, R0, #0x2F0000
FFFF0548                 MOVL    R3, 0xFFFFFFC
FFFF054C                 SUB     R3, R3, #0x2BC0000
FFFF0550                 ORR     R0, R0, #0xBA000000
FFFF0554                 SUB     R3, R3, #0x28000
FFFF0558                 ORR     R0, R0, #0xD00000
FFFF055C                 STR     R0, [R3]
FFFF0560                 MOV     R0, #1
FFFF0564                 B       unused12
FFFF0564 ; End of function unused2
FFFF0568 ; =============== S U B R O U T I N E =======================================
FFFF0568 unused3
FFFF0568                 STR     R1, [R0]
FFFF056C                 BX      LR
FFFF056C ; End of function unused3
FFFF0570 ; =============== S U B R O U T I N E =======================================
FFFF0570 unused4
FFFF0570                 LDR     R0, [R0]
FFFF0574                 BX      LR
FFFF0574 ; End of function unused4
FFFF0578 ; =============== S U B R O U T I N E =======================================
FFFF0578 unused5
FFFF0578                 STRH    R1, [R0]
FFFF057C                 BX      LR
FFFF057C ; End of function unused5
FFFF0580 ; =============== S U B R O U T I N E =======================================
FFFF0580 unused6
FFFF0580                 LDRH    R0, [R0]
FFFF0584                 BX      LR
FFFF0584 ; End of function unused6
FFFF0588 ; =============== S U B R O U T I N E =======================================
FFFF0588 delay                                   ; CODE XREF: panic+20 panic+34
FFFF0588                 CMP     R0, #0
FFFF058C                 BXEQ    LR
FFFF0590 loc_FFFF0590                            ; CODE XREF: delay+C
FFFF0590                 SUBS    R0, R0, #1
FFFF0594                 BNE     loc_FFFF0590
FFFF0598                 BX      LR
FFFF0598 ; End of function delay
FFFF059C ; =============== S U B R O U T I N E =======================================
FFFF059C unused7
FFFF059C                 STMFD   SP!, {R0-R3}
FFFF05A0                 ADD     SP, SP, #0x10
FFFF05A4                 RET
FFFF05A4 ; End of function unused7
FFFF05A8 ; =============== S U B R O U T I N E =======================================
FFFF05A8 unused8
FFFF05A8                 STMFD   SP!, {R0-R3}
FFFF05AC                 ADD     SP, SP, #0x10
FFFF05B0                 RET
FFFF05B0 ; End of function unused8
FFFF05B4 ; =============== S U B R O U T I N E =======================================
FFFF05B4 unused9
FFFF05B4                 STMFD   SP!, {R0-R3}
FFFF05B8                 ADD     SP, SP, #0x10
FFFF05BC                 RET
FFFF05BC ; End of function unused9
FFFF05C0 ; =============== S U B R O U T I N E =======================================
FFFF05C0 ; int __stdcall memset(void *dest, int c, int len)
FFFF05C0 memset                                  ; CODE XREF: main+114
FFFF05C0                 SUB     R2, R2, #1
FFFF05C4                 CMN     R2, #1
FFFF05C8                 MOV     R3, R0
FFFF05CC                 BXEQ    LR
FFFF05D0 loc_FFFF05D0                            ; CODE XREF: memset+1C
FFFF05D0                 SUB     R2, R2, #1
FFFF05D4                 CMN     R2, #1
FFFF05D8                 STRB    R1, [R3],#1
FFFF05DC                 BNE     loc_FFFF05D0
FFFF05E0                 BX      LR
FFFF05E0 ; End of function memset
FFFF05E4 ; =============== S U B R O U T I N E =======================================
FFFF05E4 ; Attributes: noreturn
FFFF05E4 unused10                                ; CODE XREF: unused11+4, unused12+4
FFFF05E4                 MCR     p15, 0, R0,c7,c0, 4
FFFF05E8 hang                                    ; CODE XREF: unused10:hang
FFFF05E8                 B       hang
FFFF05E8 ; End of function unused10
FFFF05EC ; =============== S U B R O U T I N E =======================================
FFFF05EC unused11                                ; CODE XREF: unused1+24
FFFF05EC                 MOV     R0, #0
FFFF05F0                 BL      unused10
FFFF05F0 ; End of function unused11
FFFF05F4 ; =============== S U B R O U T I N E =======================================
FFFF05F4 unused12                                ; CODE XREF: unused2+24
FFFF05F4                 MOV     R0, #1
FFFF05F8                 BL      unused10
FFFF05F8 ; End of function unused12
FFFF05F8 ; ---------------------------------------------------------------------------
FFFF05FC boot1_key       DCD 0x9258A752,0x64960D82,0x676F9044,0x56882A73
FFFF05FC                                         ; DATA XREF: main:off_FFFF04E4
FFFF060C boot1_iv        DCD  0, 0, 0, 0         ; DATA XREF: main:off_FFFF04E8
FFFF1FFC                 DCD 0xABAB0101          ; boot0_version
FFFF1FFC ; boot0         ends
