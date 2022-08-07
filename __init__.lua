if game:getdvar("gamemode") ~= "mp" then -- If its not on multiplayer then don't execute the script
    return
end

playerslistvotemap = {}
votemapRunning = 0

game:precacheshader("gradient_fadein")
game:precacheshader("gradient")
game:precacheshader("white")
game:precacheshader("line_vertical")

maptovote = "mp_convoy mp_showdown mp_bog mp_crash mp_crossfire mp_citystreets mp_shipment mp_vacant mp_broadcast mp_bloc mp_killhouse mp_strike mp_crash_snow mp_bog mp_backlot mp_farm mp_overgrown mp_carentan mp_creek mp_pipeline mp_cargoship mp_bog_summer"
dsrtovotate = "war dom hp"
time_to_vote = 20 -- seg
time_to_killcam = 3000 ---miliseg Needed for you to present the winning map/mode

local final_killcam = nil
final_killcam = game:detour("_id_A78D", "endfinalkillcam", function() -- maps/mp/gametypes/_damage = _id_A78D -- 
    level:onnotifyonce("end_vote", function()
        game:ontimeout(function()
            final_killcam.invoke() -- this calls the original, and lets the notify go through
        end, time_to_killcam)
    end)

    if( game:scriptcall("maps/mp/_utility", "_id_A1CA") == 1 and #playerslistvotemap >= 1) then        -- Votemap will run only if there are a minimum number of players and waslastround
        startvotemap() -- Once the vote is finished, it notifies by calling the finalkillcam
    else -- Set a random map
        time_to_killcam = 0
        local gametypewin = getgametypewin()
        local mapwin = getmapwin()        
        game:executecommand('set sv_maprotationcurrent "gametype ' .. gametypewin .. ' map ' .. mapwin .. '"')
        print('set sv_maprotationcurrent "gametype ' .. gametypewin .. ' map ' .. mapwin .. '"')
        level:notify("end_vote") -- notification calling finalkillcam
    end 
end)

function tablefind(tab, el)
    for index, value in pairs(tab) do
        if value == el then
            return index
        end
    end

    return nil
end
------------
function removeplayer(player)
    local index = tablefind(playerslistvotemap, player)
    if index ~= nil then
        table.remove(playerslistvotemap, index)
    end
end
-----------
function player_connected(player)  
    player:onnotifyonce("disconnect", function()
        removeplayer(player)
    end)
	if(game:isdefined(player == 1) and  game:isbot(player) == 0 and votemapRunning == 0) then
		table.insert(playerslistvotemap, player)
        player:onnotifyonce("start_vote", function()
            player:PlayerVote()
        end)
    end
end
------------
level:onnotify("connected", player_connected)
----------------
function startvotemap()

    maprotation = maptovote:split(" ")
    dsrrotation = dsrtovotate:split(" ")
    votemapRunning = 1

    windowheight = 180
    windowwidth  = 500
    borderwidth  = 20
    maps4vote    = 6 -- Number of map/mode options to vote on, max 6

    voteablemaps = {}

    tryes = 0

    while( ((#voteablemaps) < maps4vote) and (tryes < 100))
        do
            tryes = tryes + 1
            j = math.random(#maprotation)
            k = math.random(#dsrrotation);
            while(inArray(voteablemaps,(maprotation[j] .. ";" .. dsrrotation[k])) == 1)
            do
                j = math.random(#maprotation)
                k = math.random(#dsrrotation);	
            end
            table.insert(voteablemaps, maprotation[j] .. ";" .. dsrrotation[k])	
    end

    arraymaps = voteablemaps
	hudA = {}
	--center
	hudA[1] = addTextHud( "level", 0, 0, 0.6, "center", "middle", "center", "middle", 0, 100 )
	hudA[1]:setshader("white", windowwidth, windowheight)
	hudA[1].color = vector:new(0,0,0)
	hudA[1]:fadeIn( 0.3)
    --left
	hudA[2] = addTextHud( "level", (windowwidth / -2), 0, 0.6, "right", "middle", "center", "middle", 0, 100 )
	hudA[2]:setshader("gradient_fadein",borderwidth, windowheight)
	hudA[2].color = vector:new(0,0,0)
	hudA[2]:fadeIn( 0.3)
	--right
	hudA[3] = addTextHud( "level", (windowwidth / 2), 0, 0.6, "left", "middle", "center", "middle", 0, 100 )
	hudA[3]:setshader("gradient",borderwidth,windowheight)
	hudA[3].color = vector:new(0,0,0)
	hudA[3]:fadeIn( 0.3)
	--text
	hudA[4] = addTextHud( "level", 0, (windowheight / -2) - 8, 1, "center", "bottom", "center", "middle", 1.5, 102 )
    hudA[4]:settext("Map Vote: Use [{+attack}] and [{+toggleads_throw}] to Vote")
	hudA[4]:fadeIn( 0.3)
	--timer
	hudA[5] = addTextHud( "level", (windowwidth / 2 ) - 20, (windowheight / -2) -8, 1, "center", "bottom", "center", "middle", 1.5, 102 )
	hudA[5]:settenthstimer(time_to_vote)
	hudA[5]:fadeIn( 0.3)
	--blue top bg
	hudA[6] = addTextHud( "level", 0, (windowheight / -2) + 5, 0.8, "center", "bottom", "center", "middle", 2.2, 101 )
	hudA[6].color = vector:new(0, 0.402 , 1)
	hudA[6]:setshader("line_vertical", windowwidth + borderwidth + borderwidth, 50)
	hudA[6]:fadeIn( 0.3)
	--mappool
	string = ""
	hudA[7] = addTextHud( "level", 0, (windowheight / -2) + 6, 0.1, "center", "top", "center", "middle", 2.2, 101 )
	hudA[7].color = vector:new(0, 0.402 ,1)
	hudA[7]:setshader("white",windowwidth, round( (#arraymaps * 26.8)))
	hudA[7]:fadeIn( 0.3)


    loopfadein = game:oninterval(function()
        hudA[5]:fadeovertime(0.9)
		hudA[5].alpha = 0.5
		hudA[4]:fadeovertime(0.9)
		hudA[4].alpha = 0.5
    end, 500)

    loopfadein2 = game:oninterval(function()
        hudA[5]:fadeovertime(0.1)
        hudA[5].alpha = 1	
        hudA[4]:fadeovertime(0.1)
        hudA[4].alpha = 1
    end, 1000)	

    loopfadein:endon(level, "end_vote")
    loopfadein2:endon(level, "end_vote")


	string = ""
	arrayVoting = {}
	mostvotes = 0
	winning = arraymaps[1]

	mapvotes = addTextHud( "level", (windowwidth / -3), (windowheight / -2) + 8, 1, "left", "top", "center", "middle", 2.2, 102 );
	mapvotes:fadeIn(0.3)
	level:onnotifyonce("end_vote", function()
		if(game:isdefined(mapvotes) == 1) then
			mapvotes:destroy()
		end
	end)
	
	level:onnotify("end_vote", function() postVote() end) -- Show winning map and define next map/mode
    level:onnotify("end_vote", function() endvotemapPlayers() end)
	
    updatevotesmonitor = game:oninterval(function() -- wait time_to_vote seg to vote

		time_to_vote = time_to_vote - 1
		------------
		arrayVoting = {}
        for j = 1, #arraymaps do -- inicialize arrayvonting acoording #options to vote
            table.insert(arrayVoting, 0)
        end

		mostvotes = 0

        for j = 1, #arraymaps do
            for i = 1, #playerslistvotemap do
                if(game:isdefined(playerslistvotemap[i] == 1) and game:isdefined(playerslistvotemap[i].votedmap) == 1 )  then
                    if(playerslistvotemap[i].votedmap == arraymaps[j]) then
                        arrayVoting[j] = arrayVoting[j] + 1 
                    end
                end
            end
        end       

		string = ""
        for i = 1, #arraymaps do  
            if(game:isdefined(arrayVoting[i]) == 0) then
                voted = 0
            else 
                voted = arrayVoting[i]
            end
            string = string .. (voted .. " - " .. getMapNameString(arraymaps[i]:split(";")[1]) .. " " .. getGameTypeString(arraymaps[i]:split(";")[2]) .. "\n")

            if(game:isdefined(arrayVoting[i]) == 1) then		
                if(mostvotes < arrayVoting[i]) then
                    mostvotes = arrayVoting[i]
                    winning = arraymaps[i]
                end
            end	
        end

		mapvotes:settext(string) -- could cause overflow
		-----------
        if time_to_vote == 0 then -- When time reach 0 the mapvote end
			level:notify("end_vote") -- stop all threads monitors
		end
		-------------
    end, 1000)
	updatevotesmonitor:endon(level, "end_vote")
	
	level:onnotify("start_vote", function() votemapPlayers() end)
   
    level:notify("start_vote")
end
----------------
function postVote()
    
    hudA[6]:fadeOut(0.5)
    hudA[5]:fadeOut(0.5)
    hudA[4]:fadeOut(0.5)
	game:ontimeout(function()
		game:executecommand('set sv_maprotationcurrent "gametype ' .. winning:split(";")[2] .. ' map ' .. winning:split(";")[1] .. '"')
		print('set sv_maprotationcurrent "gametype ' .. winning:split(";")[2] .. ' map ' .. winning:split(";")[1] .. '"')

		hudA[4] = addTextHud( "level", 0, -20, 1, "center", "middle", "center", "middle", 1.5, 102 )
		hudA[4]:settext("Next Map:")
		hudA[4].glowalpha = 1
		hudA[4].glowcolor = vector:new(0,0.5,1)
		hudA[4]:fadeIn(0.5);

		hudA[6] = addTextHud( "level", 0, 10, 1, "center", "middle", "center", "middle", 2, 102 )
		hudA[6]:settext(getMapNameString(winning:split(";")[1]) .. " " .. getGameTypeString(winning:split(";")[2]))
		hudA[6].glowalpha = 1
		hudA[6].glowcolor = vector:new(0,0.5,1)
		hudA[6]:fadeIn(0.5)
		game:ontimeout(function()
			hudA[5]:fadeOut(0.5)
			hudA[7]:fadeOut(0.5)                
			hudA[1]:fadeOut(0.5)
			hudA[2]:fadeOut(0.5)
			hudA[3]:fadeOut(0.5)
			hudA[4]:fadeOut(0.5)
			hudA[6]:fadeOut(0.5)	
		end, 1500)
	end, 1000)
end
----------------
function string:split(delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
      table.insert( result, string.sub( self, from , delim_from-1 ) )
      from  = delim_to + 1
      delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
    return result
end   
----------
function inArray(array, text)    
    for k = 1,  #array do
        if (array[k] == text) then
          return 1
        end
    end
    return 0
end
------------
function addTextHud( who, x, y, alpha, alignX, alignY, horiz, vert, fontScale, sort ) 
    local hud = nil
	if( who ~= "level" or game:isplayer(who) == 1) then
        if game:isplayer(who) == 1 then
        end
		hud = game:newclienthudelem( who )
	else
		hud = game:newhudelem()
    end
	hud.x = x
	hud.y = y
	hud.alpha = alpha
	hud.sort = sort
	hud.alignx = alignX
	hud.aligny = alignY
	if(vert ~= nil) then
		hud.vertalign = vert
    end
	if(horiz ~= nil) then
		hud.horzalign = horiz	
    end
	if(fontScale ~= 0) then
		hud.fontscale = fontScale
    end
	hud.foreground = 1
	hud.archived = 0

	return hud
end
------------
function entity:fadeIn(time) 
	alpha = self.alpha;
	self.alpha = 0;
	self:fadeovertime(time);
	self.alpha = alpha;
end
------------
function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end
--------------
function playSoundOnAllPlayers( soundAlias ) 
	for i= 1, #playerslistvotemap do
		if(game:isdefined(playerslistvotemap[i] == 1)) then
			playerslistvotemap[i]:playlocalsound(soundAlias)
		end
    end
end
--------------
function entity:fadeOut(time) 
	if(game:isdefined(self) == 1) then
        self:fadeovertime(time);
	    self.alpha = 0;
        game:ontimeout(function() 
            self:destroy()
        end, 500)
    end	
end
--------------
function getMapNameString( mapName )  
    mapName = mapName:lower()
    if     mapName == "mp_convoy" then return "Ambush"
    elseif mapName == "mp_backlot" then return "Backlot"
    elseif mapName == "mp_bog" then return "Bog"
    elseif mapName == "mp_crash" then return "Crash"
    elseif mapName == "mp_crossfire" then return "Crossfire"
    elseif mapName == "mp_citystreets" then return "District"
    elseif mapName == "mp_farm" then return "Downpour"
    elseif mapName == "mp_overgrown" then return "Overgrown"
    elseif mapName == "mp_shipment" then return "Shipment"
    elseif mapName == "mp_vacant" then return "Vacant"
    elseif mapName == "mp_vlobby_room" then return "Lobby Map"
    elseif mapName == "mp_broadcast" then return "Broadcast"
    elseif mapName == "mp_carentan" then return "Chinatown"
    elseif mapName == "mp_countdown" then return "Countdown"
    elseif mapName == "mp_bloc" then return "Bloc"
    elseif mapName == "mp_creek" then return "Creek"
    elseif mapName == "mp_killhouse" then return "Killhouse"
    elseif mapName == "mp_pipeline" then return "Pipeline"
    elseif mapName == "mp_strike" then return "Strike"
    elseif mapName == "mp_showdown" then return "Showdown"
    elseif mapName == "mp_cargoship" then return "Wet Work"
    elseif mapName == "mp_crash_snow" then return "Winter Crash"
    elseif mapName == "mp_farm_spring" then return "Day Break"
    elseif mapName == "mp_bog_summer" then return "Beach Bog"
    end
    return mapName
end
-------------------------
function getGameTypeString( gt )  
    gt = gt:lower()
    if     gt == "war" then return " (Team Deathmatch)"
    elseif gt == "dom" then return " (Domination)"
    elseif gt == "hp" then return " (Hardpoint)"
    elseif gt == "sd" then return " (Search & Destroy)"        
    elseif gt == "conf" then return " (Kill Confirmed)"  
    elseif gt == "sab" then return " (Sabotage)"  
    elseif gt == "koth" then return " (Headquarters)"  
    elseif gt == "gun" then return " (Gun Game)"  
    elseif gt == "ctf" then return " (Capture The Flag)"  
    elseif gt == "dd" then return " (Demolition)"
    elseif gt == "dm" then return " (Free for All)"  
    end
    return gt
end
-------------------------
function votemapPlayers()
    for i = 1,  #playerslistvotemap do     
		if(game:isdefined(playerslistvotemap[i] == 1)) then
            playerslistvotemap[i]:notify("start_vote")
		end
    end
end
-------------------------
function endvotemapPlayers()
    for i = 1,  #playerslistvotemap do     
		if(game:isdefined(playerslistvotemap[i] == 1)) then
            playerslistvotemap[i]:notify("end_vote")
		end
    end
end
----------------
function entity:PlayerVote() 

    local looptime = game:oninterval(function()
        self:playlocalsound("ui_mp_timer_countdown")
    end, 1000)
    looptime:endon(level, "end_vote")
    local maps = voteablemaps
	self.howto = addTextHud( self, 0, (windowheight / 2) + 5, 1, "center", "top", "center", "middle", 2.4, 101 )
	self.howto:fadeIn(0.3)
	self.howto:settext("Voting started")
    self.selected = -1
	offset = 26.8
	self.mapvote_selection = addTextHud( self, 0, ((windowheight / -2) + 9 + (self.selected * offset)), 1, "center", "top", "center", "middle", 1.6, 101 )
	self.mapvote_selection:setshader("line_vertical", windowwidth, 25)
	self.mapvote_selection.color = vector:new(0, 0.402 ,1)
	self.mapvote_selection:fadeIn(0.3)
    --self:uplisten()
	self:notifyonplayercommand("goinup", "+speed_throw")
    self:notifyonplayercommand("goinup","+toggleads_throw")
	local notifygoinup = self:onnotify("goinup", function()
        self.selected = self.selected - 1                
        if(self.selected < 1) then
            self.selected = #maps 
        end
        self.votedmap = maps[self.selected]        
        self.mapvote_selection:affectElement("y", 0.1, ((windowheight / -2) + 9 + ((self.selected -1) * offset) ))
	end)
    notifygoinup:endon(level, "end_vote")
    notifygoinup:endon(self, "disconnect")
    --self:downlisten()
    self:notifyonplayercommand("goindown","+attack")
	local notifygoindown = self:onnotify("goindown", function()
        self.selected = self.selected + 1                
        if(self.selected > #maps) then
            self.selected = 1
        end
        self.votedmap = maps[self.selected]        
        self.mapvote_selection:affectElement("y", 0.1, ((windowheight / -2) + 9 + ((self.selected -1) * offset) ))
	end)
    notifygoindown:endon(level, "end_vote")
    notifygoindown:endon(self, "disconnect")
    
    self:onnotifyonce("disconnect", function()
        if (game:isdefined(self)) then
        self.mapvote_selection:fadeOut(0.5)
        end
    end)
    self:onnotifyonce("startingVoted", function() 
        self.howto:fadeOut(1)  
    end)

    local monitorplayerbuttonpressed = game:oninterval(function()
        if(self:adsbuttonpressed() == 1 or self:attackbuttonpressed() == 1) then           
            self:notify("startingVoted")
        end
    end, 10)
    monitorplayerbuttonpressed:endon(self, "startingVoted")
    self:onnotifyonce("end_vote", function()
        if(game:isdefined(self) == 1 and game:isdefined(self.mapvote_selection) == 1) then
                self.mapvote_selection:fadeOut(0.5)
        end
	if(game:isdefined(self) == 1 and game:isdefined(self.howto) == 1) then -- In case the player has not voted
            self.howto:fadeOut(1)  
        end
    end)
end
------------
function entity:affectElement(type, time, value) --HUD Common by DoktorSAS
    if type == "x" or type == "y" then
        self:moveovertime( time )
    elseif type == "font" then
        self:changefontscaleovertime( time )
    else
        self:fadeovertime( time )
    end

    if(type == "x") then
        self.x = value
    elseif(type == "y") then
        self.y = value
    elseif(type == "alpha") then
        self.alpha = value
    elseif(type == "color") then
        self.color = value
    end
end
-----------------
function round(float)
    local int, part = math.modf(float)
    if float == math.abs(float) and part >= .5 then return int+1    -- positive float
    elseif part <= -.5 then return int-1                            -- negative float
    end
    return int
end
------------------
 function getRealPlayers(playerlist)
    playerRealList = {}
    for i = 1,  #playerlist do
        if(game:isdefined(playerlist[i] == 1) and  game:isbot(playerlist[i]) == 0) then
			table.insert(playerRealList,playerlist[i])
        end
    end

    return playerRealList
 end
--------------------
function getgametypewin()
    
    local gametypesa = {}
    table.insert(gametypesa, "war")
    table.insert(gametypesa, "dom")
    table.insert(gametypesa, "hp")
    --table.insert(gametypesa, "sd")
    
    return gametypesa[math.random(#gametypesa)]
end
--------------------
function getmapwin()

    local mapsa = {}
    table.insert(mapsa, "mp_convoy")
    table.insert(mapsa, "mp_showdown")
    table.insert(mapsa, "mp_bog")
    table.insert(mapsa, "mp_crash")
    table.insert(mapsa, "mp_crossfire")
    table.insert(mapsa, "mp_citystreets")
    table.insert(mapsa, "mp_shipment")
    table.insert(mapsa, "mp_vacant")
    table.insert(mapsa, "mp_broadcast")
    table.insert(mapsa, "mp_bloc")
    table.insert(mapsa, "mp_killhouse")
    table.insert(mapsa, "mp_strike")
    table.insert(mapsa, "mp_crash_snow")
    table.insert(mapsa, "mp_countdown")
    table.insert(mapsa, "mp_bog_summer")

    return mapsa[math.random(#mapsa)]
end
