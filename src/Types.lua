export type CallbackResult = "Success" | "Fail" | "Unknown"

export type MessageData = {
	Data: any,
	Sent: number
}

export type Server = {
	Name: string,
	Topics: { Topic },
	_subscriptions: { [string]: RBXScriptConnection },
	
	
	Schedule: (self: Server, topic: Topic, delayTime: number, data: any) -> CallbackResult,
	Subscribe: (self: Server, topic: Topic, callback: (message: MessageData) -> ()) -> CallbackResult,
	PublishBatch: (self: Server, topics: { Topic }, data: any) -> CallbackResult,
	Publish: (self: Server, topic: Topic, data: any) -> CallbackResult,
	Unsubscribe: (self: Server, topic: Topic) -> CallbackResult,
	GetTopics: (self: Server) -> { Topic },
}

export type Topic = {
	Name: string,
	ServerParent: Server,
	Subscribers: number,
	MaxSubscribers: number,
	
	SetMaxSubscriptions: (self: Topic, limit: number) -> (),
	GetSubscriptions: (self: Topic) -> number,
	GetServer: (self: Topic) -> Server,
	Destroy: (self: Topic) -> (),
}

return {}