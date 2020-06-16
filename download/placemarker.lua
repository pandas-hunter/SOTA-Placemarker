--[[
	Placemarker
	Author: Rafael
	Date: 6/3/20
	Notes: This script must be run within SOTA in order to make  API calls,
	i.e. it will not work in an IDE. Any functions or globals that begin with "Shroud"
	are maintained on the SOTA server, and are not visible in a local IDE.
]] --

-- %%%%
function ShroudOnStart()
    VERSION = "1.1"
    OPS = "Win10"
    LUA = "Lua 5.1.5"
    DATAPATH = ShroudDataPath .. "\\Portalarium\\Shroud of the Avatar\\Lua"
    CHARACTER = ShroudGetPlayerName()
    MYPOITABLE = {} -- stores the entire table of data
    DISPLAYTABLE = {} -- stores a paginated slice of the data
    ROWTABLE = {} -- stores the row and index of the table on GUI. Used for correlating clicks to rows
    TRACK = {} -- stores the placemark that's currently being tracked
    CURRENT_PAGE = 0 -- stores the current page being viewed on GUI
    MAX_ENTRIES = 10 -- maxium number of rows to display per page on GUI
    MAX_PAGES = 0 -- stores the total number of pages needed. Will recalculate after the data has been loaded
    FIRST_INDEX = 1 -- stores the true start index in relation to MYPOITABLE. E.g. if on page 2, FIRST_INDEX == 11
    LAST_INDEX = MAX_ENTRIES -- stores the true last index in relation to MYPOITABLE. E.g. if on page 2, LAST_INDEX == 20
    INDEX = 1
    SCREEN_H = nil
    SCREEN_W = nil
    TABLEFONTSIZE = 19
    BUTTON_HEIGHT = TABLEFONTSIZE * 5
    BUTTON_HEIGHT = TABLEFONTSIZE * 5
    PAD = TABLEFONTSIZE * 2
    COLOR = "ffffff"
    X = 0
    Y = 0
    TABLEON = 1 -- Toggles table visibility, 1/0
    VISCOLOR = "#008000"
    DIST = nil

    SetAssets()
    ShroudConsoleLog(" ")
    ShroudConsoleLog(string.format("- - -"))
    ShroudConsoleLog(string.format("Placemarker Addon"))
    ShroudConsoleLog(string.format("Version: %s", VERSION))
    ShroudConsoleLog(string.format("Tested on %s/%s", OPS, LUA))
    ShroudConsoleLog(string.format("The current time is %s", TimeStamp()))
    ShroudConsoleLog(string.format("Send gifts to [00ffff]Rafael[ffffff]"))
    ShroudConsoleLog("- - -")
    ShroudConsoleLog(" ")
    ShroudConsoleLog(string.format("Greetings, %s", CHARACTER))
    ShroudConsoleLog(" ")
    ShroudConsoleLog(string.format("Type in local: <!pmhelp> for list of commands"))
end

function ShroudOnConsoleInput(channel, source, message)
    if channel == "Local" and source == string.match(CHARACTER, source) then
        if string.match(message, "!mark") then
            local _, label_text = string.find(message, "!mark")
            local subString = string.sub(message, label_text + 1)
            GrabLocation(subString)
            UpdatePages("forward")
            PrintConsole(MYPOITABLE)
        end
        if string.match(message, "!pmsave") then
            SaveLocations(MYPOITABLE)
        end
        if string.match(message, "!pmload") then
            LoadSavedLocations()
        end
        if string.match(message, "!pmrestore") then
            LoadSavedLocations(true)
            UpdatePages("forward")
        end
        if string.match(message, "!pmhelp") then
            Help()
        end
    end
end

function ShroudOnUpdate()

    if #TRACK > 0 then
        if TRACK[1][2] == ShroudGetCurrentSceneName() then
            DIST = Distance()
            Dist_Error = false
        else
            -- user selected a track which was not in the scene
            DIST = nil
            Dist_Error = true
        end
    else
        DIST = nil
    end

end

function ShroudOnGUI()
    DrawMenu()
    DrawTable()
end

