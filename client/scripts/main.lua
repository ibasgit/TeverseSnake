--// yes. this is messy. 

local PlayerList = require("scripts/PlayerList.lua")
PlayerList.Init()

local Chat = require("scripts/Chat.lua")
Chat.Init()

local Direction = nil

local GameFrame = teverse.construct("guiFrame", {
  parent = teverse.interface,
  position = guiCoord(0.3, 0, .175, 0),
  backgroundColour = colour.rgb(75, 222, 67),
  strokeAlpha = 1,
  strokeColour = colour.rgb(255, 255, 255),
  strokeRadius = 3,
  strokeWidth = 3,
  size = guiCoord(.4, 0, .7, 0),
})

teverse.construct("guiFrame", {
  parent = GameFrame,
  position = guiCoord(0, 0, 0, 0),
  backgroundColour = colour.rgb(75, 210, 67),
  size = guiCoord(.06, 0, .06, 0),
})

local BoardPositions = {}

for i2 = 1, 15 do
  local y = {}
  for i = 1 , 15 do
    local x = teverse.construct("guiFrame", {
      parent = GameFrame,
      name = tostring(i2 .. ":" .. i),
      position = guiCoord((i - 1) * .0665, 0, (i2 - 1) * 0.0665, 0),
      backgroundColour = (i % 2 == (i2 % 2)) and colour.rgb(75, 210, 67) or colour.rgb(84, 230, 76),
      size = guiCoord(.0665, 0, .0665, 0),
    })
  
    table.insert(y, x)
  end
  
  table.insert(BoardPositions, y)
end

local MiddleY = BoardPositions[math.ceil(#BoardPositions / 2)]
local MiddleX = MiddleY[math.ceil(#MiddleY / 2)]

local SnakeSegments 
local Cherry

local Running = false

local function startGame()
    Running = true
    
    if type(SnakeSegments) == "table" then
      for _,v in pairs(SnakeSegments) do
          v:destroy()
      end
    end
    
    SnakeSegments = {
      teverse.construct("guiFrame", {
        parent = GameFrame,
        position = MiddleX.position,
        size = guiCoord(.0665, 0, .0665, 0),
        zIndex = 2,
        backgroundAlpha = 1
      }),
      teverse.construct("guiFrame", {
        parent = GameFrame,
        position = MiddleX.position + guiCoord(0, 0, 0.0665 * 1, 0),
        size = guiCoord(.0665, 0, .0665, 0),
        zIndex = 2,
        backgroundAlpha = 1
      }),
      teverse.construct("guiFrame", {
        parent = GameFrame,
        position = MiddleX.position + guiCoord(0, 0, 0.0665 * 2, 0),
        size = guiCoord(.0665, 0, .0665, 0),
        zIndex = 2,
        backgroundAlpha = 1
      }),
    }
    
    while sleep(0.31) do
       if not Cherry then
          local Tile = BoardPositions[math.random(15)][math.random(15)]
          local RandomPos = Tile.position
          Cherry = {object = teverse.construct("guiImage", {
              parent = GameFrame,
              image = "fs:images/Cherry.png",
              backgroundAlpha = 0,
              position = RandomPos,
              zIndex = 1,
              size = guiCoord(.0665, 0, .0665, 0),
          }), tile = Tile}
       end
        
       if Direction then 
          local Y = math.ceil(SnakeSegments[1].position.scale.y / 0.06206666666) or 1
          local X = math.ceil(SnakeSegments[1].position.scale.x / 0.06206666666) or 1
          
          local Goto 

          if Direction == "UP" then
              if Y - 1 == 0 then
                  return 
              end
              
              Goto = BoardPositions[Y - 1][X]
          elseif Direction == "LEFT" then
              if X - 1 == 0 then
                  return 
              end
              
              Goto = BoardPositions[Y][X - 1]
           elseif Direction == "RIGHT" then
              if X + 1 == 16 then
                  return 
              end

              Goto = BoardPositions[Y][X + 1]
           elseif Direction == "DOWN" then
              if Y + 1 == 16 then
                  return 
              end

              Goto = BoardPositions[Y + 1][X]
          end
          
          teverse.tween:begin(SnakeSegments[1], .29, {
            position = Goto.position
          })
        
          if Goto == Cherry.tile then
              table.insert(SnakeSegments, teverse.construct("guiFrame", {
                parent = GameFrame,
                position = SnakeSegments[#SnakeSegments].position,
                size = guiCoord(.0665, 0, .0665, 0),
                zIndex = 2,
              }))
              
              Cherry.object:destroy()
              Cherry = nil
          end
          
          for i, v in pairs(SnakeSegments) do
              if i == 2 then
                  teverse.tween:begin(v, .29, {
                    position = BoardPositions[Y][X].position
                  })
              else 
                  if i ~= 1 then
                    teverse.tween:begin(v, .29, {
                      position = SnakeSegments[i - 1].position
                    })
                  end
              end
              
              spawn(function()
                  sleep(.29)
                  
                  local Y2 = math.ceil(v.position.scale.y / 0.06206666666) or 1
                  local X2= math.ceil(v.position.scale.x / 0.06206666666) or 1
                  
                  if i ~= 1 and BoardPositions[Y2][X2].position == Goto.position then
                      print("end game")
                  end
              end)
          end
       end
    end
    
    print("stopped")
    Running = false
end

teverse.input:on("keyDown", function(keyCode)
    if keyCode == enums.keys["KEY_W"] then
       if Direction ~= "DOWN" then
          Direction = "UP"
       end
    elseif keyCode == enums.keys["KEY_S"] then
       if Direction ~= "UP" then
          Direction = "DOWN"
       end
    elseif keyCode == enums.keys["KEY_A"] then
        if Direction ~= "RIGHT" then
          Direction = "LEFT"
        end
    elseif keyCode == enums.keys["KEY_D"] then
        if Direction ~= "LEFT" then
          Direction = "RIGHT"
        end
    elseif keyCode == enums.keys["KEY_R"] and not Running then
        startGame()
    end
end)
