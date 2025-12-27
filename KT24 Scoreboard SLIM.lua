-- KT24 Base Table Scoreboard Spaghetty Mod --
-- Multiplayer Mode ver

function getCurrentAssets()
  local status, current = pcall(UI.getCustomAssets)
  return status and current or {}
end

function mergeAssets(existing, new)
  local seen = {}
  for _, asset in ipairs(existing) do
    seen[asset.name] = true
  end
  for _, asset in ipairs(new) do
    if not seen[asset.name] then
      table.insert(existing, asset)
      seen[asset.name] = true
    end
  end
  return existing
end

function safeSetCustomAssets(newAssets)
  local currentAssets = getCurrentAssets()
  local merged = mergeAssets(currentAssets, newAssets)
  UI.setCustomAssets(merged)
end


-- Bundled by luabundle {"rootModuleName":"Scoreboard.339b7f.lua","version":"1.6.0"}
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(nil)
__bundle_register("Scoreboard.339b7f.lua", function(require, _LOADED, __bundle_register, __bundle_modules)

require("base-board/scoreboard")

end)
__bundle_register("base-board/scoreboard", function(require, _LOADED, __bundle_register, __bundle_modules)

settingsNotes = "Scoreboard Settings"
scoreboardTag = "Kill Team Scoreboard"

opMap = {
  ["Crit Op"]="critop",
  ["Tac Op"]="tacop",
  ["Kill Op"]="killop",
}

defaultSettings = [[{
  "packet":{
    "name":"KT24 Multiplayer Mode",
    "players":[
      "Red",
      "Blue",
      "Yellow",
      "Teal"
    ],
    "autoPromote":true
  },
  "scoring":{
    "maxRounds":4,
    "max":21,
    "limitRecordToMax":false,
    "critop": {
      "max":6,
      "maxEach":0,
      "VPs":[
        "Crit Op 1",
        "Crit Op 2"
      ]
    },
    "tacop": {
      "max":6,
      "maxEach":0,
      "VPs":[
        "Tac Op 1",
        "Tac Op 2"
      ],
      "options": []
    },
    "killop": {
      "max":6,
      "maxEach":6,
      "VPs":[
      ]
    },
    "primary":{
      "max":3,
      "options": ["Crit Op", "Tac Op", "Kill Op"]
    },
    "secondary":{
      "max":6,
      "maxEach":2,
      "objectives":[

      ]
    },
    "bonus":{
      "max":0,
      "objectives":[
      ]
    }
  },
  "art":{
    "graphics":{
      "eventLogo":null,
      "eventBanner":null,
      "initiative":{
        "Off":"https://steamusercontent-a.akamaihd.net/ugc/1750182972143392609/48283228AFC1906F43CD6D39A402B3DC29EAE371/",
        "On":"https://steamusercontent-a.akamaihd.net/ugc/1750182972143393402/5BE39A862B6C1F71A467892906E21C0CD54C257E/"
      },
      "primary":{
        "Off":"https://steamusercontent-a.akamaihd.net/ugc/1750182972137668614/C48602D532FC7C6974B12FDD1B8C27CC3A9F9C32/",
        "On":"https://steamusercontent-a.akamaihd.net/ugc/1750182972137669364/44345B2435C44D87BB88DB3673E25ED6C4CB7F92/"
      }
    },
    "colors":{
      "lighter":"#e74f0aff",
      "background":"#353839",
      "darker":"#1B1B1B",
      "darkest":"#e74f0aff",
      "highlight":"#e74f0aff"
    },
    "gui":{
      "overlay":{
        "logoWidth":146,
        "logoHeight":150
      },
      "scoreboard":{
        "bannerWidth":1400,
        "bannerHeight":128,
        "width":1450,
        "primaryColumns":3,
        "layFlat":true
      }
    }
  }
}]]
setupMessage = "Performing the scoreboard setup"

function atrName(s)
  return "kts__" .. s
end

function atrOp(op_type, player, rule, round, k)
  return string.format("kts__%s_player%d_%d_%d_%s", op_type, player, rule, round, k)
end

function atrInitiative(player, round, k)
  return string.format("kts__initiative_player%d_%d_%s", player, round, k)
end

function atrKillOp(player, k)
  return string.format("kts__killop_player%d_%s", player, k)
end

function atrPrimaryOp(player, k)
  return string.format("kts__primaryop_player%d_%s", player, k)
end

function atrTacOp(player, k)
  return string.format("kts__tacop_player%d_%s", player, k)
end

paramPlayer = {atrName("player1"), atrName("player2"), atrName("player3"), atrName("player4")}

players = {}
playerNames = {}
playerNumber = {}

dropdowns = {}

rules = {}
scoring = {}


function onObjectDrop(player_color, dropped_object)
end

function getUIAttribute(id, attr)
  if UI.getAttribute(id, attr) ~= nil then
    return UI.getAttribute(id, attr)
  end
  if self.UI.getAttribute(id, attr) ~= nil then
    return self.UI.getAttribute(id, attr)
  end
end

function showUI(id)
  UI.show(id)
  self.UI.show(id)
end

function hideUI(id)
  UI.hide(id)
  self.UI.hide(id)
end

function setUIValue(id, value)
  UI.setValue(id, value)
  self.UI.setValue(id, value)
end

function setUIAttribute(id, attr, value)
  UI.setAttribute(id, attr, value)
  self.UI.setAttribute(id, attr, value)
end

function setUIAttributes(id, data)
  UI.setAttributes(id, data)
end

function refresh()
  for p, uiid in pairs(players) do
    local player = Player[p]
    if player.seated then
      playerNames[p] = player.steam_name
      if rules.packet.autoPromote and not (player.host or player.promoted) then
        player.promote()
      end
    else
      playerNames[p] = p
    end
    setUIValue(uiid, playerNames[p])
    local color = Color.fromString(p)
    local color1 = color:lerp(Color(1, 1, 1), 0.25)
    local color2 = color:lerp(Color(1, 1, 1), 0.6)
    setUIAttribute(uiid.."_panel", "color", "#"..color1:toHex())
    setUIAttribute(uiid.."_panel2", "color", "#"..color2:toHex())
  end
  refreshAll()
  updateInitiativeUI()
end

function refreshAll()
  for pl=1,4 do
    refreshCommandPoints(pl)
    refreshScoreUI(pl)
  end
end

function onPlayerChangeColor(pc)
  if pc == "Red" or pc == "Blue" or pc == "Yellow" or pc == "Teal" then
    if result == nil then result = {} end
    if result[Player[pc].steam_name] == nil then
      result[Player[pc].steam_name] = {}
    end
    result[Player[pc].steam_name].color = pc
    refresh()
  end
end

function onPlayerDisconnect(pc)
  refresh()
end

function makeOpScoreTable(op_type)
  local opScore = {}
  for k,_ in pairs(rules.scoring[op_type].VPs) do
    local scoreRow = {}
    for i=1, rules.scoring.maxRounds do
      scoreRow[i] = false
    end
    opScore[k] = scoreRow
  end
  return {
    score = opScore
  }
end

function calculateOpScore(op_type, pl)
  local plPrimaries = scoring[pl][op_type].score
  local total = 0
  local maxEach = rules.scoring[op_type].maxEach
  for k,_ in pairs(rules.scoring[op_type].VPs) do
    local orule = plPrimaries[k]
    local ototal = 0
    for v=1, rules.scoring.maxRounds do
      ototal = ototal + (orule[v] and 1 or 0)
    end
    if maxEach > 0 then
      total = total + math.min(ototal, maxEach)
    else
      total = total + ototal
    end
  end
  return math.min(total, rules.scoring[op_type].max)
end

function makeKillOpScoreTable()
  local killopScore = {
    score = 0
  }
  return killopScore
end

function makePrimaryOpScoreTable()
  local primaryScore = {
    selected = nil,
    revealed = false,
    score = 0
  }
  return primaryScore
end

function makeInitiativeScoreTable()
  local initiative = {}
  for i=1, rules.scoring.maxRounds do
    initiative[i]=false
  end
  return initiative
end

function calculateKillScore(pl)
  return math.min(
    scoring[pl].killop.score,
    rules.scoring.killop.max)
end

function calculatePrimaryScore(pl)
  local score = scoring[pl].primary.score
  if scoring[pl].primary.selection and scoring[pl].primary.revealed then
    local selected = opMap[scoring[pl].primary.selection]
    if selected == 'killop' then
      score = scoring[pl][selected].score
    else
      score = calculateOpScore(selected, pl)
    end
    score = math.ceil(score / 2.0)
  end
  return math.min(
    score,
  rules.scoring.primary.max)
end

function calculateScore(pl)
  local crit = calculateOpScore('critop', pl)
  local tac = calculateOpScore('tacop', pl)
  local kill = calculateKillScore(pl)
  local primary = calculatePrimaryScore(pl)
  return math.min(crit + tac + kill, rules.scoring.max), crit, tac, kill, primary
end

function resetScoring()
  broadcastToAll("rules updated, resetting score")

  scoring = {
    {
      critop=makeOpScoreTable('critop'),
      tacop=makeOpScoreTable('tacop'),
      killop=makeKillOpScoreTable(),
      primary=makePrimaryOpScoreTable(),
      initiative=makeInitiativeScoreTable(),
      command=3
    },
    {
      critop=makeOpScoreTable('critop'),
      tacop=makeOpScoreTable('tacop'),
      killop=makeKillOpScoreTable(),
      primary=makePrimaryOpScoreTable(),
      initiative=makeInitiativeScoreTable(),
      command=3
    },
    {
      critop=makeOpScoreTable('critop'),
      tacop=makeOpScoreTable('tacop'),
      killop=makeKillOpScoreTable(),
      primary=makePrimaryOpScoreTable(),
      initiative=makeInitiativeScoreTable(),
      command=3
    },
    {
      critop=makeOpScoreTable('critop'),
      tacop=makeOpScoreTable('tacop'),
      killop=makeKillOpScoreTable(),
      primary=makePrimaryOpScoreTable(),
      initiative=makeInitiativeScoreTable(),
      command=3
    }
  }
end

function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function deepcompare(t1,t2,ignore_mt)
  local ty1 = type(t1)
  local ty2 = type(t2)
  if ty1 ~= ty2 then return false end
  -- non-table types can be directly compared
  if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
  -- as well as tables which have the metamethod __eq
  local mt = getmetatable(t1)
  if not ignore_mt and mt and mt.__eq then return t1 == t2 end
  for k1,v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not deepcompare(v1,v2) then return false end
  end
  for k2,v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not deepcompare(v1,v2) then return false end
  end
  return true
end

function setup(settings)

  if not deepcompare(settings, rules, true) then
    local player1 = settings.packet.players[1]
    local player2 = settings.packet.players[2]
    local player3 = settings.packet.players[3]
    local player4 = settings.packet.players[4]

    players[player1] = paramPlayer[1]
    players[player2] = paramPlayer[2]
    players[player3] = paramPlayer[3]
    players[player4] = paramPlayer[4]
    
    playerNumber[player1] = 1
    playerNumber[player2] = 2
    playerNumber[player3] = 3
    playerNumber[player4] = 4
    rules = settings
    resetScoring()
  end
end

-- UI Builder

function buildScoreBanner(x, y, w, h)
  local ch = {}
  if rules.art.graphics.eventBanner then
    ch = {{
      tag="Image",
      attributes={
        image="eventBanner",
        height=h
      }
    }}
  else
    ch = {{
      tag="Text",
      attributes={
        class="title"
      },
      value=rules.packet.name
    }}
  end
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      rectAlignment="UpperCenter",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y))
    },
    children=ch
  }
