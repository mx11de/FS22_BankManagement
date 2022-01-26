BankManagementEvent = {}
BankManagementEvent_mt = Class(BankManagementEvent, Event)

InitEventClass(BankManagementEvent, "BankManagementEvent")

function BankManagementEvent.emptyNew()
    local self = Event.new(BankManagementEvent_mt)
    return self
end

function BankManagementEvent.new(farm)
    local self = BankManagementEvent.emptyNew()
    self.bankManagementFarm = farm
    return self
end

function BankManagementEvent:writeStream(streamId, connection)
	if BankManagement.debug then
		print("BankManagement - DEBUG - BankManagementEvent:writeStream")
	end
    streamWriteInt32(streamId, self.bankManagementFarm.farmId)
	streamWriteInt32(streamId, self.bankManagementFarm.money)	
	streamWriteInt32(streamId, self.bankManagementFarm.equity)	
	streamWriteInt32(streamId, self.bankManagementFarm.loan)	
	streamWriteInt32(streamId, self.bankManagementFarm.minLoan)	
	streamWriteInt32(streamId, self.bankManagementFarm.maxLoan)		
    streamWriteFloat32(streamId, self.bankManagementFarm.equityLoanRatio)
    streamWriteFloat32(streamId, self.bankManagementFarm.loanAnnualInterestRate)
    streamWriteInt32(streamId, self.bankManagementFarm.creditAmountChange)
end

function BankManagementEvent:readStream(streamId, connection)
	if BankManagement.debug then
		print("BankManagement - DEBUG - BankManagementEvent:readStream")
	end
	self.bankManagementFarm = {}
    self.bankManagementFarm.farmId = streamReadInt32(streamId)
    self.bankManagementFarm.money = streamReadInt32(streamId)
    self.bankManagementFarm.equity = streamReadInt32(streamId)
    self.bankManagementFarm.loan = streamReadInt32(streamId)
    self.bankManagementFarm.minLoan = streamReadInt32(streamId)
    self.bankManagementFarm.maxLoan = streamReadInt32(streamId)
    self.bankManagementFarm.equityLoanRatio = streamReadFloat32(streamId)
    self.bankManagementFarm.loanAnnualInterestRate = streamReadFloat32(streamId)
    self.bankManagementFarm.creditAmountChange = streamReadInt32(streamId)
	
	self:run(connection)
end

function BankManagementEvent:run(connection)
	if BankManagement.debug then
		print("BankManagement - DEBUG - BankManagementEvent:run")
	end
    if g_server ~= nil and connection:getIsServer() == false then
        -- If the event is coming from a client, server have save it and broadcast to other clients
        -- Saving data if we are on the server
		BankManagement:updateGameDataFromBankManagementData(self.bankManagementFarm)
		BankManagementEvent.sendEvent(self.bankManagementFarm)
    else
        -- Applying data if we are on the client
		BankManagement:updatePlayerBankManagementFarm(self.bankManagementFarm)
	end
end

function BankManagementEvent.sendToClient(connection, bmdf)
	if g_server ~= nil then
		connection:sendEvent(BankManagementEvent.new(bmdf))
	end
end

function BankManagementEvent.sendEvent(bmdf)
	if BankManagement.debug then
		print("BankManagement - DEBUG - BankManagementEvent:sendEvent")
	end
	local event = BankManagementEvent.new(bmdf)
    if g_server ~= nil then
        -- Server have to broadcast to all clients and himself
		if BankManagement.debug then
			print("BankManagement - DEBUG - BankManagementEvent - Broadcast to all clients")
		end
		BankManagement:updateGameDataFromBankManagementData(bmdf)
        g_server:broadcastEvent(event, true)
    else
        -- Client have to send to server
		if BankManagement.debug then
			print("BankManagement - DEBUG - BankManagementEvent - client send to server")
		end
        g_client:getServerConnection():sendEvent(event)
    end	
end
