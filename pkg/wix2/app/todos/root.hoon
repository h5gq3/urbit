::  random number agent ui

::TODO root component should be able to be a sail component

::  import agent state structure
/-  sur=todos
/+  ui2, agentio
/~  components  sail-component:ui2  /app/todos/components

:-  components
^-  sail-component:ui2
|_  [=vase children=marl bowl=sail-bowl:ui2]
::
+*  this  .
    agent-state  !<(state:sur vase)
    io  ~(. agentio bowl.bowl)

::
++  on-init
  ^-  (quip card:agent:gall _this)
  `this
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
            ~&  "clicking at root"
            `this
          ==
      ==
    ==

++  manx
:: position the component in center of screen using tailwind classes
;div.absolute.inset-0.flex.flex-col.justify-center.items-center
  ;div.bg-white.rounded-lg.shadow-lg.max-w-lg
    ;div.p-4
      ;h2.text-2xl.font-bold.m-0
        ;span.text-gray-500.mr-1
          ;i.fas.fa-check-square;
        ==
        ;span(ref this.bowl): todos
      ==
      ;div.mt-4
        ;todoinput;
        ;todocontainer(props (s:ui2 todos.agent-state));
      ==
    ==
  ==
==
--