cd %~dp0

rem changed by user:
set APP_NAME=booo
set jdkbindir=c:\Program Files\Java\jdk1.8.0_112\bin
set SDK_PATH=c:\adt-bundle-windows-x86-20140702\sdk
set SDK_PLATFORM_VERSION=android-20
set BUILD_TOOLS_VERSION=android-4.4W

rem complete paths...
set buildtoolsdir=%SDK_PATH%\build-tools\%BUILD_TOOLS_VERSION%
set APK_SDK_PLATFORM=%SDK_PATH%\platforms\%SDK_PLATFORM_VERSION%
set androidjar=%SDK_PATH%\platforms\%SDK_PLATFORM_VERSION%\android.jar 
SET DX_PATH=%SDK_PATH%\build-tools\%BUILD_TOOLS_VERSION%\lib
set APK_PROJECT_PATH=.

del .\bin\* /q
rmdir .\gen /q/s
mkdir .\gen
rmdir .\classes /q/s
mkdir .\classes

rem -S res - fails, if "res" directory doesn't exist
rem generate-dependencies is needed to generate R.java file
%buildtoolsdir%\aapt p -v -f -M AndroidManifest.xml ^
  -F bin\%APP_NAME%.ap_ ^
  --generate-dependencies ^
  -I %APK_SDK_PLATFORM%\android.jar -S res -m -J gen -A ..\assets files
  

"%jdkbindir%\javac.exe" ^
  .\src\zengl\android\ZenGL.java ^
  .\src\zengl\booo\MainActivity.java ^
  -cp "%androidjar%" ^
  -d .\classes -target 1.7 -source 1.7
  

java -Djava.ext.dirs=%DX_PATH%\ -jar %DX_PATH%\dx.jar --dex --verbose --output=.\bin\classes.dex .\classes

del %APK_PROJECT_PATH%\bin\%APP_NAME%-unsigned.apk
"%jdkbindir%\java" -classpath %SDK_PATH%\tools\lib\sdklib.jar ^
  com.android.sdklib.build.ApkBuilderMain ^
  %APK_PROJECT_PATH%\bin\%APP_NAME%-unsigned.apk -v -u ^
  -z %APK_PROJECT_PATH%\bin\%APP_NAME%.ap_ ^
  -f %APK_PROJECT_PATH%\bin\classes.dex

REM Generating on the fly a debug key
rem "%jdkbindir%\keytool" -genkeypair -v -keystore .\LCLDebugBKKey.keystore -alias LCLDebugBKKey ^
rem   -keyalg RSA -validity 10000 ^
rem   -dname "cn=Havefunsoft, o=company, c=US" ^
rem   -storepass "123456" -keypass "123456" -keysize 2048

REM Signing the APK with a debug key
del bin\%APP_NAME%-unaligned.apk
"%jdkbindir%\jarsigner" -verbose ^
  -sigalg SHA1withRSA ^
  -digestalg SHA1 ^
  -keystore .\LCLDebugBKKey.keystore -keypass 123456 -storepass 123456 ^
  -signedjar bin\%APP_NAME%-unaligned.apk bin\%APP_NAME%-unsigned.apk LCLDebugBKKey  
  
REM Align the final APK package
%buildtoolsdir%\zipalign -v 4 bin\%APP_NAME%-unaligned.apk bin\%APP_NAME%.apk  

%SDK_PATH%\platform-tools\adb.exe uninstall zengl.%APP_NAME%
%SDK_PATH%\platform-tools\adb.exe install bin\%APP_NAME%.apk