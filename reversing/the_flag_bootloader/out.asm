00007C00  EB21              jmp short 0x7c23 ; initial jump
_read: ; this function reads keystrokes
00007C02  B80010            mov ax,0x1000
00007C05  CD16              int 0x16 ; return AH = scan code, AL = character
00007C07  C3                ret
_print: ; print this stuff
00007C08  60                pusha
00007C09  B40E              mov ah,0xe
00007C0B  8A04              mov al,[si]
00007C0D  3C00              cmp al,0x0
00007C0F  740E              jz 0x7c1f
00007C11  B700              mov bh,0x0
00007C13  B307              mov bl,0x7
00007C15  CD10              int 0x10
00007C17  80FE24            cmp dh,0x24
00007C1A  7403              jz 0x7c1f
00007C1C  46                inc si ; ; AL = character, BH display page, BL = foreground color
00007C1D  EBEC              jmp short 0x7c0b
00007C1F  61                popa
00007C20  B600              mov dh,0x0
00007C22  C3                ret
_main:
00007C23  31C0              xor ax,ax
00007C25  8ED8              mov ds,ax
00007C27  BE8B7D            mov si,0x7d8b
00007C2A  E8DBFF            call 0x7c08
00007C2D  BBEA7D            mov bx,0x7dea
00007C30  83C302            add bx,byte +0x2
00007C33  891EEA7D          mov [0x7dea],bx ; text buffer starts at 0x7DEC
_loop: ; 0x7de6 is out input character
00007C37  BEE67D            mov si,0x7de6  ; si = 0x7de6
00007C3A  E8C5FF            call 0x7c02
00007C3D  A2E67D            mov [0x7de6],al ; *0x7de6 = al 0x7de6 0x7de6 stores last character read
00007C40  E8C5FF            call 0x7c08
00007C43  8B1EEA7D          mov bx,[0x7dea] ; bx = *0x7dea
00007C47  81FBFD7D          cmp bx,0x7dfd ; no memory check = 0x7dfd buffer end
00007C4B  0F843501          jz near 0x7d84 ; jmp to _print_no_memory
00007C4F  8807              mov [bx],al ; store read character
00007C51  83C301            add bx,byte +0x1 ; increment position in buffer
00007C54  891EEA7D          mov [0x7dea],bx ; store current position
00007C58  803EE67D0D        cmp byte [0x7de6],0xd ; 0x0d is the ascii code for enter
00007C5D  75D8              jnz 0x7c37 ; jmp back to _loop
_endloop:
00007C5F  BED57D            mov si,0x7dd5
00007C62  E8A3FF            call 0x7c08
00007C65  E80200            call 0x7c6a ; this is probably the check function
00007C68  EBC3              jmp short 0x7c2d
_check:
00007C6A  60                pusha
00007C6B  BBEC7D            mov bx,0x7dec ; bx set to the address of our input buffer
00007C6E  BEAA7D            mov si,0x7daa ; si loaded with some other adress
00007C71  83C607            add si,byte +0x7
00007C74  B04B              mov al,0x4b
00007C76  340C              xor al,0xc ; two values xor'd together
00007C78  3807              cmp [bx],al ; and compared to a character from our inüut
00007C7A  0F85FE00          jnz near 0x7d7c ; jump to failure state
00007C7E  3004              xor [si],al ; another xor into buffer loaded into si
00007C80  46                inc si 
00007C81  3004              xor [si],al
00007C83  43                inc bx ; input buffer increment
00007C84  46                inc si
00007C85  B053              mov al,0x53
00007C87  3406              xor al,0x6
00007C89  3807              cmp [bx],al
00007C8B  0F85ED00          jnz near 0x7d7c
00007C8F  3004              xor [si],al
00007C91  46                inc si
00007C92  3004              xor [si],al
00007C94  43                inc bx
00007C95  46                inc si
00007C96  B058              mov al,0x58
00007C98  2C01              sub al,0x1
00007C9A  3807              cmp [bx],al
00007C9C  0F85DC00          jnz near 0x7d7c
00007CA0  3004              xor [si],al
00007CA2  46                inc si
00007CA3  3004              xor [si],al
00007CA5  43                inc bx
00007CA6  46                inc si
00007CA7  B062              mov al,0x62
00007CA9  2C29              sub al,0x29
00007CAB  3807              cmp [bx],al
00007CAD  0F85CB00          jnz near 0x7d7c
00007CB1  3004              xor [si],al
00007CB3  46                inc si
00007CB4  3004              xor [si],al
00007CB6  43                inc bx
00007CB7  46                inc si
00007CB8  B068              mov al,0x68
00007CBA  3423              xor al,0x23
00007CBC  3807              cmp [bx],al
00007CBE  0F85BA00          jnz near 0x7d7c
00007CC2  3004              xor [si],al
00007CC4  46                inc si
00007CC5  3004              xor [si],al
00007CC7  43                inc bx
00007CC8  46                inc si
00007CC9  B04B              mov al,0x4b
00007CCB  3400              xor al,0x0
00007CCD  3807              cmp [bx],al
00007CCF  0F85A900          jnz near 0x7d7c
00007CD3  3004              xor [si],al
00007CD5  46                inc si
00007CD6  3004              xor [si],al
00007CD8  43                inc bx
00007CD9  46                inc si
00007CDA  B062              mov al,0x62
00007CDC  2C1E              sub al,0x1e
00007CDE  3807              cmp [bx],al
00007CE0  0F859800          jnz near 0x7d7c
00007CE4  3004              xor [si],al
00007CE6  46                inc si
00007CE7  3004              xor [si],al
00007CE9  43                inc bx
00007CEA  46                inc si
00007CEB  B04D              mov al,0x4d
00007CED  2C0B              sub al,0xb
00007CEF  3807              cmp [bx],al
00007CF1  0F858700          jnz near 0x7d7c
00007CF5  3004              xor [si],al
00007CF7  46                inc si
00007CF8  3004              xor [si],al
00007CFA  43                inc bx
00007CFB  46                inc si
00007CFC  B045              mov al,0x45
00007CFE  340D              xor al,0xd
00007D00  3807              cmp [bx],al
00007D02  7578              jnz 0x7d7c
00007D04  3004              xor [si],al
00007D06  46                inc si
00007D07  3004              xor [si],al
00007D09  43                inc bx
00007D0A  46                inc si
00007D0B  B010              mov al,0x10
00007D0D  3428              xor al,0x28
00007D0F  3807              cmp [bx],al
00007D11  7569              jnz 0x7d7c
00007D13  3004              xor [si],al
00007D15  46                inc si
00007D16  3004              xor [si],al
00007D18  43                inc bx
00007D19  46                inc si
00007D1A  B058              mov al,0x58
00007D1C  341D              xor al,0x1d
00007D1E  3807              cmp [bx],al
00007D20  755A              jnz 0x7d7c
00007D22  3004              xor [si],al
00007D24  46                inc si
00007D25  3004              xor [si],al
00007D27  43                inc bx
00007D28  46                inc si
00007D29  B07A              mov al,0x7a
00007D2B  3428              xor al,0x28
00007D2D  3807              cmp [bx],al
00007D2F  754B              jnz 0x7d7c
00007D31  3004              xor [si],al
00007D33  46                inc si
00007D34  3004              xor [si],al
00007D36  43                inc bx
00007D37  46                inc si
00007D38  B065              mov al,0x65
00007D3A  2C13              sub al,0x13
00007D3C  3807              cmp [bx],al
00007D3E  753C              jnz 0x7d7c
00007D40  3004              xor [si],al
00007D42  46                inc si
00007D43  3004              xor [si],al
00007D45  43                inc bx
00007D46  46                inc si
00007D47  B033              mov al,0x33
00007D49  3407              xor al,0x7
00007D4B  3807              cmp [bx],al
00007D4D  752D              jnz 0x7d7c
00007D4F  3004              xor [si],al
00007D51  46                inc si
00007D52  3004              xor [si],al
00007D54  43                inc bx
00007D55  46                inc si
00007D56  B025              mov al,0x25
00007D58  3415              xor al,0x15
00007D5A  3807              cmp [bx],al
00007D5C  751E              jnz 0x7d7c
00007D5E  3004              xor [si],al
00007D60  46                inc si
00007D61  3004              xor [si],al
00007D63  43                inc bx
00007D64  46                inc si
00007D65  B04C              mov al,0x4c
00007D67  040C              add al,0xc
00007D69  3807              cmp [bx],al
00007D6B  750F              jnz 0x7d7c
00007D6D  3004              xor [si],al
00007D6F  46                inc si
00007D70  3004              xor [si],al
00007D72  43                inc bx
00007D73  46                inc si
00007D74  BEAA7D            mov si,0x7daa
00007D77  E88EFE            call 0x7c08
00007D7A  EB0E              jmp short 0x7d8a
00007D7C  BE9A7D            mov si,0x7d9a
00007D7F  E886FE            call 0x7c08
00007D82  EB06              jmp short 0x7d8a
_print_no_memory:
00007D84  BED77D            mov si,0x7dd7 ; load No memory!
00007D87  E87EFE            call 0x7c08 ; Call print
00007D8A  F4                hlt
00007D8B  55                push bp
00007D8C  6E                outsb
00007D8D  6C                insb
00007D8E  6F                outsw
00007D8F  636B20            arpl [bp+di+0x20],bp
00007D92  636F64            arpl [bx+0x64],bp
00007D95  653A0A            cmp cl,[gs:bp+si]
00007D98  0D0049            or ax,0x4900
00007D9B  6E                outsb
00007D9C  7661              jna 0x7dff
00007D9E  6C                insb
00007D9F  696420636F        imul sp,[si+0x20],word 0x6f63
00007DA4  6465210A          and [gs:bp+si],cx
00007DA8  0D0032            or ax,0x3200
00007DAB  3437              xor al,0x37
00007DAD  43                inc bx
00007DAE  54                push sp
00007DAF  46                inc si
00007DB0  7B77              jpo 0x7e29
00007DB2  216730            and [bx+0x30],sp
00007DB5  60                pusha
00007DB6  350C0C            xor ax,0xc0c
00007DB9  7879              js 0x7e34
00007DBB  2E2E207270        and [cs:bp+si+0x70],dh
00007DC0  7529              jnz 0x7deb
00007DC2  2B00              sub ax,[bx+si]
00007DC4  5C                pop sp
00007DC5  217062            and [bx+si+0x62],si
00007DC8  636560            arpl [di+0x60],sp
00007DCB  07                pop es
00007DCC  0D0602            or ax,0x206
00007DCF  3B3B              cmp di,[bp+di]
00007DD1  7D0A              jnl 0x7ddd
00007DD3  0D000A            or ax,0xa00
00007DD6  000A              add [bp+si],cl
00007DD8  0D4E6F            or ax,0x6f4e
00007DDB  206D65            and [di+0x65],ch
00007DDE  6D                insw
00007DDF  6F                outsw
00007DE0  7279              jc 0x7e5b
00007DE2  210A              and [bp+si],cx
00007DE4  0D0000            or ax,0x0
00007DE7  0000              add [bx+si],al
00007DE9  0000              add [bx+si],al
00007DEB  0000              add [bx+si],al
00007DED  0000              add [bx+si],al
00007DEF  0000              add [bx+si],al
00007DF1  0000              add [bx+si],al
00007DF3  0000              add [bx+si],al
00007DF5  0000              add [bx+si],al
00007DF7  0000              add [bx+si],al
00007DF9  0000              add [bx+si],al
00007DFB  0000              add [bx+si],al
00007DFD  0055AA            add [di-0x56],dl
