--
-- BankManagement by MX11
-- Version 1.0.0.0 
-- 26.10.2016
-- 05.02.2017 - Ergänzung Key Honk mit Key 9 und Änderung des StoreIcons
-- 24.11.2018 - Änderungen für LS19 ohne Prüfung ob jemand einen Farm besitzt.
-- 10.02.2019 - Anpassungen der GUI
-- 23.11.2021 - Anpassung für LS22
-- 25.11.2021 - Optimierung der GUI
-- 06.12.2021 - Umbau von BankManagementGui zu BankManagement
-- 20.01.2022 - Finalisierung Multiplayer-Sync
--
-- Keine Veränderung ohne meine Erlaubnis!
-- No modification without my permission!


BankManagement = {}
BankManagement.guiName = "FS22_BankManagementGui"
BankManagement.debug = false
BankManagement.modDirectory = g_currentModDirectory
BankManagement.scriptName = "bankManagement"
BankManagement.version = 1.0

function BankManagement:loadMap(name)
	if self.debug then
		print("----BankManagement:loadMap")
	end
	self:mergeModTranslations()
	Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, BankManagement.registerActionEventsPlayer)
	self.gui = BankManagementGui:new(self.guiName, self.modDirectory, self.scriptName)
	self.firstTime = true
end
function BankManagement:initBankManagementDataFromGameData()
	if self.debug then
		print("----BankManagement:initBankManagementDataFromGameData")
	end
	g_currentMission.BankManagementData = {}
	self.playerBankManagementFarm = nil
	for _, farm in ipairs(g_farmManager.farms) do
		local bankManagementFarm = BankManagementFarm.new()
		bankManagementFarm.farmId = farm.farmId
		bankManagementFarm.money = farm.money
		bankManagementFarm.loan = farm.loan
		bankManagementFarm.minLoan = farm.MIN_LOAN
		bankManagementFarm.maxLoan = farm.MAX_LOAN
		bankManagementFarm.loanAnnualInterestRate = farm.LOAN_INTEREST_RATE
		if farm.farmId > 0 then
			bankManagementFarm.equity =  g_farmManager:getFarmById(farm.farmId):getEquity()
		end
		bankManagementFarm.equityLoanRatio = farm.EQUITY_LOAN_RATIO
		table.insert(g_currentMission.BankManagementData, bankManagementFarm)
	end
end
function BankManagement:registerActionEventsPlayer()
	if self.debug then
		print("----BankManagement:registerActionEventsPlayer");
	end
	local valid, actionEventId, _ = g_inputBinding:registerActionEvent(InputAction.BANKMANAGEMENT_OPEN, self, BankManagement.showGui, false, true, false, true)
end
function BankManagement:keyEvent(unicode, sym, modifier, isDown)
end;

function BankManagement:showGui()
	if self.debug then
		print("----BankManagement:showGui");
		print("g_currentMission.isMasterUser:"..tostring(g_currentMission.isMasterUser))
		print("g_currentMission.missionDynamicInfo.isMultiplayer:"..tostring(g_currentMission.missionDynamicInfo.isMultiplayer))
		print("g_currentMission.missionDynamicInfo.isClient:"..tostring(g_currentMission.missionDynamicInfo.isClient))
		print("g_currentMission.getIsServer:"..tostring(g_currentMission.getIsServer()))
		print("g_currentMission.getIsClient:"..tostring(g_currentMission.getIsClient()))
		print("g_currentMission.playerUserId:"..tostring(g_currentMission.playerUserId))
		print("g_currentMission:getHasPlayerPermission(farmManager):"..tostring(g_currentMission:getHasPlayerPermission("farmManager")))	
	end
	if g_currentMission.player.farmId ~= g_farmManager.SPECTATOR_FARM_ID then
		BankManagement:updateBankManagementDataFromGameDataAll()
		BankManagement:setPlayerBankManagementFarm(g_currentMission.player.farmId)
		g_gui:showDialog("FS22_BankManagementGui", true)
	else
		if self.debug then
			print(g_i18n:getText("BANKMANAGEMENT_NOFARM"))
		end
		g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_CRITICAL, g_i18n:getText("BANKMANAGEMENT_NOFARM"))
	end
