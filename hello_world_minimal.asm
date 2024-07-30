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

TEST_MSG: db __utf16__ `Hello, World!\n`, 0



times ( ALIGNMENT - (($ - $$) % ALIGNMENT) ) db 0 ; Alignment
DATA_END:







	; --- EXECUTABLE CODE ---

section .text follows=.data
TEXT:

	; --- ENTRY ---

ENTRY:

	mov rcx, [rdx+64] ; SYSTEM_TABLE->ConOut
	lea rdx, [TEST_MSG]
	call [rcx+8] ; ConOut->OutputString()

	jmp $



times ( ALIGNMENT - (($ - $$) % ALIGNMENT) ) db 0 ; Alignment
TEXT_END:

