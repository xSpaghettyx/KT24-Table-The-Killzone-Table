-- KT24 Base Table Scoreboard Spaghetty Mod --


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
dashboardTag = "Kill Team Dashboard"
scoreboardTag = "Kill Team Scoreboard"

opMap = {
  ["Crit Op"]="critop",
  ["Tac Op"]="tacop",
  ["Kill Op"]="killop",
}

defaultSettings = [[{
  "packet":{
    "name":"KT24",
    "players":[
      "Red",
      "Blue"
    ],
    "streamers":[
      "Black",
      "White"
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
      "options": [
        "Security: Contain",
        "Security: Take Ground",
        "Security: Secure Center",
        "Seek and Destroy: Overrun",
        "Seek and Destroy: Storm Objectives",
        "Seek and Destroy: Champion",
        "Recon: Confirm Kill",
        "Recon: Recover Items",
        "Recon: Plant Beacons",
        "Infiltration: Surveillance",
        "Infiltration: Implant",
        "Infiltration: Wiretap"
      ]
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
        "bannerWidth":700,
        "bannerHeight":128,
        "width":750,
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

paramPlayer = {atrName("player1"), atrName("player2")}

players = {}
playerNames = {}
playerNumber = {}

dropdowns = {}

rules = {}
scoring = {}

-- universal event handlers
function onObjectDrop(player_color, dropped_object)
  if dropped_object.hasTag('Operative') and dropped_object.hasTag('Not Mustered') ~= true then
    op1, op2 = getStateMachine()
    if op1 ~= "preGame" then
      local newDesc = dropped_object.getDescription()
      if string.find(newDesc, Player[player_color].steam_name) then
        if result[Player[player_color].steam_name] == nil then
          result[Player[player_color].steam_name] = {}
        end
        if result[Player[player_color].steam_name].operatives == nil then
          result[Player[player_color].steam_name].operatives = {}
        end
        result[Player[player_color].steam_name].operatives[dropped_object.getGUID()] = {
          name=dropped_object.getName(),
          desc=dropped_object.getDescription(),
        }
        local pos = dropped_object.getPosition()
        if pos.x < 15 and pos.x > -15 and pos.z < 11 and pos.z > -11 then
          result[Player[player_color].steam_name].operatives[dropped_object.getGUID()].killed = false
        else
          round = getCurrentRound()
          result[Player[player_color].steam_name].operatives[dropped_object.getGUID()].killed = true
          result[Player[player_color].steam_name].operatives[dropped_object.getGUID()].roundKilled = round
        end
      end
    end
  end
end


require("base-board/pre-game-checklist")

require("base-board/legacy-mission-data")

missionSelectedForScoreboard = ""
overwatchTable = {
  checked=false
}

function getUIAttribute(id, attr)
  if UI.getAttribute(id, attr) ~= nil then
    return UI.getAttribute(id, attr)
  end
  if self.UI.getAttribute(id, attr) ~= nil then
    return self.UI.getAttribute(id, attr)
  end
end
-- ADDED by ZAKA

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
  --self.UI.setAttributes(id, data)
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
    setUIValue(uiid.."_streamer", playerNames[p])
    local color = Color.fromString(p)
    local color1 = color:lerp(Color(1, 1, 1), 0.25)
    local color2 = color:lerp(Color(1, 1, 1), 0.6)
    setUIAttribute(uiid.."_panel", "color", "#"..color1:toHex())
    setUIAttribute(uiid.."_panel2", "color", "#"..color2:toHex())
    --ADDED by ZAKA
    setUIValue("kts__red_faction_ui_text", "Red Faction")
    setUIValue("kts__blue_faction_ui_text", "Blue Faction")
    --ADDED by ZAKA
  end
  refreshAll()
  updateInitiativeUI()
end

function refreshAll()
  for pl=1,2 do
    refreshCommandPoints(pl)
    --TODO: refresh
    --refreshKillOps(pl)
    --refreshBonusUI(pl)
    refreshScoreUI(pl)
  end
end

function refreshKillOps(pl)
  local plscore = scoring[pl]
  
end

function onPlayerChangeColor(pc)
  if pc == "Red" or pc == "Blue" then

    --ADDED by ZAKA
    if checkListStatus[Player[pc].steam_name] == nil then
      checkListStatus[Player[pc].steam_name] = {
        name = "",
        allow = false,
        superFaction = "Select One",
        faction = "Select One",
        tacOps = false,
        equipment = false,
        barricades = false,
        deployed = false,
        allowOW = false,
        scouting = "Select One",
      }
    end
    if (pc == "Red" and getUIAttribute("kts__blue_roloff_winner_text", "text") ~= Player[pc].steam_name) or
       (pc == "Blue" and getUIAttribute("kts__red_roloff_winner_text", "text") ~= Player[pc].steam_name) then
      setUIAttribute("kts__"..string.lower(pc).."_roloff_winner_text", "text", Player[pc].steam_name)
      setUIAttribute("kts__toggle_"..string.lower(pc).."_accept_text", "text", Player[pc].steam_name)
      setUIAttribute("kts__toggle_"..string.lower(pc).."_tacops_text", "text", Player[pc].steam_name)
      setUIAttribute("kts__toggle_"..string.lower(pc).."_equipment_text", "text", Player[pc].steam_name)
      setUIAttribute("kts__toggle_"..string.lower(pc).."_barricades_text", "text", Player[pc].steam_name)
      setUIAttribute("kts__toggle_"..string.lower(pc).."_deployed_text", "text", Player[pc].steam_name)
      setUIAttribute("kts__toggle_"..string.lower(pc).."_overwatch_funct_text", "text", Player[pc].steam_name)
      setUIAttribute("kts__dropdown_"..string.lower(pc).."_faction_text", "text", "Faction "..Player[pc].steam_name)
    end
    if result[Player[pc].steam_name] == nil then
      result[Player[pc].steam_name] = {}
    end
    result[Player[pc].steam_name].color = pc
  --ADDED by ZAKA

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

    players[player1] = paramPlayer[1]
    players[player2] = paramPlayer[2]
    playerNumber[player1] = 1
    playerNumber[player2] = 2
    rules = settings
    resetScoring()
  end
end

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
  local primaryHeight = insertOpVps(ch, 0, 0, (w-gap)/2, round, op, op_type, 1)
  local h=primaryHeight
  insertOpVps(ch, (w-gap)/2 + gap, 0, (w-gap)/2, round, op, op_type, 2)
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
          width=130,
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
          offsetXY = string.format("%f 0", -w/4)
        }
      },
      {
        tag="Image",
        attributes={
          class="initiativeToggle",
          onClick="onInitiativePressed",
          id=atrInitiative(2, round, "toggle"),
          width=h*0.75, height=h*0.75,
          offsetXY = string.format("%f 0", w/4)
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
          offsetXY = string.format("%f 0", -w/4)
        },
        value=string.format("0/%d", rules.scoring.critop.max)
      },
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__critoptotal_player2",
          offsetXY = string.format("%f 0", w/4)
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
          offsetXY = string.format("%f 0", -w/4)
        },
        value=string.format("0/%d", rules.scoring.tacop.max)
      },
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__tacoptotal_player2",
          offsetXY = string.format("%f 0", w/4)
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
      --value="Primary Op"
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
  --local h = 90
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
      --value="Primary Op"
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
  local celw = (w-4)/2
  local h = buildTacOpCel(cch, 0, 0, 0, celw, 1)
  buildTacOpCel(cch, 0, celw+4, 0, celw, 2)

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
  local celw = (w-4)/2
  local h = buildPrimaryOpCel(cch, 0, 0, 0, celw, 1)
  buildPrimaryOpCel(cch, 0, celw+4, 0, celw, 2)

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
  local celw = (w-4)/2
  local h = buildKillOpCel(cch, 0, 0, 0, celw, 1)
  buildKillOpCel(cch, 0, celw+4, 0, celw, 2)

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
  local dd = "ktw__bonus_dropdown"
  local cch = {
    --ADDED by ZAKA
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
  --ADDED by ZAKA
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
  --ADDED by ZAKA
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
          offsetXY = string.format("%f 0", -w/4)
        },
        value=string.format("0/%d", rules.scoring.killop.max)
      },
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=h*0.75,
          id="kts__killoptotal_player2",
          offsetXY = string.format("%f 0", w/4)
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
          offsetXY="-70, 0",
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
          offsetXY="70, 0",
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

  --start ui parts
  table.insert(ch, buildScoreBanner(0,-5,bannerWidth, bannerHeight))
  uiHeight = uiHeight + bannerHeight + 10


  table.insert(ch, buildNameplate(5, -uiHeight, halfPanel, 60, 1))
  table.insert(ch, buildNameplate(halfPanel+9, -uiHeight, halfPanel, 60, 2))
  uiHeight = uiHeight + 64

  local round = 1
  uiHeight = buildInitiativeRow(ch, uiHeight, 5, 0, uiWidth, 60, round, 4) + 4
  for round=2, rules.scoring.maxRounds do
    uiHeight = buildInitiativeRow(ch, uiHeight, 5, 0, uiWidth, 60, round, 4) + 4
    uiHeight = buildOpRow(ch, uiHeight, 5, 0, uiWidth, round, rules.scoring.critop, 'critop', 4) + 4
    uiHeight = buildOpRow(ch, uiHeight, 5, 0, uiWidth, round, rules.scoring.tacop, 'tacop', 4) + 4
    --uiHeight = buildTacOpRow(ch, uiHeight, 5, 0, uiWidth, round, 4) + 4
  end
  --ADDED by ZAKA
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

function buildDashboard(target, def)
  local dbCont = {}
  target.UI.setXmlTable({
    def,
    {
      tag="Panel",
      attributes={
        color=rules.art.colors.darker,
        width=1920,
        height=1080,
        scale="-0.33 0.33 0.33",
        rotation="20 0 180",
        position="0 -300 -100"
      },
      children=dbCont
    }
  })
end

function asd(typ, atr, cls)
  local atr = atr
  if cls then atr.class = cls end
  return {
    tag=typ,
    attributes=atr
  }
end

function makeDefaults(settings)
  local colors = settings.art.colors

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
  local players = Player.getColors()
  local isStreamer = {}
  local pvis = {}
  local svis = {}

  for _,v in pairs(rules.packet.streamers) do
    isStreamer[v] = true
  end

  for _,col in pairs(players) do
    if isStreamer[col] then
      table.insert(svis, col)
    else
      table.insert(pvis, col)
    end
  end
  return table.concat(pvis, "|"), table.concat(svis, "|")
end

function streamerUINameRow(ch, uiWidth, uiHeight, border, sep)
  local h = 35
  local nw = (uiWidth-border*2-sep)/2
  hudNameElement(ch, border, -uiHeight, nw, h, "UpperLeft", 1, "_streamer")
  hudNameElement(ch, border+nw+sep, -uiHeight, nw, h, "UpperLeft", 2, "_streamer")
  return uiHeight + h
end

function streamerUICPRow(ch, uiWidth, uiHeight, border, sep)
  local h = 30
  local nw = (uiWidth-border*2-sep)/2
  hudCommandElement(ch, border, -uiHeight, nw, h, "UpperLeft", 1, "_streamer")
  hudCommandElement(ch, border+nw+sep, -uiHeight, nw, h, "UpperLeft", 2, "_streamer")
  return uiHeight + h
end

function streamerUIRoundRow(ch, uiWidth, uiHeight, border, sep, round)
  local h = 25
  local nw = (uiWidth - border*2)
  local panel = {
    tag="Panel",
    attributes={
      width=nw,
      height = h,
      offsetXY=string.format("0 %f", -uiHeight),
      rectAlignment="UpperCenter"
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=nw/2
        },
        children={
          {
            tag="Text",
            attributes={
              class="title2",
              fontSize=16,
              text="Round "..round
            }
          }
        }
      },
      {
        tag="Image",
        attributes={
          class="streamerInitiative",
          id=atrInitiative(1, round, "streamer"),
          width=h, height=h,
          rectAlignment="MiddleLeft",
          offsetXY="20 0"
        }
      },
      {
        tag="Image",
        attributes={
          class="streamerInitiative",
          id=atrInitiative(2, round, "streamer"),
          width=h, height=h,
          rectAlignment="MiddleRight",
          offsetXY="-20 0"
        }
      }
    }
  }
  table.insert(ch, panel)
  return uiHeight + h
end

function streamerPrimaryCel(t, x, y, w, h, rule, round, player)
  table.insert(t,
    {
      tag="Panel",
      attributes={
        rectAlignment="UpperLeft",
        width = w,
        height = h,
        offsetXY = string.format("%f %f", tostring(x), tostring(y))
      },
      children={
        {
          tag="Image",
          attributes={
            id=atrPrimaryOp(player, "streamer"),
            class="streamerScore",
            height=h-4,
            tooltip=rules.scoring.primary.objectives[rule]
          }
        }
      }
    }
  )
end

function streamerUIPrimaryRowPart(ch, x, y, w, pl, round)
  local objs = #rules.scoring.primary.objectives
  local cols = math.min(objs, rules.art.gui.scoreboard.primaryColumns)
  local rows = math.ceil(objs/cols)
  local celw = math.floor(w/cols)
  local celh = 26
  local pch = {}
  local h = celh * rows

  for i=1,rows do
    local rcols = math.min(cols, objs-(i-1)*cols)
    local rofs = (cols - rcols)*celw*0.5
    for j=1,rcols do
      local rule = ((i-1)*cols + j)
      streamerPrimaryCel(pch, celw*(j-1) + rofs, -celh*(i-1), celw, celh, rule, round, pl)
    end
  end

  table.insert(ch,{
    tag="Panel",
    attributes={
      class="bkgPanel",
      width=w, height=h,
      offsetXY=string.format("%f %f", x, y),
      rectAlignment="UpperLeft"
    },
    children=pch
  })
  return h
end

function streamerUIPrimaryRow(ch, uiWidth, uiHeight, border, sep, round)
  local nw = (uiWidth-border*2-sep)/2
  local h = streamerUIPrimaryRowPart(ch, border, -uiHeight, nw, 1, round)
  streamerUIPrimaryRowPart(ch, border+nw+sep, -uiHeight, nw, 2, round)
  return uiHeight + h
end

function streamerUIHiddenSecondary(ch, x, y, w, h, player)
  table.insert(ch,
  {
    tag="Panel",
    attributes={
      width=w,
      height = h,
      offsetXY=string.format("%f %f", x, y),
      color=rules.art.colors.darker,
      outline=rules.art.colors.background,
      rectAlignment="upperLeft"
    },
    children={
      {
        tag="Text",
        attributes={
          id="ktw__streamerSecondaries_player"..player,
          fontSize=16
        }
      }
    }
  }
  )
end

function streamerUIHiddenSecondaryRow(ch, uiWidth, uiHeight, border, sep)
  local nw = (uiWidth-border*2-sep)/2
  local h = 80
  streamerUIHiddenSecondary(ch, border, -uiHeight-20, nw, 60, 1)
  streamerUIHiddenSecondary(ch, border+sep+nw, -uiHeight-20, nw, 60, 2)
  table.insert(ch, {
    tag="Text",
    attributes={
      rectAlignment="UpperCenter",
      offsetXY=string.format("0 %f", -uiHeight),
      fontSize=16,
      width = uiWidth,
      height = 80,
      alignment="UpperCenter",
      text = "Hands"
    }
  })
  return uiHeight + h
end

function streamerUITotalRow(ch, uiWidth, uiHeight, border, sep, totalKind)
  local nw = (uiWidth-border*2-sep)/2
  local h = 40

  local panel = {
    tag="Panel",
    attributes={
      width=uiWidth,
      height = h,
      offsetXY=string.format("0 %f", -uiHeight),
      rectAlignment="UpperCenter"
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiWidth/3
        },
        children={
          {
            tag="Text",
            attributes={
              class="title2",
              fontSize=16,
              text=(totalKind:gsub("^%l", string.upper))
            }
          }
        }
      },
      {
        tag="Text",
        attributes={
          class="title2",
          id=string.format("kts__%stotal_player1_streamer", totalKind),
          width=2*h, height=h,
          rectAlignment="MiddleLeft",
          offsetXY="20 0"
        },
        value="0/9"
      },
      {
        tag="Text",
        attributes={
          class="title2",
          id=string.format("kts__%stotal_player2_streamer", totalKind),
          width=2*h, height=h,
          rectAlignment="MiddleRight",
          offsetXY="-20 0"
        },
        value="0/9"
      }
    }
  }
  table.insert(ch, panel)
  return uiHeight + h
end

function streamerUISecondaryDisplay(ch, x, y, w, player, sec)
  local h = 40
  table.insert(ch,{
    tag="Panel",
    attributes={
      class="bkgPanel",
      width = w,
      height = h,
      rectAlignment="UpperLeft",
      offsetXY=string.format("%f %f", tostring(x), tostring(y))
    },
    children={
      {
        tag="Text",
        attributes={
          class="title2",
          id=atrSecondary(player, sec, "streamer"),
          rectAlignment="UpperCenter",
          fontSize=16,
          height=h/2
        },
        value="..."
      },
      {
        tag="Text",
        attributes={
          class="title2",
          id=atrSecondary(player, sec, "streamer_amount"),
          rectAlignment="LowerCenter",
          width=w,
          fontSize=16,
          height=h/2
        },
        value="0"
      }
    }
  })
  return h
end

function streamerUISecondary(ch, x, y, w, sep, player)
  local h = sep
  local cch = {}
  for i=1,3 do
    h = h + streamerUISecondaryDisplay(cch, 0, -h, w, player, i) + sep
  end

  table.insert(ch, {
    tag="Panel",
    attributes={
      rectAlignment="UpperLeft",
      width=w,
      height=h,
      offsetXY=string.format("%f %f", tostring(x), tostring(y))
    },
    children=cch
  })
  return h
end

function streamerUISecondaryRow(ch, uiWidth, uiHeight, border, sep)
  local nw = (uiWidth-border*2-sep)/2
  local h = streamerUISecondary(ch, border, -uiHeight, nw, sep, 1)
  streamerUISecondary(ch, border+sep+nw, -uiHeight, nw, sep, 2)
  return uiHeight + h
end

function streamerUIGrandTotal(ch, x, y, s, player)
  table.insert(ch, {
    tag="Panel",
    attributes={
      class="bkgPanel",
      outline=rules.art.colors.highlight,
      outlineSize="2 -2",
      rectAlignment="UpperLeft",
      offsetXY = string.format("%f %f", x, y),
      width=s,
      height=s
    },
    children={
      {
        tag="Text",
        attributes={
          id="kts__grandtotal_player"..player.."_streamer",
          class="finalScore",
          rectAlignment="UpperCenter",
          height=s,
          fontSize=s-12
        },
        value="0"
      }
    }
  })
end

function streamerUIGrandTotalRow(ch, uiWidth, uiHeight, border, sep)
  local h = 50
  local gtx1 = uiWidth/2 - h - 50
  local gtx2 = uiWidth/2 + 50
  streamerUIGrandTotal(ch, gtx1, -uiHeight, h, 1)
  streamerUIGrandTotal(ch, gtx2, -uiHeight, h, 2)
  return uiHeight + h
end

function streamerUIBonusRow(ch, uiWidth, uiHeight, border, sep)
  local h = 40
  local panelw = uiWidth-border*2
  table.insert(ch,{
    tag="Panel",
    attributes={
      class="bkgPanel",
      width=panelw,
      height = h,
      rectAlignment="UpperCenter",
      offsetXY=string.format("0 %f", -uiHeight)
    },
    children={
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=20
        },
        value="Bonus"
      },
      {
        tag="Text",
        attributes={
          class="title2",
          id="kts__bonus_display_player1_streamer",
          fontSize=16,
          rectAlignment="MiddleLeft",
          width=panelw/2
        },
        value="0"
      },
      {
        tag="Text",
        attributes={
          class="title2",
          id="kts__bonus_display_player2_streamer",
          fontSize=16,
          rectAlignment="MiddleRight",
          width=panelw/2
        },
        value="0"
      }
    }
  })
  return uiHeight + h