end

function BankManagement:updatePlayerBankManagementFarm(bmdf)
	if self.debug then
		print("----BankManagement:updatePlayerBankManagementFarm");
	end
	if bmdf ~= nil then
		self.playerBankManagementFarm = bmdf
		g_farmManager:getFarmById(bmdf.farmId).money = bmdf.money	
		g_farmManager:getFarmById(bmdf.farmId).loan = bmdf.loan		
		g_farmManager:getFarmById(bmdf.farmId).MIN_LOAN = bmdf.minLoan	
		g_farmManager:getFarmById(bmdf.farmId).MAX_LOAN = bmdf.maxLoan	
		g_farmManager:getFarmById(bmdf.farmId).LOAN_INTEREST_RATE = bmdf.loanAnnualInterestRate	
		--g_farmManager:getFarmById(bmdf.farmId).equity = bmdf.equity	
		g_farmManager:getFarmById(bmdf.farmId).EQUITY_LOAN_RATIO = bmdf.equityLoanRatio	
	end
end
function BankManagement:getFarmFromBankManagementData(playerFarmId)
	if self.debug then
		print("----BankManagement:getFarmFromBankManagementData");
	end
	if playerFarmId == nil then
		playerFarmId = 1
	end
	local bmdf = nil
	for _, bankManagementFarm in ipairs(g_currentMission.BankManagementData) do
		if bankManagementFarm.farmId == playerFarmId then
			bmdf = bankManagementFarm
		end
	end
	return bmdf
end
function BankManagement:setPlayerBankManagementFarm(playerFarmId)
	if self.debug then
		print("----BankManagement:setPlayerBankManagementFarm");
		print("playerFarmId:"..tostring(playerFarmId))
	end
	if playerFarmId == nil then
		playerFarmId = 1
	end
	for _, bankManagementFarm in ipairs(g_currentMission.BankManagementData) do
		if bankManagementFarm.farmId == playerFarmId then
			BankManagement.playerBankManagementFarm = bankManagementFarm
		end
	end
end
function BankManagement:getPlayerBankManagementFarm()
	if self.debug then
		print("----BankManagement:getPlayerBankManagementFarm");
		print("g_currentMission.player.farmId:"..tostring(g_currentMission.player.farmId))
	end
	for _, bankManagementFarm in ipairs(g_currentMission.BankManagementData) do
		if bankManagementFarm.farmId == g_currentMission.player.farmId then
			return table.copy(bankManagementFarm)
		end
	end
end

function BankManagement:updateGameDataFromBankManagementDataAll()
	if self.debug then
		print("----BankManagement:updateGameDataFromBankManagementDataAll");
	end
	for _, bankManagementFarm in ipairs(g_currentMission.BankManagementData) do
		local farm = g_farmManager:getFarmById(bankManagementFarm.farmId)
		if farm ~= nil then
			farm.money = bankManagementFarm.money	
			farm.loan = bankManagementFarm.loan		
			farm.MIN_LOAN = bankManagementFarm.minLoan	
			farm.MAX_LOAN = bankManagementFarm.maxLoan	
			farm.LOAN_INTEREST_RATE = bankManagementFarm.loanAnnualInterestRate	
			--farm.equity = bankManagementFarm.equity	
			farm.EQUITY_LOAN_RATIO = bankManagementFarm.equityLoanRatio	
			farm.creditAmountChange = bankManagementFarm.creditAmountChange		
		end	
	end
end

