--!strict

local RunService = game:GetService("RunService")
local MessagingService = game:GetService("MessagingService")

--| Types |--
local Types = require(script.Parent.Types)

type Server = Types.Server
type Topic = Types.Topic
type CallbackResult = Types.CallbackResult

--| Private Functions |--
local ogWarn = warn
local function warn(message: string, showName: boolean?)
	showName = showName or false
	if RunService:IsStudio() then
		if showName then
			ogWarn(`[PULSE] {message}`)
		else
			ogWarn(message)
		end
	end
end

local ogAssert = assert
local function assert(value: any, message: string?, keepStack: boolean?)
	keepStack = keepStack or false
	if not value then
		local level = keepStack and 1 or 0
		error(message or "Assertion failed.", level)
	end
	return value
end

-- makes the pcall error sybau for other functions (#### you roblox its been 3 years fix it already)
local function try<T>(fn: () -> () | any): (boolean, T?)
	local success, result = pcall(fn)
	return success, result
end

--| CLASSES |--

local ServerMethods = {}
ServerMethods.__index = ServerMethods

local TopicMethods = {}
TopicMethods.__index = TopicMethods

--| PUBLIC API |--
local Public = {}
local ServersCache: { [string]: Server } = {}
local TopicCache: { [string]: Topic } = {}

if RunService:IsClient() then
	warn("Pulse can only be used on the server.", true)
end

--[=[
	@method newServer
	@within Pulse
	@param serverName string -- The name of the server
	@returns Server
	
	Creates a new server and returns it.
]=]
function Public.newServer(serverName: string): Server
	assert("Please pass a server name for the server")
	assert(not ServersCache[serverName], `Server '{serverName}' already exists.`)
	
	local server: Server = {
		Name = serverName,
		Topics = {},
		_subscriptions = {}
	} :: any
	setmetatable(server, ServerMethods)
	ServersCache[serverName] = server
	return server
end

--[=[
	@method newTopic
	@within Pulse
	@param server Server -- The server object
	@param topicName string -- The name of the topic
	@returns Topic
	
	Creates a new server and returns it.
]=]
function Public.newTopic(server: Server, topicName: string): Topic
	assert(server, "Please pass a server instance for the topic.")
	assert(topicName, "Please pass a topic name for the topic.")
	assert(not TopicCache[topicName], `Topic '{topicName}' already exists.`)
	
	
	local topic: Topic = {
		Name = topicName,
		ServerParent = server,
		Subscribers = 0,
		MaxSubscribers = tonumber(math.huge),
	} :: any
	setmetatable(topic, TopicMethods)
	table.insert(server.Topics, topic)
	
	ServersCache[server.Name] = server
	TopicCache[topic.Name] = topic
	
	return topic
end

--[=[
	@method GetServer
	@within Pulse
	@param serverName string -- The name of the server
	@returns Server
	
	Returns a server object if one is found.
]=]
function Public.GetServer(serverName: string): Server?
	assert(serverName, "Please pass the name of the server you want to get")
	for _, srvr in pairs(ServersCache) do
		if srvr.Name == serverName then
			return srvr
		end
	end
	warn(`Server '{serverName}' does not exist.`, true)
	return nil
end

--[=[
	@method GetTopic
	@within Pulse
	@param topicName string -- The name of the topic
	@returns Server
	
	Returns a topic object if one is found.
]=]
function Public.GetTopic(topicName: string): Topic?
	assert(topicName, "Please pass the name of the server you want to get")
	for _, tpic in pairs(TopicCache) do
		if tpic.Name == topicName then
			return tpic
		end
	end
	warn(`Topic '{topicName}' does not exist.`, true)
	return nil
end


--[=[
	@method GetTopics
	@within Pulse
	@returns {Topic}
	
	Returns an array of all created topics across all servers.
]=]
function Public.GetTopics(): { Topic }
	local topics = {}
	for _, topic in pairs(TopicCache) do
		table.insert(topics, topic)
	end
	return topics
end

--[=[
	@method GetServers
	@within Pulse
	@returns {Server}
	
	Returns an array of all created servers.
]=]
function Public.GetServers(): { Server }
	local servers = {}
	for _, server in pairs(ServersCache) do
		table.insert(servers, server)
	end
	return servers
end

--| SERVER API |--

--[=[
	@method Subscribe
	@within Server
	@param topic Topic -- The topic to subscribe to
	@param callback function -- Function to call when message is received
	@returns CallbackResult
	
	Subscribes the server to a topic with the provided callback function.
	The callback will receive a message object with Data and Sent properties.
]=]
function ServerMethods:Subscribe(topic: Topic, callback: any): CallbackResult
	--print("Subscribed to", topic.Name)
	local success, result = try(function()
		local name = topic.Name
		assert(topic.Subscribers < topic.MaxSubscribers, `Topic '{name}' has reached its max subscription limit.`, false)
		local subscription = MessagingService:SubscribeAsync(name, callback)

		self._subscriptions[name] = (self._subscriptions[name] or {}) :: any
		self._subscriptions[name] = subscription

		topic.Subscribers = (topic.Subscribers or 0) + 1
	end)
	
	if success then
		return "Success"
	else
		warn(`Failed to subscribe to topic '{topic.Name}': {result}`, true)
		return "Fail"
	end
end

--[=[
	@method Unsubscribe
	@within Server
	@param topic Topic -- The topic to unsubscribe from
	@returns CallbackResult
	
	Unsubscribes the server from the specified topic.
]=]
function ServerMethods:Unsubscribe(topic: Topic): CallbackResult
	local subscriptions = self._subscriptions
	if not subscriptions[topic.Name] then
		warn(`Server: '{self.Name}' isn't subscribed to topic: '{topic.Name}'`, true)
		return "Fail"
	end
	
	local subscription: RBXScriptConnection = subscriptions[topic.Name]
	subscription:Disconnect()
	subscriptions[topic.Name] = nil
	topic.Subscribers = math.max((topic.Subscribers or 1) - 1, 0)
	return "Success"
end

--[=[
	@method Publish
	@within Server
	@param topic Topic -- The topic to publish to
	@param data any -- The data to send
	@returns CallbackResult
	
	Publishes data to the specified topic immediately.
]=]
function ServerMethods:Publish(topic: Topic, data: any): CallbackResult
	assert(data, "Please pass some data to publish.")
	local success, result = try(function()
		return MessagingService:PublishAsync(topic.Name, data)
	end)
	
	if success then
		return "Success"
	else
		warn(`Failed to Publish to topic '{topic.Name}': {result}`, true)
		return "Fail"
	end
end

--[=[
	@method PublishBatch
	@within Server
	@param topics {Topic} -- Array of topics to publish to
	@param data any -- The data to send to all topics
	@returns CallbackResult
	
	Publishes the same data to multiple topics simultaneously.
	Returns "Unknown" since operations are asynchronous.
]=]
function ServerMethods:PublishBatch(topics: { Topic }, data: any): CallbackResult
	assert(topics, "Please pass some topics to publish data.")
	assert(data, "Please pass some data to publish.")
	--print(topics)
	for _, topic in pairs(topics) do
		task.spawn(function()
			local success, result = try(function()
				return MessagingService:PublishAsync(topic.Name, data)
			end)

			if success then
				return "Success"
			else
				warn(`Failed to Publish to topic '{topic.Name}': {result}`, true)
				return "Fail"
			end
		end)
		--break
	end
	
	return "Unknown"
end

--[=[
	@method Schedule
	@within Server
	@param topic Topic -- The topic to publish to
	@param delayTime number -- Delay in seconds before publishing
	@param data any -- The data to send
	@yields
	@returns CallbackResult
	
	Schedules a message to be published after the specified delay.
	Returns "Unknown" since the operation is asynchronous.
]=]
function ServerMethods:Schedule(topic: Topic, delayTime: number, data: any): CallbackResult
	assert(data, "Please pass some data to publish.")
	delayTime = delayTime or 1
	
	task.delay(delayTime ,function()
		local success, result = try(function()
			return MessagingService:PublishAsync(topic.Name, data)
		end)

		if success then
			return "Success"
		else
			warn(`Failed to Publish to topic '{topic.Name}': {result}`, true)
			return "Fail"
		end
	end)
	
	return "Unknown"
end

--[=[
	@method GetTopics
	@within Server
	@returns {Topic}
	
	Returns an array of all topics associated with this server.
]=]
function ServerMethods:GetTopics(): {Topic}
	return self.Topics
end

--| TOPIC API |--

--[=[
	@method GetServer
	@within Topic
	@returns Server?
	
	Returns the server that owns this topic.
]=]
function TopicMethods:GetServer(): Server?
	return self.ServerParent
end

--[=[
	@method Destroy
	@within Topic
	
	Destroys the topic, removing it from its server and the global cache.
]=]
function TopicMethods:Destroy()
	local cache: any = ServersCache[self.ServerParent.Name].Topics
	for topicNum, topic: Topic in pairs(cache) do
		if topic.Name == self.Name then
			topicNum = topicNum :: number -- doing this so it silences it below
			table.remove(cache, topicNum)
			break
		end
	end

	TopicCache[self.Name] = nil
end

--[=[
	@method GetSubscriptions
	@within Topic
	@returns number
	
	Returns the current number of active subscribers to this topic.
]=]
function TopicMethods:GetSubscriptions(): number
	return self.Subscribers
end

--[=[
	@method SetMaxSubscriptions
	@within Topic
	@param limit number -- Maximum number of allowed subscribers
	
	Sets the maximum number of subscribers allowed for this topic.
	Don't pass a limit for infinite subscriptions.
]=]
function TopicMethods:SetMaxSubscriptions(limit: number)
	limit = limit or math.huge
	self.MaxSubscribers = limit
end

return Public