end

function buildStreamerUI(svis)
  local uiWidth = 360
  local uiHeight = 5
  local border = 5
  local sep = 2
  --ADDED by ZAKA
  local panelID = "kts__streamer_panel"..missionSelectedForScoreboard
  --ADDED by ZAKA
  --DELETED by ZAKA
  --local panelID = "kts__streamer_panel"
  --DELETED by ZAKA
  local uiSubWidth = uiWidth/2
  local ch = {}

  uiHeight = streamerUINameRow(ch, uiWidth, uiHeight, border, sep) + sep
  uiHeight = streamerUICPRow(ch, uiWidth, uiHeight, border, sep) + sep
  uiHeight = streamerUIHiddenSecondaryRow(ch, uiWidth, uiHeight, border, sep) + sep*2
  for i=1,rules.scoring.maxRounds do
    uiHeight = streamerUIRoundRow(ch, uiWidth, uiHeight, border, sep, i) + sep

    --ADDED by ZAKA
    if missionSelectedForScoreboard == "e1bd09" or missionSelectedForScoreboard == "451ffb" then
      if i > 1 then
        uiHeight = streamerUIPrimaryRow(ch, uiWidth, uiHeight, border, sep, i) + sep*2
      end
    else
      uiHeight = streamerUIPrimaryRow(ch, uiWidth, uiHeight, border, sep, i) + sep*2
    end
    --ADDED by ZAKA
  end
  --ADDED by ZAKA
  if #rules.scoring.bonus.objectives > 0 then
    uiHeight = streamerUIBonusRow(ch, uiWidth, uiHeight, border, sep) + sep
  end
  --ADDED by ZAKA
  uiHeight = streamerUITotalRow(ch, uiWidth, uiHeight, border, sep, "primary") + sep*3
  uiHeight = streamerUISecondaryRow(ch, uiWidth, uiHeight, border, sep) + sep
  --DELETED by ZAKA
  --if #rules.scoring.bonus.objectives > 0 then
  --  uiHeight = streamerUIBonusRow(ch, uiWidth, uiHeight, border, sep) + sep
  --end
  --DELETED by ZAKA
  uiHeight = streamerUITotalRow(ch, uiWidth, uiHeight, border, sep, "secondary") + sep*3
  uiHeight = streamerUIGrandTotalRow(ch, uiWidth, uiHeight, border, sep) + border

  return {
    tag="Panel",
    attributes={
      class="mainPanel",
      id=panelID,
      width=uiWidth,
      height=uiHeight,
      visibility=svis,
      allowDragging=true,
      returnToOriginalPositionWhenReleased=false,
      rectAlignment="LowerRight"
    },
    children=ch
  }
end

require("base-board/panel-buttons")

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
      --DELETED by ZAKA
      --height=uiHeight,
      --DELETED by ZAKA
      --ADDED by ZAKA
      height=uiHeight+30,
      --ADDED by ZAKA
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

    --ADDED by ZAKA
    checkPanel = buildHUDCheck(def)
    table.insert(oldUI, checkPanel)
    --ADDED by ZAKA

    --table.insert(oldUI, buildStreamerUI(streamVisibility))
    Wait.frames(function() Global.UI.setXmlTable(oldUI) end, 1)
  end
end

function buildUI()
  loadAssets(rules.art.graphics)

  --build the screen overlay
  --screen overlay should be generated instead of a flat xml file
  --it should be themed the same as everything else
  --UI.setXml(uiScreenOverlay)

  --generate default UI classes
  local defaults = makeDefaults(rules)

  Wait.frames(function() buildHUD(defaults) end, 20)


  --build the main scoreboard
  buildScoreboard(defaults)

  --[[
  build dashboards.

  local dashboards = getObjectsWithTag(dashboardTag)
  for _, board in pairs(dashboards) do
    board.UI.setCustomAssets(assets)
    buildDashboard(board, defaults)
  end
  showUI("kts_startHidden")]]
end

function loadGM()
  broadcastToAll(setupMessage)
  local settings = JSON.decode(defaultSettings)

  setup(settings)
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

    --ADDED by ZAKA
    sresult = result,
    schecklist = checkListStatus,
    sgamestate = gameStateMachine,
    soverwatch = overwatchTable,
  }
  return JSON.encode(save)
end

function checkPlayerHands()
  for pl, c in pairs(rules.packet.players) do
    p = Player[c]
    hobjs = p.getHandObjects()
    honames = {}
    for n, o in pairs(hobjs) do
      table.insert(honames, o.getName())
    end
    uiid = "ktw__streamerSecondaries_player"..pl
    if #honames > 0 then
      if #honames > 3 then
        setUIValue(uiid, "Too many\nin hand")
      else
        setUIValue(uiid, table.concat(honames,"\n"))
      end
    else
      setUIValue(uiid, "")
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

      --ADDED by ZAKA
      result = state["sresult"] or result
      checkListStatus = state["schecklist"] or checkListStatus
      gameStateMachine = state["sgamestate"] or gameStateMachine
      overwatchTable = state["soverwatch"] or overwatchTable
      updateMegaDeck()
    end
  end

  --ADDED by ZAKA
  if Player["Red"].steam_name ~= nil then
    if checkListStatus[Player["Red"].steam_name] == nil then
      checkListStatus[Player["Red"].steam_name] = {
        name = "",
        allow = false,
        faction = "Select One",
        tacOps = false,
        equipment = false,
        barricades = false,
        deployed = false,
        allowOW = false,
        scouting = "Select One",
      }
    end
  end
  if Player["Blue"].steam_name ~= nil then
    if checkListStatus[Player["Blue"].steam_name] == nil then
      checkListStatus[Player["Blue"].steam_name] = {
        name = "",
        allow = false,
        faction = "Select One",
        tacOps = false,
        equipment = false,
        barricades = false,
        deployed = false,
        allowOW = false,
        scouting = "Select One",
      }
    end
  end
  --ADDED by ZAKA

  loadGM()
end

function setTacOp(pl, guid)
  local selector = atrTacOp(pl, "dropdown")
  local display = atrTacOp(pl, "display")
  local obj = getObjectFromGUID(guid)
  local name = obj.getName()
  hideUI(selector)

  setUIValue(atrTacOp(pl, "streamer"), name)
  scoring[pl].tacop.selection=name
  scoring[pl].tacop.guid=guid
end

function setPrimaryOp(pl, guid)
  local selector = atrPrimaryOp(pl, "dropdown")
  local obj = getObjectFromGUID(guid)
  local name = obj.getGMNotes()
  hideUI(selector)

  setUIValue(atrPrimaryOp(pl, "streamer"), name)
  scoring[pl].primary.selection=name
  scoring[pl].primary.guid=guid
  refreshPrimaryOpUI(pl)
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
  setUIValue(atrPrimaryOp(pl, "streamer_amount"), newstr)
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
  setUIValue(atrKillOp(pl, "streamer_amount"), newstr)
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
  local value = scoring[pl].secondary[4]
  local max = rules.scoring.bonus.max
  local newstr
  if max > 0 then
    newstr = string.format("%d/%d", value, max)
  else
    newstr = string.format("%d", value)
  end
  setUIValue("kts__bonus_display_player"..pl, newstr)
  setUIValue("kts__bonus_display_player"..pl.."_streamer", newstr)
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
  --scoring[pl].primary.selection=name
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
  local name = obj.getGMNotes()
  setUIValue(display, name)
  hideUI(revealButton)
  showUI(display)

  setUIValue(atrPrimaryOp(pl, "streamer"), name)
  --scoring[pl].primary.selection=name
  scoring[pl].primary.revealed = true
  
  if allowRecord(pl, true) then
    --TODO: 
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
  setUIValue("kts__critoptotal_player"..pl.."_streamer", crit_string)

  setUIValue("kts__tacoptotal_player"..pl, tac_string)
  setUIValue("kts__tacoptotal_player"..pl.."_streamer", tac_string)

  setUIValue("kts__killoptotal_player"..pl, kill_string)
  setUIValue("kts__killoptotal_player"..pl.."_streamer", kill_string)

  setUIValue("kts__primaryoptotal_player"..pl, primary_string)
  setUIValue("kts__primaryoptotal_player"..pl.."_streamer", primary_string)

  setUIValue("kts__grandtotal_player"..pl, grand)
  setUIValue("kts__grandtotal_player"..pl.."_streamer", grand)

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
  local displayID = atrOp(op_type, pl, rule, round, "streamer")
  if value then
    setUIAttribute(toggleID, "image", "primaryOn")
    setUIAttribute(displayID, "image", "primaryOn")
  else
    setUIAttribute(toggleID, "image", "primaryOff")
    setUIAttribute(displayID, "image", "primaryOff")
  end
end

function toggleOp(op_type, pl, rule, round)
  local player_op_score = scoring[pl][op_type].score
  local otherPlayer = (pl==1) and 2 or 1
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
  --dispatchGameLogScoringEvent()
end

function dispatchGameLogScoringEvent()
  local event = {
    type = 'scoring',
    score = JSON.encode(scoring)
  }
  local gamelogGuid = "bafa93"
  getObjectFromGUID(gamelogGuid).call("gameLogAppendScoringChange", event)
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
  local otherPlayer = (pl==1) and 2 or 1
  local si = scoring[pl].initiative
  local osi = scoring[otherPlayer].initiative
  local value = not si[round]
  setInitiativeUI(pl, round, value)
  si[round] = value
  if value and osi[round] then
    toggleInitiative(otherPlayer, round)
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
      --setUIAttribute(id, "selectedIndex", item)
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
  setUIValue(uiid.."_streamer", ncpv)
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
  -- TODO: ver que es esto
  local primary = primary or false
  if false then
  -- if increase and rules.scoring.limitRecordToMax then
    local ts, cs, ts, ks = calculateScore(pl)
    if ts < rules.scoring.max then
      if primary then
        local max = rules.scoring.primary.max
        local maxEach = rules.scoring.primary.maxEach
        if maxEach > 0 then
          local p = scoring[pl].primary[primary]
          local total = 0
          for k, v in pairs(p) do
            total = total + (v and 1 or 0)
          end
          if total >= maxEach then return false end
        end
        if max > 0 then
          return ps < max
        end
      else
        local max = rules.scoring.secondary.max
        if max > 0 then
          return ss < max
        end
      end
      return true
    end
    return false
  end
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
      setUIValue(atrPrimaryOp(p, "amount"), string.format("?/%d", rules.scoring.primary.max))
      setPrimaryOp(p, guid)
    end
  end
end

function showMaxRecordMessage(pl)
  broadcastToColor("Can't record this point: a point limit has been reached", pl.color, Color.red)
end

function onChat(message, sender)
  if sender.color == "Black" and message == "reload scoreboard" then
    broadcastToAll("Reloading scoreboard rules...")
    loadGM()
  end

  --ADDED by ZAKA
  if sender.color == "Black" and message == "my turn" then
    gameStateMachine.whoToPress = sender.steam_name
    setUIAttribute("kts__activated_button", "textColor", sender.color)
    broadcastToAll("Now it's "..gameStateMachine.whoToPress.." turn")
  end
  if sender.color == "Black" and message == "reset pregame data" then
    checkListStatus = {
      killZoneLoaded = false,
      allowOW = false,
      gameType = "Select One",
      edition = "Select One",
      mission = "Select One",
      rollOffWinner="Select One",
      rollOffAttacker=false,
      rollOffDefender=false,
      revealed=false,
      winner="",
    }
    updateCheckList()
  end
  --ADDED by ZAKA

end

function onShowChecklistBtn(player)
  if player.color == "Red" or player.color == "Blue" then
    if not string.find(getUIAttribute("kts__checklist_panel", "visibility"), player.color) then
      setUIAttribute("kts__checklist_panel", "visibility", getUIAttribute("kts__checklist_panel", "visibility") == "" and player.color.."|".."Black|White|Grey" or player.color.."|"..getUIAttribute("kts__checklist_panel", "visibility"))
    end
  end
end
function onStartGameBtn(player)
  if (player.color == "Red" or player.color == "Blue") then
    printToAll(checkListStatus.gameType)
    if checkListStatus.gameType == "Select One" then
      broadcastToAll("Select Game Type")
      return nil
    end
    if string.lower(tostring(checkListStatus.killZoneLoaded)) ~= "true" then
      broadcastToAll("Check Kill Zone Loaded")
      return nil
    end
    if checkListStatus.edition == "Select One" then
      broadcastToAll("Select Edition")
      return nil
    end
    --if checkListStatus.mission == "Select One" then
      --broadcastToAll("Select Mission")
      --return nil
    --end
    if checkListStatus.rollOffWinner == "Select One" then
      broadcastToAll("Select Roll Off winner")
      return nil
    end
    if (not checkListStatus.rollOffAttacker and not checkListStatus.rollOffDefender) then
      broadcastToAll("Select Attacker or Defender")
      return nil
    end
    if checkListStatus[Player["Red"].steam_name].faction == "Select One" then
      broadcastToAll("Select Red Faction")
      return nil
    end
    if checkListStatus[Player["Blue"].steam_name].faction == "Select One" then
      broadcastToAll("Select Blue Faction")
      return nil
    end
    if string.lower(tostring(checkListStatus[Player["Red"].steam_name].tacOps)) ~= "true" then
      broadcastToAll("Select Red TacOps")
      return nil
    end
    if string.lower(tostring(checkListStatus[Player["Red"].steam_name].equipment)) ~= "true" then
      broadcastToAll("Select Red equipment")
      return nil
    end
    if string.lower(tostring(checkListStatus[Player["Red"].steam_name].barricades)) ~= "true" then
      broadcastToAll("Place Red Barricades")
      return nil
    end
    if string.lower(tostring(checkListStatus[Player["Red"].steam_name].deployed)) ~= "true" then
      broadcastToAll("Deploy red team")
      return nil
    end
    if string.lower(tostring(checkListStatus[Player["Blue"].steam_name].tacOps)) ~= "true" then
      broadcastToAll("Select Blue TacOps")
      return nil
    end
    if string.lower(tostring(checkListStatus[Player["Blue"].steam_name].equipment)) ~= "true" then
      broadcastToAll("Select Blue equipment")
      return nil
    end
    if string.lower(tostring(checkListStatus[Player["Blue"].steam_name].barricades)) ~= "true" then
      broadcastToAll("Place Blue Barricades")
      return nil
    end
    if string.lower(tostring(checkListStatus[Player["Blue"].steam_name].deployed)) ~= "true" then
      broadcastToAll("Deploy Blue team")
      return nil
    end
    if checkListStatus[Player["Red"].steam_name].scouting == "Select One" then
      broadcastToAll("Red select scouting")
      return nil
    end
    if checkListStatus[Player["Blue"].steam_name].scouting == "Select One" then
      broadcastToAll("Blue select scouting")
      return nil
    end
    if not checkListStatus.revealed then
      broadcastToAll("Reveal scouting resolution")
      return nil
    end
    if checkListStatus.winner == "" then
      broadcastToAll("Reveal scouting resolution")
      return nil
    end
    if string.lower(checkListStatus.killZoneLoaded) == "true" and
    checkListStatus.gameType ~= "Select One" and
    checkListStatus.edition ~= "Select One" and
    checkListStatus.mission ~= "Select One" and
    checkListStatus.rollOffWinner ~= "Select One" and
    (checkListStatus.rollOffAttacker or checkListStatus.rollOffDefender) and
    (player.color == "Red" or player.color == "Blue") and
    checkListStatus[Player["Red"].steam_name].faction ~= "Select One" and
    checkListStatus[Player["Blue"].steam_name].faction ~= "Select One" and
    string.lower(checkListStatus[Player["Red"].steam_name].tacOps) == "true" and
    string.lower(checkListStatus[Player["Red"].steam_name].equipment) == "true" and
    string.lower(checkListStatus[Player["Red"].steam_name].barricades) == "true" and
    string.lower(checkListStatus[Player["Red"].steam_name].deployed) == "true" and
    string.lower(checkListStatus[Player["Blue"].steam_name].tacOps) == "true" and
    string.lower(checkListStatus[Player["Blue"].steam_name].equipment) == "true" and
    string.lower(checkListStatus[Player["Blue"].steam_name].barricades) == "true" and
    string.lower(checkListStatus[Player["Blue"].steam_name].deployed) == "true" and
    checkListStatus[Player["Red"].steam_name].scouting ~= "Select One" and
    checkListStatus[Player["Blue"].steam_name].scouting ~= "Select One" and
    checkListStatus.revealed and
    checkListStatus.winner ~= "" then
      setUIAttribute("kts__show_checklist_button", "active", false)
      setUIAttribute("kts__checklist_panel", "active", false)
      result.timestamp = os.time(os.date("!*t"))
      setUIAttribute("kts__loading_button", "active", true)
      setUIAttribute("kts__loading_button", "textColor", "Orange")
      Wait.frames(function()
        setUIAttribute("kts__loading_button", "active", false)
        setStateMachine("tp1", "init")
        setUIAttribute("kts__end_init_1_button", "active", true)
        setUIAttribute("kts__end_init_1_button", "textColor", "Orange")
        setUIAttribute("kts__end_init_2_button", "active", true)
        setUIAttribute("kts__end_init_2_button", "textColor", "Orange")
      end, 100)
      readyOperatives()
      readyLooseOrders()
      savePositions()
    else
      broadcastToAll("Please complete all fields to start")
    end
  end
end
function onStartOverBtn(player)
  if player.color == "Red" or player.color == "Blue" then
    if checkListStatus[Player["Red"].steam_name] ~= nil then
      checkListStatus[Player["Red"].steam_name].allow = "False"
      checkListStatus[Player["Red"].steam_name].faction="Select One"
      checkListStatus[Player["Red"].steam_name].superFaction="Select One"
      checkListStatus[Player["Red"].steam_name].tacOps="False"
      checkListStatus[Player["Red"].steam_name].equipment="False"
      checkListStatus[Player["Red"].steam_name].barricades="False"
      checkListStatus[Player["Red"].steam_name].deployed="False"
      checkListStatus[Player["Red"].steam_name].scouting="Select One"
      setFaction(Player["Red"], "Select One")
      setScouting(Player["Red"], "Select One")
      setAllowData(Player["Red"], false)
      result[Player["Red"].steam_name] = {}
      Wait.frames(function()
        deselectOperatives(Player["Red"])
      end, 10)
    end
    if checkListStatus[Player["Blue"].steam_name] ~= nil then
      checkListStatus[Player["Blue"].steam_name].allow = "False"
      checkListStatus[Player["Blue"].steam_name].faction="Select One"
      checkListStatus[Player["Blue"].steam_name].superFaction="Select One"
      checkListStatus[Player["Blue"].steam_name].tacOps="False"
      checkListStatus[Player["Blue"].steam_name].equipment="False"
      checkListStatus[Player["Blue"].steam_name].barricades="False"
      checkListStatus[Player["Blue"].steam_name].deployed="False"
      checkListStatus[Player["Blue"].steam_name].scouting="Select One"
      setFaction(Player["Blue"], "Select One")
      setScouting(Player["Blue"], "Select One")
      setAllowData(Player["Blue"], false)
      result[Player["Blue"].steam_name] = {}
      Wait.frames(function()
        deselectOperatives(Player["Blue"])
      end, 10)
    end
    checkListStatus.killZoneLoaded = false
    checkListStatus.allowOW = false
    checkListStatus.gameType = "Select One"
    checkListStatus.edition = "Select One"
    checkListStatus.mission = "Select One"
    checkListStatus.rollOffWinner=false
    checkListStatus.rollOffLoser=false
    checkListStatus.rollOffAttacker=false
    checkListStatus.rollOffDefender=false
    checkListStatus.revealed=false
    checkListStatus.winner=""
    result.killZoneLoaded = nil
    result.allowOW = nil
    result.gameType = nil
    result.mission = nil
    result.scoutingWinner = nil
    result.rollOffWinner = nil
    result.rollOffLoser = nil
    result.rollOffWinnerSelection= nil
    onOpenMissionSelected(Player["Red"], "Select One")
    onItdMissionSelected(Player["Red"], "Select One")
    updateCheckList()
  end