function BankManagement:updateBankManagementDataFromGameDataAll()
	if self.debug then
		print("----BankManagement:updateGameDataFromBankManagementDataAll");
	end
	if g_farmManager.farms ~= nil then
		for _, farm in ipairs(g_farmManager.farms) do
			local bmfFound = false
			for _, bankManagementFarm in ipairs(g_currentMission.BankManagementData) do
				if bankManagementFarm.farmId == farm.farmId then
					bankManagementFarm.farmId = farm.farmId
					bankManagementFarm.money = farm.money
					bankManagementFarm.loan = farm.loan
					bankManagementFarm.minLoan = farm.MIN_LOAN
					bankManagementFarm.maxLoan = farm.MAX_LOAN
					bankManagementFarm.loanAnnualInterestRate = farm.LOAN_INTEREST_RATE				
					if farm.farmId > 0 then
						bankManagementFarm.equity = g_farmManager:getFarmById(farm.farmId):getEquity()
					end
					bankManagementFarm.equityLoanRatio = farm.EQUITY_LOAN_RATIO			
					bmfFound = true
				end
			end
			if not bmfFound then
				local bankManagementFarm = BankManagementFarm.new()
				bankManagementFarm.farmId = farm.farmId
				bankManagementFarm.money = farm.money
				bankManagementFarm.loan = farm.loan
				bankManagementFarm.minLoan = farm.MIN_LOAN
				bankManagementFarm.maxLoan = farm.MAX_LOAN
				bankManagementFarm.loanAnnualInterestRate = farm.LOAN_INTEREST_RATE
				if farm.farmId > 0 then
					bankManagementFarm.equity =  g_farmManager:getFarmById(farm.farmId):getEquity()
				end
				bankManagementFarm.equityLoanRatio = farm.EQUITY_LOAN_RATIO
				table.insert(g_currentMission.BankManagementData, bankManagementFarm)
			end
		end
	else
		print("g_farmManager.farms is nil")
	end
end
function BankManagement:updateGameDataFromBankManagementData(bmd)
	if self.debug then
		print("----BankManagement:updateGameDataFromBankManagementData");
	end
	local gameDateFarm = g_farmManager:getFarmById(bmd.farmId)
	if gameDateFarm ~= nil then
		for _, bankManagementFarm in ipairs(g_currentMission.BankManagementData) do
			if bankManagementFarm.farmId == bmd.farmId then
			
				if bankManagementFarm.minLoan ~= bmd.minLoan then
					bankManagementFarm.minLoan = bmd.minLoan
					gameDateFarm.MIN_LOAN = bmd.minLoan	
				end	
				if bankManagementFarm.maxLoan ~= bmd.maxLoan then
					bankManagementFarm.maxLoan = bmd.maxLoan
					gameDateFarm.MAX_LOAN = bmd.maxLoan	
				end	
				if bankManagementFarm.loanAnnualInterestRate ~= bmd.loanAnnualInterestRate then
					bankManagementFarm.loanAnnualInterestRate = bmd.loanAnnualInterestRate
					gameDateFarm.LOAN_INTEREST_RATE = bmd.loanAnnualInterestRate	
				end		
				-- if bankManagementFarm.equity ~= bmd.equity then
					-- bankManagementFarm.equity = bmd.equity
					-- gameDateFarm.equity = bmd.equity	
				-- end
				if bankManagementFarm.equityLoanRatio ~= bmd.equityLoanRatio then
					bankManagementFarm.equityLoanRatio = bmd.equityLoanRatio
					gameDateFarm.EQUITY_LOAN_RATIO = bmd.equityLoanRatio	
				end	
				if bankManagementFarm.creditAmountChange ~= bmd.creditAmountChange then
					bankManagementFarm.creditAmountChange = bmd.creditAmountChange
				end	
				local moneyChange = 0
				if bankManagementFarm.money ~= bmd.money then
					bankManagementFarm.money = bmd.money
					moneyChange = bmd.money - gameDateFarm:getBalance()
				end	
				if bankManagementFarm.loan ~= bmd.loan then
					bankManagementFarm.loan = bmd.loan
					if bankManagementFarm.creditAmountChange == CheckedOptionElement.STATE_CHECKED then
						local moneyChangeCredit = gameDateFarm.loan - bankManagementFarm.loan
						moneyChange = moneyChange + (moneyChangeCredit*-1)
					end	
					gameDateFarm.loan = bankManagementFarm.loan	
				end		
				if self.debug then
					print("moneyChange:"..tostring(moneyChange))
				end
				if moneyChange ~= 0 then
					g_currentMission:addMoney(moneyChange, bmd.farmId, MoneyType.TRANSFER, true, true)
					bankManagementFarm.money = gameDateFarm:getBalance()
					bmd.money = gameDateFarm:getBalance()
				end			
			
			end
		end
	end
