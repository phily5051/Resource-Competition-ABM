;=========================================================================================================================================================
; CASA0011 Agent Based Modelling                                                                                                                         ;
;                                                                                                                                                        ;
; Author: PHILYOUNG JEONG                                                                                                                                ;
; Date: 05.05.2023                                                                                                                                       ;
; RESOURCE COMPETITON MODEL: TO WHAT EXTENT POPULATION CONTROL AND EXPLORATORY FOOD SEARCHING ENHANCE SURVIVAL PROSPECTS OF INCOMPETENT SPECIES?         ;
;=========================================================================================================================================================



;=========================================================================================================================================================
; VARIABLES                                                                                                                                              ;
;=========================================================================================================================================================

; A List of Parameterised Global Variables
globals
[
  ;initial-number-specie1s  ; Initial Number of Species 1
  ;initial-number-specie2s  ; Initial Number of Species 2
  ;initial-number-specie3s  ; Initial Number of Species 3
  ;gained-energy-1          ; Parameterised energy absorption level of Species 1. It is also used for setting initial energy levels for each species
  ;gained-energy-2          ; Parameterised energy absorption level of Species 2. It is also used for setting initial energy levels for each species
  ;gained-energy-3          ; Parameterised energy absorption level of Species 2. It is also used for setting initial energy levels for each species
  ;specie1s-reproduce       ; Percentage of Reproduction for Species 1
  ;specie2s-reproduce       ; Percentage of Reproduction for Species 2
  ;specie3s-reproduce       ; Percentage of Reproduction for Species 3
  ;patch-regrowth-time      ; Food Regrowth time
  ;pop-controller           ; Population Threshold
  ;memory-activation        ; Switch, If true, species can remember past locations
                            ; If false, species do not remember their locations
  ;intervention-on?         ; If true, intervention is activated to control population
  ;target-search?           ; When performing exploratory-food-searching procedure, if true, species search specifically dark green patches with no turtles
                            ; if false, search patches with no turtles on
]


; 3 Types of Species which compete for the same food sources
breed [ specie1s specie1 ]  ; Species 1
breed [ specie2s specie2 ]  ; Species 2
breed [ specie3s specie3 ]  ; Species 3


; Turtle Variable
turtles-own
[
  energy                    ; Species' energy level
  memory                    ; Memory of past locations where species visited
  energy-increment          ; Species' energy absorption level. This is set by the predefined parameter "gained-energy"
                            ; This was created as a turtle variable as it is needed during the "move procedure"
                            ; where the energy absorption level of each species is inspected to determine whether to conduct exploratory-food-searching or not.
]


; Patch Variable
patches-own [ growth-time ] ; Growth rate of food


;=========================================================================================================================================================
; *Setup Procedure*: Initialisation of Food Environment and Species                                                                                      ;
;=========================================================================================================================================================

to setup

  clear-all
  setup-patch             ; Sub-procedure to initialise patches
  create-agents           ; Sub-procedure to initialise species
  reset-ticks

end

;---------------------------------------------------------------------------------------------------------------------------------------------------------
; Sub-procedures: Procedures under Setup Procedure                                                                                                       ;
;---------------------------------------------------------------------------------------------------------------------------------------------------------

;---------------------------------------------------------------------------------------------------------------------------------------------------------
; Procedure for Patch Initialisation                                                                                                                     ;
;                                                                                                                                                        ;
; This procedure sets patch colour                                                                                                                       ;
; 62 is dark green and 66 is bright green - to differentiate patches, different colours are given                                                        ;
; Patches with different colours have a different growth-time, which is predefined by the "patch-regrowth-time" parameter.                               ;

to setup-patch

  ask patches
  [
    set pcolor one-of [ 62 66 ]                    ; sets patch colour to one of given options

    ifelse pcolor = 62                             ; If patch colour is dark green,
    [ set growth-time patch-regrowth-time ]        ; Set growth-time to the user-predefined parameterised value
    [ set growth-time random patch-regrowth-time ] ; If patch colour is light green, set growth-time to a random value within patch-regrowth-time range
  ]

end
;--------------------------------------------------------------------------------------------------------------------------------------------------------;

;---------------------------------------------------------------------------------------------------------------------------------------------------------
; Procedure for Species Initialisation                                                                                                                   ;
;                                                                                                                                                        ;
; This procedure creates three types of species                                                                                                          ;
; Each species is initialised by the user-predefined parameterised initial number (Choose a value from slider in the Interface).                         ;
; Each species is born with different energy levels and energy absorption abilities (turtle variable).                                                   ;

