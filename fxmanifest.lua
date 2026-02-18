fx_version 'cerulean'
game 'gta5'

author 'tyred'
description 'tyredffa'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@qb-core/shared/items.lua',
    '@qb-core/shared/jobs.lua',
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-target'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

ui_page 'html/index.html'
