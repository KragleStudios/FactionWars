# Money Entity
Pretty simple, to spawn money like this just spawn the entity like you normally would and then run ent:SetValue(int Value) on the entity.

# Functions
- self:SetValue(int Value): Sets the value of the money
- self:GetValue(): Returns the amount of money on the entity

# Remarks
Don't change the money model unless you are going to change the draw function, or you'll have some funky 3D2D text.
