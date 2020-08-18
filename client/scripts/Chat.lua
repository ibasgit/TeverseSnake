local Chat = {}
local Messages = {}

Chat.Init = function()
    local ChatBack = teverse.construct("guiFrame", {
        parent = teverse.interface,
        name = "ChatBack",
        position = guiCoord(0.005, 0, 0.01, 0),
        size = guiCoord(.3, 0, .25, 0),
        backgroundAlpha = 0
    })

    local ChatScrollFrame = teverse.construct("guiScrollView", {
        parent = ChatBack,
        name = "ChatScrollFrame",
        size = guiCoord(1,0,0.95,0),
        position = guiCoord(0,0,.025,0),
        canvasSize = guiCoord(0,0,0,0),
        backgroundAlpha = 0,
        backgroundColour = colour.rgb(176, 176, 176), 
        scrollbarWidth = 1
    })

    local ChatTextBox = teverse.construct("guiTextBox", {
        parent = teverse.interface,
        name = "ChatTextBox",
        size = guiCoord(.3,0,0.05,0),
        position = guiCoord(0.005,0,.26,0),
        backgroundAlpha = 0,
        backgroundColour = colour.rgb(176, 176, 176),
        dropShadowAlpha = 0.6,
        textColour = colour.rgb(255,255,255),
        textAlign = "middle",
        text = "",
        textEditable = true,
        textWrap = true,
    })

    local function CreateChat(Text, TableIndex, colour, FullColour)
        local ChatRichTextBox = teverse.construct("guiRichTextBox", {
            parent = ChatScrollFrame,
            size = guiCoord(.98,0,.15,0),
            position = ChatScrollFrame.position + guiCoord(0.02,0,-0.02, 0),
            backgroundAlpha = 0,
            backgroundColour = colour.rgb(176, 176, 176),
            dropShadowAlpha = 0.6,
            textColour = colour.rgb(255,255,255),
            text = Text,
            textWrap = true
        })

        ChatRichTextBox:setColour(1, colour)
        
        if not FullColour then
          local Split = string.split(ChatRichTextBox.text, " ")
          ChatRichTextBox:setColour(string.len(Split[1]) + 1, colour.rgb(255,255,255))
        end

        table.insert(Messages, ChatRichTextBox)
    end

    teverse.networking:on("message", function(text, SentColour, FullColour)
        if #ChatScrollFrame.children >= 40 then
            Messages[1]:destroy()
            table.remove(Messages, 1)
        end

        for i,v in pairs(Messages) do
            v.position = guiCoord(0.02,0,.15 * (#Messages - (i -1)),0)
        end

        ChatScrollFrame.canvasSize = guiCoord(1,0,.15 * (#ChatScrollFrame.children + 1),0)
        
        --// Creating colour this way is because sending colour.rgb(r, g, b) through networking does not work
        CreateChat(text, #ChatScrollFrame.children, colour.rgb(SentColour.r, SentColour.g, SentColour.b), FullColour)
    end)

    teverse.input:on("keyUp", function(keyCode)
        if keyCode == enums.keys["KEY_RETURN"] then
            teverse.networking:sendToServer("message", ChatTextBox.text)
            ChatTextBox.text = ""
        end
        
        --// todo: focus on TextBox when / is pressed, will be added when there is actual support for it
    end)

    local function MouseLeft()
        ChatScrollFrame.backgroundAlpha = 0.19
        ChatTextBox.backgroundAlpha = 0.19

        spawn(function()
            sleep(5)
            if ChatScrollFrame.backgroundAlpha ~= 0.2 then
                ChatScrollFrame.backgroundAlpha = 0
                ChatTextBox.backgroundAlpha = 0
            end
        end)
    end

    local function MouseEntered()
        ChatScrollFrame.backgroundAlpha = 0.2
        ChatTextBox.backgroundAlpha = 0.2
    end

    ChatScrollFrame:on("mouseEnter", MouseEntered)
    ChatTextBox:on("mouseEnter", MouseEntered)

    ChatScrollFrame:on("mouseExit", MouseLeft)
    ChatTextBox:on("mouseExit", MouseLeft)
end

return Chat