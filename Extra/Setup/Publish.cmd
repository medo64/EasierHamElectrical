@ECHO OFF

SET PREFIX="EasierHamElectrical-Extra"


SET         EXE_WINRAR="%PROGRAMFILES%\WinRAR\WinRAR.exe"
SET        EXE_OPTIPNG="\Tools\Books\optipng-0.7.4\optipng.exe"
SET       EXE_JPEGTRAN="\Tools\Books\JpegForWindows-6b\bin\jpegtran.exe"
SET      EXE_EPUBCHECK="%PROGRAMFILES(x86)%\Java\jre7\bin\java" -jar \Tools\Books\epubcheck-3.0.1\epubcheck-3.0.1.jar
SET      EXE_KINDLEGEN="\Tools\Books\kindlegen-2.9\kindlegen.exe"


ECHO --- PREPARE
ECHO.

RMDIR /Q /S ".\Temp" 2> NUL
MKDIR .\Temp
IF ERRORLEVEL 1 PAUSE && EXIT /B %ERRORLEVEL%

ECHO Done.

ECHO.


IF DEFINED EXE_OPTIPNG (
    ECHO --- OPTIMIZE PNG
    ECHO.

    FOR /F "delims=" %%F in ('DIR "..\*.png" /B /S /A-D') do (
        ECHO %%F
        DEL "%%F.tmp" 2> NUL
        %EXE_OPTIPNG% -o7 -silent -out "%%F.tmp" "%%F"
        MOVE /Y "%%F.tmp" "%%F" > NUL
        IF ERRORLEVEL 1 PAUSE && EXIT /B %ERRORLEVEL%
    )

    ECHO.
)


IF DEFINED EXE_JPEGTRAN (
    ECHO --- OPTIMIZE JPEG
    ECHO.

    FOR /F "delims=" %%F in ('DIR "..\*.jpg" /B /S /A-D') do (
        ECHO %%F
        DEL "%%F.tmp" 2> NUL
        %EXE_JPEGTRAN% -copy none -optimize -outfile "%%F.tmp" "%%F"
        MOVE /Y "%%F.tmp" "%%F" > NUL
        IF ERRORLEVEL 1 PAUSE && EXIT /B %ERRORLEVEL%
    )

    ECHO.
)


ECHO --- BUILD EPUB
ECHO.

SET fileName=%PREFIX%.epub
ECHO Zipping into %fileName%
%EXE_WINRAR% a -afzip -ep1 -m0 -r ".\Temp\%fileName%" ../Source/mimetype
%EXE_WINRAR% a -afzip -ep1 -m5 -r ".\Temp\%fileName%" ../Source/META-INF ../Source/OEBPS
IF ERRORLEVEL 1 PAUSE && EXIT /B %ERRORLEVEL%

ECHO.


IF DEFINED EXE_EPUBCHECK (
    ECHO --- VERIFY EPUB
    ECHO.
    
    %EXE_EPUBCHECK% ./Temp/%fileName%
    IF ERRORLEVEL 1 PAUSE && EXIT /B %ERRORLEVEL%
    
    ECHO.
)


IF DEFINED EXE_KINDLEGEN (
    ECHO --- BUILD KINDLE
    ECHO.
    
    CD .\Temp
    %EXE_KINDLEGEN% %fileName% -verbose -o %fileName:.epub=.mobi%
    IF ERRORLEVEL 1 PAUSE && EXIT /B %ERRORLEVEL%
    CD ..
    
    ECHO.
)


ECHO --- RELEASE
ECHO.

DEL /Q ..\Releases\*.* 2> NUL
MKDIR ..\Releases 2> NUL
MOVE ".\Temp\*.*" "..\Releases\." > NUL
IF ERRORLEVEL 1 PAUSE && EXIT /B %ERRORLEVEL%
RMDIR /Q /S ".\Temp"

ECHO Released.

ECHO.


ECHO.
ECHO Done.
ECHO.

explorer.exe /SELECT,"..\Releases\%fileName%"
