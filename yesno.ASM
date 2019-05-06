include 'C:\fasmw17311\INCLUDE\win32ax.inc';

.data
        titulo1 db "Mi primer programa",0
        mensaje1 db "¿Me debo presentar?",0
        mensaje2 db "Hola",0dh,0ah,"Soy un programa de prueba",0
        mensaje3 db "Entonces no me presento",0

.code
        start:
               invoke MessageBox,HWND_DESKTOP,mensaje1,titulo1,MB_YESNO+MB_ICONQUESTION

        .if eax = IDYES
               invoke MessageBox,HWND_DESKTOP,mensaje2,titulo1,MB_OK

        .elseif eax = IDNO
               invoke MessageBox,HWND_DESKTOP,mensaje3,titulo1,MB_OK

        .endif

        invoke ExitProcess,0

.end start