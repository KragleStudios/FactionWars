--[[

Available functions:

This function is used to allow voice over distance with /radio
- fw.group.registerVoiceGroup(TEAM_1, TEAM_2, ...)

This function used to to register Chat Groups with /group
- fw.group.registerChatGroup("Name Of Group", TEAM_1, ...)


]]--



fw.group.registerVoiceGroup(TEAM_POLICE, TEAM_MAYOR, TEAM_POLICE_CHIEF)

fw.group.registerChatGroup("Police", TEAM_POLICE, TEAM_POLICE_CHIEF, TEAM_MAYOR)