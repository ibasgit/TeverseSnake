--[[
    Made by Ins (Ya#1234)
    22/07/2020

    Feel free to DM me for any feature requests - I will keep on adding to this
]]

local PlayerList = {}
local Players = {}

local Tags = {
    [enums.membershipType["plus"]] = "[PLUS] ",
    [enums.membershipType["pro"]] = "[PRO] ",
}

function FindClient(Name)
    for index , value in pairs(Players) do
        if value.client.name == Name then
            return {i = index, v = value}
        end
    end

    return nil
end

PlayerList.GetChatColour = function(PlayerName)
    return FindClient(PlayerName).v["colour"]
end

PlayerList.Init = function()
    local PlayerBackFrame = teverse.construct("guiFrame", {
        parent = teverse.interface,
        name = "PlayerBackFrame",
        position = guiCoord(.845, 0, .01, 0),
        size = guiCoord(.15, 0, .4, 0),
        backgroundAlpha = 0
    })

    local PlayerScrollFrame = teverse.construct("guiScrollView", {
        parent = PlayerBackFrame,
        name = "PlayerScrollView",
        size = guiCoord(1,0,0.95,0),
        position = guiCoord(0,0,.025,0),
        canvasSize = guiCoord(0,0,0,0),
        backgroundAlpha = 0,
        backgroundColour = colour.rgb(176, 176, 176),
        scrollbarWidth = 1
    })

    local OriginalPosition = PlayerScrollFrame.position

    function CreatePlayerTextBox(PlayerName, TableIndex)
        return teverse.construct("guiRichTextBox", {
            parent = PlayerScrollFrame,
            size = guiCoord(1,0,.07,0),
            position = PlayerScrollFrame.position + guiCoord(0,0,.08 * TableIndex, 0),
            backgroundAlpha = .08,
            backgroundColour = colour.rgb(176, 176, 176),
            dropShadowAlpha = 0.6,
            textColour = colour.rgb(255,255,255),
            text = PlayerName,
            textAlign = "middle",
            textWrap = true
        })
    end

    function Update(Adding)
        PlayerScrollFrame.canvasSize = guiCoord(1, 0, (.08 * (#Players)) + 0.02, 0)

        PlayerScrollFrame:destroyChildren()
    
        for index, plr in pairs(Players) do
            local Client = plr.client
            local PlayerName = Client.name

            if Tags[Client.membership] then
                PlrName = Tags[Client.membership] .. PlayerName
            end

            CreatePlayerTextBox(PlayerName, index - 1)
         end
    end

    teverse.networking:on("_clientConnected", function(c)
        if not FindClient(c.name) then
            table.insert(Players, {client = c})
            Update()
        end
    end)

    teverse.networking:on("_clientDisconnected", function(client)   
        for i, v in pairs(Players) do
           if v.client.name == client.name then
              table.remove(Players, i)
              Update()
              
              print("Removed " .. client.name)
           end
        end
    end)

    for _, player in pairs(teverse.networking.clients) do
        if not FindClient(player.name) then
            table.insert(Players, {client = player})
            Update()
        end
    end

    local Opened = true

    teverse.input:on("keyDown", function(keyCode)
        if keyCode == enums.keys["KEY_TAB"] then
            if Opened then
                teverse.tween:begin(PlayerScrollFrame, .5, {
                    position = OriginalPosition + guiCoord(1.5,0,0,0)
                })
            else
                teverse.tween:begin(PlayerScrollFrame, .5, {
                    position = OriginalPosition
                }, "inOutQuad")

                --// This next bit is temporary as callback isn't working
                spawn(function()
                    sleep(.5)
                    Update()
                end)
            end

            Opened = not Opened
        end
    end)
end

return PlayerList