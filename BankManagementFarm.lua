BankManagementFarm = {}
local BankManagementFarm_mt = Class(BankManagementFarm)


function BankManagementFarm.new()
	if BankManagement.debug then
		print("----BankManagementFarm.new")
	end
	local self = {}
	setmetatable(self, FarmStats_mt)
	self.farmId = 0
	self.money = 1000000.0
	self.loan = 5000.0
	self.minLoan = 500000
	self.maxLoan = 3000000
	self.loanAnnualInterestRate = 0.04
	self.equity = 0
	self.equityLoanRatio = 0.8
	self.creditAmountChange = 1
	return self
end

function BankManagementFarm:delete()
	g_currentMission:removeUpdateable(self)
end