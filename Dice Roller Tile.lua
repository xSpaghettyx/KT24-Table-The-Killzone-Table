-- KT dice roller Spaghetty Mod --
-- Custom Dice Support
-- Multiplayer Mode Support

diceTabL = {}
diceTabR = {}
diceTabY = {}
diceTabT = {}

zoneGUIDs = {
    ["Red Dice Zone"]  = "13867f",
    ["Blue Dice Zone"] = "e9f069",
    ["Yellow Dice Zone"]  = "241468",
    ["Teal Dice Zone"] = "d2c53b"
}

local size = 1
local dice6Image = ''
local diceColor = Color(1.0,1.0,1.0)
local WantedDiceNumber=1
local killTeam = 0
local autoRoll2 = 0
local frame = 0
local menu = 0
local enableUI = 0
local tuto = 0
local isRolling = {}

function onLoad()
  leftColor = {"Red","Yellow"}
  rightColor = {"Blue","Teal"}
    self.addContextMenuItem("Multiplayer Mode ON", multiplayerModeON)
    self.addContextMenuItem("Multiplayer Mode OFF", multiplayerModeOFF)

  self.registerCollisions(false)
end

function getSideColor(side)
  if side == "Left" then
    return leftColor
  else
    return rightColor
  end
end

function getColorHex(color)
  return Color.fromString(color):toHex()
end

function askSpawn(args)
  local player = args["player"]
  local number = args["number"]
  local auto = args["auto"]
  if isRolling[player.color] == 1 then return end
  spawnKill(player, number, auto)
end

function spawnKill_(args)
  spawnKill(args.player, args.number, args.autoRoll)
end

function getUnlockedObjectsFromZone(zoneName)
    local zone = getObjectFromGUID(zoneGUIDs[zoneName])
    if not zone then return {} end
    local objs = zone.getObjects()
    local out = {}
    for _, obj in ipairs(objs) do
        if not obj.getLock() then
            table.insert(out, obj)
        end
    end
    return out
end