end

function buildNameplate(x, y, w, h, player)
  local playerc = rules.packet.players[player]
  local ch = {{
    tag="Text",
    attributes={
      class="steamName",
      id=paramPlayer[player],
      color= string.format("#%s", Color.fromString(playerc):toHex())
    },
    value=playerc
  }}
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y))
    },
    children=ch
  }
end

function insertOpCel(t, x, y, w, h, op, op_type, rule, round, player)
  table.insert(t,{
        tag="Panel",
        attributes={
          rectAlignment="UpperLeft",
          width = w,
          height = h,
          offsetXY = string.format("%f %f", tostring(x), tostring(y))
        },
        children={
          {
            tag="Text",
            attributes={
              rectAlignment="UpperLeft",
              width = w,
              height = 32,
              offsetXY = "0 0"
            },
            value=op.VPs[rule]
          },
          {
            tag="Image",
            attributes={
              onClick="onOpPressed",
              id=atrOp(op_type, player, rule, round,"toggle"),
              rectAlignment="UpperCenter",
              class="scoreToggle",
              width=w,
              height=h - 36,
              offsetXY= string.format("0 %f", tostring(-32))
            }
          }
        }
      } )
end

function insertOpVps(ch, x, y, w, round, op, op_type, player, gap)
  local vps = #op.VPs
  local cols = math.min(vps, rules.art.gui.scoreboard.primaryColumns)
  local rows = math.ceil(vps/cols)
  local celw = math.floor(w/cols)
  local celh = 100
  local pch = {}
  local h = celh * rows

  for i=1,rows do
    local rcols = math.min(cols, vps-(i-1)*cols)
    local rofs = (cols - rcols)*celw*0.5
    for j=1,rcols do
      local rule = ((i-1)*cols + j)
      insertOpCel(pch, celw*(j-1) + rofs, -celh*(i-1), celw, celh, op, op_type, rule, round, player)
    end
  end

  table.insert(ch, {
    tag="Panel",
    attributes={
      class="bkgPanel",
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y))
    },
    children=pch
  })
  return h
end

function buildOpRow(t, uy, x, y, w, round, op, op_type, gap)
  local ch={}
  local primaryHeight = insertOpVps(ch, 0, 0, (w-3*gap)/4, round, op, op_type, 3)
  local h=primaryHeight
  insertOpVps(ch, (w-3*gap)/4 + gap, 0, (w-3*gap)/4, round, op, op_type, 1)
  insertOpVps(ch, (w-3*gap)/2 + 2*gap, 0, (w-3*gap)/4, round, op, op_type, 2)
  insertOpVps(ch, (w-3*gap)/4*3 + 3*gap, 0, (w-3*gap)/4, round, op, op_type, 4)
  table.insert(t, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children=ch
  })
  return h + uy-y
end

function buildInitiativeRow(t, uy, x, y, w, h, round)
  table.insert(t, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=150,
          height=h
        },
        children={
          {
            tag="Text",
            attributes={
              class="title2"
            },
            value=string.format("Round %d initiative", round)
          }
        }
      },
      {
        tag="Image",
        attributes={
          class="initiativeToggle",
          onClick="onInitiativePressed",
          id=atrInitiative(1, round, "toggle"),
          width=h*0.75, height=h*0.75,
          offsetXY = string.format("%f 0", -w/8)
        }
      },
      {
        tag="Image",
        attributes={
          class="initiativeToggle",
          onClick="onInitiativePressed",
          id=atrInitiative(2, round, "toggle"),
          width=h*0.75, height=h*0.75,
          offsetXY = string.format("%f 0", w/8)
        }
      },
      {
        tag="Image",
        attributes={
          class="initiativeToggle",
          onClick="onInitiativePressed",
          id=atrInitiative(3, round, "toggle"),
          width=h*0.75, height=h*0.75,
          offsetXY = string.format("%f 0", -w/8*3)
        }
      },
      {
        tag="Image",
        attributes={
          class="initiativeToggle",
          onClick="onInitiativePressed",
          id=atrInitiative(4, round, "toggle"),
          width=h*0.75, height=h*0.75,
          offsetXY = string.format("%f 0", w/8*3)
        }
      }
    }
  })
  return uy-y + h
end

