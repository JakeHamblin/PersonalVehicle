# Personal Vehicle
A FiveM script that limits access to certain vehicles by Discord ID.

## Why use this when there are already others?
While there are plenty of good resources already, I believe many of them are overly complex for what most users want to do. Many use some cumbersome config files or use a database with oxmysql that doesn't follow any standards and uses multiple tables. This is just not the way the way that you should do it, so I created a simple resource.

## How do I install this?
To install this, it's rather simple:
- Firstly, make sure that you have [NativeUI](https://github.com/FrazzIe/NativeUILua) and [oxmysql](https://github.com/overextended/oxmysql) installed. For `oxmysql`, make sure that you setup the connection string. No database import is required manually.
- Secondly, grab the latest [release](https://github.com/JakeHamblin/PersonalVehicle/releases/latest).
- Drag and drop ths `PersonalVehicle` folder into your `resources` folder. **NOTE: This resource <ins>CAN</ins> be renamed**
- Ensure/start the resource

## Why are people not seeing their vehicles?
The user who is connecting to your server **doesn't** have their Discord connected to their FiveM account. Have them follow [this](https://support.cfx.re/hc/en-us/articles/16677419444508-How-to-link-your-Discord-account) guide from the team at CFX to connect their Discord.

## How do I add a personal vehicle while in game?
To be able to add a personal vehicle while in game, you need to add a permission node to a group that administrators are assigned to. You can do so by adding the following to your `server.cfg` or `permissions.cfg` (from vMenu):
 - `add_ace group.{GROUP NAME} JakeHamblin.AddPrivateVehicle allow`

After this, you should perform a server restart. You should then be able to run the `/addPersonalVehicle` or whatever you set the `Config.SetVehicleOwnerCommand` value of in the `config.lua`.

## How do I add a personal vehicle while not in game?
You can simply use a database viewer like [HeidiSQL](https://www.heidisql.com/) or [phpMyAdmin](https://www.phpmyadmin.net/). Open the database that you've specified for `oxmysql` and open the `hamblin_vehicles` table. You should then be able to insert a record that follows this general format:

- **discordID** (`str`): Discord ID of the user you're looking to set permissions for
- **owner** (`bool`):    Is the user the owner of the vehicle?
- **name** (`str`):      Name of the vehicle
- **spawncode** (`str`): Spawncode of the vehicle

## This script doesn't have a feature I want or has a bug. What should I do?
Firstly, please <ins>**don't**</ins> contact me directly. While I appreciate that you are using my resource, I am a regular personal with a job and am currently going to college. Go to the [issues](https://github.com/JakeHamblin/PersonalVehicle/issues) tab for this repository and create an issue. This allows me to track specific issues or feature requests, branch off and complete them, and show why a specific change was made. <ins>This is how GitHub is supposed to be used.</ins>


<br><br><p align="center">
 <img src="https://jakehamblin.com/images/hosturly.png">
</p>

### Hosting Company
Are you looking for a reliable and affordable host? Well, with many years of experience working with websites, website hosting, and dedicated server hosting, I can say that I've got a pretty good idea when a host is good. [Hosturly](https://jakehamblin.com/hosturly) is up for the task. Don't trust me? Read their reviews. They've got an almost 5 star rating, and with many years in the industry, they're here to stay. Use code `JAKE` for 10% off your order.