import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Prompt
import XMonad.Prompt.Workspace
import XMonad.Prompt.Shell
-- For tri-monitor reordering
import qualified XMonad.StackSet as W
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.CopyWindow(copy)
import Graphics.X11.ExtraTypes.XF86
import System.IO
import Data.Monoid

--myWorkspaces = [ "1", "2", "3", "4", "5", "6", "7", "8", "web", "vm" ]
myWorkspaces = [ "1", "2", "3", "4", "5", "6", "7", "web", "vm" ]

main = do
    xmproc <- spawnPipe "/home/mshildt/.cabal/bin/xmobar /home/mshildt/.xmonad/xmobarrc"
    xmonad $ defaultConfig {
          workspaces = myWorkspaces
        , terminal   = "terminator"
        , manageHook = manageDocks <+> manageHook defaultConfig
        , layoutHook = avoidStruts  $  layoutHook defaultConfig
        , handleEventHook = mconcat
                          [ docksEventHook
                          , handleEventHook defaultConfig ]
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , modMask = mod4Mask
        , startupHook = setWMName "LG3D"
        , normalBorderColor = "#005566"
        } `additionalKeys` myKeys

myKeys =
    [ ((mod4Mask, xK_F12),          spawn "xscreensaver-command -lock")
    , ((0, xF86XK_AudioMute),        spawn "amixer set Master,0 toggle,mute")
    , ((0, xF86XK_AudioLowerVolume), spawn "amixer set Master,0 5%-")
    , ((0, xF86XK_AudioRaiseVolume), spawn "amixer set Master,0 5%+")
    , ((mod4Mask, xK_F11),           spawn "pkill -USR1 xmobar")
    , ((mod4Mask .|. shiftMask, xK_BackSpace), removeWorkspace)
    , ((mod4Mask .|. shiftMask, xK_v      ), selectWorkspace defaultXPConfig)
    , ((mod4Mask, xK_m                    ), withWorkspace defaultXPConfig (windows . W.shift))
    , ((mod4Mask .|. shiftMask, xK_m      ), withWorkspace defaultXPConfig (windows . copy))
    , ((mod4Mask .|. shiftMask, xK_r      ), renameWorkspace defaultXPConfig)
    , ((mod4Mask, xK_a      ), addWorkspacePrompt defaultXPConfig)
    , ((mod4Mask, xK_o      ), selectWorkspace defaultXPConfig)
    , ((mod4Mask, xK_x      ), shellPrompt defaultXPConfig)
    ]
    ++
    [((m .|. mod4Mask, key), screenWorkspace sc >>= flip whenJust (windows . f)) -- Replace 'mod1Mask' with your mod key of choice.
    | (key, sc) <- zip [xK_w, xK_e, xK_r] [0,2,1] -- was [0..] *** change to match your screen order ***
    , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++
    zip (zip (repeat (mod4Mask)) [xK_1..xK_9]) (map (withNthWorkspace W.greedyView) [0..])
    ++
    zip (zip (repeat (mod4Mask .|. shiftMask)) [xK_1..xK_9]) (map (withNthWorkspace W.shift) [0..])
    