function buildRowTitle(t, titleText, uy, x, y, w, h)
  table.insert(t, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=130,
          height=h
        },
        children={
          {
            tag="Text",
            attributes={
              class="title2"
            },
            value=titleText
          }
        }
      }
    }
  })
  return uy-y + h
end

function buildCritOpTotalRow(t, uy, x, y, w, h)
  table.insert(t, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=130,
          height=h
        },
        children={
          {
            tag="Text",
            attributes={
              class="title2"
            },
            value="Crit Op total"
          }
        }
      },
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__critoptotal_player1",
          offsetXY = string.format("%f 0", -w/8)
        },
        value=string.format("0/%d", rules.scoring.critop.max)
      },
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__critoptotal_player2",
          offsetXY = string.format("%f 0", w/8)
        },
        value=string.format("0/%d", rules.scoring.critop.max)
      },
            {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__critoptotal_player3",
          offsetXY = string.format("%f 0", -w/8*3)
        },
        value=string.format("0/%d", rules.scoring.critop.max)
      },
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__critoptotal_player4",
          offsetXY = string.format("%f 0", w/8*3)
        },
        value=string.format("0/%d", rules.scoring.critop.max)
      }
    }
  })
  return uy-y+h
end

function buildTacOpTotalRow(t, uy, x, y, w, h)
  table.insert(t, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=130,
          height=h
        },
        children={
          {
            tag="Text",
            attributes={
              class="title2"
            },
            value="Tac Op total"
          }
        }
      },
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__tacoptotal_player1",
          offsetXY = string.format("%f 0", -w/8)
        },
        value=string.format("0/%d", rules.scoring.tacop.max)
      },
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__tacoptotal_player2",
          offsetXY = string.format("%f 0", w/8)
        },
        value=string.format("0/%d", rules.scoring.tacop.max)
      },
            {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__tacoptotal_player3",
          offsetXY = string.format("%f 0", -w/8*3)
        },
        value=string.format("0/%d", rules.scoring.tacop.max)
      },
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__tacoptotal_player4",
          offsetXY = string.format("%f 0", w/8*3)
        },
        value=string.format("0/%d", rules.scoring.tacop.max)
      }
    }
  })
  return uy-y+h
end

function optionsFor(t, def, id)
  local ddo = {}
  local ddid = {}
  local opt = {
    {
      tag="Option",
      attributes={
        selected=true
      },
      value=def
    }
  }

  for k, v in pairs(t) do
    table.insert(opt, {
      tag="Option",
      value=v
    })
    ddo[v] = k
    ddid[k] = id..k
  end

  dropdowns[id] = {
    items=ddo,
    ids=ddid,
    selected=1
  }

  return opt
end

function buildTacOpSelector(ch, uy, x, y, w, player, sec)
  local h = 90
  local dd = atrTacOp(player, "dropdown")
  local vp = rules.packet.players[player]
  local cch = {
    {
      tag="Dropdown",
      attributes={
        onValueChanged="onTacOpSelected",
        id=dd,
        rectAlignment="UpperLeft",
        width=w,
        height=40,
        itemHeight=40,
        active=true
      },
      children=optionsFor(rules.scoring.tacop.options, "Hidden Tac Op", dd)
    },
    {
      tag="Text",
      attributes={
        class="title2",
        id=atrTacOp(player, "display"),
        rectAlignment="UpperLeft",
        width=w,
        height=40,
        active=false
      },
      value="Hidden Tac Op"
    },
    {
      tag="Button",
      attributes={
        id=atrTacOp(player, "button_reveal"),
        onClick="onTacOpReveal",
        width=w, height=40,
        fontSize=28,
        rectAlignment="LowerCenter",
        offsetXY="0 4",
        active=false,
        visibility=vp,
        text="Reveal Tac Op"
      }
    }
  }

  table.insert(ch, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children=cch
  })
  return uy-y+h
end

function buildPrimaryOpSelector(ch, uy, x, y, w, player, sec)
  local h = 135
  local dd = atrPrimaryOp(player, "dropdown")
  local vp = rules.packet.players[player]
  local cch = {
    {
      tag="Dropdown",
      attributes={
        onValueChanged="onPrimarySelected",
        id=dd,
        rectAlignment="UpperLeft",
        width=w,
        height=40,
        itemHeight=40,
        active=true
      },
      children=optionsFor(rules.scoring.primary.options, "Hidden Primary", dd)
    },
    {
      tag="Text",
      attributes={
        class="title2",
        id=atrPrimaryOp(player, "display"),
        rectAlignment="UpperLeft",
        width=w,
        height=40,
        active=false
      },
      value="u cant see this"
    },
    {
      tag="Text",
      attributes={
        class="title2",
        id=atrPrimaryOp(player, "amount"),
        rectAlignment="LowerCenter",
        width=w,
        height=40
      },
      value=string.format("0/%d", rules.scoring.primary.max)
    },
    {
      tag="Button",
      attributes={
        id=atrPrimaryOp(player, "button_reveal"),
        onClick="onPrimaryOpReveal",
        width=w, height=40,
        fontSize=28,
        rectAlignment="MiddleCenter",
        offsetXY="0 4",
        active=false,
        visibility=vp,
        text="Reveal Primary Op"
      }
    },
    {
      tag="Button",
      attributes={
        id=atrPrimaryOp(player, "button_plus"),
        onClick="onIncreasePrimaryOp",
        width=80, height=32,
        fontSize=28,
        rectAlignment="LowerRight",
        offsetXY="-4 4",
        text="+"
      }
    },
    {
      tag="Button",
      attributes={
        id=atrPrimaryOp(player, "button_minus"),
        onClick="onDecreasePrimaryOp",
        width=80, height=32,
        fontSize=28,
        rectAlignment="LowerLeft",
        offsetXY="4 4",
        text="-"
      }
    }
  }

  table.insert(ch, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children=cch
  })
  return uy-y+h
end

function buildKillOpSelector(ch, uy, x, y, w, player)
  local h = 90
  local dd = atrKillOp(player, "dropdown")
  local cch = {
    {
      tag="Text",
      attributes={
        id=dd,
        rectAlignment="UpperLeft",
        width=w,
        height=40,
        itemHeight=40
      },
      value="Kill Op"
    },
    {
      tag="Text",
      attributes={
        class="title2",
        id=atrKillOp(player, "display"),
        rectAlignment="UpperLeft",
        width=w,
        height=40,
        active=false
      },
      value="u cant see this"
    },
    {
      tag="Text",
      attributes={
        class="title2",
        id=atrKillOp(player, "amount"),
        rectAlignment="LowerCenter",
        width=w,
        height=40
      },
      value="0"
    },
    {
      tag="Button",
      attributes={
        id=atrKillOp(player, "button_plus"),
        onClick="onIncreaseKillOp",
        width=80, height=32,
        fontSize=28,
        rectAlignment="LowerRight",
        offsetXY="-4 4",
        text="+"
      }
    },
    {
      tag="Button",
      attributes={
        id=atrKillOp(player, "button_minus"),
        onClick="onDecreaseKillOp",
        width=80, height=32,
        fontSize=28,
        rectAlignment="LowerLeft",
        offsetXY="4 4",
        text="-"
      }
    }
  }

  table.insert(ch, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children=cch
  })
  return uy-y+h
end