end
function updateCheckList()
  setUIAttribute("kts__toggle_red_accept", "isOn", false)
  setUIAttribute("kts__toggle_red_accept", "backgroundColor", "White")
  setUIAttribute("kts__toggle_blue_accept", "isOn", false)
  setUIAttribute("kts__toggle_blue_accept", "backgroundColor", "White")
  setUIAttribute("kts__toggle_kz_loaded", "isOn", false)
  setUIAttribute("kts__toggle_kz_loaded", "backgroundColor", "White")
  setUIAttribute("kts__toggle_red_rolloff_winner", "isOn", false)
  setUIAttribute("kts__toggle_red_rolloff_winner", "backgroundColor", "White")
  setUIAttribute("kts__toggle_blue_rolloff_winner", "isOn", false)
  setUIAttribute("kts__toggle_blue_rolloff_winner", "backgroundColor", "White")
  setUIAttribute("kts__toggle_defender_selected", "isOn", false)
  setUIAttribute("kts__toggle_defender_selected", "backgroundColor", "White")
  setUIAttribute("kts__toggle_attacker_selected", "isOn", false)
  setUIAttribute("kts__toggle_attacker_selected", "backgroundColor", "White")
  setUIAttribute("kts__toggle_red_tacops", "isOn", false)
  setUIAttribute("kts__toggle_red_tacops", "backgroundColor", "White")
  setUIAttribute("kts__toggle_blue_tacops", "isOn", false)
  setUIAttribute("kts__toggle_blue_tacops", "backgroundColor", "White")
  setUIAttribute("kts__toggle_red_equipment", "isOn", false)
  setUIAttribute("kts__toggle_red_equipment", "backgroundColor", "White")
  setUIAttribute("kts__toggle_blue_equipment", "isOn", false)
  setUIAttribute("kts__toggle_blue_equipment", "backgroundColor", "White")
  setUIAttribute("kts__toggle_red_barricades", "isOn", false)
  setUIAttribute("kts__toggle_red_barricades", "backgroundColor", "White")
  setUIAttribute("kts__toggle_blue_barricades", "isOn", false)
  setUIAttribute("kts__toggle_blue_barricades", "backgroundColor", "White")
  setUIAttribute("kts__toggle_red_deployed", "isOn", false)
  setUIAttribute("kts__toggle_red_deployed", "backgroundColor", "White")
  setUIAttribute("kts__toggle_blue_deployed", "isOn", false)
  setUIAttribute("kts__toggle_blue_deployed", "backgroundColor", "White")
  setUIAttribute("kts__toggle_overwatch", "isOn", false)
  setUIAttribute("kts__toggle_overwatch", "backgroundColor", "White")
  setUIAttribute("kts__toggle_reveal_scouting", "isOn", false)
  setUIAttribute("kts__toggle_reveal_scouting", "backgroundColor", "White")
  setUIValue("kts__scouting_resolution", "")
  changeMultiDropdown({
    "kts__dropdown_game_type",
    "kts__dropdown_edition",
    "kts__dropdown_mission_open",
    "kts__dropdown_mission_itd",
    "kts__dropdown_red_super_faction",
    "kts__dropdown_red_faction_imperium",
    "kts__dropdown_red_faction_chaos",
    "kts__dropdown_red_faction_aeldari",
    "kts__dropdown_red_faction_xenos",
    "kts__dropdown_red_scouting",
    "kts__dropdown_blue_super_faction",
    "kts__dropdown_blue_faction_imperium",
    "kts__dropdown_blue_faction_chaos",
    "kts__dropdown_blue_faction_aeldari",
    "kts__dropdown_blue_faction_xenos",
    "kts__dropdown_blue_scouting"
  },
  {
    "Select One",
    "Select One",
    "Select One",
    "Select One",
    "Select One",
    "Select One",
    "Select One",
    "Select One",
    "Select One",
    "Select One",
    "Select One",
    "Select One",
    "Select One",
    "Select One",
    "Select One"
  })
  setUIAttribute("kts__dropdown_game_type", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_edition", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_mission_open", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_mission_itd", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_red_super_faction", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_red_faction_imperium", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_red_faction_chaos", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_red_faction_aeldari", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_red_faction_xenos", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_red_scouting", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_blue_super_faction", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_blue_faction_imperium", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_blue_faction_chaos", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_blue_faction_aeldari", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_blue_faction_xenos", "textColor", "#e74f0aff")
  setUIAttribute("kts__dropdown_blue_scouting", "textColor", "#e74f0aff")

  setUIAttribute("kts__dropdown_blue_faction_imperium", "active", false)
  setUIAttribute("kts__dropdown_blue_faction_chaos", "active", false)
  setUIAttribute("kts__dropdown_blue_faction_aeldari", "active", false)
  setUIAttribute("kts__dropdown_blue_faction_xenos", "active", false)
  setUIAttribute("kts__dropdown_red_faction_imperium", "active", false)
  setUIAttribute("kts__dropdown_red_faction_chaos", "active", false)
  setUIAttribute("kts__dropdown_red_faction_aeldari", "active", false)
  setUIAttribute("kts__dropdown_red_faction_xenos", "active", false)
end

function returnEndGame(request)
  local resp = JSON.decode(request.text)
  broadcastToAll(resp.status)
end

function setMission(mission)
  result.mission = mission
  printToAll(result.mission.name.." selected as mission")
end
function setAllowData(player, value)
  if result[player.steam_name] == nil then
    result[player.steam_name] = {}
  end
  result[player.steam_name].color = player.color
  result[player.steam_name].allow = value
end

function setFaction(player, faction)
  if result[player.steam_name] == nil then
    result[player.steam_name] = {}
  end
  result[player.steam_name].color = player.color
  result[player.steam_name].faction = faction
  if faction ~= "Select One" then
    printToAll(player.steam_name.." chose "..faction)
    setUIValue("kts__"..string.lower(player.color).."_faction_ui_text", faction)
  else
    setUIValue("kts__"..string.lower(player.color).."_faction_ui_text", player.color.." Faction")
  end
  if checkListStatus[player.steam_name].factionGUID ~= nil then
    oldFaction = getObjectFromGUID(checkListStatus[player.steam_name].factionGUID)
    if oldFaction ~= nil then
      oldFaction.call("click_recall")
      oldFaction.destruct()
    else
      for _, obj in ipairs(getAllObjects()) do
        if string.find(obj.getDescription(), "faction chosen by "..player.steam_name) then
          obj.call("click_recall")
          obj.destruct()
          break
        end
      end
    end
    checkListStatus[player.steam_name].factionGUID = nil
  end
  obj = getObjectFromGUID(megaDeckGuid)
  objects = {}
  for _, containedObject in ipairs(obj.getObjects()) do
    spawnedObject = obj.takeObject()
    table.insert(objects, spawnedObject)
    if spawnedObject.getName() == faction then
      clonedObject = spawnedObject.clone()
      clonedObject.setDescription("faction chosen by "..player.steam_name)
      if player.color == "Blue" then
        clonedObject.setPosition({-25, 4, -15}, false, false)
        clonedObject.setRotation({0, -90, 0})
      else
        clonedObject.setPosition({25, 4, 15}, false, false)
        clonedObject.setRotation({0, 90, 0})
      end
      checkListStatus[player.steam_name].factionGUID = clonedObject.getGUID()
      break
    end
  end
  for _, objectToPut in ipairs(objects) do
    obj.putObject(objectToPut)
  end
end
function setScouting(player, option)
  if result[player.steam_name] == nil then
    result[player.steam_name] = {}
  end
  result[player.steam_name].color = player.color
  result[player.steam_name].scouting = option
end
function setRollOffWinner(player)
  if player.steam_name ~= nil then
    if result[player.steam_name] == nil then
      result[player.steam_name] = {}
    end
    result.rollOffWinner = player.steam_name
    result[player.steam_name].color = player.color
  else
    if result["no_player"] == nil then
      result["no_player"] = {}
    end
    result.rollOffWinner = "no_player"
    result["no_player"].color = player.color
  end
  printToAll(result.rollOffWinner.." Won the Roll off")
end
function setRollOffLoser(player)
  if player.steam_name ~= nil then
    if result[player.steam_name] == nil then
      result[player.steam_name] = {}
    end
    result.rollOffLoser = player.steam_name
    result[player.steam_name].color = player.color
  else
    if result["no_player"] == nil then
      result["no_player"] = {}
    end
    result.rollOffLoser = "no_player"
    result["no_player"].color = player.color
  end
  printToAll(result.rollOffLoser.." Lose the Roll off")
end
--TODO is this needed?
function setKillOpResult(player, secondary, score)
  colors = {"Red", "Blue"}
  secs = {"first", "second", "third"}
  rounds = {"none", "first", "second", "third", "fourth"}
  pl = Player[colors[player]].steam_name
  if pl ~= nil and scoring[player].secondary[secondary][1] ~= nil then
    round = getCurrentRound()
    if result[pl].secondaries == nil then
      result[pl].secondaries = {}
    end
    if result[pl].secondaries[secs[secondary]] == nil then
      result[pl].secondaries[secs[secondary]] = {}
      result[pl].secondaries[secs[secondary]].name = scoring[player].secondary[secondary][1]
      result[pl].secondaries[secs[secondary]].score = scoring[player].secondary[secondary][2]
      result[pl].secondaries[secs[secondary]].none = 0
      result[pl].secondaries[secs[secondary]].first = 0
      result[pl].secondaries[secs[secondary]].second = 0
      result[pl].secondaries[secs[secondary]].third = 0
      result[pl].secondaries[secs[secondary]].fourth = 0
      mult = 1
    else
      mult = result[pl].secondaries[secs[secondary]].score < scoring[player].secondary[secondary][2] and 1 or -1
      result[pl].secondaries[secs[secondary]].name = scoring[player].secondary[secondary][1]
      result[pl].secondaries[secs[secondary]].score = scoring[player].secondary[secondary][2]
    end
    result[pl].secondaries[secs[secondary]][rounds[round+1]] = result[pl].secondaries[secs[secondary]][rounds[round+1]] + (1*mult)
  end
end
function changeDropdown(id, value)
  Wait.frames(function()
    local oldUI = Global.UI.getXmlTable()
    for k1, v1 in ipairs(oldUI) do
      ch1 = oldUI[k1].children
      for k2, v2 in ipairs(ch1) do
        ch2 = oldUI[k1].children[k2].children
        for k3, v3 in ipairs(ch2) do
          ch3 = oldUI[k1].children[k2].children[k3].children
          for k4, v4 in ipairs(ch3) do
            if v4.attributes.id == id then
              options = v4.children
              for k5, v5 in ipairs(options) do
                if v5.value == value then
                  oldUI[k1].children[k2].children[k3].children[k4].children[k5].attributes.selected = true
                else
                  oldUI[k1].children[k2].children[k3].children[k4].children[k5].attributes.selected = false
                end
              end
            end
          end
        end
      end
    end
    Wait.frames(function() Global.UI.setXmlTable(oldUI) end, 10)
  end, 10)
end
function changeMultiDropdown(id, value)
  Wait.frames(function()
    local oldUI = Global.UI.getXmlTable()
    for k, v in ipairs(id) do
      for k1, v1 in ipairs(oldUI) do
        ch1 = oldUI[k1].children
        for k2, v2 in ipairs(ch1) do
          ch2 = oldUI[k1].children[k2].children
          for k3, v3 in ipairs(ch2) do
            ch3 = oldUI[k1].children[k2].children[k3].children
            for k4, v4 in ipairs(ch3) do
              if v4.attributes.id == v then
                options = v4.children
                for k5, v5 in ipairs(options) do
                  if v5.value == value[k] then
                    oldUI[k1].children[k2].children[k3].children[k4].children[k5].attributes.selected = true
                  else
                    oldUI[k1].children[k2].children[k3].children[k4].children[k5].attributes.selected = false
                  end
                end
              end
            end
          end
        end
      end
    end
    Wait.frames(function() Global.UI.setXmlTable(oldUI) end, 10)
  end, 10)
end
function setStateMachine(op1, op2)
  local oldOp1, oldOp2 = getStateMachine()
  if oldOp1 ~= "" then
    gameStateMachine[oldOp1][oldOp2]=false
  end
  gameStateMachine[op1][op2]=true
  broadcastToAll(op1.." "..op2)
end
function getStateMachine()
  for k1, v1 in pairs(gameStateMachine) do
    for k2, v2 in pairs(gameStateMachine[k1]) do
      if v2 then
        return k1, k2
      end
    end
  end
  return "", ""
end
function readyOperatives()
  for _, obj in ipairs(getCMOperativesOnBoard()) do
    if obj.hasTag('Operative') and obj.hasTag('Not Mustered') ~= true then
      if obj.getVar('KTUI_ReadyOperative') then
        obj.call('KTUI_ReadyOperative')
      end
    end
  end
end
function readyLooseOrders()
  for _, obj in ipairs(getLooseOrdersOnBoard()) do
    if string.find(obj.getName(), "_activated") then
      obj.setState(obj.getStateId()-1)
    end
  end
end
function getCMOperativesOnBoard()
  objs = {}
  for _, obj in ipairs(getAllObjects()) do
    if obj.getPosition().x < 15 and obj.getPosition().x > -15 and obj.getPosition().z < 11 and obj.getPosition().z > -11 then
      if obj.hasTag('Operative') and obj.hasTag('Not Mustered') ~= true then
        if obj.getVar('KTUI_ReadyOperative') then
          table.insert(objs, obj)
        end
      end
    end
  end
  return objs
end
function getNotCMOperativesOnBoard()
  objs = {}
  for _, obj in ipairs(getAllObjects()) do
    if obj.getPosition().x < 15 and obj.getPosition().x > -15 and obj.getPosition().z < 11 and obj.getPosition().z > -11 then
      if obj.hasTag('Operative') and obj.hasTag('Not Mustered') ~= true then
        if not obj.getVar('KTUI_ReadyOperative') then
          table.insert(objs, obj)
        end
      end
    end
  end
  return objs
end
function getLooseOrdersOnBoard()
  objs = {}
  for _, obj in ipairs(getAllObjects()) do
    if obj.getPosition().x < 15 and obj.getPosition().x > -15 and obj.getPosition().z < 11 and obj.getPosition().z > -11 then
      if string.find(obj.getName(), "Engage_ready") or
      string.find(obj.getName(), "Engage_activated") or
      string.find(obj.getName(), "Conceal_ready") or
      string.find(obj.getName(), "Conceal_activated") then
        table.insert(objs, obj)
      end
    end
  end
  return objs
end
function pressStopWatch(pl)
  local stopWatch = getObjectFromGUID("f4ee71")
  if pl.color == "Red" then
    stopWatch.call("Click_2", {player=pl})
  end
  if pl.color == "Blue" then
    stopWatch.call("Click_1", {player=pl})
  end
end
function stopStopWatch()
  local stopWatch = getObjectFromGUID("f4ee71")
  stopWatch.call("Pause")
end
function savePositions()
  for _, obj in ipairs(getNotCMOperativesOnBoard()) do
    if obj.getVar('savePosition') then
      obj.call("savePosition")
    end
  end
  for _, obj in ipairs(getCMOperativesOnBoard()) do
    if obj.getVar('savePosition') then
      obj.call("savePosition")
    end
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
function checkOverwatch(pl)
  if not overwatchTable.checked then
    if pl.color == "Red" then
      oPl = Player["Blue"]
    else
      oPl = Player["Red"]
    end
    overwatchTable[pl.steam_name] = {}
    overwatchTable[oPl.steam_name] = {}
    local overObjs = {}
    local objs = getCMOperativesOnBoard()
    local readyOps = {}
    local oReadyOps = {}
    local activatedOps = {}
    local oActivatedOps = {}
    for _, obj in ipairs(objs) do
      if obj.hasTag('Operative') and obj.hasTag('Not Mustered') ~= true then
        desc = obj.getDescription()
        objUI = obj.UI.getXmlTable()
        if string.find(desc, "Owned by "..pl.steam_name) then
          if string.find(getOperativeOrder(objUI), "_ready") then
            table.insert(readyOps, obj.getGUID())
          else
            table.insert(activatedOps, obj.getGUID())
          end
        end
        if oPl.steam_name ~= nil then
          if string.find(desc, "Owned by "..oPl.steam_name) then
            if string.find(getOperativeOrder(objUI), "_ready") then
              table.insert(oReadyOps, obj.getGUID())
            else
              table.insert(oActivatedOps, obj.getGUID())
            end
          end
        end
      end
    end
    if (next(oReadyOps) == nil and next(oActivatedOps) ~= nil) and (next(readyOps) ~= nil or not checkAllLooseOrdersActivated()) and next(overwatchTable[oPl.steam_name]) == nil then
        overwatchTable.checked = true
        for _, actObj in ipairs(oActivatedOps) do
          obj = getObjectFromGUID(actObj)
          objUI = obj.UI.getXmlTable()
          if string.find(getOperativeOrder(objUI), "Engage") then
            table.insert(overwatchTable[oPl.steam_name], actObj)
          end
        end
        local defaults = makeDefaults(rules)
        Wait.frames(function() updateOWXML(defaults, oPl) end, 20)
    else
      overwatchTable[oPl.steam_name] = {}
      overwatchTable[pl.steam_name] = {}
      overwatchTable.checked = false
    end
  end
end
function getOperativeOrder(objTable)
  for k1, v1 in ipairs(objTable) do
    ch1 = objTable[k1].children
    if objTable[k1].children ~= nil then
      for k2, v2 in ipairs(ch1) do
        if objTable[k1].children[k2].children ~= nil then
          ch2 = objTable[k1].children[k2].children
          for k3, v3 in ipairs(ch2) do
            if v3.attributes.id == "ktcnid-status-order" then
              return v3.attributes.image
            end
          end
        end
      end
    end
  end
  return ""
end
function updateOWXML(def, pl)
  oldTable = Global.UI.getXmlTable()
  if next(overwatchTable[pl.steam_name]) ~= nil then
    buttonCh = {}
    for _, actObj in ipairs(overwatchTable[pl.steam_name]) do
      addOverwatchToggle(pl, buttonCh, actObj, _)
    end
    for i, uiTable in ipairs(oldTable) do
      if uiTable.attributes.id == "kts__"..string.lower(pl.color).."_overwatch" then
        table.remove(oldTable, i)
        break
      end
    end
    table.insert(buttonCh, {
      tag="Text",
      attributes={
        class="title2",
        text=pl.steam_name.." Overwatch",
        fontSize=13,
        offsetXY="0 30"
      },
    })
    OWTable = {
      tag="Panel",
      attributes={
        id="kts__"..string.lower(pl.color).."_overwatch",
        rectAlignment="LowerRight",
        class="bkgPanel",
        height=80,
        width=300,
        offsetXY="-10 10",
        visibility=pl.color,
        active=true,
        allowDragging=true,
        returnToOriginalPositionWhenReleased=false
      },
      children=buttonCh
    }
    table.insert(oldTable, def)
    table.insert(oldTable, OWTable)
    Wait.frames(function() Global.UI.setXmlTable(oldTable) end, 1)
  end
