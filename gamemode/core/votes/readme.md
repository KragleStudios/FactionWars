# Vote System
Allows for creation and usage votes for certain groups on players in the serverside realm.

# API
 - fw.vote.createNew(title, description, group of players, callback function(decision, vote_data, decision_data), Yes Text, No Text, Length[seconds])

 For example
```
fw.vote.createNew("Test Vote", "This is a description", player.GetAll(),
		function(decision, voteData, decisionData)
			print("DECISION: ", decision)
		end, "Yes", "No", 15)
```
 - This will send a vote asking Yes or No to all players in the server, and will print the decision reached. 
 - Note: Length is in seconds
 - When there are multiple votes they are stacked in an accordion like fashoin in the bottom center of the player's screen.