function buildTacOpCel(ch, uy, x, y, w, player)
  local h = 4
  local cch = {}
  for i=1,1 do
    h = buildTacOpSelector(cch, h, 4, 0, w-8, player, i) + 4
  end

  table.insert(ch, {
    tag="Panel",
    attributes={
      class="bkgPanel",
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children=cch
  })
  return uy-y+h
end

function buildPrimaryOpCel(ch, uy, x, y, w, player)
  local h = 4
  local cch = {}
  for i=1,1 do
    h = buildPrimaryOpSelector(cch, h, 4, 0, w-8, player, i) + 4
  end

  table.insert(ch, {
    tag="Panel",
    attributes={
      class="bkgPanel",
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children=cch
  })
  return uy-y+h
end

function buildKillOpCel(ch, uy, x, y, w, player)
  local h = 4
  local cch = {}
  h = buildKillOpSelector(cch, h, 4, 0, w-8, player) + 4

  table.insert(ch, {
    tag="Panel",
    attributes={
      class="bkgPanel",
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children=cch
  })
  return uy-y+h
end

function buildTacOpRow(ch, uy, x, y, w)
  local cch = {}
  local celw = (w-12)/4
  local h = buildTacOpCel(cch, 0, 0, 0, celw, 3)
  buildTacOpCel(cch, 0, celw+4, 0, celw, 1)
  buildTacOpCel(cch, 0, celw*2+8, 0, celw, 2)
  buildTacOpCel(cch, 0, celw*3+12, 0, celw, 4)

  table.insert(ch, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width=w,
      height=h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children=cch
  })

  return uy-y+h
end

function buildPrimaryRow(ch, uy, x, y, w)
  local cch = {}
  local celw = (w-12)/4
  local h = buildPrimaryOpCel(cch, 0, 0, 0, celw, 3)
  buildPrimaryOpCel(cch, 0, celw+4, 0, celw, 1)
  buildPrimaryOpCel(cch, 0, celw*2+8, 0, celw, 2)
  buildPrimaryOpCel(cch, 0, celw*3+12, 0, celw, 4)

  table.insert(ch, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width=w,
      height=h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children=cch
  })

  return uy-y+h
end

function buildKillOpRow(ch, uy, x, y, w)
  local cch = {}
  local celw = (w-12)/4
  local h = buildKillOpCel(cch, 0, 0, 0, celw, 3)
  buildKillOpCel(cch, 0, celw+4, 0, celw, 1)
  buildKillOpCel(cch, 0, celw*2+8, 0, celw, 2)
  buildKillOpCel(cch, 0, celw*3+12, 0, celw, 4)

  table.insert(ch, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width=w,
      height=h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children=cch
  })

  return uy-y+h
end

function buildBonusRow(ch, uy, x, y, w)
  local h = 160
  local sliderw = (w-8)/2-4
  local cch = {
    {
      tag="Panel",
      attributes={
        class="bkgPanel",
        width=130,
        height=60,
        rectAlignment="UpperCenter",
      },
      children={
        {
          tag="Text",
          attributes={
            class="title2",
            rectAlignment="MiddleCenter",
          },
          value="End of the battle"
        }
      }
    },
    {
      tag="Panel",
      attributes={
        rectAlignment="LowerLeft",
        width=sliderw,
        height=80,
        offsetXY="4 4"
      },
      children={
        {
          tag="Text",
          attributes={
            class="title2",
            id="kts__bonus_display_player1",
            rectAlignment="MiddleCenter",
            width=w,
            height=40
          },
          value="0"
        },
        {
          tag="Button",
          attributes={
            id="kts__bonus_increase_player1",
            onClick="onIncreaseBonus",
            width=80, height=32,
            fontSize=28,
            rectAlignment="MiddleRight",
            offsetXY="-4 4",
            text="+"
          }
        },
        {
          tag="Button",
          attributes={
            id="kts__bonus_decrease_player1",
            onClick="onDecreaseBonus",
            width=80, height=32,
            fontSize=28,
            rectAlignment="MiddleLeft",
            offsetXY="4 4",
            text="-"
          }
        }
      }
    },
    {
      tag="Panel",
      attributes={
        rectAlignment="LowerRight",
        width=sliderw,
        height=80,
        offsetXY="-4 4"
      },
      children={
        {
          tag="Text",
          attributes={
            class="title2",
            id="kts__bonus_display_player2",
            rectAlignment="MiddleCenter",
            width=w,
            height=40
          },
          value="0"
        },
        {
          tag="Button",
          attributes={
            id="kts__bonus_increase_player2",
            onClick="onIncreaseBonus",
            width=80, height=32,
            fontSize=28,
            rectAlignment="MiddleRight",
            offsetXY="-4 4",
            text="+"
          }
        },
        {
          tag="Button",
          attributes={
            id="kts__bonus_decrease_player2",
            onClick="onDecreaseBonus",
            width=80, height=32,
            fontSize=28,
            rectAlignment="MiddleLeft",
            offsetXY="4 4",
            text="-"
          }
        }
      }
    }
  }
  table.insert(ch, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width=w,
      height=h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children=cch
  })
  return uy-y+h
end

function buildKillOpTotalRow(ch, uy, x, y, w)
  local h = 60
  table.insert(ch, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", tostring(x), tostring(y-uy))
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=130,
          height=h
        },
        children={
          {
            tag="Text",
            attributes={
              class="title2"
            },
            value="Kill Op total"
          }
        }
      },
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__killoptotal_player1",
          offsetXY = string.format("%f 0", -w/8)
        },
        value=string.format("0/%d", rules.scoring.killop.max)
      },
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__killoptotal_player2",
          offsetXY = string.format("%f 0", w/8)
        },
        value=string.format("0/%d", rules.scoring.killop.max)
      },
            {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__killoptotal_player3",
          offsetXY = string.format("%f 0", -w/8*3)
        },
        value=string.format("0/%d", rules.scoring.killop.max)
      },
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__killoptotal_player4",
          offsetXY = string.format("%f 0", w/8*3)
        },
        value=string.format("0/%d", rules.scoring.killop.max)
      }
    }
  })
  return uy-y+h
end

function buildGrandTotalRow(ch, uy, x, y, w)
  local h = 130
  table.insert(ch, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width = w,
      height = h,
      offsetXY = string.format("%f %f", x, y-uy)
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=130,
          outline=rules.art.colors.highlight,
          outlineSize="3 -3",
          offsetXY="-180, 0",
          height=h
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__grandtotal_player1",
              class="finalScore",
              fontSize=100
            },
            value="0"
          },
          {
            tag="Text",
            attributes={
              id="kts__grandtotal_max_player1",
              class="finalScore",
              fontSize=50,
              offsetXY="-163 0",
              active=false
            },
            value="MAX"
          }
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=130,
          outline=rules.art.colors.highlight,
          outlineSize="3 -3",
          offsetXY="180, 0",
          height=h
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__grandtotal_player2",
              class="finalScore",
              fontSize=100
            },
            value="0"
          },
          {
            tag="Text",
            attributes={
              id="kts__grandtotal_max_player2",
              class="finalScore",
              fontSize=50,
              offsetXY="163 0",
              active=false
            },
            value="MAX"
          }
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=130,
          outline=rules.art.colors.highlight,
          outlineSize="3 -3",
          offsetXY="-530, 0",
          height=h
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__grandtotal_player3",
              class="finalScore",
              fontSize=100
            },
            value="0"
          },
          {
            tag="Text",
            attributes={
              id="kts__grandtotal_max_player3",
              class="finalScore",
              fontSize=50,
              offsetXY="-163 0",
              active=false
            },
            value="MAX"
          }
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=130,
          outline=rules.art.colors.highlight,
          outlineSize="3 -3",
          offsetXY="530, 0",
          height=h
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__grandtotal_player4",
              class="finalScore",
              fontSize=100
            },
            value="0"
          },
          {
            tag="Text",
            attributes={
              id="kts__grandtotal_max_player4",
              class="finalScore",
              fontSize=50,
              offsetXY="163 0",
              active=false
            },
            value="MAX"
          }
        }
      }
    }
  })
  return uy-y+h
end