end
function addOverwatchToggle(pl, tab, guid, ind)
  for line in getObjectFromGUID(guid).getDescription():gmatch("([^\n]*)\n?") do
    operativeName=line
    break
  end
  table.insert(tab,
    {
      tag="Panel",
      attributes={
        class="bkgPanel",
        height=80,
        width=300/#overwatchTable[pl.steam_name],
        offsetXY=(300*(ind-1)/#overwatchTable[pl.steam_name]).." 0",
        rectAlignment="MiddleLeft"
      },
      children={
        {
          tag="Button",
          attributes={
            id="kts__toggle_"..string.lower(pl.color).."_overwatch_"..guid,
            onClick=self.getGUID().."/onOverWatchTogglePressed("..ind..")",
            onMouseEnter=self.getGUID().."/onOverWatchToggleHover("..guid..")",
            tooltip=operativeName,
            rectAlignment="LowerCenter",
            offsetXY="0 -8",
          },
        },
        {
          tag="Text",
          attributes={
            id="kts__toggle_"..string.lower(pl.color).."_overwatch_text_"..guid,
            text="Operative",
            fontSize=12,
            offsetXY="0 -20",
          },
        },
      }
    })
end
function onOverWatchTogglePressed(player, value)
  local obj = getObjectFromGUID(overwatchTable[player.steam_name][tonumber(value)])
  obj.highlightOn(player.color)
  table.remove(overwatchTable[player.steam_name], tonumber(value))
  local defaults = makeDefaults(rules)
  if next(overwatchTable[player.steam_name]) == nil then
    setUIAttribute("kts__"..string.lower(player.color).."_overwatch", "active", false)
  else
    Wait.frames(function() updateOWXML(defaults, player) end, 20)
  end
end
function onOverWatchToggleHover(player, value)
  getObjectFromGUID(value).highlightOn(player.color, 0.2)
end
function checkAllOperativesActivated()
  allOpsActivated = true
  for _, obj in ipairs(getCMOperativesOnBoard()) do
    if obj.hasTag('Operative') and obj.hasTag('Not Mustered') ~= true then
      if string.find(getOperativeOrder(obj.UI.getXmlTable()), "_ready") then
        allOpsActivated = false
      end
    end
  end
  return allOpsActivated
end
function checkAllLooseOrdersActivated()
  allOrdsActivated = true
  for _, obj in ipairs(getLooseOrdersOnBoard()) do
    if string.find(obj.getName(), "_ready") then
      allOrdsActivated = false
    end
  end
  return allOrdsActivated
end
function checkOrdersCoherency()
  notCMObj = getNotCMOperativesOnBoard()
  looseOrders = getLooseOrdersOnBoard()
  if #looseOrders ~= #notCMObj then
    broadcastToAll("Did any of you forgot to remove a loose order?")
    return false
  end
  return true
end
function split(s, delimiter)
  stringResult = {};
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
      table.insert(stringResult, match);
  end
  name = ""
  for i=2, #stringResult do
    if name == "" then
      name = stringResult[i]
    else
      name = name.." "..stringResult[i]
    end
  end
  return name
end
function unsetHighLights()
  for _, obj in ipairs(getCMOperativesOnBoard()) do
    obj.highlightOff()
  end
end
function showYoutubeLink(pl)
  tabletObj = spawnObject({
      type = "Tablet",
      position = {-50, 10, 0},
      rotation = {70, 90, 0},
      scale = {2, 2, 2}
  })
  tabletObj.setLock(true)
  Player["Red"].lookAt({
      position = {x=-50,y=10,z=0},
      pitch    = 25,
      yaw      = 90,
      distance = 20,
  })
  Player["Blue"].lookAt({
      position = {x=-50,y=10,z=0},
      pitch    = 25,
      yaw      = -90,
      distance = 20,
  })
  Wait.frames(function() tabletObj.Browser.url = 'https://www.youtube.com/watch?v=GV7AnrjQr9A' end, 50)
end
function showOperativeSelection(pl)
  if getUIAttribute("kts__"..string.lower(pl.steam_name).."_operatives_selected", "width") ~= "400" then
    oldTable = Global.UI.getXmlTable()
    selectOpTable = {
      tag="Panel",
      attributes={
        id="kts__"..string.lower(pl.steam_name).."_operatives_selected",
        rectAlignment="MiddleCenter",
        allowDragging=true,
        returnToOriginalPositionWhenReleased=false,
        class="bkgPanel",
        height=100,
        width=400,
        offsetXY="-20 10",
        visibility=pl.color,
        active=true,
      },
      children={
        {
          tag="Text",
          attributes={
            fontSize=16,
            offsetXY="0 20"
          },
          value=[[Select your operatives with area selection
          (left click and drag) then press OK.
            No matter if you select other objects like orders, etc.]]
        },
        {
          tag="Button",
          attributes={
            onClick=self.guid.."/onOperativesSelected",
            height=30,
            width=100,
            offsetXY="0 -25"
          },
          value="OK"
        },
      }
    }
    local defaults = makeDefaults(rules)
    table.insert(oldTable, defaults)
    table.insert(oldTable, selectOpTable)
    Wait.frames(function() Global.UI.setXmlTable(oldTable) end, 1)
  else
    Global.UI.show("kts__"..string.lower(pl.steam_name).."_operatives_selected")
  end
end
function onOperativesSelected(player)
  local selectedObjects = player.getSelectedObjects()
  local count = 0
  local operatives = {}
  for _, obj in ipairs(selectedObjects) do
    if obj.hasTag('Operative') and obj.hasTag('Not Mustered') ~= true then
      local oldDesc = obj.getDescription()
      if not string.find(oldDesc, "Owned by ") then
        newDesc = oldDesc.." Owned by "..player.steam_name
        obj.setDescription(newDesc)
        count = count + 1
        table.insert(operatives, obj.getGUID())
      end
    end
  end
  --local ktmanagerGuid = "3e7210"
  --getObjectFromGUID(ktmanagerGuid).call('setKillTeam', operatives)
  broadcastToAll(player.steam_name.." has "..count.." operatives")
  Global.UI.hide("kts__"..string.lower(player.steam_name).."_operatives_selected")
end
function deselectOperatives(pl)
  Global.UI.hide("kts__"..string.lower(pl.steam_name).."_operatives_selected")
  for _, obj in ipairs(getCMOperativesOnBoard()) do
    local oldDesc = obj.getDescription()
    i, j = string.find(oldDesc, "Owned by "..pl.steam_name)
    if i then
      obj.setDescription(string.sub(oldDesc, 1, i-1))
    end
  end
  for _, obj in ipairs(getNotCMOperativesOnBoard()) do
    local oldDesc = obj.getDescription()
    i, j = string.find(oldDesc, "Owned by "..pl.steam_name)
    if i then
      obj.setDescription(string.sub(oldDesc, 1, i-1))
    end
  end
end
function changeMissionScoreboard(missionGUID)
  if missionIndexItd[missionGUID] ~= nil then
    setUIAttribute("kts__streamer_panel"..missionSelectedForScoreboard, "active", false)
    missionSelectedForScoreboard = missionGUID
    local tabs = Notes.getNotebookTabs()
    for _,t in pairs(tabs) do
      if t.title == settingsNotes then
        gmn = t.body
        break
      end
    end
    newSettings = JSON.decode(gmn)
    newSettings.scoring.primary = missionIndexItd[missionGUID].primary
    newSettings.scoring.bonus = missionIndexItd[missionGUID].bonus
    gmn = JSON.encode(newSettings)
    Notes.editNotebookTab({
      title=settingsNotes,
      body=gmn,
      color="Black"
    })
    setup(newSettings)
    buildUI()
    Wait.frames(refresh, 10)
    Wait.frames(function()
      if Global.UI.getAttribute("kts__streamer_panel"..missionSelectedForScoreboard, "id") == nil then
        local oldUI = Global.UI.getXmlTable()
        local hudVisibility, streamVisibility = getHudVisibilities()
        if oldUI == nil then
    			oldUI = {}
    		end
        table.insert(oldUI, buildStreamerUI(streamVisibility))
        Wait.frames(function() Global.UI.setXmlTable(oldUI) end, 1)
      else
        setUIAttribute("kts__streamer_panel"..missionSelectedForScoreboard, "active", true)
      end
    end, 20)
  else
    -- maybe this should be dependent on mission pack selected
    if missionSelectedForScoreboard ~= "" then
      setUIAttribute("kts__streamer_panel"..missionSelectedForScoreboard, "active", false)
      setUIAttribute("kts__streamer_panel", "active", true)
      missionSelectedForScoreboard = ""
      local tabs = Notes.getNotebookTabs()
      for _,t in pairs(tabs) do
        if t.title == settingsNotes then
          gmn = t.body
          break
        end
      end
      newSettings = JSON.decode(gmn)
      newSettings.scoring.primary = {
        exclusive = JSON.decode('[false, false, false, false]'),
        max = 16,
        maxEach = 0,
        objectives = JSON.decode('["1+", "2+", "3+", "4+"]')
      }
      newSettings.scoring.bonus = {
        max = 0,
        objectives = JSON.decode('[]')
      }
      gmn = JSON.encode(newSettings)
      Notes.editNotebookTab({
        title=settingsNotes,
        body=gmn,
        color="Black"
      })
      setup(newSettings)
      buildUI()
      Wait.frames(refresh, 10)
    end
  end
end
function onObjectLeaveContainer(container, object)
  if missionIndexItd[container.getGUID()] ~= nil then
    if missionSelectedForScoreboard ~= container.getGUID() then
      changeMissionScoreboard(container.getGUID())
    end
  end
end
function updateMegaDeck()
  megaDeck = getObjectFromGUID(megaDeckGuid)
  oldMegaDeck = getObjectFromGUID(oldMegaDeckGuid)
  for _, containedObject in ipairs(megaDeck.getObjects()) do
    spawnedObject = megaDeck.takeObject()
    spawnedObject.destruct()
  end
  local objectsToPut = {}
  for _, containedObject in ipairs(oldMegaDeck.getObjects()) do
    table.insert(objectsToPut, oldMegaDeck.takeObject())
  end
  for _, objectToPut in ipairs(objectsToPut) do
    oldMegaDeck.putObject(objectToPut)
    megaDeck.putObject(objectToPut)
  end
end
--ADDED by ZAKA

end)
__bundle_register("base-board/panel-buttons", function(require, _LOADED, __bundle_register, __bundle_modules)

function onEndInitP1Btn(player)
  if player.color == "Red" then
    oldOp1, oldOp2 = getStateMachine()
    if oldOp2 == "init" then
      for i=1, 4, 1 do
        if oldOp1 == "tp"..i then
          onInitiativePressed(player, true, "kts__initiative_player1_"..i.."_toggle")
          gameStateMachine.whoToPress = player.steam_name
          break
        end
      end
      setUIAttribute("kts__scoring_button", "active", false)
      setUIAttribute("kts__end_init_1_button", "active", false)
      setUIAttribute("kts__end_init_2_button", "active", false)
      setUIAttribute("kts__loading_button", "active", true)
      setUIAttribute("kts__loading_button", "textColor", "Orange")
      Wait.frames(function ()
        setUIAttribute("kts__loading_button", "active", false)
        setStateMachine(oldOp1, "ploys")
        setUIAttribute("kts__end_ploys_button", "active", true)
        setUIAttribute("kts__end_ploys_button", "textColor", "Orange")
      end, 100)
    end
  end
end
function onEndInitP2Btn(player)
  if player.color == "Blue" then
    oldOp1, oldOp2 = getStateMachine()
    if oldOp2 == "init" then
      for i=1, 4, 1 do
        if oldOp1 == "tp"..i then
          onInitiativePressed(player, true, "kts__initiative_player2_"..i.."_toggle")
          gameStateMachine.whoToPress = player.steam_name
          break
        end
      end
      setUIAttribute("kts__scoring_button", "active", false)
      setUIAttribute("kts__end_init_1_button", "active", false)
      setUIAttribute("kts__end_init_2_button", "active", false)
      setUIAttribute("kts__loading_button", "active", true)
      setUIAttribute("kts__loading_button", "textColor", "Orange")
      Wait.frames(function ()
        setUIAttribute("kts__loading_button", "active", false)
        setStateMachine(oldOp1, "ploys")
        setUIAttribute("kts__end_ploys_button", "active", true)
        setUIAttribute("kts__end_ploys_button", "textColor", "Orange")
      end, 100)
    end
  end
end
function onEndPloysBtn(player)
  if player.color == "Red" or player.color == "Blue" then
    oldOp1, oldOp2 = getStateMachine()
    if oldOp2 == "ploys" then
      setUIAttribute("kts__end_ploys_button", "active", false)
      setUIAttribute("kts__loading_button", "active", true)
      setUIAttribute("kts__loading_button", "textColor", "Orange")
      Wait.frames(function ()
        setUIAttribute("kts__loading_button", "active", false)
        setStateMachine(oldOp1, "tacops")
        setUIAttribute("kts__end_tacops_button", "active", true)
        setUIAttribute("kts__end_tacops_button", "textColor", "Orange")
      end, 100)
    end
  end
end
function onEndTacopsBtn(player)
  if player.color == "Red" or player.color == "Blue" then
    oldOp1, oldOp2 = getStateMachine()
    if oldOp2 == "tacops" then
      pressStopWatch(Player[scoring[1].initiative[getCurrentRound()] and 'Blue' or 'Red'])
      setUIAttribute("kts__end_tacops_button", "active", false)
      setUIAttribute("kts__loading_button", "active", true)
      setUIAttribute("kts__loading_button", "textColor", "Orange")
      Wait.frames(function ()
        setUIAttribute("kts__loading_button", "active", false)
        setStateMachine(oldOp1, "firefight")
        setUIAttribute("kts__activated_button", "active", true)
        setUIAttribute("kts__activated_button", "textColor", Player["Red"].steam_name == gameStateMachine.whoToPress and "Red" or "Blue")
        setUIAttribute("kts__end_tp_button", "active", true)
        setUIAttribute("kts__end_tp_button", "textColor", "Orange")
        broadcastToAll(gameStateMachine.whoToPress.."'s turn")
      end, 100)
    end
  end
end
function onActivatedBtn(player)
  if player.steam_name == gameStateMachine.whoToPress then
    if Player['Red'].steam_name ~= nil and Player['Blue'].steam_name ~= nil then
      local oldOp1, oldOp2 = getStateMachine()
      if oldOp2 == "firefight" then
        savePositions()
        pressStopWatch(player)
        if checkOrdersCoherency() and string.lower(result.allowOW) == "true" then
          checkOverwatch(player)
        end
        gameStateMachine.whoToPress = player.color == "Red" and Player['Blue'].steam_name or Player['Red'].steam_name
        setUIAttribute("kts__activated_button", "textColor", player.color == "Red" and "Blue" or "Red")
        broadcastToAll(gameStateMachine.whoToPress.."'s turn")
      end
    else
      broadcastToAll("Both players need to be seated to continue")
    end
  else
    broadcastToAll("It's "..gameStateMachine.whoToPress.." turn")
  end
end
function onEndTPBtn(player)
  if player.color == "Red" or player.color == "Blue" then
    local oldOp1, oldOp2 = getStateMachine()
    if oldOp2 == "firefight" then
      if Player['Red'].steam_name ~= nil and Player['Blue'].steam_name ~= nil then
        isOk = checkAllOperativesActivated() and checkAllLooseOrdersActivated()
        if isOk then
          local objs = getCMOperativesOnBoard()
          for _, obj in ipairs(objs) do
            for i, color in ipairs({"Red", "Blue"}) do
              if string.find(obj.getDescription(), "Owned by "..Player[color].steam_name) then
                if result[Player[color].steam_name] == nil then
                  result[Player[color].steam_name] = {}
                end
                if result[Player[color].steam_name].operatives == nil then
                  result[Player[color].steam_name].operatives = {}
                end
                result[Player[color].steam_name].operatives[obj.getGUID()] = {
                  name=obj.getName(),
                  desc=obj.getDescription(),
                }
                local pos = obj.getPosition()
                if pos.x < 15 and pos.x > -15 and pos.z < 11 and pos.z > -11 then
                  result[Player[color].steam_name].operatives[obj.getGUID()].killed = false
                else
                  round = getCurrentRound()
                  result[Player[color].steam_name].operatives[obj.getGUID()].killed = true
                  result[Player[color].steam_name].operatives[obj.getGUID()].roundKilled = round
                end
              end
            end
          end
          stopStopWatch()
          setUIAttribute("kts__activated_button", "active", false)
          setUIAttribute("kts__end_tp_button", "active", false)
          setUIAttribute("kts__loading_button", "active", true)
          setUIAttribute("kts__loading_button", "textColor", "Orange")
          Wait.frames(function()
            setUIAttribute("kts__loading_button", "active", false)
            setStateMachine(oldOp1, "scoring")
            setUIAttribute("kts__scoring_button", "active", true)
            setUIAttribute("kts__scoring_button", "textColor", "Orange")
          end, 100)
        else
          broadcastToAll("There still are ready operatives")
        end
      else
        broadcastToAll("Need both players seated to continue")
      end
    end
  end
end
function onScoringBtn(player)
  if player.color == "Red" or player.color == "Blue" then
    oldOp1, oldOp2 = getStateMachine()
    if oldOp2 == "scoring" then
      setUIAttribute("kts__scoring_button", "active", false)
      setUIAttribute("kts__loading_button", "active", true)
      setUIAttribute("kts__loading_button", "textColor", "Orange")
      if oldOp1 ~= "tp4" then
        savePositions()
        readyOperatives()
        readyLooseOrders()
        unsetHighLights()
        overwatchTable = {}
        overwatchTable.checked = false
        oldTable = Global.UI.getXmlTable()
        for i, uiTable in ipairs(oldTable) do
          if uiTable.attributes.id == "kts__red_overwatch" then
            table.remove(oldTable, i)
          end
          if uiTable.attributes.id == "kts__blue_overwatch" then
            table.remove(oldTable, i)
          end
        end
        local defaults = makeDefaults(rules)
        table.insert(oldTable, defaults)
        Wait.frames(function ()
          Global.UI.setXmlTable(oldTable)
          setUIAttribute("kts__loading_button", "active", false)
          setUIAttribute("kts__scoring_button", "active", false)
          for i=1, 3, 1 do
            if oldOp1 == "tp"..i then
              setStateMachine("tp"..(i+1), "init")
              break
            end
          end
          setUIAttribute("kts__end_init_1_button", "active", true)
          setUIAttribute("kts__end_init_1_button", "textColor", "Orange")
          setUIAttribute("kts__end_init_2_button", "active", true)
          setUIAttribute("kts__end_init_2_button", "textColor", "Orange")
        end, 100)
      else
        Wait.frames(function()
          setUIAttribute("kts__loading_button", "active", false)
          setStateMachine("endGame", "active")
          setUIAttribute("kts__end_game_button", "active", true)
          setUIAttribute("kts__end_game_button", "textColor", "Orange")
          broadcastToAll("End Game. Press 'Send Data' button to send your game information.")
        end, 100)
      end
    end
  end
end
function onEndGame(player)
  if player.color == "Red" or player.color == "Blue" then
    if Player['Red'].steam_name ~= nil and Player['Blue'].steam_name ~= nil then
      if result[Player['Red'].steam_name].allow == "True" and result[Player['Blue'].steam_name].allow == "True" then
        local rounds = {
          "first",
          "second",
          "third",
          "fourth"
        }
        for _, player in ipairs(Player.getPlayers()) do
          if result[player.steam_name] == nil then
            result[player.steam_name] = {}
          end
          result[player.steam_name].color = player.color
        end

        auxNames = {}
        for i, play in ipairs({"Red", "Blue"}) do
          pl = Player[play].steam_name
          if pl == nil then
            pl = "no_player"
          end
          auxNames[play] = pl
          if result[pl] == nil then
            result[pl] = {}
            result[pl].color = Player[play].color
          end
          result[pl].initiative = {}
          result[pl].primaries = {}
          if result[pl].secondaries == nil then
            result[pl].secondaries = {}
          end
          result[pl].primaries.total = 0
          for round=1, rules.scoring.maxRounds do
            result[pl].initiative[round] = scoring[i].initiative[round]
            result[pl].primaries[rounds[round]] = 0
            for k,_ in pairs(rules.scoring.primary.objectives) do
              result[pl].primaries[rounds[round]] = result[pl].primaries[rounds[round]] + (scoring[i].primary[k][round] and 1 or 0)
            end
            if rules.scoring.primary.maxEach > 0 then
              result[pl].primaries.total = result[pl].primaries.total + math.min(result[pl].primaries[rounds[round]], rules.scoring.primary.maxEach)
            else
              result[pl].primaries.total = result[pl].primaries.total + result[pl].primaries[rounds[round]]
            end
          end
          result[pl].primaries["end"] = scoring[i].secondary[4]
          result[pl].primaries.total = result[pl].primaries.total + result[pl].primaries["end"]

          result[pl].secondaries.total = 0
          for s=1, 3 do
            if result[pl].secondaries[rounds[s]] == nil then
              result[pl].secondaries[rounds[s]] = {}
              result[pl].secondaries[rounds[s]].name = scoring[i].secondary[s][1]
              result[pl].secondaries[rounds[s]].score = scoring[i].secondary[s][2]
              result[pl].secondaries[rounds[s]].none = 0
              result[pl].secondaries[rounds[s]].first = 0
              result[pl].secondaries[rounds[s]].second = 0
              result[pl].secondaries[rounds[s]].third = 0
              result[pl].secondaries[rounds[s]].fourth = 0
            else
              result[pl].secondaries[rounds[s]].name = scoring[i].secondary[s][1]
            end
          end
          result[pl].secondaries.total = result[pl].secondaries[rounds[1]].score + result[pl].secondaries[rounds[2]].score + result[pl].secondaries[rounds[3]].score
          result[pl].total = result[pl].primaries.total + result[pl].secondaries.total
        end

        if result[auxNames["Red"]].total > result[auxNames["Blue"]].total then
          result.winner = auxNames["Red"]
          result.loser = auxNames["Blue"]
          result.tie = false
        elseif result[auxNames["Red"]].total < result[auxNames["Blue"]].total then
          result.winner = auxNames["Blue"]
          result.loser = auxNames["Red"]
          result.tie = false
        else
          result.winner = auxNames["Red"]
          result.loser = auxNames["Blue"]
          result.tie = true
        end
        result[auxNames["Red"]].steamId = Player['Red'].steam_id
        result[auxNames["Blue"]].steamId = Player['Blue'].steam_id
        result['tournament'] = ""
        --result.rollOffWinner = Player["Red"].steam_name == result.rollOffWinner and "red" or "blue"
        --result.rollOffLoser = Player["Red"].steam_name == result.rollOffLoser and "red" or "blue"
        --result.scoutingWinner = Player["Red"].steam_name == result.scoutingWinner and "red" or "blue"

        --result.red = result[Player['Red'].steam_name ~= nil and Player['Red'].steam_name or "no_player"]
        --result.blue = result[Player['Blue'].steam_name ~= nil and Player['Blue'].steam_name or "no_player"]

        --result[Player['Red'].steam_name ~= nil and Player['Red'].steam_name or "no_player"] = nil
        --result[Player['Blue'].steam_name ~= nil and Player['Blue'].steam_name or "no_player"] = nil

        local headers = {
          -- We're sending a JSON body in the request
          ["Content-Type"] = "application/json",
          -- We're expecting a JSON body in the response
          Accept = "application/json",
        }
        local url = "https://killteamdata.com/gamedata"
        WebRequest.custom(url, "POST", true, JSON.encode(result), headers, returnEndGame)
      else
        setUIAttribute("kts__checklist_panel", "visibility", "Red|Blue|Black|White|Grey")
        setUIAttribute("kts__checklist_panel", "active", true)
        broadcastToAll("Both players must accept data allowing")
      end
    else
      broadcastToAll("Both players must seated")
    end
  end
end

end)
__bundle_register("base-board/legacy-mission-data", function(require, _LOADED, __bundle_register, __bundle_modules)
-- TODO if mission added, update
missionIndexOpen['8cc4c8'] = {
    code=1.1,
    name="Loot and Salvage",
    objGuid='fef2fe'
  }
  missionIndexOpen['653576'] = {
    code=1.2,
    name="Consecration",
    objGuid='aa55ae'
  }
  missionIndexOpen['2da116'] = {
    code=1.3,
    name="Awaken the data Spirits",
    objGuid='6f0b59'
  }
  missionIndexOpen['cb09ac'] = {
    code=2.1,
    name="Escalating Hostilities",
    objGuid='bcfd2c'
  }
  missionIndexOpen['ab2f17'] = {
    code=2.2,
    name="Seize Ground",
    objGuid='082875'
  }
  missionIndexOpen['fd5afd'] = {
    code=2.3,
    name="Domination",
    objGuid='db097f'
  }
  missionIndexOpen['c50020'] = {
    code=3.1,
    name="Secure Archeotech",
    objGuid='91d284'
  }
  missionIndexOpen['d03785'] = {
    code=3.2,
    name="Duel of wits",
    objGuid='edd0ad'
  }
  missionIndexOpen['5ec111'] = {
    code=3.3,
    name="Master the terminals",
    objGuid='2fb4cc'
  }
  missionIndexItd = {}
  --TODO add guids
  missionIndexItd["25d8b1"] = {
    code=1.1,
    name="Command station control",
    objGuid='7ce808',
    terrainGuid='02f7ea',
    primary = {
      exclusive = JSON.decode('[false, false, false]'),
      max = 12,
      maxEach = 0,
      objectives = JSON.decode('["1+", "2+", "3+"]')
    },
    bonus = {
      max = 0,
      objectives = JSON.decode('[]')
    }
  }
  missionIndexItd["574334"] = {
    code=1.2,
    name="Power surge",
    objGuid='65ed51',
    terrainGuid='543851',
    primary = {
      exclusive = JSON.decode('[false, false, false]'),
      max = 12,
      maxEach = 0,
      objectives = JSON.decode('["1+", "2+", "3+"]')
    },
    bonus = {
      max = 0,
      objectives = JSON.decode('[]')
    }
  }
  missionIndexItd["4bd33e"] = {
    code=1.3,
    name="Supply raid",
    objGuid='03d7e1',
    terrainGuid='af8f16',
    primary = {
      exclusive = JSON.decode('[false]'),
      max = 12,
      maxEach = 0,
      objectives = JSON.decode('["1+"]')
    },
    bonus = {
      max = 8,
      objectives = JSON.decode('["End battle"]')
    }
  }
  missionIndexItd["e1bd09"] = { --NO first
    code=2.1,
    name="Junction assault",
    objGuid='',
    terrainGuid='b7e8a6',
    primary = {
      exclusive = JSON.decode('[false, false, false, false]'),
      max = 12,
      maxEach = 0,
      objectives = JSON.decode('["1+", "2+", "3+", "4+"]')
    },
    bonus = {
      max = 0,
      objectives = JSON.decode('[]')
    }
  }
  missionIndexItd["6ad39d"] = {
    code=2.2,
    name="Full-Scale attack",
    objGuid='158e30',
    terrainGuid='180b15',
    primary = {
      exclusive = JSON.decode('[false, false, false, false, false, false]'),
      max = 12,
      maxEach = 0,
      objectives = JSON.decode('["1+", "2+", "3+", "4+", "5+", "6+"]')
    },
    bonus = {
      max = 0,
      objectives = JSON.decode('[]')
    }
  }
  missionIndexItd["d23b90"] = {
    code=2.3,
    name="Mysterious signature",
    objGuid='d49add',
    terrainGuid='6e6c6b',
    primary = {
      exclusive = JSON.decode('[false]'),
      max = 12,
      maxEach = 0,
      objectives = JSON.decode('["1+"]')
    },
    bonus = {
      max = 6,
      objectives = JSON.decode('["End battle"]')
    }
  }
  missionIndexItd["451ffb"] = { --NO first
    code=3.1,
    name="Forge stronghold",
    objGuid='ebe98e',
    terrainGuid='e2fb73',
    primary = {
      exclusive = JSON.decode('[false, false, false, false]'),
      max = 12,
      maxEach = 0,
      objectives = JSON.decode('["1+", "2+", "3+", "4+"]')
    },
    bonus = {
      max = 0,
      objectives = JSON.decode('[]')
    }
  }
  missionIndexItd["72ceb4"] = {
    code=3.2,
    name="Vault plunder",
    objGuid='04420d',
    terrainGuid='00e169',
    primary = {
      exclusive = JSON.decode('[false, false, false, false]'),
      max = 12,
      maxEach = 0,
      objectives = JSON.decode('["1+", "2+", "3+", "4+"]')
    },
    bonus = {
      max = 8,
      objectives = JSON.decode('["End battle"]')
    }
  }
  missionIndexItd["b3a100"] = {
    code=3.3,
    name="Exposed trove",
    objGuid='49d002',
    terrainGuid='0a6ec7',
    primary = {
      exclusive = JSON.decode('[false, false, false]'),
      max = 12,
      maxEach = 0,
      objectives = JSON.decode('["1+", "2+", "3+"]')
    },
    bonus = {
      max = 4,
      objectives = JSON.decode('["End battle"]')
    }
  }
  
end)
__bundle_register("base-board/pre-game-checklist", function(require, _LOADED, __bundle_register, __bundle_modules)
-- ADDED by ZAKA
-- TODO Add here GUID of MegaDeck
megaDeckGuid = "a2a37e"
oldMegaDeckGuid = "18fcc4"
masterBagOpen = "ebbb8c"
masterBagItd = "ef8c27"
critOpsOpenBag = "90f952"
critOpsItdBag = "87e3a8"
-- TODO for the future -> if faction added, update
imperiumFactions = {
  "Elucidian Starstriders",
  "Exaction Squad",
  "Novitiates",
  "Hunter Clade",
  "Imperial Navy Breachers",
  "Inquisitorial Agents",
  "Angels of Death",
  "Kasrkin",
  "Phobos Strike Team",
  "Scout Squad",
  "Tempestus Aquilons",
  "Veteran Guard"
}
chaosFactions = {
  "Blooded",
  "Chaos Cult",
  "Fellgor Ravager",
  "Gellerpox Infected",
  "Legionary",
  "Nemesis Claw",
  "Warp Coven"
}
xenosFactions = {
  "Brood Brothers",
  "Farstalker Kinband",
  "Hearthkyn Salvager",
  "Hernkyn Yaegirs",
  "Hierotek Circle",
  "Kommandos",
  "Pathfinders",
  "Vespids Stingwing",
  "Wyrmblade"
}
aeldariFactions = {
  "Corsair Voidscarred",
  "Blades of Khaine",
  "Hand of the Archon",
  "Mandrakes",
  "Void-dancer Troupe"
}

require("base-board/game-state-machine")

checkListPlayer = {
  name = "",
  allow = false,
  superFaction = "Select One",
  faction = "Select One",
  tacOps = false,
  equipment = false,
  barricades = false,
  deployed = false,
  scouting = "Select One",
}
checkListStatus = {
  killZoneLoaded = false,
  allowOW = false,
  gameType = "Open play",
  edition= "KT 2021 - Open",
  mission = "Select One",
  tournament = "Select One",
  rollOffWinner="Select One",
  rollOffAttacker=false,
  rollOffDefender=false,
  revealed=false,
  winner="",
}
result = {}
missionIndexOpen = {}
missionIndexItd = {}
missionIndexCritOps = {
  {code = 'A', name = 'Loot'},
  {code = 'B', name = 'Secure'},
  {code = 'C', name = 'Capture'},
}
missionIndexCritOpsItd = {
  {code = 'A', name = 'Loot'},
  {code = 'B', name = 'Secure'},
  {code = 'C', name = 'Capture'},
}
factionsInSuperDeck = {}

-- TODO if tournament added, update
tournamentIndex = {
  'None',
  'Liga Mercenaria',
  'Other'
}

-- TODO if game type added, update
gameTypeIndex = {
  "Open Play",
  "Matched Play",
  "Narrative Play",
}

-- TODO if edition added, update
editionIndex = {
  "KT 2022 - Crit Ops",
  "KT 2022 - Crit Ops - ITD",
  "KT 2021 - Open",
  "KT 2022 - Into the Dark",
}
function onGameTypeSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    result.gameType = "Select One"
    checkListStatus.gameType = "Select One"
    setUIAttribute("kts__dropdown_game_type", "textColor", "#e74f0aff")
    if value ~= "Select One" then
      checkListStatus.gameType = value
      result.gameType = value
      broadcastToAll("Game type: "..value.." selected")
      setUIAttribute("kts__dropdown_game_type", "textColor", player.color)
    end
    if value ~= "Matched play" then
      result.tournament = "Select One"
      checkListStatus.tournament = "Select One"
      setUIAttribute("kts__dropdown_tournament", "textColor", "#e74f0aff")
      Wait.frames(function ()
        changeDropdown("kts__dropdown_tournament", "Select One")
      end, 50)
    end
  end
  changeDropdown("kts__dropdown_game_type", checkListStatus.gameType)
end
function onTournamentSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    result.tournament = "Select One"
    checkListStatus.tournament = "Select One"
    setUIAttribute("kts__dropdown_tournament", "textColor", "#e74f0aff")
    if value ~= "Select One" then
      if result.gameType == "Matched Play" then
        checkListStatus.tournament = value
        result.tournament = value
        broadcastToAll("Tournament: "..value.." selected")
        setUIAttribute("kts__dropdown_tournament", "textColor", player.color)
      else
        broadcastToAll("To choose a tournament, select 'Matched play' on Game type")
      end
    end
  end
  changeDropdown("kts__dropdown_tournament", checkListStatus.tournament)
end
function onKillZoneLoaded(player, value)
  if player.color == "Red" or player.color == "Blue" then
    result.killZoneLoaded = value
    checkListStatus.killZoneLoaded = value
    setUIAttribute("kts__toggle_kz_loaded", "backgroundColor", value == "True" and player.color or "White")
  end
  setUIAttribute("kts__toggle_kz_loaded", "isOn", checkListStatus.killZoneLoaded == "True" and true or false)
end
function onOpenMissionSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    for k,v in pairs(missionIndexOpen) do
      obj = getObjectFromGUID(k)
      if obj ~= nil then
        obj.call("buttonClick_recall")
      end
      obj = getObjectFromGUID(v.objGuid)
      if obj ~= nil then
        obj.call("buttonClick_recall")
      end
      if string.match(' '..value..' ', '%A'..v.code..'%A') ~= nil then
        setMission(missionIndexOpen[k])
        for k,v in pairs(missionIndexOpen) do
          if v == result.mission then
            Wait.frames(
              function()
                obj = getObjectFromGUID(k)
                if obj ~= nil then
                  obj.call("buttonClick_place")
                end
                obj = getObjectFromGUID(v.objGuid)
                Wait.frames(
                function ()
                  if obj ~= nil then
                    obj.call("buttonClick_place")
                  end
                end, 30)
              end, 30
            )
            changeMissionScoreboard(k)
          end
        end
        checkListStatus.mission = value
        setUIAttribute("kts__dropdown_mission_open", "textColor", value == "Select One" and "#e74f0aff" or player.color)
      end
    end
  end
  Wait.frames(function()
    changeDropdown("kts__dropdown_mission_open", checkListStatus.mission)
  end, 10)
end
function onCritOpsMissionSelected(player, value)
  checkListStatus.mission = value
end
function onCritOpsItdMissionSelected(player, value)
  checkListStatus.mission = value
end
function onItdMissionSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    for k,v in pairs(missionIndexItd) do
      obj = getObjectFromGUID(k)
      if obj ~= nil then
        obj.call("buttonClick_recall")
      end
      obj = getObjectFromGUID(v.objGuid)
      if obj ~= nil then
        obj.call("buttonClick_recall")
      end
      obj = getObjectFromGUID(v.terrainGuid)
      if obj ~= nil then
        obj.call("buttonClick_recall")
      end
      if string.match(' '..value..' ', '%A'..v.code..'%A') ~= nil then
        setMission(missionIndexItd[k])
        for k,v in pairs(missionIndexItd) do
          if v == result.mission then
            Wait.frames(
              function()
                obj = getObjectFromGUID(k)
                if obj ~= nil then
                  obj.call("buttonClick_place")
                end
                obj = getObjectFromGUID(v.objGuid)
                Wait.frames(
                function ()
                  if obj ~= nil then
                    obj.call("buttonClick_place")
                  end
                  obj = getObjectFromGUID(v.terrainGuid)
                  Wait.frames(
                  function ()
                    if obj ~= nil then
                      obj.call("buttonClick_place")
                    end
                  end, 30)
                end, 30)
              end, 30
            )
            changeMissionScoreboard(k)
          end
        end
        checkListStatus.mission = value
        setUIAttribute("kts__dropdown_mission_itd", "textColor", value == "Select One" and "#e74f0aff" or player.color)
      end
    end
  end
  Wait.frames(function()
    changeDropdown("kts__dropdown_mission_itd", checkListStatus.mission)
  end, 10)
end
function onRedWonRollOff(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if getUIAttribute("kts__red_rolloff_winner_text", "text") ~= "no_player" then
      checkListStatus.rollOffAttacker=false
      checkListStatus.rollOffDefender=false
      checkListStatus.rollOffWinner="Select One"
      result.rollOffWinner = nil
      result.rollOffLoser = nil
      setUIAttribute("kts__toggle_red_rolloff_winner", "backgroundColor", value == "True" and player.color or "White")
      if value == "True" then
        setUIAttribute("kts__toggle_blue_rolloff_winner", "isOn", false)
        setUIAttribute("kts__toggle_red_rolloff_winner", "isOn", true)
        setUIAttribute("kts__toggle_blue_rolloff_winner", "backgroundColor", "White")
        for _,pl in ipairs(Player.getPlayers()) do
          if pl.steam_name == getUIAttribute("kts__red_roloff_winner_text", "text") then
            checkListStatus.rollOffWinner = pl.steam_name
            setRollOffWinner(pl)
            if pl.color == "Red" then
              setRollOffLoser(Player["Blue"])
            else
              setRollOffLoser(Player["Red"])
            end
          end
        end
      end
      setUIAttribute("kts__toggle_attacker_selected", "isOn", checkListStatus.rollOffAttacker)
      setUIAttribute("kts__toggle_defender_selected", "isOn", checkListStatus.rollOffDefender)
    else
      broadcastToAll("No one is yet here")
    end
  else
    setUIAttribute("kts__toggle_red_rolloff_winner", "isOn", value=="True" and false or true)
  end
end
function onBlueWonRollOff(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if getUIAttribute("kts__blue_rolloff_winner_text", "text") ~= "no_player" then
      checkListStatus.rollOffAttacker=false
      checkListStatus.rollOffDefender=false
      checkListStatus.rollOffWinner="Select One"
      result.rollOffWinner = nil
      result.rollOffLoser = nil
      setUIAttribute("kts__toggle_blue_rolloff_winner", "backgroundColor", value == "True" and player.color or "White")
      if value == "True" then
        setUIAttribute("kts__toggle_red_rolloff_winner", "isOn", false)
        setUIAttribute("kts__toggle_blue_rolloff_winner", "isOn", true)
        setUIAttribute("kts__toggle_red_rolloff_winner", "backgroundColor", "White")
        for _,pl in ipairs(Player.getPlayers()) do
          if pl.steam_name == getUIAttribute("kts__blue_roloff_winner_text", "text") then
            checkListStatus.rollOffWinner = pl.steam_name
            setRollOffWinner(pl)
            if pl.color == "Red" then
              setRollOffLoser(Player["Blue"])
            else
              setRollOffLoser(Player["Red"])
            end
          end
        end
      end
      setUIAttribute("kts__toggle_attacker_selected", "isOn", checkListStatus.rollOffAttacker)
      setUIAttribute("kts__toggle_defender_selected", "isOn", checkListStatus.rollOffDefender)
    else
      broadcastToAll("No one is yet here")
    end
  else
    setUIAttribute("kts__toggle_blue_rolloff_winner", "isOn", value=="True" and false or true)
  end
end
function onAttackerSelected(player, value)
  checkListStatus.rollOffAttacker=false
  checkListStatus.rollOffDefender=false
  if result.rollOffWinner ~= nil then
    if player.steam_name == result.rollOffWinner then
      result.rollOffWinnerSelection = "Attacker"
      checkListStatus.rollOffAttacker=true
      checkListStatus.rollOffDefender=false
    else
      broadcastToAll("Only "..result.rollOffWinner.." can select this")
    end
  else
    broadcastToAll("Select roll off winner")
  end
  setUIAttribute("kts__toggle_attacker_selected", "isOn", checkListStatus.rollOffAttacker)
  setUIAttribute("kts__toggle_defender_selected", "isOn", checkListStatus.rollOffDefender)
end
function onDefenderSelected(player, value)
  checkListStatus.rollOffAttacker=false
  checkListStatus.rollOffDefender=false
  if result.rollOffWinner ~= nil then
    if player.steam_name == result.rollOffWinner then
      result.rollOffWinnerSelection = "Defender"
      checkListStatus.rollOffAttacker=false
      checkListStatus.rollOffDefender=true
    else
      broadcastToAll("Only "..result.rollOffWinner.." can select this")
    end
  else
    broadcastToAll("Select roll off winner")
  end
  setUIAttribute("kts__toggle_attacker_selected", "isOn", checkListStatus.rollOffAttacker)
  setUIAttribute("kts__toggle_defender_selected", "isOn", checkListStatus.rollOffDefender)
end
function onRedSuperFactionSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if string.match(getUIAttribute("kts__dropdown_red_faction_text", "text"), player.steam_name) then
      setUIAttribute("kts__dropdown_red_faction_imperium", "active", false)
      setUIAttribute("kts__dropdown_red_faction_chaos", "active", false)
      setUIAttribute("kts__dropdown_red_faction_aeldari", "active", false)
      setUIAttribute("kts__dropdown_red_faction_xenos", "active", false)
      if checkListStatus[player.steam_name].superFaction ~= "Select One" then
        setFaction(player, "Select One")
      end
      setUIAttribute("kts__dropdown_red_faction_"..string.lower(value), "active", true)
      checkListStatus[player.steam_name].superFaction = value
      setUIAttribute("kts__dropdown_red_super_faction", "textColor", value == "Select One" and "#e74f0aff" or player.color)
    else
      broadcastToAll("Only "..split(getUIAttribute("kts__dropdown_red_faction_text", "text"), " ").." can select this")
    end
  end
  changeMultiDropdown({
    "kts__dropdown_red_super_faction",
    "kts__dropdown_red_faction_imperium",
    "kts__dropdown_red_faction_chaos",
    "kts__dropdown_red_faction_aeldari",
    "kts__dropdown_red_faction_xenos"
  },
  {
    checkListStatus[split(getUIAttribute("kts__dropdown_red_faction_text", "text"), " ")].superFaction,
    "Select One",
    "Select One",
    "Select One",
    "Select One"
  })
end
function onRedFactionSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if string.match(getUIAttribute("kts__dropdown_red_faction_text", "text"), player.steam_name) then
      setFaction(player, value)
      checkListStatus[player.steam_name].faction = value
      setUIAttribute("kts__dropdown_red_faction_imperium", "textColor", value == "Select One" and "#e74f0aff" or player.color)
      setUIAttribute("kts__dropdown_red_faction_chaos", "textColor", value == "Select One" and "#e74f0aff" or player.color)
      setUIAttribute("kts__dropdown_red_faction_aeldari", "textColor", value == "Select One" and "#e74f0aff" or player.color)
      setUIAttribute("kts__dropdown_red_faction_xenos", "textColor", value == "Select One" and "#e74f0aff" or player.color)
    else
      broadcastToAll("Only "..split(getUIAttribute("kts__dropdown_red_faction_text", "text"), " ").." can select this")
    end
  end
  changeDropdown("kts__dropdown_red_faction_"..string.lower(checkListStatus[split(getUIAttribute("kts__dropdown_red_faction_text", "text"), " ")].superFaction), checkListStatus[split(getUIAttribute("kts__dropdown_red_faction_text", "text"), " ")].faction)
end
function onRedFactionMouseEnter(player)
  if not string.match(getUIAttribute("kts__dropdown_red_faction_text", "text"), player.steam_name) then
    factVis = getUIAttribute("kts__dropdown_red_faction", "visibility")
    factVis1 = getUIAttribute("kts__dropdown_red_faction_1", "visibility")
    color = player.color
    if string.match(factVis, color.."|") then
      setUIAttribute("kts__dropdown_red_faction", "visibility", string.gsub(factVis, color.."|", ""))
    elseif string.match(factVis, color) then
      setUIAttribute("kts__dropdown_red_faction", "visibility", string.gsub(factVis, color, ""))
    end
    if string.match(factVis1, color.."|") then
      setUIAttribute("kts__dropdown_red_faction_1", "visibility", string.gsub(factVis1, color.."|", ""))
    elseif string.match(factVis1, color) then
      setUIAttribute("kts__dropdown_red_faction_1", "visibility", string.gsub(factVis1, color, ""))
    end
  end
end
function onRedFactionPanelMouseExit(player)
  factVis = getUIAttribute("kts__dropdown_red_faction", "visibility")
  factVis1 = getUIAttribute("kts__dropdown_red_faction_1", "visibility")
  color = player.color
  if not string.match(factVis, color) then
    setUIAttribute("kts__dropdown_red_faction", "visibility", color.."|"..factVis)
  end
  if not string.match(factVis1, color) then
    setUIAttribute("kts__dropdown_red_faction_1", "visibility", color.."|"..factVis1)
  end
end
function onBlueSuperFactionSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if string.match(getUIAttribute("kts__dropdown_blue_faction_text", "text"), player.steam_name) then
      setUIAttribute("kts__dropdown_blue_faction_imperium", "active", false)
      setUIAttribute("kts__dropdown_blue_faction_chaos", "active", false)
      setUIAttribute("kts__dropdown_blue_faction_aeldari", "active", false)
      setUIAttribute("kts__dropdown_blue_faction_xenos", "active", false)
      if checkListStatus[player.steam_name].superFaction ~= "Select One" then
        changeMultiDropdown({
          "kts__dropdown_blue_faction_imperium",
          "kts__dropdown_blue_faction_chaos",
          "kts__dropdown_blue_faction_aeldari",
          "kts__dropdown_blue_faction_xenos"
        },
        {
          "Select One",
          "Select One",
          "Select One",
          "Select One"
        })
        setFaction(player, "Select One")
      end
      setUIAttribute("kts__dropdown_blue_faction_"..string.lower(value), "active", true)
      checkListStatus[player.steam_name].superFaction = value
      setUIAttribute("kts__dropdown_blue_super_faction", "textColor", value == "Select One" and "#e74f0aff" or player.color)
    else
      broadcastToAll("Only "..split(getUIAttribute("kts__dropdown_blue_faction_text", "text"), " ").." can select this")
    end
  end
  changeMultiDropdown({
    "kts__dropdown_blue_super_faction",
    "kts__dropdown_blue_faction_imperium",
    "kts__dropdown_blue_faction_chaos",
    "kts__dropdown_blue_faction_aeldari",
    "kts__dropdown_blue_faction_xenos"
  },
  {
    checkListStatus[split(getUIAttribute("kts__dropdown_blue_faction_text", "text"), " ")].superFaction,
    "Select One",
    "Select One",
    "Select One",
    "Select One"
  })
end
function onBlueFactionSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if string.match(getUIAttribute("kts__dropdown_blue_faction_text", "text"), player.steam_name) then
      setFaction(player, value)
      checkListStatus[player.steam_name].faction = value
        setUIAttribute("kts__dropdown_blue_faction_imperium", "textColor", value == "Select One" and "#e74f0aff" or player.color)
        setUIAttribute("kts__dropdown_blue_faction_chaos", "textColor", value == "Select One" and "#e74f0aff" or player.color)
        setUIAttribute("kts__dropdown_blue_faction_aeldari", "textColor", value == "Select One" and "#e74f0aff" or player.color)
        setUIAttribute("kts__dropdown_blue_faction_xenos", "textColor", value == "Select One" and "#e74f0aff" or player.color)
    else
      broadcastToAll("Only "..split(getUIAttribute("kts__dropdown_blue_faction_text", "text"), " ").." can select this")
    end
  end
  changeDropdown("kts__dropdown_blue_faction_"..string.lower(checkListStatus[split(getUIAttribute("kts__dropdown_blue_faction_text", "text"), " ")].superFaction), checkListStatus[split(getUIAttribute("kts__dropdown_blue_faction_text", "text"), " ")].faction)
end
function onBlueFactionMouseEnter(player)
  if not string.match(getUIAttribute("kts__dropdown_blue_faction_text", "text"), player.steam_name) then
    factVis = getUIAttribute("kts__dropdown_blue_faction", "visibility")
    factVis1 = getUIAttribute("kts__dropdown_blue_faction_1", "visibility")
    color = player.color
    if string.match(factVis, color.."|") then
      setUIAttribute("kts__dropdown_blue_faction", "visibility", string.gsub(factVis, color.."|", ""))
    elseif string.match(factVis, color) then
      setUIAttribute("kts__dropdown_blue_faction", "visibility", string.gsub(factVis, color, ""))
    end
    if string.match(factVis1, color.."|") then
      setUIAttribute("kts__dropdown_blue_faction_1", "visibility", string.gsub(factVis1, color.."|", ""))
    elseif string.match(factVis1, color) then
      setUIAttribute("kts__dropdown_blue_faction_1", "visibility", string.gsub(factVis1, color, ""))
    end
  end
end
function onBlueFactionPanelMouseExit(player)
  factVis = getUIAttribute("kts__dropdown_blue_faction", "visibility")
  factVis1 = getUIAttribute("kts__dropdown_blue_faction_1", "visibility")
  color = player.color
  if not string.match(factVis, color) then
    setUIAttribute("kts__dropdown_blue_faction", "visibility", color.."|"..factVis)
  end
  if not string.match(factVis1, color) then
    setUIAttribute("kts__dropdown_blue_faction_1", "visibility", color.."|"..factVis1)
  end
end
function onRedTacOpsSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if player.steam_name == getUIAttribute("kts__toggle_red_tacops_text", "text") then
      printToAll(player.steam_name.." selected TacOps")
      checkListStatus[player.steam_name].tacOps = value
      setUIAttribute("kts__toggle_red_tacops", "isOn", value == "True" and true or false)
      setUIAttribute("kts__toggle_red_tacops", "backgroundColor", value == "True" and player.color or "White")
    else
      player.broadcast("Only "..getUIAttribute("kts__toggle_red_tacops_text", "text").." can check this")
    end
  end
  setUIAttribute("kts__toggle_red_tacops", "isOn", checkListStatus[getUIAttribute("kts__toggle_red_tacops_text", "text")] ~= nil and checkListStatus[getUIAttribute("kts__toggle_red_tacops_text", "text")].tacOps or checkListPlayer.tacOps)
end
function onBlueTacOpsSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if player.steam_name == getUIAttribute("kts__toggle_blue_tacops_text", "text") then
      printToAll(player.steam_name.." selected TacOps")
      checkListStatus[player.steam_name].tacOps = value
      setUIAttribute("kts__toggle_blue_tacops", "isOn", value == "True" and true or false)
      setUIAttribute("kts__toggle_blue_tacops", "backgroundColor", value == "True" and player.color or "White")
    else
      player.broadcast("Only "..getUIAttribute("kts__toggle_blue_tacops_text", "text").." can check this")
    end
  end
  setUIAttribute("kts__toggle_blue_tacops", "isOn", checkListStatus[getUIAttribute("kts__toggle_blue_tacops_text", "text")] ~= nil and checkListStatus[getUIAttribute("kts__toggle_blue_tacops_text", "text")].tacOps or checkListPlayer.tacOps)
end
function onRedEquipmentSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if player.steam_name == getUIAttribute("kts__toggle_red_equipment_text", "text") then
      printToAll(player.steam_name.." selected equipment")
      checkListStatus[player.steam_name].equipment = value
      setUIAttribute("kts__toggle_red_equipment", "isOn", value == "True" and true or false)
      setUIAttribute("kts__toggle_red_equipment", "backgroundColor", value == "True" and player.color or "White")
    else
      player.broadcast("Only "..getUIAttribute("kts__toggle_red_equipment_text", "text").." can check this")
    end
  end
  setUIAttribute("kts__toggle_red_equipment", "isOn", checkListStatus[getUIAttribute("kts__toggle_red_equipment_text", "text")] ~= nil and checkListStatus[getUIAttribute("kts__toggle_red_equipment_text", "text")].equipment or checkListPlayer.equipment)
end
function onBlueEquipmentSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if player.steam_name == getUIAttribute("kts__toggle_blue_equipment_text", "text") then
      printToAll(player.steam_name.." selected equipment")
      checkListStatus[player.steam_name].equipment = value
      setUIAttribute("kts__toggle_blue_equipment", "isOn", value == "True" and true or false)
      setUIAttribute("kts__toggle_blue_equipment", "backgroundColor", value == "True" and player.color or "White")
    else
      player.broadcast("Only "..getUIAttribute("kts__toggle_blue_equipment_text", "text").." can check this")
    end
  end
  setUIAttribute("kts__toggle_blue_equipment", "isOn", checkListStatus[getUIAttribute("kts__toggle_blue_equipment_text", "text")] ~= nil and checkListStatus[getUIAttribute("kts__toggle_blue_equipment_text", "text")].equipment or checkListPlayer.equipment)
end
function onRedBarricadesPlaced(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if player.steam_name == getUIAttribute("kts__toggle_red_barricades_text", "text") then
      printToAll(player.steam_name.." placed barricades")
      checkListStatus[player.steam_name].barricades = value
      setUIAttribute("kts__toggle_red_barricades", "isOn", value == "True" and true or false)
      setUIAttribute("kts__toggle_red_barricades", "backgroundColor", value == "True" and player.color or "White")
    else
      player.broadcast("Only "..getUIAttribute("kts__toggle_red_barricades_text", "text").." can check this")
    end
  end
  setUIAttribute("kts__toggle_red_barricades", "isOn", checkListStatus[getUIAttribute("kts__toggle_red_barricades_text", "text")] ~= nil and checkListStatus[getUIAttribute("kts__toggle_red_barricades_text", "text")].barricades or checkListPlayer.barricades)
end
function onBlueBarricadesPlaced(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if player.steam_name == getUIAttribute("kts__toggle_blue_barricades_text", "text") then
      printToAll(player.steam_name.." placed barricades")
      checkListStatus[player.steam_name].barricades = value
      setUIAttribute("kts__toggle_blue_barricades", "isOn", value == "True" and true or false)
      setUIAttribute("kts__toggle_blue_barricades", "backgroundColor", value == "True" and player.color or "White")
    else
      player.broadcast("Only "..getUIAttribute("kts__toggle_blue_barricades_text", "text").." can check this")
    end
  end
  setUIAttribute("kts__toggle_blue_barricades", "isOn", checkListStatus[getUIAttribute("kts__toggle_blue_barricades_text", "text")] ~= nil and checkListStatus[getUIAttribute("kts__toggle_blue_barricades_text", "text")].barricades or checkListPlayer.barricades)
end
function onRedDeployed(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if player.steam_name == getUIAttribute("kts__toggle_red_deployed_text", "text") then
      printToAll(player.steam_name.." has deployed")
      checkListStatus[player.steam_name].deployed = value
      setUIAttribute("kts__toggle_red_deployed", "isOn", value == "True" and true or false)
      setUIAttribute("kts__toggle_red_deployed", "backgroundColor", value == "True" and player.color or "White")
      Wait.frames(function()
        if value == "True" then
          showOperativeSelection(player)
        else
          deselectOperatives(player)
        end
      end, 1)
    else
      player.broadcast("Only "..getUIAttribute("kts__toggle_red_deployed_text", "text").." can check this")
    end
  end
  setUIAttribute("kts__toggle_red_deployed", "isOn", checkListStatus[getUIAttribute("kts__toggle_red_deployed_text", "text")] ~= nil and checkListStatus[getUIAttribute("kts__toggle_red_deployed_text", "text")].deployed or checkListPlayer.deployed)
end
function onBlueDeployed(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if player.steam_name == getUIAttribute("kts__toggle_blue_deployed_text", "text") then
      printToAll(player.steam_name.." has deployed")
      checkListStatus[player.steam_name].deployed = value
      setUIAttribute("kts__toggle_blue_deployed", "isOn", value == "True" and true or false)
      setUIAttribute("kts__toggle_blue_deployed", "backgroundColor", value == "True" and player.color or "White")
      Wait.frames(function()
        if value == "True" then
          showOperativeSelection(player)
        else
          deselectOperatives(player)
        end
      end, 1)
    else
      player.broadcast("Only "..getUIAttribute("kts__toggle_blue_deployed_text", "text").." can check this")
    end
  end
  setUIAttribute("kts__toggle_blue_deployed", "isOn", checkListStatus[getUIAttribute("kts__toggle_blue_deployed_text", "text")] ~= nil and checkListStatus[getUIAttribute("kts__toggle_blue_deployed_text", "text")].deployed or checkListPlayer.deployed)
end
function onAllowOverwatchSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    result.allowOW = value
    checkListStatus.allowOW = value
    setUIAttribute("kts__toggle_overwatch", "backgroundColor", value == "True" and player.color or "White")
  end
  setUIAttribute("kts__toggle_overwatch", "isOn", checkListStatus.allowOW == "True" and true or false)
end
function onRedScoutingSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    setScouting(player, value)
    checkListStatus[player.steam_name].scouting = value
  end
  changeDropdown("kts__dropdown_red_scouting", checkListStatus[Player['Red'].steam_name].scouting)
end
function onBlueScoutingSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    setScouting(player, value)
    checkListStatus[player.steam_name].scouting = value
  end
  changeDropdown("kts__dropdown_blue_scouting", checkListStatus[Player['Blue'].steam_name].scouting)
end
function onRevealScouting(player, value)
  if player.color == "Red" or player.color == "Blue" then
    checkListStatus.revealed = false
    if Player["Blue"].steam_name ~= nil then
      blueName = Player["Blue"].steam_name
    else
      blueName = "no_player"
    end
    if Player["Red"].steam_name ~= nil then
      redName = Player["Red"].steam_name
    else
      redName = "no_player"
    end
    if result[blueName] ~= nil and result[redName] ~= nil then
      if result[blueName].scouting ~= nil and result[redName].scouting ~= nil and
      result[blueName].scouting ~= "Select One" and result[redName].scouting ~= "Select One" and
      checkListStatus.rollOffWinner ~= "Select One" and
      (checkListStatus.rollOffAttacker or checkListStatus.rollOffDefender) then
        checkListStatus.revealed = true
        if result[blueName].scouting == "Fortify" and result[redName].scouting == "Infiltrate" or
        result[blueName].scouting == "Infiltrate" and result[redName].scouting == "Recon" or
        result[blueName].scouting == "Recon" and result[redName].scouting == "Fortify" then
          result.scoutingWinner = blueName
          checkListStatus.winner = blueName
        elseif result[blueName].scouting == result[redName].scouting then
          if result.rollOffWinnerSelection == "Attacker" then
            result.scoutingWinner = result.rollOffWinner
            checkListStatus.winner = result.rollOffWinner
          else
            result.scoutingWinner = result.rollOffLoser
            checkListStatus.winner = result.rollOffLoser
          end
        else
          result.scoutingWinner = redName
          checkListStatus.winner = redName
        end
        setUIAttribute("kts__toggle_reveal_scouting", "backgroundColor", value == "True" and player.color or "White")
        gameStateMachine.whoToPress = checkListStatus.winner
        setUIValue("kts__scouting_resolution", checkListStatus.winner)
        printToAll("-----------")
        printToAll("Scouting...")
        printToAll(redName.." selected "..result[redName].scouting)
        printToAll(blueName.." selected "..result[blueName].scouting)
        printToAll("And the winner is "..result.scoutingWinner)
        printToAll("-----------")
        broadcastToAll("The scouting winner is "..result.scoutingWinner)
      else
        broadcastToAll("Both players must select a value for scouting and select roll off winner")
      end
    else
      broadcastToAll("Both players must be seated")
    end
  end
  setUIAttribute("kts__toggle_reveal_scouting", "isOn", checkListStatus.revealed)
end
function onHideChecklistBtn(player)
  if player.color == "Red" or player.color == "Blue" then
    setUIAttribute("kts__checklist_panel", "visibility", string.gsub(getUIAttribute("kts__checklist_panel", "visibility"), player.color.."|", ""))
  end
end
function buildControlButtons(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight*2,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Button",
        attributes={
          id="kts__start_over_button",
          onClick=self.getGUID().."/onStartOverBtn",
          width=uiMiddleZone/3,
          rectAlignment="MiddleLeft",
        },
        value="Start Over"
      },
      {
        tag="Button",
        attributes={
          id="kts__hide_checklist_button",
          onClick=self.getGUID().."/onHideChecklistBtn",
          width=uiMiddleZone/3,
          rectAlignment="MiddleCenter",
        },
        value="Hide Checklist"
      },
      {
        tag="Button",
        attributes={
          id="kts__start_game_button",
          onClick=self.getGUID().."/onStartGameBtn",
          width=uiMiddleZone/3,
          rectAlignment="MiddleRight",
        },
        value="Let's WAAAAAAGH!!"
      },
    }
  }
end

function buildAllowDataCollection1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone,
          rectAlignment="UpperCenter",
          padding="10 0 0 0",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
            },
            value="Allow data collection?"
          },
        }
      }
    }
  }
