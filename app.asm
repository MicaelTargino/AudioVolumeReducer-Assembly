.686                              
.model flat, stdcall              
option casemap :none              

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data        
    welcome_string db "Seja bem vindo ao projeto de reducao de volume. Siga os passos abaixo:  ", 0Dh, 0Ah, 0 ; String para iniciar a execução
    string_request_input_file_name db "Digite o nome do arquivo de entrada: ", 0  ; String para solicitar o nome do arquivo de entrada.
    string_request_output_file_name db  "Digite o nome do arquivo de saida: ", 0   ; String para solicitar o nome do arquivo de saída.
    string_request_volume_reduction db "Digite a constante de reducao (1 a 10): ", 0 ; String para solicitar a constante de redução de volume.
    
    input_file_name db 50 dup(0)           ; Buffer para o nome do arquivo de entrada.
    output_file_name db 50 dup(0)          ; Buffer para o nome do arquivo de saída.
    volume_reduction_string db 50 dup(0)   ; Buffer para a string da constante de redução de volume.
    volume_reduction_constant dd 0         ; Constante de redução de volume.
    
    input_handle dd 0                     ; Handle do console de entrada.
    output_handle dd 0                    ; Handle do console de saída.
    console_count dd 0                    ; Contador de caracteres lidos/escritos do console.
    
    input_file_name_length dd 0             ; Tamanho da string do nome do arquivo de entrada.
    output_file_name_length dd 0            ; Tamanho da string do nome do arquivo de saída.
    volume_reduction_string_length dd 0 ; Tamanho da string da constante de redução de volume


.code                             
start:
    ; Obtém o handle de entrada do console (teclado) usando a função API GetStdHandle.
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov input_handle, eax        ; Armazena o handle de entrada na variável inputHandle.

    ; Obtém o handle de saída do console (tela) usando a função API GetStdHandle.
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov output_handle, eax       ; Armazena o handle de saída na variável outputHandle.

    ; Imprime na tela a mensagem inicial para o usuário
    invoke WriteConsole, output_handle, addr welcome_string, sizeof welcome_string, addr console_count, NULL
    
    ; Imprime na tela a mensagem para o usuário digitar o nome do arquivo de entrada
    invoke WriteConsole, output_handle, addr string_request_input_file_name , sizeof string_request_input_file_name, addr console_count, NULL
    
    ; Lê o nome do arquivo de entrada digitado pelo usuário e calcula o tamanho da string
    invoke ReadConsole, input_handle, addr input_file_name, sizeof input_file_name, addr console_count, NULL
    invoke StrLen, addr input_file_name
    mov input_file_name_length, eax

    ; Imprime na tela a mensagem para o usuário digitar o nome do arquivo de saída
    invoke WriteConsole, output_handle, addr string_request_output_file_name , sizeof string_request_output_file_name, addr console_count, NULL
    
    ; Lê o nome do arquivo de saída digitado pelo usuário e calcula o tamanho da string
    invoke ReadConsole, input_handle, addr output_file_name, sizeof output_file_name, addr console_count, NULL
    invoke StrLen, addr output_file_name
    mov output_file_name_length, eax

    ; Imprime na tela a mensagem para o usuário digitar a constante de redução do volume
    invoke WriteConsole, output_handle, addr string_request_volume_reduction , sizeof string_request_volume_reduction, addr console_count, NULL
    ; Lê a string digitada e calcula o tamanho da string
    invoke ReadConsole, input_handle, addr volume_reduction_string, sizeof volume_reduction_string, addr console_count, NULL
    invoke StrLen, addr volume_reduction_string
    mov volume_reduction_string_length, eax

    
    ; Antes de realizar a conversão da constante lida para DWORD, vamos limpar o "carriage return" da string inserida.
    mov esi, offset volume_reduction_string  ; Load the address of the input string into ESI register.

proximo:
    mov al, [esi]                ; Carrega o byte atual (caractere) da string lida.
    inc esi                      ; Move para o próximo caractere
    cmp al, 13                   ; Compara o caractere com o carriage return (ASCII 13).
    jne proximo                  ; Se não for o carriage return, continua o loop.
    dec esi                      ; Caso seja, volta um passo (Apontar para o último caractere válido).
    xor al, al                   ; Zera o registrador AL (usado para marcar o final da string).
    mov [esi], al                ; Define o null terminator (`0x00`) no final da string.

    ; Converte a string  para DWORD usando atodw (função auxiliar do MASM32).
    invoke atodw, offset volume_reduction_string
    MOV dword ptr [volume_reduction_constant], eax   ; Salva o número convertido na variável "volume_reduction_constant"


    ; Imprime os valores digitados pelo usuário (remover esta parte depois)
    invoke WriteConsole, output_handle, addr input_file_name, sizeof input_file_name, addr console_count, NULL
    invoke WriteConsole, output_handle, addr output_file_name, sizeof output_file_name, addr console_count, NULL
    invoke WriteConsole, output_handle, addr volume_reduction_string, sizeof volume_reduction_string, addr console_count, NULL

    invoke ExitProcess, 0          
end start                      