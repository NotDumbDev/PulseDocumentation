# Pulse
**A Structured & Reliable Messaging Layer for Roblox**

Pulse is a lightweight framework built on top of Roblox's [`MessagingService`](https://create.roblox.com/docs/reference/engine/classes/MessagingService).  
It turns raw publish / subscribe into **servers**, **topics**, and **utilities** that make cross server communication **organized, reliable, and extensible**.  

---

## ✨ Features
- **Smart Subscriptions** – Safely subscribe, unsubscribe, and track listeners.  
- **Safe & Reliable** – Extra guardrails on top of `MessagingService` to reduce errors.  
- **Extensible by Design** – Add utilities without fighting the API.  
- **Simple API** – Learn it in minutes, scale it with ease.  

---

## 📦 Installation
### Roblox Studio
1. [Download Pulse here](https://create.roblox.com/store/asset/90476891179690/Pulse).  
2. Put the Module into `ServerScriptService`.  

> Rojo/Wally installation workflow isn't supported yet.

---

## Quick Start

```lua
local Pulse = require(path.to.Pulse)

-- Create a new server
local MyServer = Pulse.newServer("MainServer")

-- Create a topic
local Announcements = Pulse.newTopic(MyServer, "Announcements")

-- Subscribe to the topic
MyServer:Subscribe(Announcements, function(data)
    print("Received:", data.Data)
end)

-- Publish data to the topic
MyServer:Publish(Announcements, "Hello World!")
```

## 📖 Documentation
Full documentation can be found here: [Documentation](https://notdumbdev.github.io/PulseDocumentation/)
