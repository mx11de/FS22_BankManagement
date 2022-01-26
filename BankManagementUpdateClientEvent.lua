BankManagementUpdateClientEvent = {}
BankManagementUpdateClientEvent_mt = Class(BankManagementUpdateClientEvent, Event)

InitEventClass(BankManagementUpdateClientEvent, "BankManagementUpdateClientEvent")

function BankManagementUpdateClientEvent.emptyNew()
    local self = Event.new(BankManagementUpdateClientEvent_mt)
    return self
end

function BankManagementUpdateClientEvent.new(farmId)
    local self = BankManagementUpdateClientEvent.emptyNew()
    self.farmId = farmId
    return self
end

function BankManagementUpdateClientEvent:writeStream(streamId, connection)
	if BankManagement.debug then
		print("BankManagement - DEBUG - BankManagementUpdateClientEvent:writeStream")
	end
	streamWriteInt32(streamId, self.farmId)
end

function BankManagementUpdateClientEvent:readStream(streamId, connection)
	if BankManagement.debug then
		print("BankManagement - DEBUG - BankManagementUpdateClientEvent:readStream")	
	end
	self.farmId = streamReadInt32(streamId)
	self:run(connection)
end

function BankManagementUpdateClientEvent:run(connection)
	if BankManagement.debug then
		print("BankManagement - DEBUG - BankManagementUpdateClientEvent:run")
	end
    if g_server ~= nil then
		if BankManagement.debug then
			print("BankManagement - DEBUG - BankManagementUpdateClientEvent:run SendToClient")
		end
		BankManagementEvent.sendToClient(connection, BankManagement:getFarmFromBankManagementData(farmId))
	end
end

function BankManagementUpdateClientEvent.sendEvent(farmId)
	if g_server == nil then
		g_client:getServerConnection():sendEvent(BankManagementUpdateClientEvent.new(farmId))
	end
end