function DrawMenu() -- Called on the GUI. Be careful what you process here.

    if SCREEN_H == nil  or SCREEN_W == nil then
        SetAssets()
        --ShroudConsoleLog("read screen size on GUI")
    end

-- Mark Button: Records location at time of click,  but with no label
    if
        ShroudButton(
            SCREEN_W - (BUTTON_WIDTH),
            SCREEN_H - (BUTTON_HEIGHT),
            BUTTON_WIDTH,
            BUTTON_HEIGHT,
            TransTexture,
            string.format("<size=%d>Mark</size>", TABLEFONTSIZE),
            "Mark"
        ) == true
     then
        if CURRENT_PAGE < 1 then
            CURRENT_PAGE = 1
        end
        local newLocation = GrabLocation("NA")
        --CURRENT_PAGE = MAX_PAGES
        UpdatePages("mark")
        ConsoleLog("POI Recorded")
        PrintConsole(newLocation)
    end

    -- Size +: Increase the size of everything, it scales linearly, and not so elegant.
    if
        ShroudButton(
            SCREEN_W - (BUTTON_WIDTH * 2),
            SCREEN_H - (BUTTON_HEIGHT),
            BUTTON_WIDTH,
            BUTTON_HEIGHT,
            TransTexture,
            string.format("<size=%d>Size +</size>", TABLEFONTSIZE),
            "Increase"
        ) == true
     then
        TABLEFONTSIZE = TABLEFONTSIZE + 1
        PAD = TABLEFONTSIZE * 2.5
        SetAssets()
    end

    -- Size -: Decrease the size of everything, linearly.
    if
        ShroudButton(
            SCREEN_W - (BUTTON_WIDTH * 3),
            SCREEN_H - (BUTTON_HEIGHT),
            BUTTON_WIDTH,
            BUTTON_HEIGHT,
            TransTexture,
            string.format("<size=%d>Size -</size>", TABLEFONTSIZE),
            "Decrease"
        ) == true
     then
        TABLEFONTSIZE = TABLEFONTSIZE - 1
        PAD = TABLEFONTSIZE * 2
        SetAssets()
    end

    -- Toggle visibility of the Data Table, controlled by the DrawTable()
    if
        ShroudButton(
            SCREEN_W - (BUTTON_WIDTH * 4),
            SCREEN_H - (BUTTON_HEIGHT),
            BUTTON_WIDTH,
            BUTTON_HEIGHT,
            TransTexture,
            string.format("<size=%d><color=%s>Vis</color></size>", TABLEFONTSIZE, VISCOLOR),
            "Show/Hide Table"
        ) == true
     then
        -- Toggle
        TABLEON = math.abs(TABLEON - 1)

        if TABLEON == 1 then
            VISCOLOR = "#008000"
        else
            VISCOLOR = "#b80c2e"
        end
    end

    -- Save the onscreen table to places.txt file, see SaveLocations()
    if
        ShroudButton(
            SCREEN_W - (BUTTON_WIDTH * 5),
            SCREEN_H - (BUTTON_HEIGHT),
            BUTTON_WIDTH,
            BUTTON_HEIGHT,
            TransTexture,
            string.format("<size=%d>Save</size>", TABLEFONTSIZE),
            "Save to file"
        ) == true
     then
        SaveLocations(MYPOITABLE)
    end


    -- Load clears current table and loads one from places.txt, see LoadSavedLocations()
    if
        ShroudButton(
            SCREEN_W - (BUTTON_WIDTH * 6),
            SCREEN_H - (BUTTON_HEIGHT),
            BUTTON_WIDTH,
            BUTTON_HEIGHT,
            TransTexture,
            string.format("<size=%d>Load</size>", TABLEFONTSIZE),
            "Load from file"
        ) == true
     then
        LoadSavedLocations(false)
        --CURRENT_PAGE = 1
        UpdatePages("forward")
    end

    -- Clear data table
    if
        ShroudButton(
            SCREEN_W - (BUTTON_WIDTH * 7),
            SCREEN_H - (BUTTON_HEIGHT),
            BUTTON_WIDTH,
            BUTTON_HEIGHT,
            TransTexture,
            string.format("<size=%d>Clear</size>", TABLEFONTSIZE),
            "Clear table"
        ) == true
     then
        DISPLAYTABLE = {}
        MYPOITABLE = {}
        TRACK = {}
        CURRENT_PAGE = 0
        MAX_PAGES = 0
    end
    -- Next Page Button
    if
        ShroudButton(
            SCREEN_W - (BUTTON_WIDTH * 8),
            SCREEN_H - (BUTTON_HEIGHT),
            BUTTON_WIDTH,
            BUTTON_HEIGHT,
            TransTexture,
            string.format("<size=%d>-></size>\n%d/%d", TABLEFONTSIZE-1, CURRENT_PAGE, MAX_PAGES),
            "Next Page"
        ) == true
     then
        --[[if MAX_PAGES > 0 then
            CURRENT_PAGE = CURRENT_PAGE + 1
        else
            CURRENT_PAGE = 0
        end

        if CURRENT_PAGE > MAX_PAGES then
            CURRENT_PAGE = 1
        end]]--
        UpdatePages("forward")
    end
    -- Last Page Button
    if
        ShroudButton(
            SCREEN_W - (BUTTON_WIDTH * 9),
            SCREEN_H - (BUTTON_HEIGHT),
            BUTTON_WIDTH,
            BUTTON_HEIGHT,
            TransTexture,
            string.format("<size=%d><-</size>\n%d/%d", TABLEFONTSIZE-1, CURRENT_PAGE, MAX_PAGES),
            "Last Page"
        ) == true
     then
        --[[if MAX_PAGES > 0 then
            CURRENT_PAGE = CURRENT_PAGE - 1
        else
            CURRENT_PAGE = 0
        end

        if CURRENT_PAGE < 1 then
            CURRENT_PAGE = MAX_PAGES
        end]]--
        UpdatePages("back")
    end

    -- Show distance if the track is in the same scene, otherwise show a  red message.
    if DIST then
        ShroudGUILabel(
            (SCREEN_W / 2) - 50,
            (SCREEN_H / 2.1),
            300,
            200,
            string.format("<size=%d><color=#00ff00>%.1f</color></size>", TABLEFONTSIZE, DIST)
        )
    end

    if Dist_Error then
        ShroudGUILabel(
            (SCREEN_W / 2) - 300,
            (SCREEN_H / 2.1),
            600,
            100,
            string.format(
                "<size=%d><color=#ff0000>Tracked placemark is not in this scene</color></size>",
                TABLEFONTSIZE
            )
        )
    end

