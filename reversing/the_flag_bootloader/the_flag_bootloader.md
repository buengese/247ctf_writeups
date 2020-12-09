### The Flag Bootloader (Easy)

This challenge is rated easy despite that it has a relatively low number of solves. I guess that's because it's not that straightforward to solve this challenge just by looking at the disassembly. Luckily there is a better option.

The downloaded file `flag.com` is MBR boot sector with boot code. The important point here is that we can run it with qemu.
E.g.
```
$ qemu-system-i386 -drive format=raw,file=flag.com
```

Booting the file presents as with a promt for an Unlock code. We can input an alphanumeric password and we only seem to have one attempt after which we have to repeat. Also if try to enter more than 18 characters we get an out of memory error.

https://en.wikipedia.org/wiki/Master_boot_record
Need to use 0x7C00h as offset since that's where the mbr is loaded. 
```
$ ndisasm -o 0x7C00h flag.com
```
We are dealing with x86 real mode assembly here. Since I had very little experience with that i looked at 
https://wiki.osdev.org/Real_mode_assembly_I
There are also some BIOS interrupt used for input and output. There is full list of them here
https://en.wikipedia.org/wiki/BIOS_interrupt_call

The check function mostly consists of repeated sections like this. 
```
00007C6B  BBEC7D            mov bx,0x7dec ; bx set to the address of our input buffer
00007C6E  BEAA7D            mov si,0x7daa ; si loaded with some other adress
00007C71  83C607            add si,byte +0x7
00007C74  B04B              mov al,0x4b
00007C76  340C              xor al,0xc ; two values xor'd together
00007C78  3807              cmp [bx],al ; and compared to a character from our inüut
00007C7A  0F85FE00          jnz near 0x7d7c ; jump to failure state
00007C7E  3004              xor [si],al ; xor'd value store in buffer loaded into si
```

Importantly there is another xord that store it's result in the bufferr at `0x7daa`. So we can just set the zero flag for each of each of these checks with gdb. First set all the breakpoint
```
break *0x7c7a
break *0x7c8b
break *0x7c9c
break *0x7cad
break *0x7cbe
break *0x7ccf
break *0x7ce0
break *0x7cf1
break *0x7d02
break *0x7d11
break *0x7d20
break *0x7d2f
break *0x7d3e
break *0x7d4d
break *0x7d5c
break *0x7d6b
```
We can set the zero flag with:
```
(gdb) set $eflags |= (1 << 6)
```
Once we've reached 0x7D74 we can print it.
```
(gdb) set $eflags |= (1 << 6)
0x7daa: "247CTF{xxxxxxxxxxxxxxxxxxxxxxxx}\n\r"
```
Though the program will also print int for us. 

Notes:
A version of the disassembly for flag.com with all my annotations is also in this repository.
