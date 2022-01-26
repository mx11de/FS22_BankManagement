--
-- BankManagementGui
-- 
-- Copyright (c) MX11 2019
--
-- @author  MX11
-- @date  	23.11.2021
-- 25.11.2021 - Optimierung der GUI
-- 06.12.2021 - Umbau von MoneyToolGui zu BankManagement
-- 20.01.2022 - Finalisierung Multiplayer-Sync
--
-- Keine Veränderung ohne meine Erlaubnis!
-- No modification without my permission!

BankManagementGui = {}
BankManagementGui.CONTROLS = {
	"boxLayout",
	"amountText",
	"equityText",	
	"equityLoanRatioText",	
	"loanText",	
	"loanAnnualInterestRateText",
	"minLoanText",
	"maxLoanText",
	"checkCreditAmountChange",
	"versionText"
}

local BankManagementGui_mt = Class(BankManagementGui, ScreenElement)

function BankManagementGui:new(guiName, modDirectory, scriptName)
	if BankManagement.debug then
		print("----BankManagementGui:new")
	end
	if custom_mt == nil then
		custom_mt = BankManagementGui_mt
	end		
	local self = ScreenElement.new(nil, custom_mt or BankManagementGui_mt)
	self:registerControls(BankManagementGui.CONTROLS)
	self.guiName = guiName
	self.optionElements = {}
	self.BankManagementData = {}
	self.moneyAmount = 1000000
	self.initialMinLoan = 500000
	self.initialMaxLoan = 3000000
	self.initialEquityLoanRatio =  0.8
	self.initialLoanInterestRate = 0.04
	self.equityLoanRatio = 0
	self.loanAnnualInterestRate = 0
	self.scriptName=scriptName
	g_gui:loadGui(modDirectory.."BankManagementGui.xml", guiName, self)
	return self
end

function BankManagementGui:onOpen(element)
	if BankManagement.debug then
		print("----BankManagementGui:onOpen")
	end
	self:assignTableTexts()
	if g_server == nil then
		if BankManagement.debug then
			print("Sync Client Request")
		end
		BankManagementUpdateClientEvent.sendEvent(g_currentMission.player.farmId)
	end	
	self.BankManagementData = BankManagement:getPlayerBankManagementFarm()
	self:updateUITexts()
	self.versionText:setText("Version: "..tostring(BankManagement.version).." - "..g_i18n:getText("BANKMANAGEMENT_COPYRIGHT"))	
    BankManagementGui:superClass().onOpen(self)
end
function BankManagementGui:updateDataFromUI()
	if BankManagement.debug then
		print("----BankManagementGui:updateDataFromUI")
		print("self.amountText:"..self.moneyAmount)
		print("self.equityText:"..self.equityText.text)
		print("self.equityLoanRatio:"..tostring(self.equityLoanRatio))
		print("self.loanText:"..self.loanText.text)
		print("self.loanAnnualInterestRate:"..tostring(self.loanAnnualInterestRate))
		print("self.minLoanText:"..self.minLoanText.text)
		print("self.maxLoanText:"..self.maxLoanText.text)
	end	
	self.BankManagementData.money = Utils.getNoNil(tonumber(self.moneyAmount), 1000000)
	self.BankManagementData.equity = g_farmManager:getFarmById(g_currentMission:getFarmId()):getEquity()
	self.BankManagementData.equityLoanRatio = Utils.getNoNil(tonumber(self.equityLoanRatio/100), self.initialEquityLoanRatio)
	self.BankManagementData.loanAnnualInterestRate = Utils.getNoNil(tonumber(self.loanAnnualInterestRate)/100, self.initialLoanInterestRate)
	self.BankManagementData.loan =  Utils.getNoNil(tonumber(self.loanText.text), 0)
	self.BankManagementData.minLoan = g_farmManager:getFarmById(g_currentMission:getFarmId()).MIN_LOAN
	self.BankManagementData.maxLoan = math.floor(Utils.getNoNil(tonumber(self.maxLoanText.text), self.initialMaxLoan)/ 5000) * 5000
	if self.BankManagementData.loan > self.BankManagementData.maxLoan then
		self.BankManagementData.maxLoan = self.BankManagementData.loan
	else
		if self.BankManagementData.maxLoan > self.initialMaxLoan then
			self.BankManagementData.maxLoan = self.BankManagementData.maxLoan
		else
			self.BankManagementData.maxLoan = MathUtil.clamp(self.BankManagementData.maxLoan,self.initialMinLoan,self.initialMaxLoan)
		end
	end
	self.BankManagementData.creditAmountChange = Utils.getNoNil(self.checkCreditAmountChange:getState(), 1)
	if BankManagement.debug then
		print("self.BankManagementData.money:"..tostring(self.BankManagementData.money))
		print("self.BankManagementData.equity:"..tostring(self.BankManagementData.equity))
		print("self.BankManagementData.loan:"..tostring(self.BankManagementData.loan))
		print("self.BankManagementData.minLoan:"..tostring(self.BankManagementData.minLoan))
		print("self.BankManagementData.maxLoan:"..tostring(self.BankManagementData.maxLoan))
	end
