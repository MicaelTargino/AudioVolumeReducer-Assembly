.686                              
.model flat, stdcall              
option casemap :none              

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data        
    welcome_string db "Seja bem vindo ao projeto de reducao de volume. Siga os passos abaixo:  ", 0Dh, 0Ah, 0 ; String de boas-vindas.
    string_request_input_file_name db "Digite o nome do arquivo de entrada: ", 0  ; Solicita��o do arquivo de entrada.
    string_request_output_file_name db  "Digite o nome do arquivo de saida: ", 0  ; Solicita��o do arquivo de sa�da.
    string_request_volume_reduction db "Digite a constante de reducao (1 a 10): ", 0 ; Solicita��o da constante de redu��o de volume.
    string_request_continue db 0Dh, 0Ah, "Deseja reduzir o volume de outro arquivo? (sim/nao): ", 0 ; Pergunta para continuar ou finalizar.
    string_thanks db 0Dh, 0Ah, "Obrigado por utilizar o programa. Ate mais!", 0  ; Agradecimento ao usu�rio.

    yes_string db "sim", 0                  ; Resposta positiva para continuar.
    no_string db "nao", 0                   ; Resposta negativa para encerrar.
    
    input_file_name db 50 dup(0)            ; Nome do arquivo de entrada.
    output_file_name db 50 dup(0)           ; Nome do arquivo de sa�da.
    volume_reduction_string db 50 dup(0)    ; Constante de redu��o como string.
    continue_string db 50 dup(0)            ; String para armazenar a resposta se quer continuar.
    volume_reduction_constant dd 0          ; Constante de redu��o (DWORD).
    
    input_handle dd 0                       ; Handle do console de entrada.
    output_handle dd 0                      ; Handle do console de sa�da.
    console_count dd 0                      ; Contador de caracteres lidos/escritos do console.
    
    input_file_name_length dd 0             ; Tamanho do nome do arquivo de entrada.
    output_file_name_length dd 0            ; Tamanho do nome do arquivo de sa�da.
    volume_reduction_string_length dd 0     ; Tamanho da string de redu��o de volume.

    input_file_handle dd 0                  ; Handle do arquivo de entrada.
    output_file_handle dd 0                 ; Handle do arquivo de sa�da.
    buffer db 44 dup(0)                     ; Buffer para armazenar o cabe�alho do arquivo WAV.
    bytes_read dd 0                         ; N�mero de bytes lidos.
    bytes_written dd 0                      ; N�mero de bytes escritos.


    mov esi, eax            
    shr ecx, 1              ; Cada amostra tem 2 bytes (16 bits), portanto divide por 2

process_samples:
    ; Carrega uma amostra de 16 bits (2 bytes)
    movsx eax, word ptr [esi]   ; Move os 2 bytes para EAX como um n�mero de 16 bits com sinal
    cdq                         ; Extende edx:eax para divis�o correta
    idiv dword ptr [volume_reduction_constant] ; Divide eax pela constante de redu��o

    ; Clipa o valor para o intervalo de 16 bits com sinal (-32768 a 32767)
    cmp eax, 32767
    jle check_min_value
    mov eax, 32767

check_min_value:
    cmp eax, -32768
    jge store_sample
    mov eax, -32768

store_sample:
    ; Armazena o valor processado de volta no buffer
    mov [esi], ax               
    add esi, 2                  ; Avan�a para a pr�xima amostra de 2 bytes
    loop process_samples        

    mov esp, ebp                ; Restaura a pilha
    pop ebp                     ; Restaura o valor anterior de EBP
    ret                         ; Retorna para a fun��o chamadora

start:
    ; Loop principal para processar m�ltiplos arquivos
main_loop:
    ; Obt�m o handle de entrada do console (teclado)
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov input_handle, eax        ; Armazena o handle de entrada.

    ; Obt�m o handle de sa�da do console (tela)
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov output_handle, eax       ; Armazena o handle de sa�da.

    ; Imprime a mensagem de boas-vindas
    invoke WriteConsole, output_handle, addr welcome_string, sizeof welcome_string, addr console_count, NULL
    
    ; Solicita o nome do arquivo de entrada
    invoke WriteConsole, output_handle, addr string_request_input_file_name, sizeof string_request_input_file_name, addr console_count, NULL
    invoke ReadConsole, input_handle, addr input_file_name, sizeof input_file_name, addr console_count, NULL
    ; Remove newline e carriage return do nome do arquivo de entrada
    mov esi, offset input_file_name
input_next:
    mov al, [esi]
    inc esi
    cmp al, 13               ; Verifica se � carriage return (\r)
    je input_terminate
    cmp al, 10               ; Verifica se � newline (\n)
    je input_terminate
    cmp al, 0                ; Se for null terminator, termina
    je input_terminate
    jmp input_next
input_terminate:
    dec esi
    mov byte ptr [esi], 0    ; Define o null terminator

    ; Solicita o nome do arquivo de sa�da
    invoke WriteConsole, output_handle, addr string_request_output_file_name, sizeof string_request_output_file_name, addr console_count, NULL
    invoke ReadConsole, input_handle, addr output_file_name, sizeof output_file_name, addr console_count, NULL
    ; Remove newline e carriage return do nome do arquivo de sa�da
    mov esi, offset output_file_name