end

function BankManagement:update(dt)
	if self.firstTime then
		if self.debug then
			print("update - firstTime")
		end	
		self:initBankManagementDataFromGameData()
		-- if g_currentMission.missionInfo.isValid == false == new savegame
		if g_currentMission.missionInfo.isValid then
			if g_server ~= nil then
				if self.debug then
					print("Initial firstTime on Server")
				end
				if g_currentMission.missionInfo.savegameDirectory ~= nil then
					self:loadSavegame()
				end
			else
				if self.debug then
					print("Sync Client initial Request")
				end
				BankManagementUpdateClientEvent.sendEvent(g_currentMission.player.farmId)
			end
		end
		self.firstTime = false
	end
end

function BankManagement:draw()
end
function BankManagement:deleteMap()
end
function BankManagement:mouseEvent(posX, posY, isDown, isUp, button)
end

function BankManagement:loadSavegame()
	if self.debug then
		print("----BankManagement:loadSavegame")
	end
	local xmlFilename = g_currentMission.missionInfo.savegameDirectory .. "/"..self.scriptName..".xml"
	if not fileExists(xmlFilename) then
		return false
	end
	local xmlFile = XMLFile.load("bankManagementXML", xmlFilename)
	if xmlFile == nil then
		print("xmlFile is nil")
		return false
	end

	local tag = "bankManagement"
	local version = Utils.getNoNil(xmlFile:getFloat(tag.."#version"), 0.0)
	version = math.floor(version*1000)/1000
	if (version <= BankManagement.version) then
		tag = tag..".farm"
		xmlFile:iterate(tag, function (_, key)
			local farmId = xmlFile:getInt(key.."#farmId")
			local found = false
			local foundedBankManagementFarm = nil
			for _, bankManagementFarm in ipairs(g_currentMission.BankManagementData) do
				if bankManagementFarm.farmId == farmId then
					found = true
					foundedBankManagementFarm = bankManagementFarm
				end
			end
			if found then
				foundedBankManagementFarm.money = Utils.getNoNil(xmlFile:getFloat(key..".finances.money"), 0)
				foundedBankManagementFarm.loan = Utils.getNoNil(xmlFile:getFloat(key..".finances.loan"), 0)
				foundedBankManagementFarm.minLoan = Utils.getNoNil(xmlFile:getFloat(key..".finances.minLoan"), 0)
				foundedBankManagementFarm.maxLoan = Utils.getNoNil(xmlFile:getFloat(key..".finances.maxLoan"), 0)
				foundedBankManagementFarm.loanAnnualInterestRate = Utils.getNoNil(xmlFile:getFloat(key..".finances.loanAnnualInterestRate"), 0)
				foundedBankManagementFarm.equity = Utils.getNoNil(xmlFile:getFloat(key..".finances.equity"), 0)
				foundedBankManagementFarm.equityLoanRatio = Utils.getNoNil(xmlFile:getFloat(key..".finances.equityLoanRatio"), 0)
				foundedBankManagementFarm.creditAmountChange = Utils.getNoNil(xmlFile:getInt(key..".finances.creditAmountChange"), 1)
			else
				local bankManagementFarm = BankManagementFarm.new()
				bankManagementFarm.farmId = Utils.getNoNil(xmlFile:getInt(key.."#farmId"), 0)
				bankManagementFarm.money = Utils.getNoNil(xmlFile:getFloat(key..".finances.money"), 0)
				bankManagementFarm.loan = Utils.getNoNil(xmlFile:getFloat(key..".finances.loan"), 0)
				bankManagementFarm.minLoan = Utils.getNoNil(xmlFile:getFloat(key..".finances.minLoan"), 0)
				bankManagementFarm.maxLoan = Utils.getNoNil(xmlFile:getFloat(key..".finances.maxLoan"), 0)
				bankManagementFarm.loanAnnualInterestRate = Utils.getNoNil(xmlFile:getFloat(key..".finances.loanAnnualInterestRate"), 0)
				bankManagementFarm.equity = Utils.getNoNil(xmlFile:getFloat(key..".finances.equity"), 0)
				bankManagementFarm.equityLoanRatio = Utils.getNoNil(xmlFile:getFloat(key..".finances.equityLoanRatio"), 0)
				bankManagementFarm.creditAmountChange = Utils.getNoNil(xmlFile:getInt(key..".finances.creditAmountChange"), 1)
				table.insert(g_currentMission.BankManagementData, bankManagementFarm)
			end
		end)
	end
	if xmlFile ~= nil then
		xmlFile:delete()
	end
	self:updateGameDataFromBankManagementDataAll()
