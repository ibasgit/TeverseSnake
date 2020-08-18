local ServerChat = {}
local AssignedColours = {}

local PlayerData = {}

local Colours = {
    {r = 122, g = 199, b = 40},
    {r = 232, g = 32, b = 79},
    {r = 13, g = 140, b = 219},
    {r = 242, g = 242, b = 65},
    {r = 122, g = 199, b = 40},
    {r = 232, g = 32, b = 79},
    {r = 13, g = 140, b = 219},
}

local ServerColour = {r = 255, g = 255, b = 255}
--[[colour.rgb(13, 140, 219),
    colour.rgb(232, 32, 79),
    colour.rgb(242, 242, 65)]]


ServerChat.ServerMessage = function(text, player, colour)
    if player then
        teverse.networking:sendToClient(player, "message", text, ServerColour)
    else
        teverse.networking:broadcast("message", text, colour or ServerColour, true)
    end
end

ServerMessage = ServerChat.ServerMessage

ServerChat.Init = function()
  teverse.networking:on("_clientConnected", function(client)
      AssignedColours[client.name] = Colours[(string.len(client.name) % (#Colours - 1)) + 1]
      ServerMessage(client.name .. " joined the game")

      PlayerData[client.name] = {SpamCount = 0, JustSent = false, Cooldown = 0}
  end)

  teverse.networking:on("_clientDisconnected", function(client)   
      AssignedColours[client.name] = nil
      ServerMessage(client.name .. " left the game")
  end)

  teverse.networking:on("message", function(client, message, targetPlayers)
      local Data = PlayerData[client.name]
      local ShouldReturn = false

      if Data.Cooldown > 0 then
          return ServerMessage("Please wait " .. Data.Cooldown .. " second(s) before sending another message", client)
      end

      if Data.JustSent then
          Data.SpamCount = Data.SpamCount + 1
      end

      if Data.SpamCount >= 5 then
          spawn(function()
              for i = 15, 1, -1 do
                  PlayerData[client.name].Cooldown = i
                  sleep(1)

                  if i == 1 then
                      Data.SpamCount = 0
                      Data.Cooldown = 0
                  end
              end 
          end)

          return ServerMessage("Please wait 15 second(s) before sending another message", client) 
      end
      
      for _ in string.gmatch(message,  "%s+") do
          ShouldReturn = true
      end
      
      for _ in string.gmatch(message,  "%w+") do
          ShouldReturn = false
      end

      if type(message) ~= "string" or ShouldReturn then
          return
      end

      if string.len(message) == 0 then
          return
      end

      spawn(function()
          if not Data.JustSent then
              Data.JustSent = true
              sleep(.3)
              Data.JustSent = false
          else
              Data.SpamCount = Data.SpamCount + 1
          end
      end)

      teverse.networking:broadcast("message", string.format("[%s]: %s", client.name, message), AssignedColours[client.name])
  end)
end

return ServerChat
