.686
.MODEL  Flat,StdCall
OPTION  CaseMap:None

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\msvcrt.lib
include \masm32\macros\macros.asm

.code
start:
    xor eax, eax
    mov ecx, 1
meuLaco:
    add eax, ecx
    inc ecx
    ;printf("meu")
    cmp ecx, 100
    jbe meuLaco
    printf("O valor do somatorio eh: %d", eax)
    invoke ExitProcess, 0
end start 