end

function BankManagement:saveSavegame()
	if self.debug then
		print("----BankManagement:saveSavegame")
	end
	if g_server ~= nil then
		BankManagement:updateBankManagementDataFromGameDataAll()
		local xmlFile = XMLFile.create("bankManagementXML", g_currentMission.missionInfo.savegameDirectory .. "/bankManagement.xml", "bankManagement")
		if xmlFile ~= nil then
			local key = "bankManagement"
			xmlFile:setInt(key .. "#revision", 1)
			xmlFile:setBool(key .. "#valid", true)
			xmlFile:setFloat(key .. "#version", BankManagement.version)
			key = key..".farm"
			xmlFile:setTable(key, g_currentMission.BankManagementData, function (key, bankManagementFarm)
	
				xmlFile:setInt(key .. "#farmId", bankManagementFarm.farmId)
				xmlFile:setFloat(key .. ".finances.money", Utils.getNoNil(bankManagementFarm.money,0))
				xmlFile:setFloat(key .. ".finances.loan", Utils.getNoNil(bankManagementFarm.loan,0))
				xmlFile:setFloat(key .. ".finances.minLoan", Utils.getNoNil(bankManagementFarm.minLoan,0))
				xmlFile:setFloat(key .. ".finances.maxLoan", Utils.getNoNil(bankManagementFarm.maxLoan,0))
				xmlFile:setFloat(key .. ".finances.loanAnnualInterestRate", Utils.getNoNil(bankManagementFarm.loanAnnualInterestRate,0))
				xmlFile:setFloat(key .. ".finances.equity", Utils.getNoNil(bankManagementFarm.equity,0))
				xmlFile:setFloat(key .. ".finances.equityLoanRatio", Utils.getNoNil(bankManagementFarm.equityLoanRatio,0))
				xmlFile:setInt(key .. ".finances.creditAmountChange", Utils.getNoNil(bankManagementFarm.creditAmountChange,1))				
			end)
	
			xmlFile:save()
			xmlFile:delete()			
		end
	end
end


function BankManagement:mergeModTranslations()
	-- make l10n global so they can be used in GUI XML files directly (Thanks `Mogli!)
    -- We can copy all our translations to the global table because we prefix everything with guidanceSteering_
    -- Thanks for blocking the getfenv Giants..
    local modEnvMeta = getmetatable(_G)
    local env = modEnvMeta.__index
    local global = env.g_i18n.texts
    for key, text in pairs(g_i18n.texts) do
		if string.sub( key, 1, 14 ) == "BANKMANAGEMENT" then
			global[key] = text
		end
    end
end

FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, BankManagement.saveSavegame)

addModEventListener(BankManagement)