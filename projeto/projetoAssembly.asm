.686                        ;oq define o conjunto de instruções suportados pelo programa
.model flat, stdcall        ;flat - modelo do endereçamento de memoria que vai fazer o computador gerar o executavel, stdcall- como o assembler vai gerar o codigo para chamada de função (udo de pilha, passagem de argumento)
option casemap: none        ;responsavel por chamar as funções da api do windows
    
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc
include \masm32\macros\macros.asm
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\msvcrt.lib

.data                                           ;cria nova seção de dados
    mensagem1 db "digite a nota 1: ", 0h        ;db trata oq ta do lado esquerdo dele como variável
    mensagem2 db "digite a nota 2: ", 0h
    mensagem3 db "digite a nota 3: ", 0h
    mensagem4 db "Media: ", 0h
    mensagem5 db "                O aluno foi aprovado", 0h
    mensagem6 db "                O aluno foi reprovado", 0h
    mensagem7 db "                Nota necessaria na Final: ", 0h
    nota1 db 20 dup(0)                          ; aloca 20 bytes (duplica 0 20x)
    nota2 db 22 dup(0)
    nota3 db 20 dup(0)
    strbuffer db 14 dup(0)                      ; buffer para usar na conversao para ascii

.code ;seção do código

; declaração do procedimento ascii p/ int
; ponteiro para inicio da string em eax
; resultado armazenado em eax
_toint proc uses ebx ecx edx esi edi            ; uses = facilidade do masm preservar valores dos registradores antes da execução do procedimento e no final do procedimento restaurar esse valores para o resto do programa n ser impactado pelo procedimnto
    mov esi, eax                                ; salva ponteiro da string em esi                                 
    xor eax, eax                                ; zera eax   (total começa com 0)
    mov ecx, 10                                 ; guarda o valor da multiplicação (10) do algoritmo

    next:                                       ; label para loop 
        xor edx, edx                            ; zera edx, edx guarda cada caractere q estou trabalhando
        mov dl, byte ptr [esi]                  ; pega 1 byte do endereço esi, esi guarda ponteiro para onde começa a string; dl é uma parte de edx com 8 bit
        inc esi                                 ; move ponteiro para o prox caractere

        cmp dl, '0'                             ; menor que 0? (se for n é mais um numero)
        jl done                                 ; return (pula para onde tem a flag done)
        cmp dl, '9'                             ; maior que 9? (se for n é mais um numero)
        jg done                                 ;return

        imul eax, ecx                           ;valor atual x 10 (algoritimo de conversão)

        sub dl, '0'                             ; subtrai caractere '0', convertendo caractere para representação decimal
        add eax, edx                            ; adiciona tal valor ao eax
        jmp next                                ; vai para prox interação
    done:                                       ; label para terminar
        ret                                     ; retorna (terminou o número)
_toint endp

; declaração do procedimento  int p/ ascii
; valor armazenado em eax
; ponteiro apontando para resultado em eax
_tostr proc uses ecx edx edi
    mov ecx, 10                                 ; divisor (algoritmo)
    mov edi, offset strbuffer + 14              ; ponterio para o buffer

    next:                                       ; label para loop
        dec edi                                 ; decrementa edi p/ cada interação colocar um caractere na frente do buffer atual
        xor edx, edx                            ; zera edx que é onde o resto da divisão fica armazenada
        div ecx                                 ; divide eax por 10 (ecx), resto é armazenado em edx
        add dl, '0'                             ; adiciona carectere '0' ao resto da divisão, transformando o valor decimal em caractere ASCII
        mov byte ptr [edi], dl                  ; move 1 byte (caractere) para o buffer
        cmp eax, 0                              ; eax é diferente de 0? se n for continua e se for para
        jne next                                ; prox interação
    
    mov eax, edi                                ; move o ponteiro do buffer para eax
    ret                                         ; return
_tostr endp



aluno_aprovado:
        ;invoke StdOut, Crlf                      ; Adicione uma linha em branco
        invoke StdOut, offset mensagem5
        invoke ExitProcess, 0
aluno_reprovado:
        ;invoke Crlf                             ; Adicione uma linha em branco
        invoke StdOut, offset mensagem6
        invoke ExitProcess, 0


main:
    invoke StdOut, offset mensagem1
    invoke StdIn, offset nota1, 10

    invoke StdOut, offset mensagem2
    invoke StdIn, offset nota2, 12

    invoke StdOut, offset mensagem3
    invoke StdIn, offset nota3, 10

    mov eax, offset nota1                       ; move para eax o ponteiro para inicio da string da nota1
    call _toint                                 ; chama a função para converte para inteiro que armazena o resultado em eax
    push eax                                    ; grava valor de eax no topo da pilha 

    mov eax, offset nota2                       ; move para eax o ponteiro para inicio da string da nota2
    call _toint                                 ; chama a função para converte para inteiro que armazena o resultado em eax

    pop edx                                     ; coloca em edx o valor do topo da pilha (nota1)
    add eax, edx                                ; soma edx(nota1) com eax(nota2)
    push eax                                    ; grava valor de eax(nota1+nota2) no topo da pilha 
    
    mov eax, offset nota3                       ; move para eax o ponteiro para inicio da string da nota3
    call _toint                                 ; chama a função para converte para inteiro que armazena o resultado em eax

    pop edx                                     ; coloca em edx o valor do topo da pilha (nota1+nota2)
    add eax, edx                                ; soma edx(nota1+nota2) com eax(nota3)


    xor edx, edx                                ; zera edx
    mov ebx, 3                                  ; qtd de nota, valor para a media

    div ebx                                     ; valor que divide o eax(soma das notas)

    push eax                                    ; armazena a media no topo da pilha
    invoke StdOut, offset mensagem4
    
    pop eax                                     ; pega a media do topo da pilha
    push eax                                    ; guarda novamente por causa do invoke (?????????)
    invoke _tostr                               ; chama a função para converte para inteiro que armazena o resultado em eax
    invoke StdOut, eax

    

    ; Verifique se a média é maior ou igual a 7
    pop eax                                     ; pega a media do topo da pilha para comparar
    cmp eax, 7                                  ; compara a media com 7
    jge aluno_aprovado                          ; Se maior ou igual a 7, pule para a etiqueta aluno_aprovado
    cmp eax, 4
    jl aluno_reprovado


    ;Quanto vai precisar tirar na final
    xor edx, edx                                ; zera edx
    mov ebx, 6                                  ; a media sera multiplicada por 6 (formula)
    mul ebx                                     ; multiplicação da media*6

    mov ebx, 50                                 ; sera subtraido de 50 o resultado da multiplicação
    sub ebx, eax                                ; subtraçao da formula 50-(media*6)
    mov eax,ebx                                 ; coloca o resultado em eax

    xor edx, edx                                ; zera edx
    mov ebx, 4                                  ; o resultado da subtraçao sera dividido por 4 (formula)
    div ebx                                     ; valor que divide o eax(resultado da subtraçao)
    push eax 

    invoke StdOut, offset mensagem7
    pop eax
    invoke _tostr                               ; chama a função para converte para inteiro que armazena o resultado em eax
    invoke StdOut, eax                          ; quanto o aluno percisa na final
    
    

    invoke ExitProcess, 0
end main