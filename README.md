# OSXChangeDesktopFix
Quick tool that aims to get rid of OS X's active window bug when switching desktop.

The bug in question is discussed here: https://discussions.apple.com/thread/5844062?tstart=0

# Usage
Open the project, compile and put the resulting binary in /Application or anywhere you want. Go to Settings -> Users & Groups -> (Select your main account) -> Login and add the app to your list of start-up items. Then open the tool manually. You might notice a quick flash when the active window quickly loses focus and is activated again the next time you switch desktops, I haven't found a fix for this yet. Anyway, still much faster than manually selecting your previous window every time you switch desktops ;)