to create-agents; this procedure creates 3 types of breeds


  ; Create species 1
  create-specie1s initial-number-specie1s    ; Parameterised number of species 1 is initialised
  [

    set shape  "circle"                      ; Species 1 is a circle shape
    set color 46                             ; Yellow-ish colour
    set size 1                               ; Size
    set energy-increment gained-energy-1     ; The energy absorption ability that a species can obtain from food, equals to the user-predefined parameter value
    set energy random (2 * gained-energy-1)  ; Initial energy levels
    setxy random-xcor random-ycor            ; Born in random coordinates, to avoid any bias in the model and mimic natural environment
    set memory []                            ; Each species has an ability to collect their past locations
  ]

  ; Create species 2
  create-specie2s initial-number-specie2s    ; Parameterised number of species 2 is initialised
  [

    set shape "arrow"                        ; Species 2 is an arrow shape
    set color 95                             ; Sky blue
    set size 1                               ; Size
    set energy-increment gained-energy-2     ; The energy absorption ability that a species can obtain from food, equals to the user-predefined parameter value
    set energy random (2 * gained-energy-2)  ; Initial energy levels
    setxy random-xcor random-ycor            ; Born in random coordinates, to avoid any bias in the model and mimic natural environment
    set memory []                            ; Each species has an ability to collect their past locations
  ]

  ; Create species 3
  create-specie3s initial-number-specie3s    ; Parameterised number of species 3 is initialised
  [

    set shape  "box"                         ; Species 3 is a box shape
    set color red                            ; Red
    set size 1                               ; Size
    set energy-increment gained-energy-3     ; The amount of energy increment that a species can obtain from food, set by user-predefined parameter value
    set energy random (2 * gained-energy-3)  ; Initial energy levels
    setxy random-xcor random-ycor            ; Born in random coordinates
    set memory []                            ; Each species has an ability to collect their past locations
  ]

end


;=========================================================================================================================================================
; *Go Procedure*: Agents behaviours and Patch characteristics                                                                                            ;
;=========================================================================================================================================================


to go

  ; If Species 1 are dead, show a pop-up message and stop
  if not any? (specie1s)
  [
    user-message "Species 1 are dead"
    stop
  ]

  ; If Species 2 are dead, show a pop-up message and stop
  if not any? (specie2s)
  [
    user-message "Species 2 are dead"
    stop
  ]

  ; If Species 3 are dead, show a pop-up message and stop
  if not any? (specie3s)
  [
    user-message "Species 3 are dead"
    stop
  ]

  if ticks = 500                            ; Stop simulation at 500 ticks, which is sufficient time to embody "warm-up" period.
  [stop]

  ask turtles
  [
    move                                    ; Species move procedure
    food-consumption                        ; An aggregated food consumption procedure of each species
    death                                   ; Death procedure
    reproduction                            ; An aggregated reproduction procedure of each species
    invisible-hand                          ; Controlling population
  ]

  ask patches [
    grow-food                               ; Food growth procedure
  ]

  tick
end


;---------------------------------------------------------------------------------------------------------------------------------------------------------
; Sub-procedures: Procedures under Go Procedure                                                                                                          ;
;---------------------------------------------------------------------------------------------------------------------------------------------------------

;---------------------------------------------------------------------------------------------------------------------------------------------------------
; Procedure for intervention                                                                                                                             ;
;                                                                                                                                                        ;
; This procedure is activated by a switch - "intervention-on?"                                                                                           ;
; If the switch is on, the population of each species is controlled under the user-predefined parameterised threshold "pop-controller".                  ;

to invisible-hand                           ; Population control procedure

  if intervention-on?                       ; If "intervention-on" true,
  [
    nature-intervention-1                   ; Keeps population under threshold
    nature-intervention-2                   ; Keeps population under threshold
    nature-intervention-3                   ; keeps population under threshold
  ]