function buildScoreboard(def)
  local ch = {}
  local uiHeight = 0
  local uiPanelWidth = rules.art.gui.scoreboard.width
  local uiWidth = uiPanelWidth-10
  local halfPanel = (uiWidth-4)/2
  local bannerHeight = rules.art.gui.scoreboard.bannerHeight or 150
  local bannerWidth = rules.art.gui.scoreboard.bannerWidth or uiWidth

  table.insert(ch, buildScoreBanner(0,-5,bannerWidth, bannerHeight))
  uiHeight = uiHeight + bannerHeight + 10

  table.insert(ch, buildNameplate(4, -uiHeight, (uiWidth-12)/4, 60, 3))
  table.insert(ch, buildNameplate((uiWidth-12)/4+4, -uiHeight, (uiWidth-4)/4, 60, 1))
  table.insert(ch, buildNameplate((uiWidth-12)/2+8, -uiHeight, (uiWidth-4)/4, 60, 2))
  table.insert(ch, buildNameplate((uiWidth-12)/4*3+12, -uiHeight, (uiWidth-4)/4, 60, 4))
  uiHeight = uiHeight + 64

  local round = 1
  uiHeight = buildInitiativeRow(ch, uiHeight, 5, 0, uiWidth, 60, round, 4) + 4
  for round=2, rules.scoring.maxRounds do
    uiHeight = buildInitiativeRow(ch, uiHeight, 5, 0, uiWidth, 60, round, 4) + 4
    uiHeight = buildOpRow(ch, uiHeight, 5, 0, uiWidth, round, rules.scoring.critop, 'critop', 4) + 4
    uiHeight = buildOpRow(ch, uiHeight, 5, 0, uiWidth, round, rules.scoring.tacop, 'tacop', 4) + 4
  end

  uiHeight = buildRowTitle(ch, 'Kill Op', uiHeight, 5, 0, uiWidth, 60, round, 4) + 4
  uiHeight = buildKillOpRow(ch, uiHeight, 5, 0, uiWidth) + 4
  uiHeight = buildRowTitle(ch, 'Tac Op', uiHeight, 5, 0, uiWidth, 60, round, 4) + 4
  uiHeight = buildTacOpRow(ch, uiHeight, 5, 0, uiWidth) + 4
  uiHeight = buildRowTitle(ch, 'Primary Op', uiHeight, 5, 0, uiWidth, 60, round, 4) + 4
  uiHeight = buildPrimaryRow(ch, uiHeight, 5, 0, uiWidth) + 4
  uiHeight = buildCritOpTotalRow(ch, uiHeight, 5, -5, uiWidth, 60) + 9
  uiHeight = buildTacOpTotalRow(ch, uiHeight, 5, -5, uiWidth, 60) + 9
  uiHeight = buildKillOpTotalRow(ch, uiHeight, 5, -5, uiWidth) + 9
  uiHeight = buildGrandTotalRow(ch, uiHeight, 5, 0, uiWidth) + 5

  local uiHalf = uiHeight/2
  local rotation
  local position
  if rules.art.gui.scoreboard.layFlat then
    rotation="0 0 180"
    position="0 0 -15"
  else
    rotation="45 0 180"
    position="0 0 -"..(math.sqrt((uiHalf*uiHalf)/2) + 150)
  end
  local xmt = {
    def,
    {
      tag="Panel",
      attributes={
        class="mainPanel",
        active=true,
        width=uiPanelWidth,
        height=uiHeight,
        rotation=rotation,
        position=position
      },
      children=ch
    }
  }
  self.UI.setXmlTable(xmt)
end

function makeDefaults(settings)
  local colors = settings.art.colors

  local function asd(typ, atr, cls)
    local atr = atr
    if cls then atr.class = cls end
    return {
      tag=typ,
      attributes=atr
    }
  end

  return {
    tag="Defaults",
    children={
      asd("Image", {
        raycastTarget=false,
        preserveAspect=true
      }),
      asd("Text", {
        fontSize=16,
        color=colors.lighter
      }),
      asd("Dropdown", {
        fontSize=24,
        color=colors.background,
        textColor=colors.lighter
      }),
      asd("Panel", {
        color=colors.darker
      }, "mainPanel"),
      asd("Panel", {
        color=colors.background
      }, "bkgPanel"),
      asd("Text", {
        fontSize=80,
        fontStyle="BoldAndItalic"
      }, "title"),
      asd("Text", {
        fontSize=24,
        fontStyle="Bold"
      }, "title2"),
      asd("Text", {
        resizeTextForBestFit=true,
        fontStyle="Bold",
        color=colors.highlight,
        outline=colors.darker
      }, "steamName"),
      asd("Text", {
        fontStyle="Bold",
        color=colors.highlight,
        outline=colors.darker
      }, "finalScore"),
      asd("Image", {
        raycastTarget=true,
        type="Simple",
        image="primaryOff"
      }, "scoreToggle"),
      asd("Image", {
        raycastTarget=true,
        tooltipPosition="Above",
        type="Simple",
        image="primaryOff"
      }, "streamerScore"),
      asd("Image", {
        raycastTarget=true,
        type="Simple",
        image="initiativeOff"
      }, "initiativeToggle"),
      asd("Image", {
        type="Simple",
        image="initiativeOff"
      }, "streamerInitiative"),
      asd("Button", {
        textColor=colors.darkest,
        colors=colors.background
      }),
      asd("Image", {
        type="Simple",
        image="initiativeOn",
        showAnimation="Grow",
        hideAnimation="Shrink",
        active=false
      }, "initiativeDisplay")
    }
  }
end

function makeAsset(assets, n, u)
  table.insert(assets,{
    name=n,
    url=u
  })
end

function makeAssetButton(assets, graphics, name)
  for n, u in pairs(graphics[name]) do
    makeAsset(assets, name..n, u)
  end
end

function loadAssets(graphics)
  local assets = {}
  if graphics.eventLogo then
    makeAsset(assets, "eventLogo", graphics.eventLogo)
  end
  if graphics.eventBanner then
    makeAsset(assets, "eventBanner", graphics.eventBanner)
  end
  makeAssetButton(assets, graphics, "initiative")
  makeAssetButton(assets, graphics, "primary")

  safeSetCustomAssets(assets)
end

-- HUD Builder

function hudScoreElement(ch, x, y, s, layout, pl)
  local grandH = math.floor(s*0.75)
  local subH = s - grandH
  table.insert(ch, {
    tag="Panel",
    attributes={
      class="bkgPanel",
      outline=rules.art.colors.highlight,
      outlineSize="2 -2",
      rectAlignment=layout,
      offsetXY = string.format("%f %f", x, y),
      width=s,
      height=s
    },
    children={
      {
        tag="Text",
        attributes={
          id="kts__grandtotal_player"..pl,
          class="finalScore",
          rectAlignment="UpperCenter",
          height=grandH,
          fontSize=grandH-12
        },
        value="0"
      },
      {
        tag="Text",
        attributes={
          class="title2",
          height=subH,
          width=s/3,
          fontSize=subH-8,
          rectAlignment="LowerLeft",
          id="kts__critoptotal_player"..pl
        },
        value=string.format("0/%d", rules.scoring.critop.max)
      },
      {
        tag="Text",
        attributes={
          class="title2",
          height=subH,
          width=s/3,
          fontSize=subH-8,
          rectAlignment="LowerCenter",
          id="kts__tacoptotal_player"..pl
        },
        value=string.format("0/%d", rules.scoring.tacop.max)
      },
      {
        tag="Text",
        attributes={
          class="title2",
          height=subH,
          width=s/3,
          fontSize=subH-8,
          rectAlignment="LowerRight",
          id="kts__killoptotal_player"..pl
        },
        value=string.format("0/%d", rules.scoring.killop.max)
      }
    }
  })
end

function hudInitiativeElement(ch, x, y, s, layout, pl)
  table.insert(ch,{
    tag="Image",
    attributes={
      class="initiativeDisplay",
      id="kts__initiative_display_player"..pl,
      width=s, height=s,
      rectAlignment=layout,
      offsetXY = string.format("%f %f", x, y)
    }
  })
end

function hudNameElement(ch, x, y, w, h, layout, pl, suffix)
  local playerc = rules.packet.players[pl]
  local suffix = suffix or ""
  table.insert(ch,{ --1888
    tag="Panel",
    attributes={
      class="bkgPanel",
      rectAlignment=layout,
      width = w,
      height = h,
      offsetXY = string.format("%f %f", x, y)
    },
    children={
      {
        tag="Text",
        attributes={
          class="steamName",
          id=paramPlayer[pl]..suffix,
          color= string.format("#%s", Color.fromString(playerc):toHex())
        },
        value=playerc
      }
    }
  })
