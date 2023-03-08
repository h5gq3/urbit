::  random number agent ui

::TODO root component should be able to be a sail component

::  import agent state structure
/-  sur=todos
/+  ui2

^-  sail-component:ui2
|_  [=vase children=marl bowl=sail-bowl:ui2]
::
+*  this  .
    todos  ;;(todos:sur !<(* vase))
::
++  on-init
  ^-  (quip card:agent:gall _this)
  `this
++  on-poke
  |=  [=mark =^vase]
  ^-  (quip card:agent:gall _this)
  `this
++  manx
;div
 ;*  (turn todos |=(=todo:sur ;todo(props (s:ui2 priority.todo)):"{(trip text.todo)}"))
 ;todocontainerinner;
 ;todocontainerinner;
==
--