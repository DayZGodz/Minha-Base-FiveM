fx_version 'adamant'
game 'gta5'

description 'GODZ Ecosystem - Identity & Character Creation'
author 'GODZ DEV TEAM'
contact 'E-mail: contato@ziraflix.com - Discord: discord.gg/ziraflix'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js'
}

client_scripts {
	'@vrp/lib/utils.lua',
	'hansolo/*.lua'
}

server_scripts {
	'@vrp/lib/utils.lua',
	'skywalker.lua'
}