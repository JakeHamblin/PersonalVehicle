fx_version 'cerulean'
games {'gta5'}

author 'Jake Hamblin <jake@jakehamblin.com>'
description 'Limit access to addon vehicles in game to specific Discord users'
version '1.0.0'

client_scripts {
    '@NativeUI/NativeUI.lua',
    'config.lua',
    'client.lua',
}

server_scripts {
    'server.lua',
}

files {
    'vehicles.json',
}