end

function hudCommandElement(ch, x, y, w, h, layout, pl, suffix)
  local guid = self.getGUID()
  local vp = rules.packet.players[pl]
  local suffix = suffix or ""
  table.insert(ch,{
    tag="Panel",
    attributes={
      class="bkgPanel",
      rectAlignment=layout,
      width = w,
      height = h,
      offsetXY = string.format("%f %f", x, y)
    },
    children={
      {
        tag="Text",
        attributes={
          class="title2",
          id="kts__command_player"..pl..suffix
        },
        value="3 CP"
      },
      {
        tag="Button",
        attributes={
          onClick=guid.."/onCommandPointUpPressed",
          width=h-8, height=h-8,
          text="+", fontSize=h-8,
          rectAlignment="MiddleRight",
          visibility=vp,
          id="kts__command_increase_player"..pl
        }
      },
      {
        tag="Button",
        attributes={
          onClick=guid.."/onCommandPointDownPressed",
          width=h-8, height=h-8,
          text="-", fontSize=h-8,
          rectAlignment="MiddleLeft",
          visibility=vp,
          id="kts__command_increase_player"..pl
        }
      }
    }
  })
end

function getHudVisibilities()
  -- Streamer functionality removed; return visibility of player colors only
  local players = Player.getColors()
  local pvis = {}
  for _,col in pairs(players) do
    table.insert(pvis, col)
  end
  return table.concat(pvis, "|"), ""
end

function buildHUD(def)
  local guid = self.getGUID()
  local uiWidth = 650
  local uiHeight = 90
  local panelID = "kts__hud_panel"
  local chl = {}
  local chr = {}
  local logoVisible = rules.art.graphics.eventLogo ~= nil
  local uiSubWidth = uiWidth*0.5
  local logoWidth = rules.art.gui.overlay.logoWidth
  local logoHeight = rules.art.gui.overlay.logoHeight
  local uiMiddleZone = 150
  local nameplateWidth = math.floor(uiSubWidth*0.5 + 32)

  local hudVisibility, streamVisibility = getHudVisibilities()

  if logoVisible then
    uiMiddleZone = math.max(uiMiddleZone, logoWidth+4)
  end
  uiWidth = uiWidth + uiMiddleZone

  hudScoreElement(chl, 0, 5, uiHeight, "LowerRight", 1)
  hudInitiativeElement(chl, -(uiHeight + 4), -4, 32, "UpperRight", 1)
  hudNameElement(chl, 2, -2, nameplateWidth, uiHeight*0.33, "UpperLeft", 1)
  hudCommandElement(chl, 2, 2, nameplateWidth, uiHeight*0.66-6, "LowerLeft", 1)

  hudScoreElement(chr, 0, 5, uiHeight, "LowerLeft", 2)
  hudInitiativeElement(chr, (uiHeight + 4), -4, 32, "UpperLeft", 2)
  hudNameElement(chr, -2, -2, nameplateWidth, uiHeight*0.33, "UpperRight", 2)
  hudCommandElement(chr, -2, 2, nameplateWidth, uiHeight*0.66-6, "LowerRight", 2)

  hudScoreElement(chl, 0, uiHeight+5, uiHeight, "LowerRight", 3)
  hudInitiativeElement(chl, -(uiHeight + 4), uiHeight-4, 32, "UpperRight", 3)
  hudNameElement(chl, 2, uiHeight-2, nameplateWidth, uiHeight*0.33, "UpperLeft", 3)
  hudCommandElement(chl, 2, uiHeight+2, nameplateWidth, uiHeight*0.66-6, "LowerLeft", 3)

  hudScoreElement(chr, 0, uiHeight+5, uiHeight, "LowerLeft", 4)
  hudInitiativeElement(chr, (uiHeight + 4), uiHeight-4, 32, "UpperLeft", 4)
  hudNameElement(chr, -2, uiHeight-2, nameplateWidth, uiHeight*0.33, "UpperRight", 4)
  hudCommandElement(chr, -2, uiHeight+2, nameplateWidth, uiHeight*0.66-6, "LowerRight", 4)

  local ch = {
    {
      tag="Panel",
      attributes={
        id="scoreBoardGUI",
        class="mainPanel",
        width=uiMiddleZone,
        height=uiHeight/2,
        rectAlignment="LowerCenter"
      },
      children={
        {
          tag="Text",
          attributes={
            class="title2",
            fontSize=uiHeight*0.3,
            id="kts__round_current"
          },
          value="KT 24"
        },

      }
    },

        {
      tag="Panel",
      attributes={
        class="mainPanel",
        width=uiSubWidth,
        height=uiHeight,
        rectAlignment="LowerLeft"
      },
      children=chl
    },
    {
      tag="Panel",
      attributes={
        class="mainPanel",
        width=uiSubWidth,
        height=uiHeight,
        rectAlignment="LowerRight"
      },
      children=chr
    },
    {
      tag="Image",
      attributes={
        rectAlignment="LowerCenter",
        offsetXY="0 "..(uiHeight*0.5),
        image="eventLogo",
        width=logoWidth,
        height=logoHeight,
        active=logoVisible
      }
    }
  }

  local basePanel = {
    tag="Panel",
    attributes={
      id=panelID,
      width=uiWidth,
      height=uiHeight+30,
      allowDragging=true,
      returnToOriginalPositionWhenReleased=false,
      visibility=hudVisibility,
      rectAlignment="LowerCenter"
    },
    children = ch
  }

  if Global.UI.getAttribute("scoreBoardGUI", "id") == nil then
    local oldUI = Global.UI.getXmlTable()

    if oldUI == nil then
			oldUI = {}
		end
    table.insert(oldUI, def)
    table.insert(oldUI, basePanel)

    Wait.frames(function() Global.UI.setXmlTable(oldUI) end, 1)
  end
end

function buildUI()
  loadAssets(rules.art.graphics)

  local defaults = makeDefaults(rules)

  Wait.frames(function() buildHUD(defaults) end, 20)

  buildScoreboard(defaults)
end

function loadGM()
  broadcastToAll(setupMessage)
  local settings = JSON.decode(defaultSettings)

  setup(settings)

    scoring = {
    {
      critop=makeOpScoreTable('critop'),
      tacop=makeOpScoreTable('tacop'),
      killop=makeKillOpScoreTable(),
      primary=makePrimaryOpScoreTable(),
      initiative=makeInitiativeScoreTable(),
      command=3
    },
    {
      critop=makeOpScoreTable('critop'),
      tacop=makeOpScoreTable('tacop'),
      killop=makeKillOpScoreTable(),
      primary=makePrimaryOpScoreTable(),
      initiative=makeInitiativeScoreTable(),
      command=3
    },
    {
      critop=makeOpScoreTable('critop'),
      tacop=makeOpScoreTable('tacop'),
      killop=makeKillOpScoreTable(),
      primary=makePrimaryOpScoreTable(),
      initiative=makeInitiativeScoreTable(),
      command=3
    },
    {
      critop=makeOpScoreTable('critop'),
      tacop=makeOpScoreTable('tacop'),
      killop=makeKillOpScoreTable(),
      primary=makePrimaryOpScoreTable(),
      initiative=makeInitiativeScoreTable(),
      command=3
    }
  }

  buildUI()
  Wait.frames(refresh, 10)
  Timer.create({
    identifier=self.getGUID(),
    function_name="checkPlayerHands",
    delay=1,
    repetitions=0
  })
end

function onSave()
  local save = {
    splayers=players,
    splayerNumber=playerNumber,
    srules=rules,
    sscoring=scoring,
    sresult = result or {}
  }
  return JSON.encode(save)
end

function checkPlayerHands()
  for pl, c in pairs(rules.packet.players) do
    p = Player[c]
    if p ~= nil then
      hobjs = p.getHandObjects()
      honames = {}
      for n, o in pairs(hobjs) do
        table.insert(honames, o.getName())
      end
      uiid = "ktw__streamerSecondaries_player"..pl -- legacy id; harmless if absent
      -- simplified: do not attempt to set streamer UI; keep behavior minimal
    end
  end
