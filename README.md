# SOTA-Placemarker
### Written by Rafael

![Screenshot](placemarker_screenshot.png)
<h3>Description</h3>
A placemarker add-on for Shroud of the Avatar game.

<b>This script works only in the Shroud of the Avatar (SOTA) game.</b>

Download SOTA here: https://www.shroudoftheavatar.com/
Or from Steam here: https://store.steampowered.com/app/326160/

<b>Purpose</b>:
Placemarker allows players to save locations of interest and get the distance to a chosen saved location.

<b>Installation</b>:
Place the required files and folders into this folder:
[Your Game's Datapath]\Portalarium\Shroud of the Avatar\Lua

For example-
C:\Users\Rafael\AppData\Roaming\Portalarium\Shroud of the Avatar\Lua

<h3> In-game setup </h3>
* Open the game's chat console.<br />
* Create a new tab, or select an existing tab.<br />
* Click the gear icon and ensure `Lua` is checkmarked.<br />

Placemarker's functions can be run by clicking on the buttons, but there are some commands that must be issued through the console.

Typed commands must be typed into the Local chat channel. Keep in mind, local chats are visible to other players and saved in the logs.

<b>Type commands in local chat</b>
"!pmhelp": for list of commands
"!pmsave": saves placemarks on your screen to a file
"!pmload": loads placemarks from file
"!mark some label": to manually enter a labelled placemark
"/lua unload": to remove the addon
"/lua reload": to reload the addon; and resets it
  
<b>Button functions</b>
"Mark": record without label
"X": delete row from on-screen table
"T": track distance to that placemark
"&": append a single row to the data file
"Clear": clear on-screen data table. Will not affect saved file
"Vis": toggle visibility of on-screen data table
"Save": overwrite and save data file with on-screen data. Be careful
"Load": clear on-screen data table and load places from file. Be careful
"Size -": decreases the size of all text and GUI elements
"Size +": increases the size of all text and GUI elements