end

function DrawTable() -- Called on the GUI. Be careful what you process here

    if SCREEN_H == nil  or SCREEN_W == nil then
        SetAssets()
        --ShroudConsoleLog("read screen size on GUI")
    end

    -- WORKING HERE.
    if TABLEON == 1 then
        for i, v in ipairs(DISPLAYTABLE) do
            local row = TableY + (i * PAD)
            local col = TableX
            -- Record the row Y-coordinate.
            -- I use this table to detect if a click was made close enough to the row
            ROWTABLE[i] = row
            -- The buttons

            ShroudGUILabel(
                col,
                row,
                TableRowWidth,
                TableRowHeight,
                string.format(
                    "<size=%d><color=%s>D:%s Scene: %s Label:%s X:%.1f Y:%.1f Z:%.1f</color></size>",
                    TABLEFONTSIZE,
                    v[7],
                    v[1],
                    v[2],
                    v[3],
                    v[4],
                    v[5],
                    v[6]
                )
            )
            -- Delete a row
            if
                ShroudButton(
                    col - PAD,
                    row,
                    SmallButtonWidth,
                    SmallButtonHeight,
                    TransTexture,
                    string.format("<size=%d>X</size>", TABLEFONTSIZE),
                    "Delete"
                ) == true
                then
                for index, buttrow in ipairs(ROWTABLE) do
                    -- Compute the INDEX for the MYPOITABLE from the current page
                    -- and row of the DISPLAYTABLE which only shows MAX_ENTRIES (10)  at a time
                    INDEX = index + (MAX_ENTRIES * (CURRENT_PAGE - 1))
                    -- find the row the button was near in ROWTABLE - using 10 px
                    if math.abs((ShroudMouseY - (buttrow + (SmallButtonHeight / 2)))) < 10 then
                        ShroudConsoleLog(string.format("Removed %s", MYPOITABLE[INDEX][3]))
                        table.remove(MYPOITABLE, INDEX)
                        UpdatePages("null")
                        if CURRENT_PAGE > MAX_PAGES then
                            CURRENT_PAGE = MAX_PAGES
                        end
                        UpdatePages("delete")
                    end
                end
            end
            if
                ShroudButton(
                    col - PAD * 2,
                    row,
                    SmallButtonWidth,
                    SmallButtonHeight,
                    TransTexture,
                    string.format("<size=%d>T</size>", TABLEFONTSIZE),
                    "Track"
                ) == true
                then
                for index, buttrow in ipairs(ROWTABLE) do
                    -- Compute the INDEX for the MYPOITABLE from the current page
                    -- and row of the DISPLAYTABLE which only shows MAX_ENTRIES (10)  at a time
                    INDEX = index + (MAX_ENTRIES * (CURRENT_PAGE - 1))
                    -- find what row the click was near - using 10 px
                    Dist_Error = false -- clear the error
                    if math.abs((ShroudMouseY - (buttrow + (SmallButtonHeight / 2)))) < 10 then
                        -- if the placemark is already being tracked, then clear it
                        if INDEX == TRACK[2] then
                            -- otherwise assign a new placemark to the track table
                            TRACK = {}
                            MYPOITABLE[INDEX][7] = "#ffffff"
                        elseif TRACK[2] then
                            MYPOITABLE[TRACK[2]][7] = "#ffffff"
                            TRACK = {}
                        else
                            TRACK[1] = MYPOITABLE[INDEX]
                            TRACK[2] = INDEX
                            -- set new flaged row to gold
                            MYPOITABLE[INDEX][7] = "#ffd700"
                            ShroudConsoleLog(
                                string.format(
                                    "Tracking: %s, %.1f, %.1f, %.1f",
                                    TRACK[1][3],
                                    TRACK[1][4],
                                    TRACK[1][5],
                                    TRACK[1][6]
                                )
                            )
                        end
                    end
                end
            end
            if
                ShroudButton(
                    col - PAD * 3,
                    row,
                    SmallButtonWidth,
                    SmallButtonHeight,
                    TransTexture,
                    string.format("<size=%d>&</size>", TABLEFONTSIZE),
                    "Append to file"
                ) == true
                then
                for index, buttrow in ipairs(ROWTABLE) do
                    -- Compute the INDEX for the MYPOITABLE from the current page
                    -- and row of the DISPLAYTABLE which only shows MAX_ENTRIES (10)  at a time
                    INDEX = index + (MAX_ENTRIES * (CURRENT_PAGE - 1))
                    -- find the row the button was near in ROWTABLE -- Using 10 px
                    if math.abs((ShroudMouseY - (buttrow + (SmallButtonHeight / 2)))) < 10 then
                        --ShroudConsoleLog(string.format("Append placemark %s to file", MYPOITABLE[index][3]))
                        Append(MYPOITABLE[INDEX])
                    end
                end
            end
        end
    end
