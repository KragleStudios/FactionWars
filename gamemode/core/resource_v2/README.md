# Resources
Resources are a system

# Entity Configuration
Each entity may define (or not) any of the following tables:
 - ENT.ConsumesResources
 - ENT.GeneratesResources
on it's base. Individual entities may also set the field
 - self.CurrentStorage
to indicate that they are essentially a battery or gas canister for that resource and when the resource
is used it will be taken away from the entity's CurrentStorage table

Money Printer Example:
```Lua
ENT.ConsumesResources = {
  ['electricity'] = 2, -- a printer consumes electricity
  ['water'] = 1, -- if water is available a printer will cool itself
}
ENT.GeneratesResources = {
  ['heat'] = 1, -- thermal recycler can use heat to produce a bit of extra energy if you want efficiency
}
```

Gas Canister Example
```Lua
function ENT:Initialize()
  ...
  self.CurrentStorage = {
    ['gas'] = 100, -- 100 units of gasoline that a printer can consume
  }
```

# Registration
When a resource is registered it must be registered both server side and client side.
```
fw.resource.register('electricity', {
  ...
})
```
