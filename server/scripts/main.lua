local Chat = require("scripts/ServerChat.lua")
Chat.Init()

local function NotifyPlayerScore(client, score)
    Chat.ServerMessage(client.name .. " died in snake with a score of " .. score .. "!", nil, {r = 235, g= 225, b = 52})
end

spawn(function()
  while sleep(5) do
      NotifyPlayerScore({name = "Ins"}, 3424)
  end
end)