end	
function BankManagementGui:updateUITexts()
	if BankManagement.debug then
		print("----BankManagementGui:updateUITexts")
	end
	self:assignDynamicTexts()
	self:assignDynamicTableTexts()
end
function BankManagementGui:assignDynamicTexts()
	if BankManagement.debug then
		print("----BankManagementGui:assignDynamicTexts")
	end
	self.amountText:setText(tostring(self.BankManagementData.money))
	self.equityText:setText(g_i18n:formatMoney(g_farmManager:getFarmById(g_currentMission:getFarmId()):getEquity()))
	self.loanText:setText(tostring(self.BankManagementData.loan))
	self.minLoanText:setText(g_i18n:formatMoney(self.BankManagementData.minLoan))
	self.maxLoanText:setText(tostring(self.BankManagementData.maxLoan))	
end
function BankManagementGui:assignDynamicTableTexts()
	if BankManagement.debug then
		print("----BankManagementGui:assignDynamicTableTexts")
	end
	self.moneyAmount = self.BankManagementData.money
	self.loanAnnualInterestRate = MathUtil.round(self.BankManagementData.loanAnnualInterestRate*100,0)
	for i = 1,#self.loanAnnualInterestRatetextTable, 1 do
		if self.loanAnnualInterestRatetextTable[i] == tostring(MathUtil.round(self.BankManagementData.loanAnnualInterestRate*100,0)) then
			self.loanAnnualInterestRateText:setState(i)
		end
	end
	self.equityLoanRatio = MathUtil.round(self.BankManagementData.equityLoanRatio*100,0)
	for i = 1,#self.equityLoanRatiotextTable, 1 do
		if self.equityLoanRatiotextTable[i] == tostring(MathUtil.round(self.BankManagementData.equityLoanRatio*100,0)) then
			self.equityLoanRatioText:setState(i)
		end
	end
	self.checkCreditAmountChange:setState(self.BankManagementData.creditAmountChange)
end

function BankManagementGui:assignTableTexts()
	if BankManagement.debug then
		print("----BankManagementGui:assignTableTexts")
	end
	self.loanAnnualInterestRatetextTable = {}
	for i = 1,100, 1 do
		table.insert(self.loanAnnualInterestRatetextTable, tostring(i))
	end
	self.loanAnnualInterestRateText:setTexts(self.loanAnnualInterestRatetextTable)

	self.equityLoanRatiotextTable = {}
	for i = 5,50, 1 do
		table.insert(self.equityLoanRatiotextTable, tostring(i*10))
	end
	self.equityLoanRatioText:setTexts(self.equityLoanRatiotextTable)
end
function BankManagementGui:onCreateScroller(element, amount)
	local amount = tonumber(amount)
	self.optionElements[element] = amount
end
function BankManagementGui:onClickEquityLoanRatio(state)
	if BankManagement.debug then
		print("----BankManagementGui:onClickEquityLoanRatio")
		print("state:"..tostring(state))
	end
	self.equityLoanRatio = self.equityLoanRatiotextTable[state]
end
function BankManagementGui:onClickloanAnnualInterestRate(state)
	if BankManagement.debug then
		print("----BankManagementGui:onClickloanAnnualInterestRate")
		print("state:"..tostring(state))
	end
	self.loanAnnualInterestRate = self.loanAnnualInterestRatetextTable[state]
end
function BankManagementGui:onClickLeft(element)
	if BankManagement.debug then
		print("----BankManagementGui:onClickLeft")
	end
	local amount = -1 * self.optionElements[element.parent]
	self.moneyAmount = self.moneyAmount + amount
	self.amountText:setText(tostring(self.moneyAmount))
end

function BankManagementGui:onClickRight(element)
	if BankManagement.debug then
		print("----BankManagementGui:onClickRight")
	end
	local amount = self.optionElements[element.parent]
	self.moneyAmount = self.moneyAmount + amount
	self.amountText:setText(tostring(self.moneyAmount))
end
function BankManagementGui:onDoubleClickAmount()
	if BankManagement.debug then
		print("----BankManagementGui:onDoubleClick")
	end
	self.moneyAmount = 0
	self.amountText:setText(tostring(self.moneyAmount))
end
function BankManagementGui:onEnterPressedAmount()
	if BankManagement.debug then
		print("----BankManagementGui:onEnterPressedAmount")
	end
	self.moneyAmount = Utils.getNoNil(self.amountText.text, 0)
end
function BankManagementGui:onClickCheckboxCreditAmountChange(state)
	if BankManagement.debug then
		print("----BankManagementGui:onClickCheckboxCreditAmountChange")
		print("state:"..tostring(state))
	end
	self.BankManagementData.creditAmountChange =  Utils.getNoNil(state, 1)
end
function BankManagementGui:onClickBack()
	if BankManagement.debug then
		print("----BankManagementGui:onClickBack")
	end
	g_gui:showGui("")
end
function BankManagementGui:onClickSave()
	if BankManagement.debug then
		print("----BankManagementGui:onClickSave")
	end
	self:updateDataFromUI()
	BankManagementEvent.sendEvent(self.BankManagementData)
	self:assignDynamicTexts()
	self:assignDynamicTableTexts()
end