end

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Procedure for Exploratory Food Searching                                                                                                                                    ;
;                                                                                                                                                                             ;
; **WARNING**: This procedure is computationally intensive, especially if you activate "target-search?"                                                                       ;
; It is recommended to set the energy absorption ability ("gained-energy") of **ONLY ONE SPECIES** less than 6, and others over 6.                                            ;
; To perform exploratory food searching, activate "memory-activation" first, and then choose type of food searching between target and random searching                       ;
;                                                                                                                                                                             ;
; This procedure aims to understand an exploratory food-searching behaviour of agents whose energy absorption ability is poor compared to other species                       ;
; Will searching the food in the unexplored land help these species, with poor energy absorption ability, overcome their circumstances                                        ;
; and hopefully increase their populations?                                                                                                                                   ;
;                                                                                                                                                                             ;
; This procedure is activated by a switch - "memory-activation"                                                                                                               ;
; Up to 15 last locations are stored in the memory, if the number of locations in the memory is more than 15,                                                                 ;
; the oldest location is eliminated and a new location is added to memory                                                                                                     ;
; Agents aim to obtain foods in an unexplored location which is not in the memory                                                                                             ;
; If there are locations on which there are no species at the moment, the agent checks whether it has visited the currently unoccupied patches before.                        ;
; If the patch has not been explored recently, the agent heads to the closest patch.                                                                                          ;
; If there are no potential unvisited patches available, the agent heads to the random location.                                                                              ;
; This procedure applies the concept of "habitat partitioning" from resource competition theory.                                                                              ;

to exploratory-food-searching           ; Applicable only to agents, with low energy absorption abilities, which perform exploratory food searching

  if memory-activation                  ; If true, agents can have a memory of their previously visited locations

  [
    ifelse length memory < 15           ; Memory only keeps last 15 patch locations, recently visited patches are likely to be not rich in food so try to avoid those patches
    [set memory lput patch-here memory] ; If there are less than 15 locations in the meory, add current patch to the end of a list
    [set memory but-first memory]       ; If there are 15 locations in the list, eliminate the oldest memory

    ifelse target-search?               ; If target-searching is true,
    [target-searching]                  ; Species specifically search for patches with no-turtles and rich food resources
    [random-searching]                  ; If false, species search for patches with no-turtles on
  ]
end

;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Sub-sub procedure for target-searching                                                                                                                                                         ;
; This procedure performs a smart food searching which allows for species to find out patches with no turtles and rich food resources                                                            ;
; This is only performed when "target-search" switch is ON!!                                                                                                                                     ;
; This procedure is computationally intensive and takes a bit more time as agents pinpoint only those lands with food resources                                                                  ;

to target-searching                                                                         ; Species specifically search for unoccupied patches with rich food resources

  let potential-unvisited-patches patches with [ (not any? turtles-here) and (pcolor = 62)] ; Dark green patches on which there are no turtles now
  ifelse any? potential-unvisited-patches                                                   ; If these patches exist,
  [
    foreach memory [ x ->                                                                   ; Run through previously visited locations in the memory
      ifelse (x = potential-unvisited-patches)                                              ; Check whether potential-unvisited-patches are one of the previously visited locations in the memory
      [                                                                                     ; If the locations are one of the 15 last visited locations,
        rt random 180                                                                       ; Turn right randomly within 180 degree
        fd 1                                                                                ; Forward 1
      ]
      [                                                                                     ; If the potential patch is not in the memory list?
        move-to min-one-of potential-unvisited-patches [distance myself]                    ; If the locations have not been explored before, go to the one with the shortest distance
      ]
    ]
  ]
  [                                                                                         ; If the potential unvisited patches do not exist at all
    rt random 180                                                                           ; Turn right randomly within 180
    fd 1                                                                                    ; Forward 1
  ]

end

;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Sub-sub procedure for random-searching                                                                                                                                                         ;
; This procedure performs a random food searching which allows for species to find out patches with no turtles                                                                                   ;
; This is only performed when "target-search" switch is OFF!!                                                                                                                                    ;


to random-searching                                                                         ; Species search for patches on which there are no turtles now

  let potential-unvisited-patches patches with [ (not any? turtles-here) ]                  ; Patches on which there are no turtles now
  ifelse any? potential-unvisited-patches                                                   ; If these patches exist
  [
    foreach memory [ x ->                                                                   ; Run through previously visited locations in the memory
      ifelse (x = potential-unvisited-patches)                                              ; Check whether potential-unvisited-patches are one of the previously visited locations in the memory
      [                                                                                     ; If the locations are one of the 15 last visited locations,
        rt random 180                                                                       ; Turn right randomly within 180 degree
        fd 1                                                                                ; Forward 1
      ]
      [                                                                                     ; If the potential patch is not in the memory list?
        move-to min-one-of potential-unvisited-patches [distance myself]                    ; If the locations have not been explored before, go to the one with the shortest distance
      ]
    ]
  ]
  [                                                                                         ; If the potential unvisited patches do not exist at all
    rt random 180                                                                           ; Turn right randomly within 180
    fd 1                                                                                    ; Forward 1
  ]

