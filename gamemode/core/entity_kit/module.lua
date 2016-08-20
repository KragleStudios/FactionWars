--
-- This module defines a bunch of utilities to be used by entities
--

fw.entity_kit = {}

fw.dep(CLIENT, '3d2d')
fw.dep(CLIENT, 'hook')

fw.include_cl 'entity_ui_cl.lua'
fw.include_sh 'shared_utils_sh.lua'
