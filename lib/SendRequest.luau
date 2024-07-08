local RunService = game:GetService("RunService")

local Bridge = require("@yetanothernet/Bridge")
type Bridge = Bridge.Bridge

type Recipient = Bridge.Recipient
type IncomingPacket = Bridge.IncomingPacket
type OutgoingPacket = Bridge.OutgoingPacket

type IncomingQueue = Bridge.IncomingQueue
type OutgoingQueue = Bridge.OutgoingQueue

type NetServer = Bridge.NetServer

local Identifier = require("@yetanothernet/Identifier")
export type Identifier = Identifier.Identifier

--[=[
	@class SendRequest
	@since v0.4.0

	Allows for modification of queued packets before they're sent.
]=]
type SendRequestImpl = {
	_outgoingQueue: { OutgoingPacket },
	_position: number,

	__index: SendRequestImpl,

	to: (self: SendRequest, recipient: Recipient) -> (),
}

export type SendRequest = typeof(setmetatable({}, {} :: SendRequestImpl))

local SendRequest: SendRequestImpl = {} :: SendRequestImpl
SendRequest.__index = SendRequest

--[=[
	@method to
	@within SendRequest

	Modifies the recipients of the packet to the one(s) provided in the parameter.

	@param recipient { Player } | Player | "NET_SERVER"
]=]
function SendRequest:to(recipient: Recipient)
	if RunService:IsRunning() and RunService:IsClient() then
		warn("You should not use the SendRequest:to() method on the Client")
	end

	local position = self._position

	local packet = self._outgoingQueue[position]
	local newPacket = {
		channel = packet.channel,
		identifier = packet.identifier,
		recipient = recipient,
		data = packet.data,
	}

	self._outgoingQueue[position] = newPacket

	return
end

return SendRequest