end

;----------------------------------------------------------------------------------------------------------------------------------------------------------------
; Move procedure                                                                                                                                                ;
;                                                                                                                                                               ;
; If you want to test the exploratory food searching procedure                                                                                                  ;
; Please set the "energy-gained" (energy absorption level) parameter of only one species below **6**!!                                                          ;
; You may experiment with three species with energy absorption levels less than 6.                                                                              ;
; But it is recommended to experiment with only one species with energy-increment below 6 as it is computationally heavy!!                                      ;

to move                                                                  ; Agent random movement procedure

  let energy-list (list gained-energy-1 gained-energy-2 gained-energy-3) ; Creates a list which contains energy absorption ability of all species
  foreach energy-list [ y ->                                             ; Run through each energy absorption abilities of each species
    ifelse (y <= 6)                                                      ; If the energy absorption ability of a species is less than 6,
    [ ask (breed with [energy-increment = y])                            ; Ask breeds whose energy absorption ability is less than 6,
      [ exploratory-food-searching ]                                     ; To perform exploratory food searching procedure
    ]
    [                                                                    ; If the energy absorption ability is over 6, exploratory food searching is not performed
      rt random 180                                                      ; Turn right randomly within 180 degrees
      lt random 180                                                      ; Turn left randomly within 180 degrees
      fd 1                                                               ; Forward 1
    ]
  ]
  set energy (energy - 1)                                                ; Species lose energy by 1 when they move at each tick

end

;----------------------------------------------------------------------------------------------------------------------------------------------------------------
; Species' food consumption procedure                                                                                                                           ;
;                                                                                                                                                               ;

to food-consumption                                                     ; Aggregated food consumption procedures of each species

  if breed = specie1s                                                   ; Food consumption procedure for species 1
  [eat-food-1]

  if breed = specie2s                                                   ; Food consumption procedure for species 2
  [eat-food-2]

  if breed = specie3s                                                   ; Food consumption procedure for species 3
  [eat-food-3]

end

to eat-food-1                                                            ; Species 1 consumes dark green patches
                                                                         ; When species 1 eats food, it changes the patch color to bright green
  if breed = specie1s
  [
    if pcolor = 62                                                       ; If patch color is dark green
    [
      set pcolor 66                                                      ; When species eat food, it changes patch colour to bright green
      set energy (energy + gained-energy-1)                              ; Food consumption increases species' energy in accordance with its energy absorption ability
    ]
  ]
end

to eat-food-2                                                            ; Species 2 consumes on dark green patches

  if breed = specie2s
  [
    if pcolor = 62                                                       ; If patch color is dark green
    [
      set pcolor 66                                                      ; When species eat food, it changes patch colour to bright green
      set energy (energy + gained-energy-2)                              ; Food consumption increases species' energy in accordance with its energy absorption ability
    ]
  ]
end

to eat-food-3                                                            ; Species 3 consumes on dark green patches

  if breed = specie3s
  [
    if pcolor = 62                                                       ; If patch color is dark green
    [
      set pcolor 66                                                      ; When species eat food, it changes patch colour to bright green
      set energy (energy + gained-energy-3)                              ; Food consumption increases species' energy in accordance with its energy absorption ability
    ]
  ]
end

;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Species' reproduction procedure                                                                                                                                            ;
;                                                                                                                                                                            ;

to reproduction                                      ; Aggregated reproduction procedures of each species

  if breed = specie1s                                ; Reproduction procedure for species 1
  [reproduce-1]

  if breed = specie2s                                ; Reproduction procedure for species 2
  [reproduce-2]

  if breed = specie3s                                ; Reproduction procedure for species 3
  [reproduce-3]

end


to reproduce-1                                        ; Species 1 reproduction procedure
  if breed = specie1s
  [
    if random-float 100 < specie1s-reproduce          ; Probability of reproduction, specie1s-reproduce is an user-predefined parameterised reproduction rate for species 1
    [                                                 ; If the random value is less than the parameterised reproduction rate, give a birth
      set energy (energy / 3)                         ; Set energy levels for an offspring, one-third of its parent
      hatch-specie1s 1 [ rt random-float 360 fd 1 ]   ; Hatch an offspring, turn right randomly within 360, and forward 1

    ]
  ]
end

