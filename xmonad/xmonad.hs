import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import Graphics.X11.ExtraTypes.XF86
import System.IO

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar /home/mshildt/.xmonad/xmobarrc"
    xmonad $ defaultConfig
        { terminal   = "terminator"
        , manageHook = manageDocks <+> manageHook defaultConfig
        , layoutHook = avoidStruts  $  layoutHook defaultConfig
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , modMask = mod4Mask
        , startupHook = setWMName "LG3D"
        , normalBorderColor = "#005566"
        } `additionalKeys`
        [ ((mod4Mask, xK_F12),           spawn "xscreensaver-command -lock")
        , ((mod4Mask, xK_F2),            spawn "chromium")
        , ((0, xF86XK_AudioMute),        spawn "amixer set Master,0 toggle,mute")
        , ((0, xF86XK_AudioLowerVolume), spawn "amixer set Master,0 5%-")
        , ((0, xF86XK_AudioRaiseVolume), spawn "amixer set Master,0 5%+")
        , ((mod4Mask, xK_F11),           spawn "pkill -USR1 xmobar")
        ]
