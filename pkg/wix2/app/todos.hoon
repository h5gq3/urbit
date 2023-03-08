/-  *todos
/+  default-agent, dbug, ui2
/=  root  /app/todos/root

|%
+$  pokes
  $%  [%add =todo]
      [%remove =todo]
      [%clear ~]
      [%mark-done =todo]
  ==
+$  versioned-state
    $%  state-0
    ==
+$  state-0  [%0 =todos]
--
=|  state-0
=*  state  -
^-  agent:gall
%-  agent:dbug
%+  agent:ui2  root
|_  =bowl:gall
+*  this     .
    default   ~(. (default-agent this %|) bowl)
::
++  on-init
~&  >  'on-init'
    :_  this
  :~
  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]
  ==
++  on-save
  ^-  vase
  !>(state)
++  on-load
  ~&  >  'on-load'
  |=  =old-state=vase
  =+  !<(old-state=state-0 old-state-vase)
  `this(state old-state)
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card:agent:gall _this)
  ~&  >  'on-poke'
  ?+    mark    (on-poke:default mark vase)
      %noun
    =/  pokes=pokes
      !<(pokes vase)
    ?-    -.pokes
        %add
      :_  this(todos (snoc todos todo.pokes))
      ~
        %remove
      =/  todos=(list todo)
        %+  skip  todos
        |=  =todo
        ^-  ?
        =(todo todo.pokes)
      :_  this(todos todos)
      ~
        %clear
      :_  this(todos ~)
      ~
        %mark-done
      =/  todos=(list todo)
        %+  turn  todos
        |=  =todo
        ~&  "todo from poke"
        ~&  todo.pokes
        ?:  =(todo todo.pokes)
          todo(done !done.todo)
        todo
      :_  this(todos todos)
      ~
    ==
  ==
++  on-watch  on-watch:default
++  on-leave
  |=  path
  `this
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ~&  >  'on-peek'
  ?+    path        (on-peek:default path)
      [%x %todos ~]
    ``[%noun !>(todos)]
  ==
++  on-agent  on-agent:default
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card:agent:gall _this)
  ?+  sign-arvo  (on-arvo:default wire sign-arvo)
      [%eyre %bound *]
    ~?  !accepted.sign-arvo
      [dap.bowl 'eyre bind rejected!' binding.sign-arvo]
    [~ this]
  ==
++  on-fail   on-fail:default
--