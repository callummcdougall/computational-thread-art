#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

:*:;nm::Callum 
:*:;fnm::Callum McDougall

:*:;shrug::¯\_(ツ)_/¯
:*:;upsmile::🙃

:*:;sig::Best,{Enter}Callum
:*:;lsig::Many thanks, {Enter}Callum

:*:;implies::⇒

:*:;camaddress::Room 2, Flat 5, The Lodge, Causewayside, Fen Causeway, Cambridge CB3 9HD
:*:;campost::CB3 9HD

:*:;eaaddress::18 Rugby St, London WC1N 3QZ, UK
:*:;eapost::WC1N 3QZ

:*:;bc::**````**{Left 3}
:*:;m::\(\){Left 2}
:*:;b::**** {Left 3}

:*:;def::{#}{#}{#}{#}{#}{#} Definition{Enter}
:*:h4::{#}{#}{#}{#}{Space}
:*:h5::{#}{#}{#}{#}{#}{Space}
:*:h6::{#}{#}{#}{#}{#}{#}{Space}

:*:;del::δ
:*:;t::θ
:*:;eps::ε
:*:;eta::η
:*:;pi::π
:*:;w::ω
:*:;rh::ρ
:*:;la::λ
:*:;x::ξ
:*:;mu::μ
:*:;al::α
:*:;be::β
:*:;ps::ψ
:*:;sm::σ
:*:;SM::Σ
:*:;gm::γ
:*:;GM::Λ
;	ςερτυθιοπασδφγηκλζχψωβνμ
;	ΘΠΣΔΦΓΞΛΨΩ

:*:;a-jn::
SendRaw from jupyter_to_anki import *
Send {Enter}
SendRaw write_cards_to_anki_package()

:*:;anki-code::
SendRaw content::CS::Python::___ src::Documentation::___
Send {Enter}(URL){Enter}[DECK] CS
Return

:*:;anki-math::
Send (URL){Enter}
SendRaw src::Cambridge_Tripos::III
Send {Enter}rgb(0, 0, 0){Enter}[DECK] Stats
Return

:*:;import-np::
FileRead, clipboard, C:\Users\calsm\Documents\PythonScripts\Dependencies\import-np.txt
Send ^v
Return

:*:;import-stats::
FileRead, clipboard, C:\Users\calsm\Documents\PythonScripts\Dependencies\import-stats.txt
Send ^v
Return

:*:;import-basic::
FileRead, clipboard, C:\Users\calsm\Documents\PythonScripts\Dependencies\import-basic.txt
Send ^v
Return

:*:;import-display::
FileRead, clipboard, C:\Users\calsm\Documents\PythonScripts\Dependencies\import-display.txt
Send ^v
Return

:*:;import-px::
FileRead, clipboard, C:\Users\calsm\Documents\PythonScripts\Dependencies\import-px.txt
Send ^v
Return

:*:;table::
Send __ | __{Enter}------------: | :------------{Enter}
Return

:*:woxicons::C:\Users\calsm\AppData\Local\Wox\app-1.4.1196\Plugins\Wox.Plugin.WebSearch