end

function PrintConsole(tbl)
    for i, v in pairs(tbl) do
        ShroudConsoleLog(string.format("T: %s", v[1]))
        ShroudConsoleLog(string.format("Scene: %s", v[2]))
        ShroudConsoleLog(string.format("Label: %s", v[3]))
        ShroudConsoleLog(string.format("X: %s", v[4]))
        ShroudConsoleLog(string.format("Y: %s", v[5]))
        ShroudConsoleLog(string.format("Z: %s", v[6]))
    end
end

function GrabLocation(label)
    local scene = ShroudGetCurrentSceneName()
    local X = ShroudPlayerX
    local Y = ShroudPlayerY
    local Z = ShroudPlayerZ
    -- write new entry into the global table
    table.insert(MYPOITABLE, {TimeStamp(), scene, label, X, Y, Z, "#ffffff"})
    ShroudConsoleLog(string.format("Placemark #: %d", #MYPOITABLE))
    -- return the new line in case we need to do something else with it... such as print
    return {{TimeStamp(), scene, label, X, Y, Z}}
end

function SetAssets()
    SCREEN_W = ShroudGetScreenX()
    SCREEN_H = ShroudGetScreenY()
    BUTTON_WIDTH = TABLEFONTSIZE * 5
    BUTTON_HEIGHT = TABLEFONTSIZE * 5
    TableX = SCREEN_W * .66
    TableY = SCREEN_H * .15
    SmallButtonWidth = TABLEFONTSIZE * 1.5
    SmallButtonHeight = TABLEFONTSIZE * 1.5
    TableRowWidth = SCREEN_W * .33
    TableRowHeight = SCREEN_H * .1

    ButtonTexture = ShroudLoadTexture("/Placemarker/assets/button.png")
    BGTexture = ShroudLoadTexture("Placemarker/assets/bg.png")
    BorderTexture = ShroudLoadTexture("Placemarker/assets/border.png")
    TransTexture = ShroudLoadTexture("Placemarker/assets/transparent_1x1.png")
end

function UpdatePages(direction)
    MAX_PAGES = math.ceil(#MYPOITABLE/10)
    if (direction == "forward") and (MAX_PAGES > 0) then
        if (CURRENT_PAGE >= MAX_PAGES) then
            CURRENT_PAGE = 1
        elseif CURRENT_PAGE <  MAX_PAGES then
            CURRENT_PAGE = CURRENT_PAGE + 1
        else
            CURRENT_PAGE = CURRENT_PAGE
        end
    end
    if direction == "back" then
        if CURRENT_PAGE <= 1 then
            CURRENT_PAGE = MAX_PAGES
        else
            CURRENT_PAGE = CURRENT_PAGE - 1
        end
    end

    if direction == "delete" then
        if CURRENT_PAGE > MAX_PAGES then
            CURRENT_PAGE = MAX_PAGES
        end
    end

    if direction == "mark" then
        CURRENT_PAGE = MAX_PAGES
    end

    if CURRENT_PAGE <= MAX_PAGES then
        FIRST_INDEX = (10 * (CURRENT_PAGE - 1)) + 1
        LAST_INDEX = 10 * CURRENT_PAGE
    end

    DISPLAYTABLE = SliceTable(MYPOITABLE, FIRST_INDEX, LAST_INDEX)
    --ShroudConsoleLog(string.format("cpage = %d, mpage = %d, findex = %d, lindex = %d",CURRENT_PAGE, MAX_PAGES, FIRST_INDEX, LAST_INDEX))


end

function TimeStamp()
    return os.date("%m-%d-%Y|%H:%M:%S")
end

function Distance()
    local pX = ShroudPlayerX
    local pY = ShroudPlayerY
    local pZ = ShroudPlayerZ

    local deltaX = math.abs(pX - TRACK[1][4])
    local deltaY = math.abs(pY - TRACK[1][5])
    local deltaZ = math.abs(pZ - TRACK[1][6])

    return math.sqrt((deltaX * deltaX) + (deltaY * deltaY) + (deltaZ * deltaZ))
end

function SaveLocations(tbl)

    -- Create a backup if there's an old file. It's just too easy to lose everything by saving over the same file.
    local filePath = DATAPATH .. "\\Placemarker\\data\\places.txt"
    local oldFP = DATAPATH .. "\\Placemarker\\data\\places.old"

    local old = os.remove(oldFP)
    local backup = os.rename(filePath, oldFP)
    if backup then
        ShroudConsoleLog(string.format("[ffd700]Backing up old file[ffffff]"))
    end

    local file = io.open(filePath, "w")
    for i, v in ipairs(tbl) do
        local line =
            string.format(
            "<D>%s</D> <SCENE>%s</SCENE> <LABEL>%s</LABEL> <X>%.1f</X> <Y>%.1f</Y> <Z>%.1f</Z> <C>%s</C>\n",
            v[1],
            v[2],
            v[3],
            v[4],
            v[5],
            v[6],
            v[7]
        )
        file:write(line)
    end
    ShroudConsoleLog(string.format("[ffd700]Saved %s places[ffffff]", #tbl))
    file:close()
    --
end

function LoadSavedLocations(restore)
    -- clear the table, hope you saved it!
    MYPOITABLE = {}
    local temp = {}
    -- parse text file by these tags
    local tags = {
        {"<C>", "</C>"},
        {"<Z>", "</Z>"},
        {"<Y>", "</Y>"},
        {"<X>", "</X>"},
        {"<LABEL>", "</LABEL>"},
        {"<SCENE>", "</SCENE>"},
        {"<D>", "</D>"}
    }

    local filePath = DATAPATH .. "\\Placemarker\\data\\places.txt"

    if restore == true then
        filePath = DATAPATH .. "\\Placemarker\\data\\places.old"
        --file = io.open(filePath, "r")
    end

    local file = io.open(filePath, "r")
    if file then
        file:close()

        -- Make a lua table
        local rowNumber = 1
        for line in io.lines(filePath) do
            local lineTable = {}
            for _, tag in ipairs(tags) do
                local _, tagOpen = string.find(line, tag[1])
                local tagClose, _ = string.find(line, tag[2])
                table.insert(lineTable, 1, string.sub(line, tagOpen + 1, tagClose - 1))
            end
            table.insert(MYPOITABLE, rowNumber, lineTable)
            rowNumber = rowNumber + 1
        end
        ShroudConsoleLog(string.format("[ffd700]Loaded %s places[ffffff]", #MYPOITABLE))
        
    else
        ShroudConsoleLog(string.format "[ff0000]Could not find places.txt[ffffff]")
    end
end

function Append(row)
    local line =
        string.format(
        "<D>%s</D> <SCENE>%s</SCENE> <LABEL>%s</LABEL> <X>%.1f</X> <Y>%.1f</Y> <Z>%.1f</Z> <C>%s</C>\n",
        row[1],
        row[2],
        row[3],
        row[4],
        row[5],
        row[6],
        row[7]
    )
    -- I cannot open the file in append mode. IDK why.
    -- Using a different approach. Open in r+, go to the end, then insert new line.
    local file = io.open(DATAPATH .. "\\Placemarker\\data\\places.txt", "r+")
    file:seek("end", 0)
    file:write(line)
    file:close()
    ShroudConsoleLog(string.format("[ffd700]Appended %s to your file[ffffff]", row[3]))
end

function SliceTable(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end

    return sliced
  end

function Help()
    ShroudConsoleLog(" ")
    ShroudConsoleLog("Helping you...")
    ShroudConsoleLog(string.format("Type commands in local chat"))
    ShroudConsoleLog(string.format("- - -"))
    ShroudConsoleLog(string.format("Type: <!pmhelp> for list of commands"))
    ShroudConsoleLog(string.format("Type: <!pmsave> saves placemarks on your screen to a file and backs up last file"))
    ShroudConsoleLog(string.format("Type: <!pmload> loads placemarks from file"))
    ShroudConsoleLog(string.format("Type: <!pmrestore> loads last backup"))
    ShroudConsoleLog(string.format("Type: <!mark some label> to manually enter a labelled placemark"))
    ShroudConsoleLog(string.format("Type: </lua unload> to remove the addon"))
    ShroudConsoleLog(string.format("Type: </lua reload> to reload the addon; and resets it"))
    ShroudConsoleLog(string.format(" "))
    ShroudConsoleLog(string.format("Button commands"))
    ShroudConsoleLog(string.format("- - -"))
    ShroudConsoleLog(string.format("[Mark] button to record without label"))
    ShroudConsoleLog(string.format("[X] to delete row from on-screen table"))
    ShroudConsoleLog(string.format("[T] to track distance to that placemark"))
    ShroudConsoleLog(string.format("[&] to append a single row to the data file"))
    ShroudConsoleLog(string.format("[Clr] to clear on-screen data table. Will not affect saved file"))
    ShroudConsoleLog(string.format("[Vis] toggle visibility of on-screen data table"))
    ShroudConsoleLog(string.format("[Save] to overwrite and save data file with on-screen data. Be careful"))
    ShroudConsoleLog(string.format("[Load] to clear on-screen data table and load places from file. Be careful"))
end