end

function onLoad(state)
  self.setTags({scoreboardTag})
  self.addContextMenuItem("Reset Scoreboard", resetScoring, false)
  if state then
    local state = JSON.decode(state)
    if state then
      players = state["splayers"] or players
      playerNumber = state["splayerNumber"] or playerNumber
      rules = state["srules"] or rules
      scoring = state["sscoring"] or scoring
      result = state["sresult"] or {}
    end
  end

  loadGM()
end

function setTacOp(pl, guid)
  local selector = atrTacOp(pl, "dropdown")
  local display = atrTacOp(pl, "display")
  local obj = getObjectFromGUID(guid)
  local name = obj.getName()
  hideUI(selector)

  setUIValue(atrTacOp(pl, "streamer"), name) -- streamer field kept for compatibility but not used elsewhere
  scoring[pl].tacop.selection=name
  scoring[pl].tacop.guid=guid
end


function onSecondarySelected(pl, val, id)
  local pl, sec = string.gmatch(id, "(%d+)_(%d+)")()
  setSecondaryObjective(tonumber(pl), tonumber(sec), val)
end

function refreshPrimaryOpUI(pl)
  local score = scoring[pl].primary.score
  local max = rules.scoring.primary.max
  local newstr
  if max > 0 then
    newstr = string.format("%d/%d", score, max)
  else
    newstr = string.format("%d", score)
  end
  setUIValue(atrPrimaryOp(pl, "amount"), newstr)
end

function refreshKillOpUI(pl)
  local killop = scoring[pl].killop
  local max = rules.scoring.killop.maxEach
  local newstr
  if max > 0 then
    newstr = string.format("%d/%d", killop.score, max)
  else
    newstr = string.format("%d", killop.score)
  end
  setUIValue(atrKillOp(pl, "amount"), newstr)
end

function refreshPrimaryOpScore(pl)
  setPrimaryOpScore(pl, calculatePrimaryScore(pl))
end

function setPrimaryOpScore(pl, val)
  local max = rules.scoring.primary.max
  local newval = math.max(0, math.min(val, max))
  scoring[pl].primary.score = newval
  refreshPrimaryOpUI(pl)
  updateScoreUI(pl)
end

function setKillOpScore(pl, val)
  local killop = scoring[pl].killop
  local max = rules.scoring.killop.max
  local newval = math.max(0, math.min(val, max))
  killop.score = newval
  refreshKillOpUI(pl)
  refreshPrimaryOpScore(pl)
  updateScoreUI(pl)
end

function refreshBonusUI(pl)
  local value = scoring[pl].secondary and scoring[pl].secondary[4] or 0
  local max = rules.scoring.bonus.max
  local newstr
  if max > 0 then
    newstr = string.format("%d/%d", value, max)
  else
    newstr = string.format("%d", value)
  end
  setUIValue("kts__bonus_display_player"..pl, newstr)
end

function setBonusScore(pl, val)
  local max = rules.scoring.bonus.max
  scoring[pl].secondary[4] = math.max(0, math.min(val, max))

  refreshBonusUI(pl)
  updateScoreUI(pl)
end

function onTacOpReveal(player, val, id)
  local pl = string.gmatch(id, "(%d+)")()
  pl = tonumber(pl)
  local revealButton = atrTacOp(pl, "button_reveal")
  local display = atrTacOp(pl, "display")
  local obj = getObjectFromGUID(scoring[pl].tacop.guid)
  if obj then
    obj.rotate(Vector(180, 180, 0))
    local name = obj.getName()
    setUIValue(display, name)
  end
  hideUI(revealButton)
  showUI(display)

  setUIValue(atrTacOp(pl, "streamer"), name)
  scoring[pl].tacop.revealed = true
end

function onPrimaryOpReveal(player, val, id)
  local pl = string.gmatch(id, "(%d+)")()
  pl = tonumber(pl)
  local revealButton = atrPrimaryOp(pl, "button_reveal")
  local display = atrPrimaryOp(pl, "display")
  local obj = getObjectFromGUID(scoring[pl].primary.guid)
  if obj then
    obj.rotate(Vector(180, 180, 0))
  end
  local name = obj and obj.getGMNotes() or ""
  setUIValue(display, name)
  hideUI(revealButton)
  showUI(display)

  setUIValue(atrPrimaryOp(pl, "streamer"), name)
  scoring[pl].primary.revealed = true
  
  if allowRecord(pl, true) then
    setPrimaryOpScore(pl, calculatePrimaryScore(pl))
  else
    showMaxRecordMessage(player)
  end
end

function onIncreaseKillOp(player, val, id)
  local pl = string.gmatch(id, "(%d+)")()
  pl = tonumber(pl)
  if allowRecord(pl, true) then
    setKillOpScore(pl, scoring[pl].killop.score + 1)
  else
    showMaxRecordMessage(player)
  end
end

function onDecreaseKillOp(player, val, id)
  local pl = string.gmatch(id, "(%d+)")()
  pl = tonumber(pl)
  setKillOpScore(pl, scoring[pl].killop.score - 1)
end

function onIncreasePrimaryOp(player, val, id)
  local pl = tonumber(string.gmatch(id, "(%d+)")())
  setPrimaryOpScore(pl, scoring[pl].primary.score + 1)
end

function onDecreasePrimaryOp(player, val, id)
  local pl = tonumber(string.gmatch(id, "(%d+)")())
  setPrimaryOpScore(pl, scoring[pl].primary.score - 1)
end

function onIncreaseBonus(player, val, id)
  local pl = tonumber(string.gmatch(id, "(%d+)")())
  if allowRecord(pl, true) then
    setBonusScore(pl, scoring[pl].secondary[4] + 1)
  else
    showMaxRecordMessage(player)
  end
end

function onDecreaseBonus(player, val, id)
  local pl = tonumber(string.gmatch(id, "(%d+)")())
  setBonusScore(pl, scoring[pl].secondary[4] - 1)
end

function refreshScoreUI(pl)
  local score, crit, tac, kill, primary = calculateScore(pl)
  local crit_string = string.format("%d/%d", crit, rules.scoring.critop.max)
  local tac_string = string.format("%d/%d", tac, rules.scoring.tacop.max)
  local kill_string = string.format("%d/%d", kill, rules.scoring.killop.max)
  local primary_string = string.format("%d/%d", primary, rules.scoring.primary.max)
  local grand = string.format("%d", crit + tac + kill + primary)

  setUIValue("kts__critoptotal_player"..pl, crit_string)
  setUIValue("kts__tacoptotal_player"..pl, tac_string)
  setUIValue("kts__killoptotal_player"..pl, kill_string)
  setUIValue("kts__primaryoptotal_player"..pl, primary_string)

  setUIValue("kts__grandtotal_player"..pl, grand)

  if score == rules.scoring.max then
    showUI("kts__grandtotal_max_player"..pl)
  else
    hideUI("kts__grandtotal_max_player"..pl)
  end
end

function updateScoreUI(pl)
  refreshPrimaryOpUI(pl)
  refreshScoreUI(pl)
  dispatchGameLogScoringEvent()
end

function setScoring(jsonEncodedScoring)
  scoring = JSON.decode(jsonEncodedScoring)
  refreshAll()
end

function setOpUI(op_type, pl, rule, round, value)
  local toggleID = atrOp(op_type, pl, rule, round, "toggle")
  if value then
    setUIAttribute(toggleID, "image", "primaryOn")
  else
    setUIAttribute(toggleID, "image", "primaryOff")
  end
end

function toggleOp(op_type, pl, rule, round)
  local player_op_score = scoring[pl][op_type].score
  local value = not player_op_score[rule][round]
  if allowRecord(pl, value, rule) then
    setOpUI(op_type, pl, rule, round, value)

    player_op_score[rule][round] = value
    
    refreshPrimaryOpScore(pl)
    updateScoreUI(pl)
  else
    return false
  end
  return true