to reproduce-2                                        ; Species 2 reproduction procedure
  if breed = specie2s
  [
    if random-float 100 < specie2s-reproduce          ; Probability of reproduction, specie2s-reproduce is an user-predefined parameterised reproduction rate for species 2
    [                                                 ; If the random value is less than the parameterised reproduction rate, give a birth
      set energy (energy / 3)                         ; Set energy levels for an offspring, one-third of its parent
      hatch-specie2s 1 [ rt random-float 360 fd 1 ]   ; Hatch an offspring, turn right randomly within 360, and forward 1
    ]
  ]
end

to reproduce-3                                        ; Species 3 reproduction procedure
  if breed = specie3s
  [
    if random-float 100 < specie3s-reproduce          ; Probability of reproduction, specie3s-reproduce is an user-predefined parameterised reproduction rate for species 3
    [                                                 ; If the random value is less than the parameterised reproduction rate, give a birth
      set energy (energy / 3)                         ; Set energy levels for an offspring, one-third of its parent
      hatch-specie3s 1 [ rt random-float 360 fd 1 ]   ; Hatch an offspring, turn right randomly within 360, and forward 1
    ]
  ]
end


;------------------------------------------------------------------------------------------------------------------------------------------------------------;
; Death procedure                                                                                                                                            ;
;                                                                                                                                                            ;

to death                                              ; Turtle procedure

  if energy < 0 [ die ]                               ; If species have no energy, die

end

;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------;
; Nature intervention procedure                                                                                                                                                     ;
; This procedure aims to keep the population of species under the threshold for sustainable food environment, and impose less pressures on land                                     ;
; This subprocedure applies the concept of "density dependent" factors from resource competition theory.                                                                            ;
; The changes in the abundance and behaviour of dominant species result in coexistence of other species.                                                                            ;

to nature-intervention-1                                                       ; Population control for Species 1

  let num-specie1s (count specie1s)                                            ; Count the number of species 1
  if (num-specie1s <= pop-controller)                                          ; If the number of species 1 reaches an user-predefined parameterised threshold
  [ stop ]                                                                     ; If true, the procedure stops executing further

  let chance-to-die-specie1s ((num-specie1s - pop-controller) / num-specie1s)  ; Calculate the percentage of the exceeded number
  ask specie1s                                                                 ; divided by the number of species 1
    [
      if (random-float 1.0 < chance-to-die-specie1s)                           ; Check if the randomly generated float value between 0 and 1 is less than "chance-to-die-specie1s".
      [ die ]                                                                  ; If true, the agent is removed from the simulation using the "die" command.
    ]
end


to nature-intervention-2                                                       ; Population control for Species 2

  let num-specie2s (count specie2s)                                            ; Count the number of species 2
  if (num-specie2s <= pop-controller)                                          ; If the number of species 2 reaches an user-predefined parameterised threshold
  [ stop ]                                                                     ; If true, the procedure stops executing further

  let chance-to-die-specie2s ((num-specie2s - pop-controller) / num-specie2s)  ; Calculate the percentage of the exceeded number
  ask specie2s                                                                 ; divided by the number of species 2
  [
    if (random-float 1.0 < chance-to-die-specie2s)                             ; Check if the randomly generated float value between 0 and 1 is less than "chance-to-die-specie2s".
    [ die ]                                                                    ; If true, the agent is removed from the simulation using the "die" command.
  ]
end

to nature-intervention-3                                                       ; Population control for Species 3

  let num-specie3s (count specie3s)                                            ; Count the number of species 3
  if (num-specie3s <= pop-controller)                                          ; If the number of species 3 reaches an user-predefined parameterised threshold
  [ stop ]                                                                     ; If true, the procedure stops executing further

  let chance-to-die-specie3s ((num-specie3s - pop-controller) / num-specie3s)  ; Calculate the percentage of the exceeded number
  ask specie3s                                                                 ; divided by the number of species 3
    [
      if (random-float 1.0 < chance-to-die-specie3s)                           ; Check if the randomly generated float value between 0 and 1 is less than "chance-to-die-specie3s".
      [ die ]                                                                  ; If true, the agent is removed from the simulation using the "die" command.
    ]
end

;--------------------------------------------------------------------------------------------------------------------------------------------------------;
; Food growth procedure                                                                                                                                  ;
;                                                                                                                                                        ;

to grow-food                                   ; Patch procedure

  if pcolor = 66                               ; Patches with bright green colour, whose food consumed by species
  [
    ifelse growth-time <= 0                    ; If the growth-time of bright green patches reaches 0,
    [
      set pcolor 62                            ; Bright green patches turn to dark green patches
      set growth-time patch-regrowth-time      ; Set growth-time to that of dark green patches accordingly
    ]
    [
      set growth-time growth-time - 1          ; If the growth-time of bright green patches hasn't reached 0, subtract the growth-time by 1
    ]
  ]

