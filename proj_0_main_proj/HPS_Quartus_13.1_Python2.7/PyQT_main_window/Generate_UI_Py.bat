@echo off

rem echo ~dp0 is 	%~dp0
rem echo cd is 		%cd%





set python_driv=d
set uic_path=D:\Python27x86\Lib\site-packages\PyQt4\uic

set /p ui_fname=Input The UI File Name: 

for %%I in (%ui_fname%) do ( 
set ori_ui_fname=%%~nI
) 

rem echo The UI File Path is: %ui_fname%
set full_ui_path=%cd%\%ui_fname%
set full_ori_ui_path=%cd%\%ori_ui_fname%
set bat_path=%cd%


%python_driv%:
cd %uic_path%
python pyuic.py -o %full_ori_ui_path%.py %full_ui_path%

pause