end

function onOpPressed(player, val, id)
  local op_type, pl, rule, round = string.gmatch(id, "(%a+)_player(%d+)_(%d+)_(%d+)")()
  if not toggleOp(op_type, tonumber(pl), tonumber(rule), tonumber(round)) then
    showMaxRecordMessage(player)
  end
end

function setInitiativeUI(pl, round, value)
  local toggleID = atrInitiative(pl, round, "toggle")
  local displayID = atrInitiative(pl, round, "streamer")
  if value then
    setUIAttribute(toggleID, "image", "initiativeOn")
    setUIAttribute(displayID, "image", "initiativeOn")
  else
    setUIAttribute(toggleID, "image", "initiativeOff")
    setUIAttribute(displayID, "image", "initiativeOff")
  end
end

function dispatchGameLogScoringEvent()
  local event = {
    type = 'scoring',
    score = JSON.encode(scoring)
  }
  -- best-effort: if gamelog object exists, call it; otherwise skip silently
  local gamelogGuid = "bafa93"
  local obj = getObjectFromGUID(gamelogGuid)
  if obj and obj.call then
    pcall(function() obj.call("gameLogAppendScoringChange", event) end)
  end
end

function updateInitiativeUI()
  local round = 0
  local ip, np = 0, 0
  local maxRounds = rules.scoring.maxRounds
  for i=maxRounds,1,-1 do
    if scoring[1].initiative[i] then
      round = i
      ip, np = 1, 2
      break
    end
    if scoring[2].initiative[i] then
      round = i
      ip, np = 2, 1
      break
    end
  end

  if round > 0 then
    showUI("kts__initiative_display_player"..ip)
    hideUI("kts__initiative_display_player"..np)
    setUIValue("kts__round_current", "Round "..round)
  else
    hideUI("kts__initiative_display_player1")
    hideUI("kts__initiative_display_player2")
    setUIValue("kts__round_current", "Pre game")
  end
end

function toggleInitiative(pl, round)
  local si = scoring[pl].initiative
  local value = not si[round]

  setInitiativeUI(pl, round, value)
  si[round] = value

  if value then
    for otherPl = 1, #scoring do
      if otherPl ~= pl then
        local osi = scoring[otherPl].initiative
        if osi[round] then
          setInitiativeUI(otherPl, round, false)
          osi[round] = false
        end
      end
    end
  end
end


function onInitiativePressed(player, val, id)
  local pl, round = string.gmatch(id, "(%d+)_(%d+)")()
  toggleInitiative(tonumber(pl), tonumber(round))
  updateInitiativeUI()
end

function setDropdownItem(id, value)
  local drop = dropdowns[id]
  if drop then
    local item = drop.items[value]
    if item and item ~= drop.selected then
      setUIValue(id, item)
      drop.selected = item
    end
  end
end

function refreshCommandPoints(pl)
  local val = scoring[pl].command
  local ncpv = string.format("%d CP", val)
  local uiid = "kts__command_player"..pl
  setUIValue(uiid, ncpv)
end

function setCommandPoints(pl, val)
  scoring[pl].command = val
  refreshCommandPoints(pl)
  dispatchGameLogScoringEvent()
end

function onCommandPointUpPressed(player, val, id)
  local pl = tonumber(string.gmatch(id, "player(%d+)")())
  setCommandPoints(pl, scoring[pl].command + 1)

  local p = Player[player.color]
  local name = p.steam_name
  if name == nil or name == "" then
    name = tostring(p.color) .. " player"
  end

  broadcastToAll(name .. " has GAINED CP (now at " .. scoring[pl].command .. ")", stringColorToRGB(p.color))
end

function onCommandPointDownPressed(player, val, id)
  local pl = tonumber(string.gmatch(id, "player(%d+)")())
  setCommandPoints(pl, scoring[pl].command - 1)

  local p = Player[player.color]
  local name = p.steam_name
  if name == nil or name == "" then
    name = tostring(p.color) .. " player"
  end

  broadcastToAll(name .. " has SPENT CP (now at " .. scoring[pl].command .. ")", stringColorToRGB(p.color))
end

function allowRecord(pl, increase, primary)
  -- simplified: preserve default permissive behavior
  return true
end

function comSetSelectedTacOp(params)
  local color = params.player
  local guid = params.guid
  if color and guid then
    local p = playerNumber[color]
    if p then
      showUI(atrTacOp(p, "button_reveal"))
      hideUI(atrTacOp(p, "dropdown"))
      setTacOp(p, guid)
    end
  end
end

function comSetSelectedPrimaryOp(params)
  local color = params.player
  local guid = params.guid
  if color and guid then
    local p = playerNumber[color]
    if p then
      showUI(atrPrimaryOp(p, "button_reveal"))
      hideUI(atrPrimaryOp(p, "dropdown"))
      setUIAttribute(atrPrimaryOp(p, "button_plus"), 'active', false)
      setUIAttribute(atrPrimaryOp(p, "button_minus"), 'active', false)

      local primaryMax = 0
      if rules and rules.scoring and rules.scoring.primary and type(rules.scoring.primary.max) == "number" then
        primaryMax = rules.scoring.primary.max
      end

      if not scoring or not scoring[p] then
        resetScoring()
      end

      setPrimaryOp(p, guid)
    end
  end
end

function setPrimaryOp(pl, guid)
  -- fixed: use 'pl' (the parameter) instead of undefined 'player'
  local selector = atrPrimaryOp(pl, "dropdown")
  local obj = getObjectFromGUID(guid)
  local name = ""
  if obj and obj.getGMNotes then
    name = obj.getGMNotes() or ""
  end

  if selector then
    hideUI(selector)
  end

  -- ensure scoring structure exists
  scoring = scoring or {}
  scoring[pl] = scoring[pl] or {
    critop = makeOpScoreTable('critop'),
    tacop  = makeOpScoreTable('tacop'),
    killop = makeKillOpScoreTable(),
    primary = makePrimaryOpScoreTable(),
    initiative = makeInitiativeScoreTable(),
    command = 3
  }

  setUIValue(atrPrimaryOp(pl, "streamer"), name)
  scoring[pl].primary.selection = name
  scoring[pl].primary.guid = guid
  refreshPrimaryOpUI(pl)
end
function showMaxRecordMessage(pl)
  broadcastToColor("Can't record this point: a point limit has been reached", pl.color, Color.red)
end

function onChat(message, sender)
  if sender.color == "Black" and message == "reload scoreboard" then
    broadcastToAll("Reloading scoreboard rules...")
    loadGM()
  end
end

function getCurrentRound()
  local round = 0
  local maxRounds = rules.scoring.maxRounds
  for i=maxRounds,1,-1 do
    if scoring[1].initiative[i] then
      round = i
      break
    end
    if scoring[2].initiative[i] then
      round = i
      break
    end
  end
  return round
end

-- minimal helpers (some original functions referenced by gameplay flow)
function savePositions() end
function readyOperatives() end
function readyLooseOrders() end
function getCMOperativesOnBoard() return {} end
function getNotCMOperativesOnBoard() return {} end
function getLooseOrdersOnBoard() return {} end
function pressStopWatch(pl) end
function stopStopWatch() end

end)
__bundle_register("base-board/game-state-machine", function(require, _LOADED, __bundle_register, __bundle_modules)

gameStateMachine = {
  whoToPress="",
  preGame={
    active=false,
  },
  tp1={
    init=false,
    ploys=false,
    tacops=false,
    firefight=false,
    scoring=false
  },
  tp2={
    init=false,
    ploys=false,
    tacops=false,
    firefight=false,
    scoring=false
  },
  tp3={
    init=false,
    ploys=false,
    tacops=false,
    firefight=false,
    scoring=false
  },
  tp4={
    init=false,
    ploys=false,
    tacops=false,
    firefight=false,
    scoring=false
  },
  endGame={
    active=false,
  },
}

end)
return __bundle_require("Scoreboard.339b7f.lua")
