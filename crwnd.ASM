format PE GUI 4.0
entry start

include 'C:\fasmw17311\INCLUDE\win32a.inc'

section '.data' data readable writeable
     wHMain         dd   ?
     wHInstance     dd   ?

     wTitle         db   'Mi primer ventana',0
     wClsName       db   'MiPrimerVentana',0

     wMsg      MSG
     wCls      WNDCLASS

     expBoxTitle    db   'Descripción de la acción del menú',0
     expBoxDesc11   db   'MenuBar A -> MenuItem A',0
     expBoxDesc12   db   'Barra de Menú A -> Elemento de Menú B',0
     expBoxDesc13   db   'Barra de Menú A -> Elemento de Menú C',0
     expBoxDesc21   db   'Barra de Menú B -> Elemento de Menú A',0
     expBoxDesc30   db   'Mi programa es el mas perron aqui',0dh,0ah,'Version beta',0
     progNombre     db   'Calc.exe',0
     notePad        db   'notepad.exe',0
     sonido         db   'C:\Users\ADM\Downloads\aplauso.wav'

     ;Constantes para PlaySound
     SND_ALIAS          equ     10000h
     SND_RESOURCE       equ     40005h
     SND_FILENAME       equ     20000h
     SND_ASYNC          equ     1h

section '.code' code readable executable
     start:
          ;**Pasos para crear una ventana**
          ; 1.-Obtener la instancia de nuestro programa (requerido)
          ; 2.-Obtener la línea de comando (no se requiere a menos que se desee procesar la línea de comando)
          ; 3.-Registrar la clase de nuestra ventana (window class). Paso requerido a menos que se use
          ;    algun tipo predefinido de ventana (ejemplo: MessageBox o un dialog box)
          ; 4.-Crear la ventana (requerido)
          ; 5.-Mostrar ka ventana en el escritorio (requerido a menos que no se desee mostrar la ventana inmediatamente)
          ; 6.-Refrescar el área cliente de la ventana
          ; 7.-Entrar a un ciclo infinito, revisando los mensaje de Windows
          ; 8.-Si un mensaje arriba, es procesado por una función especial responsable de la ventana
          ; 9.-Salir del programa si el usuario cierra la ventana
          ; +-----------------------------------+
          ; |Registrando la Clase de la Ventana |
          ; +-----------------------------------+
          invoke    GetModuleHandle,NULL        ;Las funciones de Windows regresan los resultados en eax
                    mov  [wHInstance],eax
                    mov  [wCls.hInstance],eax
                    mov  [wCls.style],CS_HREDRAW or CS_VREDRAW
                    mov  [wCls.lpfnWndProc],window_procedure
                    mov  [wCls.lpszClassName],wClsName
                    mov  [wCls.hbrBackground],COLOR_WINDOW+1
          invoke    LoadIcon,NULL,IDI_APPLICATION
                    mov  [wCls.hIcon],eax
          invoke    LoadCursor,NULL,IDC_ARROW
                    mov  [wCls.hCursor],eax
          invoke    RegisterClass,wCls
          invoke    LoadMenu,[wHInstance],30
          ; +------------------------------+
          ; | Creando la ventana principal |
          ; +------------------------------+

          invoke    CreateWindowEx,\
                         0,\               ; estilo extendido de ventana
                         wClsName,\        ; puntero al nombre de la clase registrada
                         wTitle,\          ; puntero al nombre de la ventana
                         WS_OVERLAPPEDWINDOW,\ ; estilo de ventana
                         CW_USEDEFAULT,\       ; posición horizontal de la ventana
                         CW_USEDEFAULT,\       ; posición vertical de la ventana
                         CW_USEDEFAULT,\       ; ancho de la ventana
                         CW_USEDEFAULT,\       ; alto de la ventan
                         NULL,\                ; manejador de la ventana padre o propietaria
                         eax,\                 ; manejador de menu, o identificador de ventana hija
                         [wHInstance],\        ; manejador de la instancia de la aplicación
                         NULL                  ; puntero a los datos de creación de la ventana
                    mov  [wHMain],eax
          invoke    ShowWindow,[wHMain],SW_SHOW
          ; +-----------------------------+
          ; | Ciclo de manejo de mensajes |
          ; +-----------------------------+
          window_message_loop_start:
               invoke    GetMessage,wMsg,NULL,0,0
                         or   eax,eax           ;si se presionó salir del programa GetMessage regresa un false (0) en eax
                         je   window_message_loop_end  ;sirve para verificar la bandera z, si está enecendida debemos salir
                                                       ; Las dos sentencias anteriores son equivalentes a .BREAK .IF (!eax)
               invoke    TranslateMessage,wMsg         ; Si el usuario presiona alguna tecla, se crea un mensaje y se agrega a la cola de mensajes
               invoke    DispatchMessage,wMsg          ; Envía los datos del mensaje al procedimiento de ventana correspondiente.
                         jmp  window_message_loop_start  ; Prosigue el ciclo infinito

          window_message_loop_end:
               invoke    ExitProcess,0  ; Termina el programa

          ; +----------------------------+
          ; |Procedimiento de la ventana |
          ; +----------------------------+
          proc window_procedure,hWnd,uMsg,wParam,lParam
               push ebx esi edi    ;Por seguridad guardamos los valores de los registros
               cmp  [uMsg],WM_COMMAND
               je   wmCOMMAND
               cmp  [uMsg],WM_DESTROY
               je   wmDESTROY

               wmDEFAULT:
                    invoke    DefWindowProc,[hWnd],[uMsg],[wParam],[lParam]
                              jmp  wmBYE
               wmCOMMAND:
                              mov  eax,[wParam]
                              cmp  ax,11
                              je   wmCOMMAND_11
                              cmp  ax,12
                              je   wmCOMMAND_12
                              cmp  ax,13
                              je   wmCOMMAND_13
                              cmp  ax,21
                              je   wmCOMMAND_21
                              cmp  ax,22
                              je   wmCOMMAND_22
                              cmp  ax,30
                              je   wmCOMMAND_30
                              jmp  wmDEFAULT

                    wmCOMMAND_11:
                             ; invoke    MessageBox,[hWnd],expBoxDesc11,expBoxTitle,MB_OK
                              invoke ShellExecute,0,0,progNombre,0,0,SW_SHOW
                              jmp  wmBYE
                    wmCOMMAND_12:
                              ;invoke    MessageBox,[hWnd],expBoxDesc12,expBoxTitle,MB_OK
                              invoke ShellExecute,0,0,notePad,0,0,SW_SHOW
                              jmp  wmBYE
                    wmCOMMAND_13:
                             ; invoke    MessageBox,[hWnd],expBoxDesc13,expBoxTitle,MB_OK
                              invoke MessageBeep,0
                              invoke ExitProcess,0
                              jmp  wmBYE
                    wmCOMMAND_21:
                              invoke    MessageBox,[hWnd],expBoxDesc21,expBoxTitle,MB_OK
                              jmp  wmBYE
                    wmCOMMAND_22:
                              invoke    PlaySound,sonido,0,(SND_FILENAME + SND_ASYNC)
                              jmp  wmBYE
                    wmCOMMAND_30:
                              invoke    MessageBox,[hWnd],expBoxDesc30,expBoxTitle,MB_OK
                              jmp  wmBYE
               wmDESTROY:
                    invoke    PostQuitMessage,0  ;Indica a Windows que el "hilo" o proceso ha hecho
                                                 ;una petición para terminar. Esta función se usa normalmente
                                                 ;como respuesta a un mensaje WM_DESTROY.

               wmBYE:
                    pop  edi esi ebx
                    ret
          endp

