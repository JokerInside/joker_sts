<h1 align='center'>FOR [ESX] FRAMEWORK</a></h1><p align='center'><b><a href='https://dsc.gg/SSTT'>Discord</a> - <a href='https://documentation.esx-framework.org/legacy/installation'>Documentation</a></b></h5>

## Requirements
- [joker_core](https://github.com/JokerInside/joker_core)


[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/JokerInside/joker_sts joker_sts
```
3) Import joker_sts.sql in your database
4) Add this in your server.cfg :

```
start joker_sts
```

[HOWTO]

server.lua
```lua

local name    = 'hunger'
local default = 1000000
local color   = '#CFAD0F'

TriggerEvent('joker_sts:registerStatus', name, default, color, 
	function(status) -- Visible calllback, if it return true the status will be visible
		return true
	end,
	function(status) -- Tick callback, what to do at each tick
		status.remove(200)
	end,
	{remove = 200} -- Client action (add / remove) so the client can be in sync with server
)


```
