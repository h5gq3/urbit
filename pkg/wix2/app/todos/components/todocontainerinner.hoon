::  random number agent ui

::TODO root component should be able to be a sail component

::  import agent state structure
/+  ui2, agentio

^-  sail-component:ui2
|_  [=vase children=marl bowl=sail-bowl:ui2]
::
+*  this  .
    io  ~(. agentio bowl.bowl)

::
++  on-init
  ^-  (quip card:agent:gall _this)
  `this
  ::   :_  this
  :: :~
  :: (fact:io [%domevents !>([(crip this.bowl) ~[%click]])] [/component-init]~)
  :: ==
++  on-poke
  |=  [=mark =^vase]
  ^-  (quip card:agent:gall _this)
  :: handle click
    ?+  mark  `this
    %ui
    =/  poke  !<(ui-poke:ui2 vase)

    ?-  -.poke
      %domevent
        ?+  +<.poke  `this
          %click
            ~&  "clicking at todocontainerinner"
            `this
          ==
      ==
    ==
++  manx
;div
 ;p: "inner container"
==
--