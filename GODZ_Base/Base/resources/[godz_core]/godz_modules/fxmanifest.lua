-- Siga o modelo para unificação de resources (apenas scripts com server.lua e client.lua)
fx_version "bodacious"
game "gta5"

description "GODZ Ecosystem - Core Modules"

client_scripts {
	"@vrp/lib/utils.lua",
	"/**/client.lua",
	"config_wall.lua",
}

server_scripts {
	"@vrp/lib/utils.lua",
	"/**/server.lua",
	"config_wall.lua",
}
