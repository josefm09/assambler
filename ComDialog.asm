;Common Dialog Box - Abrir Archivo

format PE GUI 4.0
entry start

include 'C:\fasmw17311\INCLUDE\win32ax.inc'

MI_OPEN   equ  110
MI_EXIT   equ  120

section '.data' data readable writeable
     hMain          dd   ?
     hInstance      dd   ?

     wTitle         db   'Abrir archivo',0
     wClsName       db   'openFile',0

     wMsg      MSG
     wCls      WNDCLASS

     dlgOpenTitle   db   'Abrir archivo',0
     dlgOpenOfn     OPENFILENAME
     dlgOpenFilter  db   'Todos los archivos (*.*)',0,'*.*',0
                    db   'Archivos bitmap (*.bmp)',0,'*.bmp',0
                    db   'Archivos JPG (*.jpg)',0,'*.jpg',0,0

     dlgOpenBuffer: times 512 db 0

     str1           db   'La ruta completa del archivo es : ',0
     str2           db   'El nombre del archivo es : ',0
     str3           db   'La extensión es : ',0
     strMsgSize     equ  512
     strMsg:        times strMsgSize db 0
     br             db   0xD,0xA,0

section '.code' code readable executable
     start:
          ; +------------------------------------+
          ; | registrando la clase de la ventana |
          ; +------------------------------------+
          invoke    GetModuleHandle,NULL
                    mov  [hInstance],eax
                    mov  [wCls.hInstance],eax
                    mov  [wCls.style],CS_HREDRAW or CS_VREDRAW
                    mov  [wCls.lpfnWndProc],window_procedure
                    mov  [wCls.lpszClassName],wClsName
                    mov  [wCls.lpszMenuName],30
                    mov  [wCls.hbrBackground],COLOR_WINDOW+1
          invoke    LoadIcon,NULL,IDI_APPLICATION
                    mov  [wCls.hIcon],eax
          invoke    LoadCursor,NULL,IDC_ARROW
                    mov  [wCls.hCursor],eax
          invoke    RegisterClass,wCls

          ; +--------------------------+
          ; | Ventana principal        |
          ; +--------------------------+
          invoke    CreateWindowEx,\
                         WS_EX_CLIENTEDGE,\
                         wClsName,\
                         wTitle,\
                         WS_OVERLAPPEDWINDOW or WS_VISIBLE,\
                         CW_USEDEFAULT,\
                         CW_USEDEFAULT,\
                         300,\
                         200,\
                         NULL,\
                         NULL,\
                         [hInstance],\
                         NULL
                    mov  [hMain],eax
          ;invoke   ShowWindow,[wHMain],SW_SHOW
          ; +---------------------------+
          ; | Ciclo de manejo de mensaje|
          ; +---------------------------+
          window_message_loop_start:
               invoke    GetMessage,wMsg,NULL,0,0
                         or   eax,eax
                         je   window_message_loop_end
               invoke    TranslateMessage,wMsg
               invoke    DispatchMessage,wMsg
                         jmp  window_message_loop_start

          window_message_loop_end:
               invoke    ExitProcess,0

          ; +-----------------------------+
          ; | El procedimiento de ventana |
          ; +-----------------------------+
          proc window_procedure,hWnd,uMsg,wParam,lParam
               push ebx esi edi
               cmp  [uMsg],WM_COMMAND
               je   wmCOMMAND
               cmp  [uMsg],WM_DESTROY
               je   wmDESTROY

               wmDEFAULT:
                    invoke    DefWindowProc,[hWnd],[uMsg],[wParam],[lParam]
                              jmp  wmBYE
               wmCOMMAND:
                    cmp  [wParam],0xFFFF and MI_OPEN
                    je   wmCOMMAND_MI_OPEN
                    cmp  [wParam],0xFFFF and MI_EXIT
                    je   wmCOMMAND_MI_EXIT
                    jmp  wmBYE

                    wmCOMMAND_MI_EXIT:
                         invoke    DestroyWindow,[hWnd]
                                   jmp  wmBYE

                    wmCOMMAND_MI_OPEN:
                                   mov  [dlgOpenOfn.lStructSize],sizeof.OPENFILENAME
                                   push [hWnd]
                                   pop  [dlgOpenOfn.hwndOwner]
                                   push [hInstance]
                                   pop  [dlgOpenOfn.hInstance]
                                   mov  [dlgOpenOfn.lpstrFilter],dlgOpenFilter
                                   mov  [dlgOpenOfn.lpstrFile],dlgOpenBuffer
                                   mov  [dlgOpenOfn.nMaxFile],256
                                   mov  [dlgOpenOfn.Flags],OFN_FILEMUSTEXIST or\
                                        OFN_PATHMUSTEXIST or OFN_LONGNAMES or\
                                        OFN_EXPLORER or OFN_HIDEREADONLY
                                   mov  [dlgOpenOfn.lpstrTitle],dlgOpenTitle
                         invoke    GetOpenFileName,dlgOpenOfn
                                   cmp  eax,TRUE  ;El usuario seleccionó un archivo
                                   je   wmCOMMAND_MI_OPEN_TRUE
                                   jmp  wmBYE

                    wmCOMMAND_MI_OPEN_TRUE:
                         invoke    lstrcat,strMsg,str1
                         invoke    lstrcat,strMsg,[dlgOpenOfn.lpstrFile]
                         invoke    lstrcat,strMsg,br
                         invoke    lstrcat,strMsg,str2
                                   mov  eax,[dlgOpenOfn.lpstrFile]
                                   push ebx
                                   xor  ebx,ebx   ;borrar ebx
                                   mov  bx,[dlgOpenOfn.nFileOffset]
                                   add  eax,ebx
                                   pop  ebx
                         invoke    lstrcat,strMsg,eax
                         invoke    lstrcat,strMsg,br
                         invoke    lstrcat,strMsg,str3
                                   mov  eax,[dlgOpenOfn.lpstrFile]
                                   push ebx
                                   xor  ebx,ebx
                                   mov  bx,[dlgOpenOfn.nFileExtension]
                                   add  eax,ebx
                                   pop  ebx
                         invoke    lstrcat,strMsg,eax
                         invoke    MessageBox,[hWnd],strMsg,wTitle,MB_OK
                         invoke    RtlZeroMemory,strMsg,strMsgSize
                                   jmp  wmBYE

               wmDESTROY:
                    invoke    PostQuitMessage,0
               wmBYE:
                    pop  edi esi ebx
                    ret
          endp