end
function buildVideoTutorial1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone,
          rectAlignment="UpperCenter",
          padding="10 0 0 0",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
            },
            value="For a video tutorial, follow this link:"
          },
        }
      }
    }
  }
end
function buildVideoTutorial2(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      onClick=self.getGUID().."/onTutorialClick",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone,
          rectAlignment="UpperCenter",
          padding="10 0 0 0",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
              color="White",
            },
            value="https://youtu.be/GV7AnrjQr9A"
          },
        }
      }
    }
  }
end
function buildAllowDataCollection2(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
      tag="Panel",
      attributes={
        class="bkgPanel",
        height=panelHeight,
        rectAlignment="UpperCenter",
        offsetXY="0 "..yPos,
      },
      children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperLeft",
        },
        children={
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_red_accept",
              rectAlignment="MiddleRight",
              offsetXY="10 0",
              tooltip="We will use your Steam name to help us getting the game data but only in game. Your name will not be sent to the database, and the data stored will be anonymous.",
              tooltipPosition="Above",
              onValueChanged=self.getGUID().."/onRedAcceptedDataCollection",
              isOn=Player['Red'].steam_name ~= nil and checkListStatus[Player['Red'].steam_name].allow == "True" and true or false or false,
            },
          },
          {
            tag="Text",
            attributes={
              id="kts__toggle_red_accept_text",
              offsetXY="-"..(uiMiddleZone/16).." 0",
              text=Player['Red'].steam_name ~= nil and Player['Red'].steam_name or "no_player",
              fontSize=12,
            },
          },
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperRight",
        },
        children={
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_blue_accept",
              rectAlignment="MiddleRight",
              offsetXY="10 0",
              tooltip="We will use your Steam name to help us getting the game data but only in game. Your name will not be sent to the database, and the data stored will be anonymous.",
              tooltipPosition="Above",
              onValueChanged=self.getGUID().."/onBlueAcceptedDataCollection",
              isOn=Player['Blue'].steam_name ~= nil and checkListStatus[Player['Blue'].steam_name].allow == "True" and true or false or false,
            },
          },
          {
            tag="Text",
            attributes={
              id="kts__toggle_blue_accept_text",
              text=Player['Blue'].steam_name ~= nil and Player['Blue'].steam_name or "no_player",
              fontSize=12,
              offsetXY="-"..(uiMiddleZone/16).." 0",
            },
          },
        }
      }
    }
  }
