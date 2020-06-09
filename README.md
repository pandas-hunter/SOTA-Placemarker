# SOTA-Placemarker
### Written by Rafael

![Screenshot](placemarker_screenshot.png)
<h3>Description</h3>
A placemarker add-on for the game, "Shroud of the Avatar" (SOTA).
<br />
<b>This script works only in SOTA.</b>
<br />
<br />
Download SOTA here: https://www.shroudoftheavatar.com/ <br />
Or from Steam here: https://store.steampowered.com/app/326160/ <br />
<br />
<h3>Purpose</h3>
Placemarker allows players to save locations of interest and get the distance to a chosen saved location.
<br />
<br />
<h3>Installation</h3>
Place the contents of the download folder in this repo into your game's Lua folder<br />
<br />
[Your Game's Datapath]\Portalarium\Shroud of the Avatar\Lua
<br />
<br />
For example<br />
<br />
C:\Users\Rafael\AppData\Roaming\Portalarium\Shroud of the Avatar\Lua
<br />

![folderexample](lua_folder.PNG)
<h3> In-game setup </h3>
1. Open the game's chat console.<br />
2. Create a new tab, or select an existing tab.<br />
3. Click the gear icon and ensure `Lua` is checkmarked.<br />
<br />
Placemarker's functions can be run by clicking on the buttons, but there are some commands that must be issued through the console.<br />
<br />
Typed commands must be entered into the Local chat channel. Keep in mind, local chats are visible to other players and saved in the logs.<br />
<br />
<h3>Type commands in local chat</h3>
"!pmhelp": for list of commands<br />
"!pmsave": saves placemarks on your screen to a file<br />
"!pmload": loads placemarks from file<br />
"!mark some label": to manually enter a labelled placemark<br />
"/lua unload": removes all addons<br />
"/lua reload": reloads addons<br />
<br />
<h3>Button functions</h3>
"Mark": record without label<br />
"X": delete row from on-screen table<br />
"T": track distance to that placemark<br />
"&": append a single row to the data file<br />
"Clear": clear on-screen data table. Will not affect saved file<br />
"Vis": toggle visibility of on-screen data table<br />
"Save": overwrite and save data file with on-screen data. Be careful<br />
"Load": clear on-screen data table and load places from file. Be careful<br />
"Size -": decreases the size of all text and GUI elements<br />
"Size +": increases the size of all text and GUI elements<br />
