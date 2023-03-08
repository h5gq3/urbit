:: todo input sail-component

/+  ui2, agentio

|%
+$  state
  $:  buffer=tape
  ==
--
::
=|  state
=*  state  -
::
^-  sail-component:ui2
|_  [=vase children=marl bowl=sail-bowl:ui2]
::
+*  this  .
    io  ~(. agentio bowl.bowl)
::
++  on-init
  ^-  (quip card:agent:gall _this)
  :_  this
  :~
  (fact:io [%domevents !>([(crip this.bowl) ~[%keydown]])] [/event-listeners]~)
  ==
++  on-poke
  |=  [=mark =^vase]
  ^-  (quip card:agent:gall _this)
  ?+  mark  `this
    %ui
    =/  poke  !<(ui-poke:ui2 vase)
    :: ~&  poke
    ?-  -.poke
      %domevent
        ?+  +<.poke  `this
          %keydown
            :: ~&  +>.poke
            ~&  "pressed {<key:+>.poke>} key down"
            ~&  "buffer is {buffer}"
            =^  cards  this
            =/  handle-key
              ::  if key is a character, weld it to the buffer
              ?:  =(1 (lent (trip key:+>.poke)))  `this(buffer (weld buffer (trip key:+>.poke)))
              ::  if key is backspace, remove the last character from the buffer
              ?:  =("Backspace" (trip key:+>.poke))  `this(buffer (snip buffer))
              ::  if key is enter, set the seed to the buffer
              ?:  =("Enter" (trip key:+>.poke))
                ::  poke our agent with the seed
                =/  todo
                  =/  text  (crip buffer)
                  =/  priority  %normal
                  =/  done  %.n
                  [text priority done]
                :_  this(buffer "")
                :: poke our agent to add a todo
                :~
                (~(poke-self pass:io /component-poke) %noun !>([%add todo]))
                ==
              ::  otherwise, do nothing
              `this
            handle-key
              ::
            [cards this]
              ==
          ==
    ==
++  manx
:: add todo
;input(ref this.bowl, placeholder "add a todo, press enter", autofocus "true", value buffer);
--