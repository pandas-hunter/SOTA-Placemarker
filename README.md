# SOTA-Placemarker
# Written by Rafael
Description: A placemarker add-on for Shroud of the Avatar game.

First--this script works only in the Shroud of the Avatar (SOTA) game.
Download SOTA here: https://www.shroudoftheavatar.com/
Or from Steam here: https://store.steampowered.com/app/326160/


Purpose: Placemarker allows players to save locations of interest and get the distance to a chosen saved location.

Installation:
Place the required files and folders into this folder:
[Your Game's Datapath]\Portalarium\Shroud of the Avatar\Lua

Mine is: C:\Users\Rafael\AppData\Roaming\Portalarium\Shroud of the Avatar\Lua

Required files:
placemarker.lua [script file]
Placemarker [folder]
    assets [folder]
        - bg.png
        - border.png
        - button.png
        - transparent_1x1.png
    data [empty folder]

In-game setup:
Open the game's chat console.
Create a new tab, or select an existing tab.
Click the gear icon and ensure `Lua` is checkmarked.

Placemarker's functions can be run by clicking on the buttons, but there are some commands that must be issued through the console.

Typed commands must be typed into the Local chat channel. Keep in mind, local chats are visible to other players and saved in the logs.

Type commands in local chat
- - -
Type: <!pmhelp> for list of commands
Type: <!pmsave> saves placemarks on your screen to a file
Type: <!pmload> loads placemarks from file
Type: <!mark some label> to manually enter a labelled placemark
Type: </lua unload> to remove the addon
Type: </lua reload> to reload the addon; and resets it
  
Button commands
- - -
[Mark] button to record without label
[X] to delete row from on-screen table
[T] to track distance to that placemark
[&] to append a single row to the data file
[Clear] to clear on-screen data table. Will not affect saved file
[Vis] toggle visibility of on-screen data table
[Save] to overwrite and save data file with on-screen data. Be careful
[Load] to clear on-screen data table and load places from file. Be careful
[Size -] decreases the size of all text and GUI elements
[Size +] increases the size of all text and GUI elements