function spawnKill(player, number, autoRoll)
    player.clearSelectedObjects()
    deleteDice(obj, player)

    local count = tonumber(number) or 0

    local zoneMap = {
        Red    = "Red Dice Zone",
        Blue   = "Blue Dice Zone",
        Yellow = "Yellow Dice Zone",
        Teal   = "Teal Dice Zone"
    }
    local zoneName = zoneMap[player.color] or "Blue Dice Zone"

    local templates = getUnlockedObjectsFromZone(zoneName)

    if #templates == 0 then
        for i = 1, count do
            local spawnParams = {
                type              = 'Die_6',
                position          = self.getPosition(),
                rotation          = {x=-90, y=0, z=0},
                scale             = {x=1+((size-1)*2), y=1+((size-1)*2), z=1+((size-1)*2)},
                sound             = true,
                snap_to_grid      = false,
                callback_function = function(obj) spawn_callback(obj, player, autoRoll, true, key) end
            }
            spawnObject(spawnParams)
        end
    else

        local offsetMap = {
            Red    = -4.8,
            Blue   = 4.8,
            Yellow = -13.5,
            Teal   = 13.5
        }
        local offset = offsetMap[player.color] or 0

        local gridPositions = getGrid(count, -1, -1, 2*size, offset)
        for i = 1, count do
            local template = templates[(i - 1) % #templates + 1]
            local cloned = template.clone({
                position     = gridPositions[i],
                rotation     = template.getRotation(),
                snap_to_grid = false
            })
            if cloned then
                spawn_callback(cloned, player, autoRoll, false, key)
            end
        end
    end
end


function spawn_callback(obj,player,autoRoll,defaultSpawn,key)
    local newobj = obj
    local timeToWait = 0.5

    if player.color == "Red" then
        table.insert(diceTabL,newobj)
    elseif player.color == "Blue" then
        table.insert(diceTabR,newobj)
    elseif player.color == "Yellow" then
        table.insert(diceTabY,newobj)
    elseif player.color == "Teal" then
        table.insert(diceTabT,newobj)
    end

    Wait.condition(
        function()
            newobj.addToPlayerSelection(player.color)

            -- Only tint if this was a default die spawn
            if defaultSpawn then
                newobj.setColorTint(player.color)
            end

            if autoRoll2 == 1 or autoRoll == 1 then
                Wait.time(function() roll(player) end,timeToWait)
            end
        end,
        function()
            return regroup(player)
        end
    )
end


function regroup(player)
  local buff = true
  local offset = -4.8

  if player.color == "Blue" then
    offset = -offset
  elseif player.color == "Yellow" then
    offset = 3 * offset
  elseif player.color == "Teal" then
    offset = -3 * offset
  end

  fixValue(player)
  getDiceNumber(player)

  for key,value in pairs(getGrid(getDiceNumber(player),-1,-1,2*size,offset)) do
    if player.color == "Red" then
      diceTabL[key].setRotation({x=diceTabL[key].getRotation().x,y=self.getRotation().y,z=diceTabL[key].getRotation().z})
      if diceTabL[key].setPositionSmooth(value, false, true) == false then
        buff = false
      end
    elseif player.color == "Blue" then
      diceTabR[key].setRotation({x=diceTabR[key].getRotation().x,y=self.getRotation().y,z=diceTabR[key].getRotation().z})
      if diceTabR[key].setPositionSmooth(value, false, true) == false then
        buff = false
      end
    elseif player.color == "Yellow" then
      diceTabY[key].setRotation({x=diceTabY[key].getRotation().x,y=self.getRotation().y,z=diceTabY[key].getRotation().z})
      if diceTabY[key].setPositionSmooth(value, false, true) == false then
        buff = false
      end
    elseif player.color == "Teal" then
      diceTabT[key].setRotation({x=diceTabT[key].getRotation().x,y=self.getRotation().y,z=diceTabT[key].getRotation().z})
      if diceTabT[key].setPositionSmooth(value, false, true) == false then
        buff = false
      end
    end
  end
  return buff
end

function getGrid(number,offx,offy,space,offset)
  local grid = {}
  local counter = 0
  if number > 3 then
    counter = 1
  end
  if number > 0 then
    table.insert(grid, getPoint(-counter + offset,0))
  end
  if number > 1 then
    table.insert(grid, getPoint(-counter + offset,2))
  end
  if number > 2 then
    table.insert(grid, getPoint(-counter + offset,-2))
  end
  if number > 3 then
    table.insert(grid, getPoint(counter + offset,2))
  end
  if number > 4 then
    table.insert(grid, getPoint(counter + offset,0))
  end
  if number > 5 then
    table.insert(grid, getPoint(counter + offset,-2))
  end

  return grid
end

function getPoint(relativeX, relativeZ)
  local pos = Vector(self.getPosition().x,self.getPosition().y,self.getPosition().z)
  local rot = self.getRotation()
  local angleY = -math.rad(rot.y -90)
  local newX = (relativeX * math.cos(angleY) - relativeZ * math.sin(angleY)) + pos.x
  local newY = pos.y + 4
  local newZ = (relativeZ * math.cos(angleY) + relativeX * math.sin(angleY)) + pos.z
  local final = vector(newX, newY, newZ)
  return final
end

function round(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

function fixValue(player)
  if player.color == "Red" then
    for key,value in pairs(diceTabL) do
      if value ~= nil then
        value.setValue(value.getValue())
      end
    end
  elseif player.color == "Blue" then
    for key,value in pairs(diceTabR) do
      if value ~= nil then
        value.setValue(value.getValue())
      end
    end
  elseif player.color == "Yellow" then
    for key,value in pairs(diceTabY) do
      if value ~= nil then
        value.setValue(value.getValue())
      end
    end
  elseif player.color == "Teal" then
    for key,value in pairs(diceTabT) do
      if value ~= nil then
        value.setValue(value.getValue())
      end
    end
  end
end

function deleteDice(obj, player)

  if player.color == "Red" then
    for key,value in pairs(diceTabL) do
      if value ~= nil then
        destroyObject(value)
      end
    end
  elseif player.color == "Blue" then
    for key,value in pairs(diceTabR) do
      if value ~= nil then
        destroyObject(value)
      end
    end
  elseif player.color == "Yellow" then
    for key,value in pairs(diceTabY) do
      if value ~= nil then
        destroyObject(value)
      end
    end
  elseif player.color == "Teal" then
    for key,value in pairs(diceTabT) do
      if value ~= nil then
        destroyObject(value)
      end
    end
  end
  getDiceNumber(player)
end

function getDiceNumber(player)

  local diceNumber = 0
  local diceTabTemp = {}
  if player.color == "Red" then
    for key,value in pairs(diceTabL) do
      if value ~= nil then
        diceNumber = diceNumber + 1
        table.insert(diceTabTemp,value)
      end
    end
    diceTabL = diceTabTemp
  elseif player.color == "Blue" then
    for key,value in pairs(diceTabR) do
      if value ~= nil then
        diceNumber = diceNumber + 1
        table.insert(diceTabTemp,value)
      end
    end
    diceTabR = diceTabTemp
  elseif player.color == "Yellow" then
    for key,value in pairs(diceTabY) do
      if value ~= nil then
        diceNumber = diceNumber + 1
        table.insert(diceTabTemp,value)
      end
    end
    diceTabY = diceTabTemp
  elseif player.color == "Teal" then
    for key,value in pairs(diceTabT) do
      if value ~= nil then
        diceNumber = diceNumber + 1
        table.insert(diceTabTemp,value)
      end
    end
    diceTabT = diceTabTemp
  end
  return diceNumber
end

function setDiceValue()
  all = 0
  for i=1,6 do
    buff = 0
    for k,v in ipairs(diceTabL) do
      if v ~= nil and v.getValue() == i  then
        buff = buff + 1
      end
    end
    all = all + buff
    self.UI.setValue('r'..i,buff)
    Global.UI.setValue('r'..i,buff)
  end

  self.UI.setValue('rA',all)
  Global.UI.setValue('rA',all)

  all = 0
  for i=1,6 do
    buff = 0
    for k,v in ipairs(diceTabR) do
      if v ~= nil and v.getValue() == i  then
        buff = buff + 1
      end
    end
    all = all + buff
    self.UI.setValue('b'..i,buff)
    Global.UI.setValue('b'..i,buff)
  end

  self.UI.setValue('bA',all)
  Global.UI.setValue('bA',all)

  all = 0
  for i=1,6 do
    buff = 0
    for k,v in ipairs(diceTabY) do
      if v ~= nil and v.getValue() == i  then
        buff = buff + 1
      end
    end
    all = all + buff
    self.UI.setValue('y'..i,buff)
    Global.UI.setValue('y'..i,buff)
  end

  self.UI.setValue('yA',all)
  Global.UI.setValue('yA',all)

  all = 0
  for i=1,6 do
    buff = 0
    for k,v in ipairs(diceTabT) do
      if v ~= nil and v.getValue() == i  then
        buff = buff + 1
      end
    end
    all = all + buff
    self.UI.setValue('t'..i,buff)
    Global.UI.setValue('t'..i,buff)
  end

  self.UI.setValue('tA',all)
  Global.UI.setValue('tA',all)
end

function onUpdate()
  if frame > 20 then
    frame = 0
    setDiceValue()
  else
    frame = frame +1
  end
end

function roll(player)

  if getDiceNumber(player) ~= 0 then
    for key,value in pairs(player.getSelectedObjects()) do
      value.roll()
      value.roll()
    end
  end
  if isRolling[player.color] ~= 1 then
    isRolling[player.color] = 1
    Wait.time(function() order(player) end, 2.2)
  end
end

function order(player)

  fixValue(player)

  for diceValue=1, 6, 1 do
    local diceIndex = 0
    local tabLength = 0
    local diceTabTemp = {}
    local diceTabCurrent = {}

    if player.color == "Red" then
      diceTabCurrent = diceTabL
    elseif player.color == "Blue" then
      diceTabCurrent = diceTabR
    elseif player.color == "Yellow" then
      diceTabCurrent = diceTabY
    elseif player.color == "Teal" then
      diceTabCurrent = diceTabT
    end

    for key,value in pairs(diceTabCurrent) do
      if diceTabCurrent[key] ~= nil then
        if diceTabCurrent[key].getRotationValue() == diceValue then
          table.insert(diceTabTemp, diceTabCurrent[key])
          tabLength = tabLength + 1
        end
      end
    end

    local count = 0
    for key,value in pairs(diceTabTemp) do
      diceTabTemp[key].setRotation({x=diceTabTemp[key].getRotation().x,y=self.getRotation().y,z=diceTabTemp[key].getRotation().z})
      local p = -count- 2
      if player.color == rightColor then p = -p end
      diceTabTemp[key].setPositionSmooth(getPoint(p, (-diceValue*1.17)+4.66),false, true)
      count = count + 1.1
    end
  end

  printresultsTable(player)
end

function selectValueP(player,valueDice)

  if valueDice == "0" then
    local lowestSoFar = 7
    local lowestItemSoFar = nil

    player.clearSelectedObjects()
    if player.color == "Red" then
      for key,value in pairs(diceTabL) do
        if value ~= nil and value.getRotationValue() < lowestSoFar then
          lowestSoFar = value.getRotationValue()
          lowestItemSoFar = value
        end
      end
    elseif player.color == "Blue" then
      for key,value in pairs(diceTabR) do
        if value ~= nil and value.getRotationValue() < lowestSoFar then
          lowestSoFar = value.getRotationValue()
          lowestItemSoFar = value
        end
      end
    elseif player.color == "Yellow" then
      for key,value in pairs(diceTabY) do
        if value ~= nil and value.getRotationValue() < lowestSoFar then
          lowestSoFar = value.getRotationValue()
          lowestItemSoFar = value
        end
      end
    elseif player.color == "Teal" then
      for key,value in pairs(diceTabT) do
        if value ~= nil and value.getRotationValue() < lowestSoFar then
          lowestSoFar = value.getRotationValue()
          lowestItemSoFar = value
        end
      end
    end

    if lowestItemSoFar ~= nil then
      lowestItemSoFar.addToPlayerSelection(player.color)
    end
    return
  end

  player.clearSelectedObjects()
  if player.color == "Red" then
    for key,value in pairs(diceTabL) do
      if value ~= nil and value.getRotationValue() <= tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  elseif player.color == "Blue" then
    for key,value in pairs(diceTabR) do
      if value ~= nil and value.getRotationValue() <= tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  elseif player.color == "Yellow" then
    for key,value in pairs(diceTabY) do
      if value ~= nil and value.getRotationValue() <= tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  elseif player.color == "Teal" then
    for key,value in pairs(diceTabT) do
      if value ~= nil and value.getRotationValue() <= tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  end
  getDiceNumber(player)
end

function selectValue(player,valueDice)

  player.clearSelectedObjects()

  if player.color == "Red" then
    for key,value in pairs(diceTabL) do
      if value ~= nil and value.getRotationValue() == tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  elseif player.color == "Blue" then
    for key,value in pairs(diceTabR) do
      if value ~= nil and value.getRotationValue() == tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  elseif player.color == "Yellow" then
    for key,value in pairs(diceTabY) do
      if value ~= nil and value.getRotationValue() == tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  elseif player.color == "Teal" then
    for key,value in pairs(diceTabT) do
      if value ~= nil and value.getRotationValue() == tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  end
  getDiceNumber(player)
end

function destroyValueP(player,valueDice)

  if(valueDice == "1") then
    valueDice = "7"
  end

  if player.color == "Red" then
    for key,value in pairs(diceTabL) do
      if value ~= nil and value.getRotationValue() < tonumber(valueDice) then
        destroyObject(value)
      end
    end
  elseif player.color == "Blue" then
    for key,value in pairs(diceTabR) do
      if value ~= nil and value.getRotationValue() < tonumber(valueDice) then
        destroyObject(value)
      end
    end
  elseif player.color == "Yellow" then
    for key,value in pairs(diceTabY) do
      if value ~= nil and value.getRotationValue() < tonumber(valueDice) then
        destroyObject(value)
      end
    end
  elseif player.color == "Teal" then
    for key,value in pairs(diceTabT) do
      if value ~= nil and value.getRotationValue() < tonumber(valueDice) then
        destroyObject(value)
      end
    end
  end
  getDiceNumber(player)
  selectAll(player)
end

function selectAll(player)

  player.clearSelectedObjects()

  if player.color == "Red" then
    for key,value in pairs(diceTabL) do
      if value ~= nil then
        value.addToPlayerSelection(player.color)
      end
    end
  elseif player.color == "Blue" then
    for key,value in pairs(diceTabR) do
      if value ~= nil then
        value.addToPlayerSelection(player.color)
      end
    end
  elseif player.color == "Yellow" then
    for key,value in pairs(diceTabY) do
      if value ~= nil then
        value.addToPlayerSelection(player.color)
      end
    end
  elseif player.color == "Teal" then
    for key,value in pairs(diceTabT) do
      if value ~= nil then
        value.addToPlayerSelection(player.color)
      end
    end
  end
  getDiceNumber(player)
end

destroyTimer = 0

function timerDestroy()
  destroyTimer = 0
end

function toggleMenu(player,value,id)

  if menu == 0 then
    menu = 1
    self.UI.show('menu')
  else
    menu = 0
    self.UI.hide('menu')
  end
end

function toggleUI(player)

  local side = "Left"
  if player.color == rightColor then
    side = "Right"
  end

  if enablePlayerUI == nil then
    enablePlayerUI = {
      Left = false,
      Right = false
    }
  end

  if enablePlayerUI[side] == false then
    enablePlayerUI[side] = true
  else
    enablePlayerUI[side] = false
  end

  local visibility = ""
  if enablePlayerUI["Left"] == true then
    visibility = leftColor
  end

  if enablePlayerUI["Right"] == true then
    if visibility ~= "" then
      visibility = visibility.."|"
    end
    visibility = visibility..rightColor
  end

  if visibility == "" then
    Global.UI.setAttribute('diceUI', 'active', 'false')
    self.UI.setAttribute('UIB', 'color', '#cccccc')
    --Global.UI.setAttribute('dicePrintUI', 'active', 'false')
  else
    Global.UI.setAttribute('diceUI', 'active', 'true')
    self.UI.setAttribute('UIB', 'color', '#9cd310')
    --Global.UI.setAttribute('dicePrintUI', 'active', 'true')
  end

  Global.UI.setAttribute('diceUI', 'visibility', visibility)
  --Global.UI.setAttribute('dicePrintUI', 'visibility', visibility)
end

function toggleRoll()
  if autoRoll2 == 0 then
    autoRoll2 = 1
    self.UI.setAttribute('autoB', 'color', '#9cd310')
  else
    autoRoll2 = 0
    self.UI.setAttribute('autoB', 'color', '#cccccc')
  end
end

function toggleTuto()
  if tuto == 0 then
    tuto = 1
    self.UI.setAttribute('tuto', 'active', 'true')
    self.UI.setAttribute('tutoB', 'color', '#9cd310')
  else
    tuto = 0
    self.UI.setAttribute('tuto', 'active', 'false')
    self.UI.setAttribute('tutoB', 'color', '#cccccc')
  end
end

function zoom(player)
  player.lookAt(
    {
      position = self.getPosition(),
      pitch    = self.getRotation().x + 75,
      yaw      = self.getRotation().y + 270,
      distance = 20*size,
    })
end

function setDice(args)
  local player = args["player"]
  local color = player.color
  local diceTab = args["diceTabTemp"]

  if color == "Red" then
    diceTabL = diceTab
    for _, die in pairs(diceTabL) do
      local rot = die.getRotation()
      die.setRotation({x = rot.x, y = self.getRotation().y, z = rot.z})
    end
  elseif color == "Blue" then
    diceTabR = diceTab
    for _, die in pairs(diceTabR) do
      local rot = die.getRotation()
      die.setRotation({x = rot.x, y = self.getRotation().y, z = rot.z})
    end
  elseif color == "Yellow" then
    diceTabY = diceTab
    for _, die in pairs(diceTabY) do
      local rot = die.getRotation()
      die.setRotation({x = rot.x, y = self.getRotation().y, z = rot.z})
    end
  elseif color == "Teal" then
    diceTabT = diceTab
    for _, die in pairs(diceTabT) do
      local rot = die.getRotation()
      die.setRotation({x = rot.x, y = self.getRotation().y, z = rot.z})
    end
  end

  selectAll(player)
end


function printresultsTable(player)
  isRolling[player.color] = 0

  local params = {
    resultTab = {},
    player_name = player.steam_name,
    color = player.color
  }

  if player.color == "Red" then
    params.resultTab = diceTabL
  elseif player.color == "Blue" then
    params.resultTab = diceTabR
  elseif player.color == "Yellow" then
    params.resultTab = diceTabY
  elseif player.color == "Teal" then
    params.resultTab = diceTabT
  end

  announceResults(params)

end

function announceResults(params)
  local resultTab = params["resultTab"]
  local player_name = params["player_name"]
  local color = params["color"]

  local rolls_for_log={}
  local result = ""
  for i=1,6,1 do
    for key,value in pairs(resultTab) do
      local rolledValue = 0
      if type(value) == "number" then
        rolledValue = value
      else
        rolledValue = value.getValue()
      end
      if rolledValue == i then
        if result ~= "" then
          result = result .. ", "
        end
        result = result .. tostring(i)
        rolls_for_log[#rolls_for_log+1] = rolledValue
      end
    end
  end

  local time = '[' .. os.date("%H") .. ':' .. os.date("%M") .. ':' .. os.date("%S") .. '] '
  local message = time .. " " .. player_name .. " rolls: " .. result
  broadcastToAll(message, stringColorToRGB(color))
  -- add rolls to game log
  local gamelogGuid = 'bafa93'
  getObjectFromGUID(gamelogGuid).call('gameLogAppendRoll', {rolls=rolls_for_log, player=player_name})
end

function multiplayerModeON()
	multiplayerDiceUION()
end

function multiplayerModeOFF()
	multiplayerDiceUIOFF()
end

function multiplayerDiceUION()
    self.UI.show('yColumn')
    self.UI.show('yButtons')
    self.UI.show('tButtons')
    self.UI.show('tColumn')
end

function multiplayerDiceUIOFF()
    self.UI.hide('yColumn')
    self.UI.hide('yButtons')
    self.UI.hide('tButtons')
    self.UI.hide('tColumn')
end