output_next:
    mov al, [esi]
    inc esi
    cmp al, 13               
    je output_terminate
    cmp al, 10               
    je output_terminate
    cmp al, 0                
    je output_terminate
    jmp output_next
output_terminate:
    dec esi
    mov byte ptr [esi], 0    ; Define o null terminator

    ; Solicita a constante de redu��o do volume
    invoke WriteConsole, output_handle, addr string_request_volume_reduction, sizeof string_request_volume_reduction, addr console_count, NULL
    invoke ReadConsole, input_handle, addr volume_reduction_string, sizeof volume_reduction_string, addr console_count, NULL
    ; Remove o carriage return
    mov esi, offset volume_reduction_string  
proximo:
    mov al, [esi]
    inc esi
    cmp al, 13
    jne proximo
    dec esi
    xor al, al
    mov [esi], al                ; Define o null terminator

    ; Converte a constante de redu��o para DWORD
    invoke atodw, offset volume_reduction_string
    mov dword ptr [volume_reduction_constant], eax

    ; Abrindo o arquivo de entrada (.wav)
    invoke CreateFile, addr input_file_name, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov input_file_handle, eax
    cmp input_file_handle, INVALID_HANDLE_VALUE
    je fim ; Verifica se ocorreu um erro ao abrir o arquivo de entrada

    ; Abrindo o arquivo de sa�da (.wav)
    invoke CreateFile, addr output_file_name, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov output_file_handle, eax
    cmp output_file_handle, INVALID_HANDLE_VALUE
    je fim ; Verifica se ocorreu um erro ao criar o arquivo de sa�da

    ; Lendo os primeiros 44 bytes do arquivo de entrada (cabe�alho .wav)
    invoke ReadFile, input_file_handle, addr buffer, 44, addr bytes_read, NULL
    cmp eax, 0
    je fim ; Verifica se ocorreu um erro ao ler o arquivo de entrada
    cmp bytes_read, 44
    jne fim ; Verifica se foram lidos exatamente 44 bytes

    ; Escrevendo o cabe�alho no arquivo de sa�da
    invoke WriteFile, output_file_handle, addr buffer, 44, addr bytes_written, NULL
    cmp eax, 0
    je fim ; Verifica se ocorreu um erro ao escrever no arquivo de sa�da
    cmp bytes_written, 44
    jne fim ; Verifica se foram escritos exatamente 44 bytes

next_chunk:
    ; Lendo 16 bytes do arquivo de entrada
    invoke ReadFile, input_file_handle, addr buffer, 16, addr bytes_read, NULL
    cmp eax, 0                ; Verifica se houve erro ao ler
    je fim                    ; Se houve erro, finaliza
    cmp bytes_read, 0         ; Verifica se atingiu o final do arquivo
    je fim                    ; Se bytes lidos = 0, fim do arquivo

    ; Chamando a fun��o ProcessBuffer para processar o buffer lido
    push bytes_read           ; Passando o segundo par�metro (n�mero de bytes lidos)
    push offset buffer        ; Passando o primeiro par�metro (endere�o do buffer)
    call ProcessBuffer        ; Chamando a fun��o para processar o buffer
    add esp, 8                ; Limpando os par�metros da pilha

    ; Escrevendo os bytes processados no arquivo de sa�da
    invoke WriteFile, output_file_handle, addr buffer, bytes_read, addr bytes_written, NULL
    cmp eax, 0                ; Verifica se houve erro ao escrever
    je fim                    ; Se houve erro, finaliza

    ; Continua o loop de leitura e escrita
    jmp next_chunk

fim:
    ; Fechando os arquivos
    invoke CloseHandle, input_file_handle
    invoke CloseHandle, output_file_handle

    ; Pergunta ao usu�rio se deseja processar outro arquivo
    invoke WriteConsole, output_handle, addr string_request_continue, sizeof string_request_continue, addr console_count, NULL
    invoke ReadConsole, input_handle, addr continue_string, sizeof continue_string, addr console_count, NULL
    ; Remove newline e carriage return da resposta
    mov esi, offset continue_string
continue_next:
    mov al, [esi]
    inc esi
    cmp al, 13               ; Verifica se � carriage return (\r)
    je continue_terminate
    cmp al, 10               ; Verifica se � newline (\n)
    je continue_terminate
    cmp al, 0                ; Se for null terminator, termina
    je continue_terminate
    jmp continue_next
continue_terminate:
    dec esi
    mov byte ptr [esi], 0    ; Define o null terminator

    ; Verifica se o usu�rio quer continuar ou n�o
    invoke lstrcmpi, addr continue_string, addr yes_string ; Compara com "sim"
    cmp eax, 0               ; Se for igual a "sim", retorna 0
    je main_loop             ; Se o usu�rio digitou "sim", repete o processo

    ; Agradecimento final
    invoke WriteConsole, output_handle, addr string_thanks, sizeof string_thanks, addr console_count, NULL

    invoke ExitProcess, 0    ; Finaliza o programa

end start
