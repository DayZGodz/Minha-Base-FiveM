fx_version 'adamant'
game 'gta5'

description 'GODZ Ecosystem - Inventory (Legacy)'

ui_page 'nui/darkside.html'

client_scripts {
	'@vrp/lib/utils.lua',
	'config/config.lua',
	'hansolo/*.lua'
}

server_scripts {
	'@vrp/lib/utils.lua',
	'config/config.lua',
	'skywalker.lua'
}

files {
	'nui/*.html',
	'nui/*.css',
	'nui/*.js'
}