section '.idata' import data readable writeable
     library   KERNEL32, 'KERNEL32.DLL',\
               USER32,   'USER32.DLL',\
               COMDLG32, 'COMDLG32.DLL'

     import    KERNEL32,\
               GetModuleHandle,    'GetModuleHandleA',\
               lstrcat,            'lstrcat',\
               RtlZeroMemory,      'RtlZeroMemory',\
               ExitProcess,        'ExitProcess'

     import    USER32,\
               RegisterClass,      'RegisterClassA',\
               CreateWindowEx,     'CreateWindowExA',\
               DefWindowProc,      'DefWindowProcA',\
               LoadCursor,         'LoadCursorA',\
               LoadIcon,           'LoadIconA',\
               MessageBox,         'MessageBoxA',\
               GetMessage,         'GetMessageA',\
               DestroyWindow,      'DestroyWindow',\
               TranslateMessage,   'TranslateMessage',\
               DispatchMessage,    'DispatchMessageA',\
               PostQuitMessage,    'PostQuitMessage'

     import    COMDLG32,\
               GetOpenFileName,    'GetOpenFileNameA'

section '.rsrc' resource data readable
     directory RT_MENU,appMenu

     resource  appMenu,\
               30,LANG_NEUTRAL,menuMain

     menu menuMain
          menuitem  '&Archivo',0,MFR_POPUP + MFR_END
          menuitem       '&Abrir',MI_OPEN,0
                         menuseparator
          menuitem       '&Salir',MI_EXIT,MFR_END