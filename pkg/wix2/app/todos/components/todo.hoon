::  div component
::
/+  ui2, manx-tools, agentio
::
|%
+$  props
  $:  priority=?(%normal %high)
  ==
--
::
=|  checkbox-toggled=_|
=|  mouseover=_|
=|  mouseout=_|
::
^-  sail-component:ui2
|_  [vas=vase children=marl bowl=sail-bowl:ui2]
+*  this  .
    io  ~(. agentio bowl.bowl)
    pass  pass:io
    props  ;;(^props !<(* vas))  :: why does this not work?
::
++  on-init
  ^-  (quip card:agent:gall _this)
  :_  this
  :~
  (fact:io [%domevents !>([(crip this.bowl) ~[%click %mouseenter %mouseleave]])] [/event-listeners]~)
  ==
++  on-poke
  |=  [=mark =vase]

  ^-  (quip card:agent:gall _this)
  ?+  mark  `this
    %ui
    =/  poke  !<(ui-poke:ui2 vase)

    ?-  -.poke
      %domevent
        ?+  +<.poke  `this
          %click
            :: reconstruct the todo from the props
            =/  todo
              =/  text  (crip (~(get-inner-text manx-tools *^manx) children))
              =/  priority  priority.props
              =/  done  checkbox-toggled
              [text priority done]
            ::  if click poke target-id is "close", send a %remove poke to the agent
            ::
            ?:  =(+.target-id.+>.poke 'close')
              =/  card
                (~(poke-self pass:io /component-poke) [%noun !>([%remove todo])])
              [[card]~ this]
            :: toggle the checkbox
            :: ~&  "toggling checkbox"
            ::
            :: send a %mark-done poke to the agent to mark the todo as done
            =/  card
              (~(poke-self pass:io /component-poke) [%noun !>([%mark-done todo])])
            :: ~&  "children"
            :: ~&  children
            :: ~&  "reconstructed todo"
            ~&  todo
            [[card]~ this(checkbox-toggled !checkbox-toggled)]
          %mouseenter
            :: ~&  "mouseover"
            `this(mouseover &, mouseout |)
          %mouseleave
            :: ~&  "mouseout"
            `this(mouseout &, mouseover |)
          ==
    ==
  ==
++  manx
  :: ~&  children
  =/  props  ;;(^props !<(* vas))

  =/  no-of-zaps
    ?~  children  0
    %-  lent
    (scan (~(get-inner-text manx-tools *^manx) children) ;~(pfix (star ;~(less zap prn)) (star zap)))
  =/  font-size
    ?:  =(no-of-zaps 0)  "1em"
    ?:  =(no-of-zaps 1)  "1.5em"
    ?:  =(no-of-zaps 2)  "2em"
    ?:  =(no-of-zaps 3)  "2.5em"
    ?:  =(no-of-zaps 4)  "3em"
    ?:  =(no-of-zaps 5)  "3.5em"
    "1em"
  =/  style
    ?-  priority.props
      %normal  "font-weight: normal; font-size: {font-size}; line-height: 1.5em; margin: 0.5em 0; padding: 0.5em 0; border-bottom: 1px solid #eee; {?:(checkbox-toggled "text-decoration: line-through;" "")}"
      %high   "font-weight: bold; font-size: 1.5em; line-height: 1.5em; margin: 0.5em 0; padding: 0.5em 0; border-bottom: 1px solid #eee; {?:(checkbox-toggled "text-decoration: line-through;" "")}"
    ==
  =/  input  ::TODO boolean attributes need to be handled differently since they don't have a value (e.g. checked="true")
    ?:  checkbox-toggled
      :: if checkbox is toggled, add the checked attribute
      :: add tailwind classes to the input checkbox:
      :: if checkbox-toggled, add green bg
      :: add other tailwind classes: "rounded-sm"
      ;input#cbox.bg-green-500.rounded-sm.mr-1(ref this.bowl, type "checkbox", checked "true");
      :: ;input.bg-green-500(ref this.bowl, type "checkbox", checked "true");
    :: if checkbox is not toggled, don't add the checked attribute
    :: add tailwind classes to the input checkbox:
    :: if checkbox-toggled is false, add white bg
    :: add other tailwind classes: margin-right: 0.25rem
    ;input.bg-white.mr-1(ref this.bowl, type "checkbox");
    :: ;input(ref this.bowl, type "checkbox");
  =/  close-button
    ?:  mouseover
      ;span#close(ref this.bowl):"x"
    ;/  ~
  ::   :: add tailwind classes to the close button:
  ::   :: if mouseover, add red bg
  ::   :: if mouseout, add white bg
  ::   :: add other tailwind classes: "rounded-sm"
  ::   ;button.bg-white.rounded-sm(ref this.bowl)
  ::     :: add tailwind classes to the close button:
  ::     :: if mouseover, add red bg
  ::     :: if mouseout, add white bg
  ::     :: add other tailwind classes: "rounded-sm"
  ::     ;svg(ref this.bowl, xmlns "http://www.w3.org/2000/svg", viewBox "0 0 20 20", fill "currentColor")
  ::       :: add tailwind classes to the close button:
  ::       :: if mouseover, add red bg
  ::       :: if mouseout, add white bg
  ::       :: add other tailwind classes: "rounded-sm"
  ::       ;path(ref this.bowl, stroke-linecap "round", stroke-linejoin "round", stroke-width "2", d "M6 18L18 6M6 6l12 12");
  ::     ==
  ::   ==
  ::
  ::
    ;div(ref this.bowl, style "display: flex; flex-direction: row; flex: 1 1 auto; min-height: 0; overflow: auto;")
      ;+  input
        :: add tailwind classes:
        :: if checkbox-toggled, add "line-through"
        :: if priority is high, add "font-bold"
        :: if no-of-zaps is 0, add "text-sm"
        :: if no-of-zaps is 1, add "text-base"
        :: if no-of-zaps is 2, add "text-lg"
        :: if no-of-zaps is 3, add "text-xl"
        :: if no-of-zaps is 4, add "text-2xl"
        :: if no-of-zaps is 5, add "text-3xl"
      ;p
        =class  "{?:(checkbox-toggled "line-through" "")} {?:(=(priority.props %high) "font-bold" "")} {?:(=(no-of-zaps 0) "text-sm" "")} {?:(=(no-of-zaps 1) "text-base" "")} {?:(=(no-of-zaps 2) "text-lg" "")} {?:(=(no-of-zaps 3) "text-xl" "")} {?:(=(no-of-zaps 4) "text-2xl" "")} {?:(=(no-of-zaps 5) "text-3xl" "")}"
        ;*  children
    ==
    ;+  close-button
  ==
--