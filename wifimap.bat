@echo off
if /i -%1- equ -- (
 goto rien
) else if /i -%1- equ -/l- (
  goto liste
) else if /i -%1- equ -/k- (
  goto key
) else if /i -%1- equ -/d- (
 goto deleteProfile
) else if /i -%1- equ -/?- (
 goto aide
) else (
 goto ErreurSyn
)
goto fin

:ErreurSyn
echo Erreur de syntaxe. Consulter le manuel d'aide
:FinErreurSyn
goto fin

:rien
echo La syntaxe de la commande est incorrecte.
echo Taper "wifimap /?" pour consulter le manuel d'aide
:finrien
goto fin

:liste
 if /i -%2- neq -- (
  goto test
 ) else (
  goto simpleListe
 )

 :test


  if /i -%2- neq -""- goto snipperListe
 :fintest

 :simpleListe
  echo Liste des Reseaux sans fils
  for /f "skip=9 tokens=1 delims=" %%a in ('netsh wlan show profiles') do (
   echo %%a
  )
  goto fin
 :finsimpleListe

 :snipperListe
  echo Liste des Reseaux sans fils correspondant a la recherche
  for /f "delims=" %%a in ('@netsh wlan show profiles ^| @findstr /i /r %2') do (
   echo %%a
  )
  goto fin
 :finsnipperListe

 goto fin
:finliste


:key
 set ssid_name=%2

 if /i -%2- equ -- (
  goto erreur
 ) else if /i -%2- equ -""- (
  goto erreur
 ) else (
  goto suite
 )
 goto finkey

 :erreur
  echo Commande incomplet, Vous devez taper le "SSID" du wifi pour voir sa clef de securite
  goto fin
 :finerreur
 

 :suite
  echo     nom du reseau                : %ssid_name%
  @netsh wlan show profile name=%ssid_name% key=clear | findstr /l "Contenu"
  @if %errorlevel% equ 1 (
   echo     SSID introuvable ou cle de securite absent
  )
  goto fin
 :finsuite


goto fin
:finkey

:aide
echo La syntaxe de cette commande est :
echo wifimap [/?] [/l] [[/k] [/d] "wifi_name"]
echo.
echo  [/?]    Ce manuel d'aide.
echo  [/l]    Liste des Reseaux sans fils deja utiliser
echo      {Possibilite d'utilise des caracteres generique pour affine la recherche}
echo      expl: wifimap /l "nom*reste"
echo  [/k "wifi_name"] Fais apparaitre la cle de securiter du reseau
echo  [/d "wifi_name"] Supprimer le profile wifi et ces interfaces
:finaide
goto fin

:deleteProfile
set ssid_name=%2

if /i -%2- equ -- (
 goto erreurD
) else (
 goto suiteD
)
goto findeleteProfile

:erreurD
echo Commande incomplet, Vous devez taper le "SSID" du wifi pour pouvoir supprimer son profile
echo Taper wifimap /? pour plus d'information
:finerreurD
goto fin

:suiteD
netsh wlan delete profile name=%ssid_name% i=*
:finsuiteD
goto fin

:findeleteProfile
goto fin

:fin
set ssid_name=
set ici=