end
function buildSecondaryTitle(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=30,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Text",
        attributes={
          class="title2",
          fontSize=15,
        },
        value="Game setup checklist - Complete all in order"
      },
    }
  }
end
function buildGameType1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone,
          rectAlignment="UpperCenter",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
              alignment="MiddleCenter"
            },
            value="Select Edition and Game type"
          },
        }
      },
    }
  }
end
function buildGameType2(yPos, uiWidth, uiMiddleZone, panelHeight)
  local optionsEd = buildEditionDropdownUI()
  local optionsGt = buildGameTypeDropdownUI()
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=35,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperLeft",
          padding="10 10 3 3",
        },
        children={
          {
            tag="Dropdown",
            attributes={
              id="kts__dropdown_edition",
              width=uiMiddleZone,
              fontSize=12,
              onValueChanged=self.getGUID().."/onEditionSelected",
            },
            children=optionsEd,
          },
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperRight",
          padding="10 10 3 3",
        },
        children={
          {
            tag="Dropdown",
            attributes={
              id="kts__dropdown_game_type",
              width=uiMiddleZone,
              fontSize=12,
              onValueChanged=self.getGUID().."/onGameTypeSelected",
            },
            children=optionsGt,
          },
        }
      },
    }
  }
end
function buildTournament1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone,
          rectAlignment="UpperCenter",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
              alignment="MiddleCenter"
            },
            value="Select Tournament"
          },
        }
      },
    }
  }
