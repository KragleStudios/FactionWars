# hook
Provides a framework for hooking gamemode functions. These hooks get added to the GM table
so they will be called after all the hooks registered by addons. The order in which the hooks are added
is the same as the order in which they are called, so if you use fw.dep(module name) hooks added in
(module name) will get called before hooks in your module.

## API
 - fw.hook.Add(name, id, func) standard lua hook format
 - fw.hook.Call(name, arguments...)
 - fw.hook.Remove(name, id) removes the hook with the given name and function id