section '.idata' import data readable writeable
     library   KERNEL32, 'KERNEL32.DLL',\
               USER32,   'USER32.DLL', \
               SHELL32,   'SHELL32.DLL', \
               WINMM,     'WINMM.DLL'

     import    KERNEL32,\
               GetModuleHandle,    'GetModuleHandleA',\
               ExitProcess,        'ExitProcess'

     import    USER32,\
               RegisterClass,      'RegisterClassA',\
               CreateWindowEx,     'CreateWindowExA',\
               DefWindowProc,      'DefWindowProcA',\
               ShowWindow,         'ShowWindow',\
               LoadCursor,         'LoadCursorA',\
               LoadIcon,           'LoadIconA',\
               LoadMenu,           'LoadMenuA',\
               GetMessage,         'GetMessageA',\
               MessageBox,         'MessageBoxA',\
               TranslateMessage,   'TranslateMessage',\
               DispatchMessage,    'DispatchMessageA',\
               PostQuitMessage,    'PostQuitMessage',\
               MessageBeep,        'MessageBeep'

      import   SHELL32,\
               ShellExecute,    'ShellExecuteA'

      import   WINMM,\
               PlaySound,    'PlaySoundA'

section '.rsrc' resource data readable
     directory RT_MENU,appMenu

     resource  appMenu,\
               30,LANG_ENGLISH,menuMain

     menu menuMain
          menuitem  'Utilerias',10,MFR_POPUP
          menuitem       'Calculadora',11,MFT_STRING
          menuitem       'Bloc de notas',12,MFT_STRING
                         menuseparator
          menuitem       'Salir',13,MFR_END
          menuitem  'Operaciones',20,MFR_POPUP
          menuitem       'Cuadro de dialogo',21,MFT_STRING
          menuitem       'Reproducir sonido',22,MFR_END
          menuitem  'Acerca de...',30,MFR_END