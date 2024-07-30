bits 64
default rel



	; --- HEADER ---

ALIGNMENT equ 512 ; Smallest supported power-of-2 alignment



section .header
HEADERS:

; DOS Header
	dd "MZ" ; DOS magic number
	times 56 db 0
	dd PE_HEADER ; Address of PE Header
	times 64 db 0

; PE Header
PE_HEADER:
	dd "PE" ; PE magic number
	dw 0x8664 ; x86_64
	dw 2 ; Number of sections (.text & .data)
	dd 0x66666666 ; Timestamp
	dq 0
	dw (OPTIONAL_HEADER_END - OPTIONAL_HEADER) ; Optional header size
	dw 2 ; Characteristics: Executable

; Optional Header
OPTIONAL_HEADER:
	dw 0x020B ; PE32
	dw 0
	dd (TEXT_END - TEXT) ; Size of .text section
	dd (DATA_END - DATA) ; Size of .data section
	dd 0
	dd ENTRY ; Address of entry
	dd TEXT ; Address of .text
	dq 0 ; Image base
	dd ALIGNMENT ; Section alignment
	dd ALIGNMENT ; File alignment
	times 16 db 0
	dd ((HEADERS_END - HEADERS) + (TEXT_END - TEXT) + (DATA_END - DATA)) ; Size of image
	dd (HEADERS_END - HEADERS) ; Size of headers
	dd 0 ; Checksum
	dw 0x000A ; Subsystem EFI
	dw 0
	dq 65536 ; Size of stack reserve
	dq 64 ; Size of stack commit
	dq 65536 ; Size of heap reserve
	dq 64 ; Size of heap commit
	dd 0
	dd ((DATA_DIRECTORIES_END - DATA_DIRECTORIES) / 8) ; Num of data directories -v

; Data directories
DATA_DIRECTORIES:
	times 16 dq 0

DATA_DIRECTORIES_END:

OPTIONAL_HEADER_END:

; Section table
	dq ".text" ; Section name
	dd (TEXT_END - TEXT) ; Virtual size
	dd TEXT ; Virtual address
	dd (TEXT_END - TEXT) ; Size
	dd TEXT ; Address
	times 12 db 0
	dd 0x60000020; Characteristics: Code + readable + executable

	dq ".data" ; Section name
	dd (DATA_END - DATA) ; Virtual size
	dd DATA ; Virtual address
	dd (DATA_END - DATA) ; Size
	dd DATA ; Address
	times 12 db 0
	dd 0xC0000040; Characteristics: Initialized data + readable + writeable

times ( ALIGNMENT - (($ - $$) % ALIGNMENT) ) db 0 ; Alignment
HEADERS_END:















	; --- DATA ---

section .data follows=.header
DATA:

EFI_HANDLE: dq 0

EFI_SYSTEM_TABLE_PTR: dq 0
; +0 - +20 EFI_TABLE_HEADER
; +24 - FIRMWARE_VENDOR_PTR
; +32 - FIRMWARE_REVISION
; +40 - CONSOLE_IN_HANDLE
; +48 - CONSOLE_IN_PTR
; +56 - CONSOLE_OUT_HANDLE
; +64 - CONSOLE_OUT_PTR
; +72 - STD_ERR_HANDLE
; +80 - STD_ERR_PTR
; +88 - RUNTIME_SERVICES_PTR
; +96 - BOOT_SERVICES_PTR
; +104 - NUM_OF_TABLE_ENTRIES
; +108 - CONFIG_TABLE_PTR
; - 116 == END



TEST_MSG: db __utf16__ `Hello, World!\n`, 0



ERROR_PRINT_FAILED_MSG: db __utf16__ `ERROR: print failed\n`, 0



times ( ALIGNMENT - (($ - $$) % ALIGNMENT) ) db 0 ; Alignment
DATA_END:















	; --- EXECUTABLE CODE ---

section .text follows=.data
TEXT:

; rdx == OUT_STRING_PTR
print:
	push rbp
	mov rbp, rsp
	sub rsp, 0x20



	mov rax, [EFI_SYSTEM_TABLE_PTR]
	mov rcx, [rax+64] ; SYSTEM_TABLE->ConOut
	call [rcx+8] ; ConOut->OutputString()



	mov rsp, rbp
	pop rbp
	ret







; rdx == ERR_MSG_PTR
error_exit:
	call print
	jmp end



ERROR_print_failed:
	lea rdx, [ERROR_PRINT_FAILED_MSG]
	jmp error_exit



	; --- ENTRY ---

ENTRY:
	push rbp
	mov rbp, rsp
	sub rsp, 0x20

	mov [EFI_HANDLE], rcx
	mov [EFI_SYSTEM_TABLE_PTR], rdx



	lea rdx, [TEST_MSG]
	call print
	test rax, rax
	jnz ERROR_print_failed



end:
	mov rsp, rbp
	pop rbp
	ret



times ( ALIGNMENT - (($ - $$) % ALIGNMENT) ) db 0 ; Alignment
TEXT_END:

