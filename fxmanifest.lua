fx_version 'cerulean'
games {'gta5'}

author 'Jake Hamblin <jake@jakehamblin.com>'
description 'Limit access to addon vehicles in game to specific Discord users'
version '1.0.0'

dependencies {
    'oxmysql',
    'NativeUI',
}

shared_scripts {
    'config.lua',
}

client_scripts {
    '@NativeUI/NativeUI.lua',
    'client/functions.lua',
    'client/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
}