end
function buildTournament2(yPos, uiWidth, uiMiddleZone, panelHeight)
  local options = buildTournamentDropdownUI()
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=35,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone,
          rectAlignment="UpperRight",
          padding="10 10 3 3",
        },
        children={
          tag="Dropdown",
          attributes={
            id="kts__dropdown_tournament",
            width=uiMiddleZone,
            fontSize=12,
            onValueChanged=self.getGUID().."/onTournamentSelected",
          },
          children=options,
        },
      },
    }
  }
end
function buildKillZoneLoaded1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Text",
        attributes={
          fontSize=12,
          alignment="MiddleCenter",
        },
        value="Kill Zone additively loaded?"
      },
    }
  }
end
function buildKillZoneLoaded2(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Toggle",
        attributes={
          id="kts__toggle_kz_loaded",
          tooltip="Did you load the Kill Zone?",
          tooltipPosition="Above",
          onValueChanged=self.getGUID().."/onKillZoneLoaded",
          isOn=checkListStatus.killZoneLoaded == "True" and true or false,
        },
      },
    }
  }
end
function buildSelectMission1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone,
          rectAlignment="UpperCenter",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
              alignment="MiddleCenter"
            },
            value="Select Mission"
          },
        }
      },
    }
  }
end
function buildSelectMission2(yPos, uiWidth, uiMiddleZone, panelHeight)
  local optionsOpen = buildMissionDropdownUI(missionIndexOpen)
  local optionsItd = buildMissionDropdownUI(missionIndexItd)
  local optionsCritOps = buildMissionDropdownUI(missionIndexCritOps)
  local optionsCritOpsItd = buildMissionDropdownUI(missionIndexCritOpsItd)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=35,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone,
          rectAlignment="UpperRight",
          padding="10 10 3 3",
        },
        children={
          {
            tag="Dropdown",
            attributes={
              id="kts__dropdown_mission_open",
              active=checkListStatus.edition == "KT 2021 - Open" and true or false,
              width=uiMiddleZone,
              fontSize=12,
              onValueChanged=self.getGUID().."/onOpenMissionSelected",
            },
            children=optionsOpen,
          },
          {
            tag="Dropdown",
            attributes={
              id="kts__dropdown_mission_itd",
              active=checkListStatus.edition == "KT 2022 - Into The Dark" and true or false,
              width=uiMiddleZone,
              fontSize=12,
              onValueChanged=self.getGUID().."/onItdMissionSelected",
            },
            children=optionsItd,
          },
          {
            tag="Dropdown",
            attributes={
              id="kts__dropdown_mission_critops",
              active=checkListStatus.edition == "KT 2022 - Crit Ops" and true or false,
              width=uiMiddleZone,
              fontSize=12,
              onValueChanged=self.getGUID().."/onCritOpsMissionSelected",
            },
            children=optionsCritOps,
          },
          {
            tag="Dropdown",
            attributes={
              id="kts__dropdown_mission_critopsitd",
              active=checkListStatus.edition == "KT 2022 - Crit Ops - ITD" and true or false,
              width=uiMiddleZone,
              fontSize=12,
              onValueChanged=self.getGUID().."/onCritOpsItdMissionSelected",
            },
            children=optionsCritOpsItd,
          },
        },
      },
    }
  }
end
--ADDED by ZAKA
function buildDropdownUI(group, playerName)
  optionTable = {}
  for _,name in ipairs(group) do
    newFaction = {
      tag="Option",
      attributes={
        selected=playerName ~= nil and checkListStatus[playerName].faction == name and true or false or true,
      },
      value=name,
    }
    table.insert(optionTable, newFaction)
  end
  table.insert(optionTable, {
    tag="Option",
    attributes={
      selected=playerName ~= nil and checkListStatus[playerName].faction == "Select One" and true or false or true,
    },
    value="Select One",
  })
  return optionTable
end
function buildMissionDropdownUI(missionIndex)
  optionTable = {}
  for k,v in pairs(missionIndex) do
    newFaction = {
      tag="Option",
      attributes={
        selected=checkListStatus.mission == v.code.." "..v.name and true or false,
      },
      value=v.code.." "..v.name,
    }
    table.insert(optionTable, newFaction)
  end
  table.insert(optionTable, {
    tag="Option",
    attributes={
      selected=checkListStatus.mission == "Select One" and true or false,
    },
    value="Select One",
  })
  return optionTable
end

function buildTournamentDropdownUI()
  optionTable = {}
  for _,name in ipairs(tournamentIndex) do
    table.insert(optionTable, {
      tag="Option",
      attributes={
        selected=checkListStatus.tournament == name and true or false,
      },
      value=name,
    })
  end
  table.insert(optionTable, {
    tag="Option",
    attributes={
      selected=true,
    },
    value="Select One",
  })
  return optionTable
end
function buildEditionDropdownUI()
  optionTable = {}
  for _,name in ipairs(editionIndex) do
    table.insert(optionTable, {
      tag="Option",
      attributes={
        selected=checkListStatus.edition == name and true or false,
      },
      value=name,
    })
  end
  table.insert(optionTable, {
    tag="Option",
    attributes={
      selected=true,
    },
    value="Select One",
  })
  return optionTable
end
function buildGameTypeDropdownUI()
  optionTable = {}
  for _,name in ipairs(gameTypeIndex) do
    table.insert(optionTable, {
      tag="Option",
      attributes={
        selected=checkListStatus.gameType == name and true or false,
      },
      value=name,
    })
  end
  table.insert(optionTable, {
    tag="Option",
    attributes={
      selected=true,
    },
    value="Select One",
  })
  return optionTable
end
function buildRollOffWinner1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiWidth/4,
          rectAlignment="UpperCenter",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
              alignment="MiddleCenter"
            },
            value="Dropzone Rolloff winner"
          },
        }
      },
    },
  }
end
function buildRollOffWinner2(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperLeft",
        },
        children={
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_red_rolloff_winner",
              onValueChanged=self.getGUID().."/onRedWonRollOff",
              rectAlignment="MiddleRight",
              offsetXY="10 0",
              isOn=Player['Red'].steam_name ~= nil and Player['Red'].steam_name == checkListStatus.rollOffWinner and true or false or false,
            },
          },
          {
            tag="Text",
            attributes={
              id="kts__red_roloff_winner_text",
              text=Player['Red'].steam_name ~= nil and Player['Red'].steam_name or "no_player",
              fontSize=12,
              offsetXY="-"..(uiMiddleZone/16).." 0",
            },
          },
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperRight",
        },
        children={
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_blue_rolloff_winner",
              rectAlignment="MiddleRight",
              offsetXY="10 0",
              onValueChanged=self.getGUID().."/onBlueWonRollOff",
              isOn=Player['Blue'].steam_name ~= nil and Player['Blue'].steam_name == checkListStatus.rollOffWinner and true or false or false,
            },
          },
          {
            tag="Text",
            attributes={
              id="kts__blue_roloff_winner_text",
              text=Player['Blue'].steam_name ~= nil and Player['Blue'].steam_name or "no_player",
              fontSize=12,
              offsetXY="-"..(uiMiddleZone/16).." 0",
            },
          },
        }
      },
    },
  }
end
function buildRollOffSelection1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone,
          rectAlignment="UpperCenter",
          padding="10 0 0 0",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
            },
            value="Rolloff winner selection"
          },
        }
      },
    }
  }
end
function buildRollOffSelection2(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperLeft",
        },
        children={
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_attacker_selected",
              onValueChanged=self.getGUID().."/onAttackerSelected",
              rectAlignment="MiddleRight",
              offsetXY="10 0",
              isOn=checkListStatus.rollOffAttacker,
            },
          },
          {
            tag="Text",
            attributes={
              fontSize=12,
              offsetXY="-"..(uiMiddleZone/16).." 0",
            },
            value="Attacker"
          },
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperRight",
        },
        children={
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_defender_selected",
              rectAlignment="MiddleRight",
              offsetXY="10 0",
              onValueChanged=self.getGUID().."/onDefenderSelected",
              isOn=checkListStatus.rollOffDefender,
            },
          },
          {
            tag="Text",
            attributes={
            fontSize=12,
            offsetXY="-"..(uiMiddleZone/16).." 0",
            },
            value="Defender"
          },
        }
      },
    }
  }
end
function buildFaction1(yPos, uiWidth, uiMiddleZone, panelHeight, player)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone,
          rectAlignment="UpperCenter",
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__dropdown_"..string.lower(player.color).."_faction_text",
              fontSize=12,
              text="Faction "..(player.steam_name ~= nil and player.steam_name or "no_player"),
            },
          },
        }
      },
    }
  }
end
function buildFaction2(yPos, uiWidth, uiMiddleZone, panelHeight, player)
  local imperiumFactionsOpts = buildDropdownUI(imperiumFactions, player.steam_name)
  local chaosFactionsOpts = buildDropdownUI(chaosFactions, player.steam_name)
  local xenosFactionsOpts = buildDropdownUI(xenosFactions, player.steam_name)
  local aeldariFactionsOpts = buildDropdownUI(aeldariFactions, player.steam_name)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=35,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
      onMouseExit=self.getGUID().."/on"..player.color.."FactionPanelMouseExit",
      onMouseEnter=self.getGUID().."/on"..player.color.."FactionMouseEnter",
    },
    children={
      {
        tag="Panel",
        attributes={
          id="kts__dropdown_"..string.lower(player.color).."_faction",
          visibility="Blue|"..player.color.."|Black|Grey",
          onMouseExit=self.getGUID().."/on"..player.color.."FactionPanelMouseExit",
          onMouseEnter=self.getGUID().."/on"..player.color.."FactionMouseEnter",
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperLeft",
          padding="10 10 3 3",
        },
        children={
          {
            tag="Dropdown",
            attributes={
              id="kts__dropdown_"..string.lower(player.color).."_super_faction",
              fontSize=12,
              onValueChanged=self.getGUID().."/on"..player.color.."SuperFactionSelected",
              onMouseEnter=self.getGUID().."/on"..player.color.."FactionMouseEnter",
            },
            children={
              {
                tag="Option",
                attributes={
                  selected=player.steam_name ~= nil and checkListStatus[player.steam_name].superFaction == "Select One" and true or false or true,
                },
                value="Select One",
              },
              {
                tag="Option",
                attributes={
                  selected=player.steam_name ~= nil and checkListStatus[player.steam_name].superFaction == "Imperium" and true or false or false,
                },
                value="Imperium",
              },
              {
                tag="Option",
                attributes={
                  selected=player.steam_name ~= nil and checkListStatus[player.steam_name].superFaction == "Chaos" and true or false or false,
                },
                value="Chaos",
              },
              {
                tag="Option",
                attributes={
                  selected=player.steam_name ~= nil and checkListStatus[player.steam_name].superFaction == "Xenos" and true or false or false,
                },
                value="Xenos",
              },
              {
                tag="Option",
                attributes={
                  selected=player.steam_name ~= nil and checkListStatus[player.steam_name].superFaction == "Aeldari" and true or false or false,
                },
                value="Aeldari",
              },
            }
          }
        }
      },
      {
        tag="Panel",
        attributes={
          id="kts__dropdown_"..string.lower(player.color).."_faction_1",
          visibility="Blue|"..player.color.."|Black|Grey",
          onMouseExit=self.getGUID().."/on"..player.color.."FactionPanelMouseExit",
          onMouseEnter=self.getGUID().."/on"..player.color.."FactionMouseEnter",
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperRight",
          padding="10 10 3 3",
        },
        children={
          {
            tag="Dropdown",
            attributes={
              id="kts__dropdown_"..string.lower(player.color).."_faction_imperium",
              active=player.steam_name ~= nil and checkListStatus[player.steam_name].superFaction == "Imperium" and true or false or false,
              fontSize=12,
              onValueChanged=self.getGUID().."/on"..player.color.."FactionSelected",
              onMouseEnter=self.getGUID().."/on"..player.color.."FactionMouseEnter",
            },
            children=imperiumFactionsOpts,
          },
          {
            tag="Dropdown",
            attributes={
              id="kts__dropdown_"..string.lower(player.color).."_faction_chaos",
              active=player.steam_name ~= nil and checkListStatus[player.steam_name].superFaction == "Chaos" and true or false or false,
              fontSize=12,
              onValueChanged=self.getGUID().."/on"..player.color.."FactionSelected",
              onMouseEnter=self.getGUID().."/on"..player.color.."FactionMouseEnter",
            },
            children=chaosFactionsOpts,
          },
          {
            tag="Dropdown",
            attributes={
              id="kts__dropdown_"..string.lower(player.color).."_faction_aeldari",
              active=player.steam_name ~= nil and checkListStatus[player.steam_name].superFaction == "Aeldari" and true or false or false,
              fontSize=12,
              onValueChanged=self.getGUID().."/on"..player.color.."FactionSelected",
              onMouseEnter=self.getGUID().."/on"..player.color.."FactionMouseEnter",
            },
            children=aeldariFactionsOpts,
          },
          {
            tag="Dropdown",
            attributes={
              id="kts__dropdown_"..string.lower(player.color).."_faction_xenos",
              active=player.steam_name ~= nil and checkListStatus[player.steam_name].superFaction == "Xenos" and true or false or false,
              fontSize=12,
              onValueChanged=self.getGUID().."/on"..player.color.."FactionSelected",
              onMouseEnter=self.getGUID().."/on"..player.color.."FactionMouseEnter",
            },
            children=xenosFactionsOpts,
          },
        }
      },
    }
  }
