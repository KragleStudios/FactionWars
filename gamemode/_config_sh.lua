fw.config = fw.config or {}

--how often should payroll be issued? seconds
fw.config.payrollTime = 60
--should payroll be deducted from the faction bank?
fw.config.useFactionBank = true
--should the boss have powers, allowing them to demote and remove without votes?
fw.config.bossPowers = true
--how many slots should the player get for default in their inventory?
fw.config.defaultInvSlots = 10
--should faction currency persist over restart?
fw.config.factionBankPersist = true
--should the physgun color be set as the faction's color?
fw.config.physgunColorFactionColor = true
--how many points does a faction need to capture a zone
fw.config.zoneCaptureScore = 100
--every <x> seconds score is added to the faction in control
fw.config.zoneCaptureRate =  1
