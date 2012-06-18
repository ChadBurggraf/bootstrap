@echo off

set BOOTSTRAP=.\docs\assets\css\bootstrap.css
set BOOTSTRAP_LESS=.\less\bootstrap.less
set BOOTSTRAP_RESPONSIVE=.\docs\assets\css\bootstrap-responsive.css
set BOOTSTRAP_RESPONSIVE_LESS=.\less\responsive.less
set HR=##################################################

if "%1" equ "bootstrap" goto bootstrap
if "%1" equ "watch" goto watch

::
:: BUILD DOCS
::

echo. && echo %HR%
echo Building Bootstrap...
echo %HR% && echo.
pushd js && cat *.js > jshint.tmp && mv jshint.tmp jshint.js && popd
call jshint js\jshint.js --config js\.jshintrc
del js\jshint.js
pushd js\tests\unit && cat *.js > jshint.tmp && mv jshint.tmp jshint.js && popd
call jshint js\tests\unit\jshint.js --config js\.jshintrc
del js\tests\unit\jshint.js
echo Running JSHint on javascript...               Done
call recess --compile %BOOTSTRAP_LESS% > %BOOTSTRAP%
call recess --compile %BOOTSTRAP_RESPONSIVE_LESS% > %BOOTSTRAP_RESPONSIVE%
echo Compiling LESS with Recess...                 Done
call node .\docs\build
xcopy img\* docs\assets\img /I /Y /Q > nul
xcopy js\*.js docs\assets\js /I /Y /Q > nul
xcopy js\tests\vendor\jquery.js docs\assets\js /I /Y /Q > nul
echo Compiling documentation...                    Done
cat js\bootstrap-transition.js js\bootstrap-alert.js js\bootstrap-button.js js\bootstrap-carousel.js js\bootstrap-collapse.js js\bootstrap-dropdown.js js\bootstrap-modal.js js\bootstrap-tooltip.js js\bootstrap-popover.js js\bootstrap-scrollspy.js js\bootstrap-tab.js js\bootstrap-typeahead.js > docs\assets\js\bootstrap.js
call uglifyjs -nc docs\assets\js\bootstrap.js > docs\assets\js\bootstrap.min.tmp.js
(echo /** && echo * Bootstrap.js by @fat ^& @mdo && echo * Copyright 2012 Twitter, Inc. && echo * http://www.apache.org/licenses/LICENSE-2.0.txt && echo */) > docs\assets\js\copyright.js
cat docs\assets\js\copyright.js docs\assets\js\bootstrap.min.tmp.js > docs\assets\js\bootstrap.min.js
del docs\assets\js\copyright.js docs\assets\js\bootstrap.min.tmp.js
echo Compiling and minifying javascript...         Done
echo. && echo %HR%
echo Bootstrap successfully built at %time%.
echo %HR% && echo.
echo Thanks for using Bootstrap, && echo ^<3 @mdo and @fat && echo.
goto :EOF

::
:: BUILD SIMPLE BOOTSTRAP DIRECTORY
:: recess & uglifyjs are required
::

:bootstrap
md bootstrap\img
md bootstrap\css
md bootstrap\js
xcopy img\* bootstrap\img /I /Y /Q > nul
call recess --compile %BOOTSTRAP_LESS% > bootstrap\css\bootstrap.css
call recess --compress %BOOTSTRAP_LESS% > bootstrap\css\bootstrap.min.css
call recess --compile %BOOTSTRAP_RESPONSIVE_LESS% > bootstrap\css\bootstrap-responsive.css
call recess --compress %BOOTSTRAP_RESPONSIVE_LESS% > bootstrap\css\bootstrap-responsive.min.css
cat js\bootstrap-transition.js js\bootstrap-alert.js js\bootstrap-button.js js\bootstrap-carousel.js js\bootstrap-collapse.js js\bootstrap-dropdown.js js\bootstrap-modal.js js\bootstrap-tooltip.js js\bootstrap-popover.js js\bootstrap-scrollspy.js js\bootstrap-tab.js js\bootstrap-typeahead.js > bootstrap\js\bootstrap.js
call uglifyjs -nc bootstrap\js\bootstrap.js > bootstrap\js\bootstrap.min.tmp.js
(echo /** && echo * Bootstrap.js by @fat ^& @mdo && echo * Copyright 2012 Twitter, Inc. && echo * http://www.apache.org/licenses/LICENSE-2.0.txt && echo */) > bootstrap\js\copyright.js
cat bootstrap\js\copyright.js bootstrap\js\bootstrap.min.tmp.js > bootstrap\js\bootstrap.min.js
del bootstrap\js\copyright.js bootstrap\js\bootstrap.min.tmp.js
goto :EOF

::
:: WATCH LESS FILES
::

:watch
echo Watching LESS files...
watchr -e "watch('less\/.*\.less') { system 'make.bat' }"