end
function buildTacOpsSelected1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          rectAlignment="UpperCenter",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
            },
            value="Tac Ops Selected?"
          },
        }
      },
    }
  }
end
function buildTacOpsSelected2(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperLeft",
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__toggle_red_tacops_text",
              text=Player['Red'].steam_name ~= nil and Player['Red'].steam_name or "no_player",
              fontSize=12,
              offsetXY="-"..(uiMiddleZone/16).." 0",
            },
          },
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_red_tacops",
              rectAlignment="MiddleRight",
              offsetXY="10 0",
              onValueChanged=self.getGUID().."/onRedTacOpsSelected",
              isOn=Player['Red'].steam_name ~= nil and checkListStatus[Player['Red'].steam_name].tacOps == "True" and true or false or false,
            },
          },
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperRight",
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__toggle_blue_tacops_text",
              fontSize=12,
              offsetXY="-"..(uiMiddleZone/16).." 0",
              text=Player['Blue'].steam_name ~= nil and Player['Blue'].steam_name or "no_player",
            },
          },
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_blue_tacops",
              rectAlignment="MiddleRight",
              offsetXY="10 0",
              onValueChanged=self.getGUID().."/onBlueTacOpsSelected",
              isOn=Player['Blue'].steam_name ~= nil and checkListStatus[Player['Blue'].steam_name].tacOps == "True" and true or false or false,
            },
          },
        }
      }
    }
  }
end
function buildEquipmentSelected1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone,
          rectAlignment="UpperCenter",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
            },
            value="Equipment selected?"
          },
        }
      },
    }
  }
end
function buildEquipmentSelected2(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperLeft",
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__toggle_red_equipment_text",
              text=Player['Red'].steam_name ~= nil and Player['Red'].steam_name or "no_player",
              fontSize=12,
              offsetXY="-"..(uiMiddleZone/16).." 0"
            },
          },
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_red_equipment",
              rectAlignment="MiddleRight",
              offsetXY="10 0",
              onValueChanged=self.getGUID().."/onRedEquipmentSelected",
              isOn=Player['Red'].steam_name ~= nil and checkListStatus[Player['Red'].steam_name].equipment == "True" and true or false or false,
            },
          },
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperRight",
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__toggle_blue_equipment_text",
              text=Player['Blue'].steam_name ~= nil and Player['Blue'].steam_name or "no_player",
              fontSize=12,
              offsetXY="-"..(uiMiddleZone/16).." 0"
            },
          },
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_blue_equipment",
              offsetXY="10 0",
              rectAlignment="MiddleRight",
              onValueChanged=self.getGUID().."/onBlueEquipmentSelected",
              isOn=Player['Blue'].steam_name ~= nil and checkListStatus[Player['Blue'].steam_name].equipment == "True" and true or false or false,
            },
          },
        }
      }
    }
  }
end
function buildBarricadePlacing1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone,
          rectAlignment="UpperCenter",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
            },
            value="Barricades placed?"
          },
        }
      },
    }
  }
end
function buildBarricadePlacing2(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperLeft",
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__toggle_red_barricades_text",
              text=Player['Red'].steam_name ~= nil and Player['Red'].steam_name or "no_player",
              fontSize=12,
              offsetXY="-"..(uiMiddleZone/16).." 0"
            },
          },
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_red_barricades",
              rectAlignment="MiddleRight",
              offsetXY="10 0",
              onValueChanged=self.getGUID().."/onRedBarricadesPlaced",
              isOn=Player['Red'].steam_name ~= nil and checkListStatus[Player['Red'].steam_name].barricades == "True" and true or false or false,
            },
          },
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperRight",
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__toggle_blue_barricades_text",
              text=Player['Blue'].steam_name ~= nil and Player['Blue'].steam_name or "no_player",
              fontSize=12,
              offsetXY="-"..(uiMiddleZone/16).." 0"
            },
          },
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_blue_barricades",
              offsetXY="10 0",
              rectAlignment="MiddleRight",
              onValueChanged=self.getGUID().."/onBlueBarricadesPlaced",
              isOn=Player['Blue'].steam_name ~= nil and checkListStatus[Player['Blue'].steam_name].barricades == "True" and true or false or false,
            },
          },
        }
      }
    }
  }
end
function buildDeploymentDone1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          rectAlignment="UpperCenter",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
            },
            value="Operatives deployed/orders given?"
          },
        }
      },
    }
  }
end
function buildDeploymentDone2(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperLeft",
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__toggle_red_deployed_text",
              text=Player['Red'].steam_name ~= nil and Player['Red'].steam_name or "no_player",
              fontSize=12,
              offsetXY="-"..(uiMiddleZone/16).." 0"
            },
          },
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_red_deployed",
              offsetXY="10 0",
              rectAlignment="MiddleRight",
              onValueChanged=self.getGUID().."/onRedDeployed",
              isOn=Player['Red'].steam_name ~= nil and checkListStatus[Player['Red'].steam_name].deployed == "True" and true or false or false,
            },
          },
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/2,
          rectAlignment="UpperRight",
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__toggle_blue_deployed_text",
              text=Player['Blue'].steam_name ~= nil and Player['Blue'].steam_name or "no_player",
              fontSize=12,
              offsetXY="-"..(uiMiddleZone/16).." 0"
            },
          },
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_blue_deployed",
              rectAlignment="MiddleRight",
              offsetXY="10 0",
              onValueChanged=self.getGUID().."/onBlueDeployed",
              isOn=Player['Blue'].steam_name ~= nil and checkListStatus[Player['Blue'].steam_name].deployed == "True" and true or false or false,
            },
          },
        }
      }
    }
  }
end
function buildAllowOverwatch1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          rectAlignment="UpperCenter",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
            },
            value="Allow Overwatch functionallity"
          },
        }
      },
    }
  }
end
function buildAllowOverwatch2(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Toggle",
        attributes={
          id="kts__toggle_overwatch",
          tooltip="Do you allow the mod to help you with Overwatch?",
          tooltipPosition="Above",
          onValueChanged=self.getGUID().."/onAllowOverwatchSelected",
          isOn=checkListStatus.allowOW == "True" and true or false,
        },
      },
    }
  }
end
function buildScoutingPhase1(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=panelHeight,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          rectAlignment="UpperCenter",
        },
        children={
          {
            tag="Text",
            attributes={
              fontSize=12,
            },
            value="Scouting Phase"
          },
        }
      },
    }
  }
end
function buildScoutingPhase2(yPos, uiWidth, uiMiddleZone, panelHeight)
  return {
    tag="Panel",
    attributes={
      class="bkgPanel",
      height=35,
      rectAlignment="UpperCenter",
      offsetXY="0 "..yPos,
    },
    children={
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/3,
          rectAlignment="UpperLeft",
          padding="10 10 3 3",
          visibility="Red|Black"
        },
        children={
          {
            tag="Dropdown",
            attributes={
              id="kts__dropdown_red_scouting",
              fontSize=12,
              onValueChanged=self.getGUID().."/onRedScoutingSelected",
            },
            children={
              {
                tag="Option",
                attributes={
                  selected=Player['Red'].steam_name ~= nil and checkListStatus[Player['Red'].steam_name].scouting == "Select One" and true or false or true,
                },
                value="Select One",
              },
              {
                tag="Option",
                attributes={
                  selected=Player['Red'].steam_name ~= nil and checkListStatus[Player['Red'].steam_name].scouting == "Fortify" and true or false or false,
                },
                value="Fortify",
              },
              {
                tag="Option",
                attributes={
                  selected=Player['Red'].steam_name ~= nil and checkListStatus[Player['Red'].steam_name].scouting == "Infiltrate" and true or false or false,
                },
                value="Infiltrate",
              },
              {
                tag="Option",
                attributes={
                  selected=Player['Red'].steam_name ~= nil and checkListStatus[Player['Red'].steam_name].scouting == "Recon" and true or false or false,
                },
                value="Recon",
              },
            }
          },
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/3,
          rectAlignment="UpperLeft",
          padding="10 10 3 3",
          visibility="Blue|Black"
        },
        children={
          {
            tag="Dropdown",
            attributes={
              id="kts__dropdown_blue_scouting",
              fontSize=12,
              onValueChanged=self.getGUID().."/onBlueScoutingSelected",
            },
            children={
              {
                tag="Option",
                attributes={
                  selected=Player['Blue'].steam_name ~= nil and checkListStatus[Player['Blue'].steam_name].scouting == "Select One" and true or false or true,
                },
                value="Select One",
              },
              {
                tag="Option",
                attributes={
                  selected=Player['Blue'].steam_name ~= nil and checkListStatus[Player['Blue'].steam_name].scouting == "Fortify" and true or false or false,
                },
                value="Fortify",
              },
              {
                tag="Option",
                attributes={
                  selected=Player['Blue'].steam_name ~= nil and checkListStatus[Player['Blue'].steam_name].scouting == "Infiltrate" and true or false or false,
                },
                value="Infiltrate",
              },
              {
                tag="Option",
                attributes={
                  selected=Player['Blue'].steam_name ~= nil and checkListStatus[Player['Blue'].steam_name].scouting == "Recon" and true or false or false,
                },
                value="Recon",
              },
            }
          },
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/3,
          rectAlignment="UpperCenter",
        },
        children={
          {
            tag="Toggle",
            attributes={
              id="kts__toggle_reveal_scouting",
              onValueChanged=self.getGUID().."/onRevealScouting",
              rectAlignment="MiddleRight",
              offsetXY="30 0",
              isOn=checkListStatus.revealed,
            },
          },
          {
            tag="Text",
            attributes={
              fontSize=12,
              rectAlignment="MiddleLeft",
            },
            value="Reveal"
          },
        }
      },
      {
        tag="Panel",
        attributes={
          class="bkgPanel",
          width=uiMiddleZone/3,
          rectAlignment="UpperRight",
        },
        children={
          {
            tag="Text",
            attributes={
              id="kts__scouting_resolution",
              fontSize=12,
            },
            value=checkListStatus.winner,
          },
        }
      },
    }
  }
end

function buildHUDCheck(def)
  local guid = self.getGUID()
  local uiWidth = 650
  local uiHeight = 990
  local panelHeight = 25
  local panelID = "kts__checklist_panel"
  local chl = {}
  local chr = {}
  local logoVisible = rules.art.graphics.eventLogo ~= nil
  local uiSubWidth = uiWidth*0.5
  local logoWidth = rules.art.gui.overlay.logoWidth
  local logoHeight = rules.art.gui.overlay.logoHeight
  local uiMiddleZone = 350
  local nameplateWidth = math.floor(uiSubWidth*0.5 + 32)

  if logoVisible then
    uiMiddleZone = math.max(uiMiddleZone, logoWidth+4)
  end
  uiWidth = uiWidth + uiMiddleZone
  local yPos = -31
  local yPosOffsS = 26
  local yPosOffsL1 = 36
  local yPosOffsL2 = 31
  local videoTutorialTitle = buildVideoTutorial1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local videoTutorial = buildVideoTutorial2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local allowDataCollectionTitle = buildAllowDataCollection1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local allowDataCollection = buildAllowDataCollection2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local secondaryTitle = buildSecondaryTitle(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsL2
  local gameTypeTitle = buildGameType1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local gameType = buildGameType2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsL1
  local tournamentTitle = buildTournament1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local tournament = buildTournament2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsL1
  local killZoneLoadedTitle = buildKillZoneLoaded1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local killZoneLoaded = buildKillZoneLoaded2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local selectMissionTitle = buildSelectMission1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local selectMission = buildSelectMission2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsL1
  local rollOffWinnerTitle = buildRollOffWinner1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS - 1
  local rollOffWinner = buildRollOffWinner2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local rollOffSelectionTitle = buildRollOffSelection1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local rollOffSelection = buildRollOffSelection2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local redFactionTitle = buildFaction1(yPos, uiWidth, uiMiddleZone, panelHeight, Player['Red'])
  yPos = yPos - yPosOffsS
  local redFaction = buildFaction2(yPos, uiWidth, uiMiddleZone, panelHeight, Player['Red'])
  yPos = yPos - yPosOffsL1
  local blueFactionTitle = buildFaction1(yPos, uiWidth, uiMiddleZone, panelHeight, Player['Blue'])
  yPos = yPos - yPosOffsS
  local blueFaction = buildFaction2(yPos, uiWidth, uiMiddleZone, panelHeight, Player['Blue'])
  yPos = yPos - yPosOffsL1
  local tacOpsSelectedTitle = buildTacOpsSelected1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local tacOpsSelected = buildTacOpsSelected2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local equipmentSelectedTitle = buildEquipmentSelected1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local equipmentSelected = buildEquipmentSelected2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local barricadePlacingTitle = buildBarricadePlacing1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local barricadePlacing = buildBarricadePlacing2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local deploymentDoneTitle = buildDeploymentDone1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local deploymentDone = buildDeploymentDone2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local allowOverwatchTitle = buildAllowOverwatch1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local allowOverwatch = buildAllowOverwatch2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local scoutingPhaseTitle = buildScoutingPhase1(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsS
  local scoutingPhase = buildScoutingPhase2(yPos, uiWidth, uiMiddleZone, panelHeight)
  yPos = yPos - yPosOffsL1
  local controlButtons = buildControlButtons(yPos, uiWidth, uiMiddleZone, panelHeight)

  local checkPanel = {
    --Pregame Checklist
    --Title
    {
      tag="Panel",
      attributes={
        class="bkgPanel",
        height=30,
        rectAlignment="UpperCenter",
      },
      children={
        {
          tag="Text",
          attributes={
            class="title2",
            fontSize=20,
          },
          value="Pre-Game Checklist"
        },
      }
    },
    --Video tutorial
    videoTutorialTitle,
    videoTutorial,
    --Allow data collection
    allowDataCollectionTitle,
    allowDataCollection,
    --Secondary title
    secondaryTitle,
    --Game type
    gameTypeTitle,
    gameType,
    --Tournament
    tournamentTitle,
    tournament,
    --Kill Zone Loaded
    killZoneLoadedTitle,
    killZoneLoaded,
    --Mission
    selectMissionTitle,
    selectMission,
    --Roll off winner
    rollOffWinnerTitle,
    rollOffWinner,
    --Roll Off winner Selection
    rollOffSelectionTitle,
    rollOffSelection,
    --Red Faction
    redFactionTitle,
    redFaction,
    --Blue Faction
    blueFactionTitle,
    blueFaction,
    --Tac Ops Selected
    tacOpsSelectedTitle,
    tacOpsSelected,
    --Equipment selected
    equipmentSelectedTitle,
    equipmentSelected,
    --Barricades placed
    barricadePlacingTitle,
    barricadePlacing,
    --Operatives Deployed
    deploymentDoneTitle,
    deploymentDone,
    --Allow Overwatch
    allowOverwatchTitle,
    allowOverwatch,
    --Scouting Phase
    scoutingPhaseTitle,
    scoutingPhase,
    --Control Buttons
    controlButtons,
  }

  local mainCheckPanel = {
    tag="Panel",
    attributes={
      id=panelID,
      class="mainPanel",
      width=uiMiddleZone,
      height=uiHeight,
      visibility="White",
      rectAlignment="LowerLeft",
      offsetXY="80 30",
    },
    children = checkPanel
  }
  return mainCheckPanel
end
--ADDED by ZAKA

--ADDED by ZAKA
function onTutorialClick(player)
  showYoutubeLink(player)
end
function onRedAcceptedDataCollection(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if player.steam_name == getUIAttribute("kts__toggle_red_accept_text", "text") then
      setAllowData(player, value)
      checkListStatus[player.steam_name].allow = value
      setUIAttribute("kts__toggle_red_accept", "isOn", value == "True" and true or false)
      setUIAttribute("kts__toggle_red_accept", "backgroundColor", value == "True" and player.color or "White")
    else
      player.broadcast("Only "..getUIAttribute("kts__toggle_red_accept_text", "text").." can check this")
    end
  end
  setUIAttribute("kts__toggle_red_accept", "isOn", checkListStatus[getUIAttribute("kts__toggle_red_accept_text", "text")] ~= nil and checkListStatus[getUIAttribute("kts__toggle_red_accept_text", "text")].allow or checkListPlayer.allow)
end
function onBlueAcceptedDataCollection(player, value)
  if player.color == "Red" or player.color == "Blue" then
    if player.steam_name == getUIAttribute("kts__toggle_blue_accept_text", "text") then
      setAllowData(player, value)
      checkListStatus[player.steam_name].allow = value
      setUIAttribute("kts__toggle_blue_accept", "isOn", value == "True" and true or false)
      setUIAttribute("kts__toggle_blue_accept", "backgroundColor", value == "True" and player.color or "White")
    else
      player.broadcast("Only "..getUIAttribute("kts__toggle_blue_accept_text", "text").." can check this")
    end
  end
  setUIAttribute("kts__toggle_blue_accept", "isOn", checkListStatus[getUIAttribute("kts__toggle_blue_accept_text", "text")] ~= nil and checkListStatus[getUIAttribute("kts__toggle_blue_accept_text", "text")].allow or checkListPlayer.allow)
end
function onEditionSelected(player, value)
  if player.color == "Red" or player.color == "Blue" then
    setUIAttribute("kts__dropdown_mission_open", "active", false)
    setUIAttribute("kts__dropdown_mission_itd", "active", false)
    setUIAttribute("kts__dropdown_mission_critops", "active", false)
    setUIAttribute("kts__dropdown_mission_critopsitd", "active", false)
    result.edition = "Select One"
    checkListStatus.edition = "Select One"
    setUIAttribute("kts__dropdown_edition", "textColor", "#e74f0aff")
    if value ~= "Select One" then
      checkListStatus.edition = value
      result.edition = value
      if value == "KT 2021 - Open" then
        setUIAttribute("kts__dropdown_mission_open", "active", true)
        getObjectFromGUID(masterBagOpen).call("masterPlace")
      elseif value == "KT 2022 - Crit Ops" then
        setUIAttribute("kts__dropdown_mission_critops", "active", true)
        getObjectFromGUID(critOpsOpenBag).call("masterPlace")
      elseif value == "KT 2022 - Crit Ops - ITD" then
          setUIAttribute("kts__dropdown_mission_critopsitd", "active", true)
          getObjectFromGUID(critOpsItdBag).call("masterPlace")
      else
        setUIAttribute("kts__dropdown_mission_itd", "active", true)
        getObjectFromGUID(masterBagItd).call("masterPlace")
      end
      broadcastToAll("Edition: "..value.." selected")
      setUIAttribute("kts__dropdown_edition", "textColor", player.color)
    end
  end
  changeMultiDropdown({
    "kts__dropdown_edition",
    "kts__dropdown_mission_open",
    "kts__dropdown_mission_itd",
  },
  {
    checkListStatus.edition,
    "Select One",
    "Select One",
  })
end

end)
__bundle_register("base-board/game-state-machine", function(require, _LOADED, __bundle_register, __bundle_modules)

gameStateMachine = {
  whoToPress="",
  preGame={
    active=true,
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