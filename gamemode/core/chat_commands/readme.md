# Chat Commands
Allows for creation and usage of chat commands throughout the serverside realm

# API
 - fw.chat.addCMD(command(with no designator), help_text, callback)
 - callback will contain all parameters designated, plus the caller
 - :addParam(name, parameter type)
 - param types include: player, bool, number, string
 - it will auto parse the string the player sent after the command

 - player will accept a username or steam id and return a player object
 - bool will accept anything and turn it to a bool
 - number will accept anything and turn it to a number
 - string will accept anything and turn it to a string

 For example
```
	fw.chat.addCMD('mock', "helptext", function(caller, targ_one, str, targ_two)
	print(targ, str)

	PrintMessage(HUD_PRINTTALK, caller:Name().." used mock! ".. targ_one:Name() .. " " .. str .. " " .. targ_two:Name())

	end):addParam('target_one', 'player'):addParam('string', 'string'):addParam('second_target', 'player')
```
- usage in game: !mock crazy "is highly in love with" STEAM_0:1:53961993
