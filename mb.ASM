include 'C:\fasmw17311\INCLUDE\win32ax.inc';

.code
        start:
               invoke MessageBox,HWND_DESKTOP,"Me debo presentar?",'Mi primer Programa',MB_YESNO+MB_ICONQUESTION

        .if eax = IDYES
               invoke MessageBox,HWND_DESKTOP,"Hola, soy un programa de prueba","Mi primer programa",MB_OK

        .elseif eax = IDNO
               invoke MessageBox,HWND_DESKTOP,"A pues ctmalv","Mi primer programa",MB_OK

        .endif

        invoke ExitProcess,0

.end start