end

;--------------------------------------------------------------------------------------------------------------------------------------------------------;
; Reporter                                                                                                                                               ;
;                                                                                                                                                        ;

to-report food                                 ; Report the amounts of food resources
  report patches with [pcolor = 62]            ; The amounts of available dark green patches
end

to-report specie1s-pop                         ; Report the number of Species 1
  report count specie1s                        ; The population of Species 1
end

to-report specie2s-pop                         ; Report the number of Species 2
  report count specie2s                        ; The population of Species 2
end

to-report specie3s-pop                         ; Report the number of Species 3
  report count specie3s                        ; The population of Species 3
end

to-report specie1s-energy                      ; Report the mean energy of Species 1
  report mean [energy] of specie1s             ; Mean energy levels of Species 1
end

to-report specie2s-energy                      ; Report the mean energy of Species 2
  report mean [energy] of specie2s             ; Mean energy levels of Species 2
end

to-report specie3s-energy                      ; Report the mean energy of Species 3
  report mean [energy] of specie3s             ; Mean energy levels of Species 3
end
@#$#@#$#@
GRAPHICS-WINDOW
776
10
1329
564
-1
-1
16.52
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
29
10
147
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
29
50
147
83
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
28
91
147
124
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1
511
194
544
initial-number-specie1s
initial-number-specie1s
10
15
15.0
1
1
NIL
HORIZONTAL

SLIDER
199
511
392
544
initial-number-specie2s
initial-number-specie2s
10
15
15.0
1
1
NIL
HORIZONTAL

SLIDER
400
511
593
544
initial-number-specie3s
initial-number-specie3s
10
15
10.0
1
1
NIL
HORIZONTAL

SLIDER
2
552
193
585
gained-energy-1
gained-energy-1
5
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
199
551
392
584
gained-energy-2
gained-energy-2
5
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
401
551
594
584
gained-energy-3
gained-energy-3
5
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
1
591
192
624
specie1s-reproduce
specie1s-reproduce
10
50
50.0
10
1
NIL
HORIZONTAL

SLIDER
199
591
393
624
specie2s-reproduce
specie2s-reproduce
10
50
50.0
10
1
NIL
HORIZONTAL

SLIDER
401
591
594
624
specie3s-reproduce
specie3s-reproduce
10
50
10.0
10
1
NIL
HORIZONTAL

SWITCH
776
594
940
627
intervention-on?
intervention-on?
1
1
-1000

SWITCH
957
593
1121
626
memory-activation
memory-activation
1
1
-1000

SLIDER
601
511
767
544
patch-regrowth-time
patch-regrowth-time
1
5
5.0
1
1
NIL
HORIZONTAL

SLIDER
601
552
768
585
pop-controller
pop-controller
100
1000
500.0
100
1
NIL
HORIZONTAL

PLOT
173
10
763
284
Population
Ticks
Population
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Species1" 1.0 0 -2674135 true "" "plot count specie1s"
"Species2" 1.0 0 -13791810 true "" "plot count specie2s"
"Species3" 1.0 0 -14439633 true "" "plot count specie3s"

PLOT
172
291
763
482
Mean Energy Levels
Ticks
Mean Average Levels
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Species1" 1.0 0 -2674135 true "" "plot mean [energy] of specie1s"
"Species2" 1.0 0 -13791810 true "" "plot mean [energy] of specie2s"
"Species3" 1.0 0 -13840069 true "" "plot mean [energy] of specie3s"

MONITOR
26
290
148
335
food
count food
17
1
11

MONITOR
27
134
147
179
Species 1
count specie1s
17
1
11

MONITOR
26
186
146
231
Species 2
count specie2s
17
1
11

MONITOR
26
238
146
283
Species 3
count specie3s
17
1
11

TEXTBOX
4
489
154
507
Species 1 Parameters
12
0.0
1

TEXTBOX
202
490
334
508
Species 2 Parameters
12
0.0
1

TEXTBOX
402
490
552
508
Species 3 Parameters
12
0.0
1

TEXTBOX
603
492
753
510
Global Parameters
12
0.0
1

SWITCH
1141
593
1304
626
target-search?
target-search?
1
1
-1000

TEXTBOX
779
573
929
591
Nature-intervention
12
0.0
1

TEXTBOX
958
573
1127
591
Exploratory Food Searching
12
0.0
1

TEXTBOX
1144
573
1294
591
Targeted Food Searching
12
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
