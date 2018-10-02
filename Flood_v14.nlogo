globals [
  actual-flood-height
  start-flood?
  start-evacuate?
  rise-count
  ]

turtles-own [
  target
  temp-target
  on-target?
  another-target
  another-target-distance
  despair-index  
  ]

patches-own [
  alt
  water?
  ]


to setup
  clear-all                             ;deleates all
  set-default-shape turtles "person"    ;the shape of the turtles - person
  ask patches [ set water? false ]      ;at the start, all patches are set to not be water
  create-coast                          ;it launches procedures ...
  create-water
  color-coast  
  color-water
  add-people
  set rise-count 1                      ;setup rise-count to 1                  
  reset-ticks                           ;resets time
end


to create-coast  ;it creates the coast
  ask n-of number-of-hills-before-diffuse patches [ if pxcor > 30 [ set alt 1 ] ]          ;randomly select the number of patches (as much as we set the variable) and se their height to 1 (the part where is the water is omitted)
  repeat 400 [ diffuse alt 0.2 ]           ;400 repeats the command diffuse alt 0.2, thereby patches transmit part of its height surrounding patches and creates a real landscape with a gradual height, constant 400 and 0.2 I have chosen based on practical experience
  scale-coast                                              ;because the diffuse wors only between 0 and 1, it is necessary to rescale the height range 0-1000 
  ask patches [ if pxcor <= 15 [ set alt 0 ] ]          ; height of patches is set to 0, where the water will be later
end


to create-water   ;it create the water
  ask patches [ if alt < 100 and pxcor <= 50 [ set water? true ] ]  ;for the first 50 patches with height under 100 on the x sets the variable water to true
  ask patches [ if water? = true [ set alt -1 ] ]  ; patches with variable water = true sets the height - 1, for another rescale
  scale-coast-final ;final coast scale
end


to scale-coast 
  let low [alt] of min-one-of patches [alt]   ;low - the lowest height of the patch  
  let high [alt] of max-one-of patches [alt]  ;high - the highest height of the patch   
  let range high - low                        ;range = disctinction between high and low                    

  ask patches [                    ;rescale by the range to 0-1000
    set alt alt - low                  
    set alt alt * 1000 / range         
    ]
end


to scale-coast-final ;rescale the final coast by the range 
  let xlow [alt] of min-one-of (patches with [water? != true]) [alt]  ;xlow - the lowest height of the patch   
  let xhigh [alt] of max-one-of (patches with [water? != true]) [alt] ;high - the highest height of the patch    
  let xrange xhigh - xlow                                             ;range = disctinction between high and low  

  ask patches [ 
    if water? != true [
      set alt alt - xlow                   
      set alt alt * 1000 / xrange          
      ]
    ]
end


to color-coast ; color patches by its height
  ask patches [ if alt >= 0 and alt < 050 [ set pcolor 51] ]
  ask patches [ if alt >= 050 and alt < 100 [ set pcolor 52] ]
  ask patches [ if alt >= 100 and alt < 150 [ set pcolor 53] ]
  ask patches [ if alt >= 150 and alt < 200 [ set pcolor 54] ]
  ask patches [ if alt >= 200 and alt < 250 [ set pcolor 55] ]
  ask patches [ if alt >= 250 and alt < 300 [ set pcolor 56] ]
  ask patches [ if alt >= 300 and alt < 350 [ set pcolor 57] ]
  ask patches [ if alt >= 350 and alt < 400 [ set pcolor 47] ]
  ask patches [ if alt >= 400 and alt < 450 [ set pcolor 46] ]
  ask patches [ if alt >= 450 and alt < 500 [ set pcolor 45] ]
  ask patches [ if alt >= 500 and alt < 550 [ set pcolor 44] ]
  ask patches [ if alt >= 550 and alt < 600 [ set pcolor 43] ]
  ask patches [ if alt >= 600 and alt < 650 [ set pcolor 42] ]
  ask patches [ if alt >= 650 and alt < 700 [ set pcolor 36] ]
  ask patches [ if alt >= 700 and alt < 750 [ set pcolor 35] ]
  ask patches [ if alt >= 750 and alt < 800 [ set pcolor 34] ]
  ask patches [ if alt >= 800 and alt < 850 [ set pcolor 33] ]
  ask patches [ if alt >= 850 and alt < 900 [ set pcolor 32] ]
  ask patches [ if alt >= 900 and alt < 950 [ set pcolor 31] ]
  ask patches [ if alt >= 950 and alt <= 1000 [ set pcolor 30] ] 
end

to color-water ;color everything what is water to 104 blue
  ask patches [ if water? = true [ set pcolor 104 ] ] 
end


to add-people
  ask n-of number-of-people (patches with [water? != true]) ;the required number of people is born on the land and their properties are set
    [ sprout 1 [ set on-target? false 
                 set color orange
                 set despair-index 0 ] 
    ] 
end


to move ;ensures the movement of people before the start of the floods, randomly turns left and right, if it is not pointed at the wall and into the water they move, otherwise they turns
  ask turtles [
    rt random 50
    lt random 50
    ifelse patch-ahead 1 != nobody 
      [ ifelse [water?] of patch-ahead 1 = true
        [ lt random-float 360 ]
        [ fd 1 ] 
      ]
      [ lt random-float 360 ]
    ] 
end


to start-flood-and-evacuate ;starts the flood and the evacuation
  set start-flood? true ;launch the flood
  set start-evacuate? true ;launch the evacuation 
end


to water_rise ; increase the flood height
  ask patches [ 
    if water? = true and alt < max-flood-height [ ;if the patch is water and it has lower height than the maximum one its surroundings its flooded, with respect of the border patches
      if pycor < 160 [
        ask patch-at-heading-and-distance 0 1 [ if alt < actual-flood-height + flood-height-step [ set water? true ] ] 
        ] 
      if pxcor < 160 [
        ask patch-at-heading-and-distance 90 1 [ if alt < actual-flood-height + flood-height-step  [ set water? true ] ] 
        ]
      if pycor > 0 [
        ask patch-at-heading-and-distance 180 1 [ if alt < actual-flood-height + flood-height-step  [ set water? true ] ] 
        ]    
      if pxcor > 0 [
        ask patch-at-heading-and-distance 270 1 [ if alt < actual-flood-height + flood-height-step  [ set water? true ] ] 
        ]
      ] 
  ]
   
  if ticks / rise-speed = rise-count [ ;increase of the height of the flood it will be done when its run by rise-speed
    ifelse actual-flood-height + flood-height-step < max-flood-height ;actual height can not be higher than the maximum one
      [ set actual-flood-height actual-flood-height + flood-height-step 
        set rise-count rise-count + 1   
        ]
      [ set actual-flood-height max-flood-height
        set rise-count rise-count + 1                
        ]
    ]

   color-water ; color the water
end


to evacuate
  
    
  ask turtles [
    
    ask self [ if water? = true [ die ] ] ; if person is drowning, he's diyng
    
    if despair-index >= max-despair-index  ; if the despair index reach its maximum, the turtle stop looking for the target and stays on the place where it is 
      [ set on-target? true
        set color red ]       
    
    ifelse target = 0 and on-target? = false ; the turtle doesn't have a target and it is not standing on it
      [ if any? patches in-radius visibility with-max [alt] [ set target max-one-of patches in-radius visibility [alt] ] ; the turtle will pick up in the visibility radius patch with the heighest altitude and set it as its target
        ] 
      [ set another-target max-one-of patches in-radius visibility [alt] ;the turtle already has a target and its looking for the better one, on the way
        set another-target-distance distance another-target 
        if another-target-distance < 20 [ set target another-target ]    ;if there is better target closer and higher, the turtle will chose the new one        
        ]
    
    ifelse distance target <= 1 and on-target? = false  ;the turtle is near the target
      [ if count turtles-on target < 1 ; there are no other turtles 
          [ move-to target ]  ; go there
          set on-target? true  ; set turtle as on the target, althrough it is only near
        ]
      [ 
        face target ;turn face to the target
        if on-target? = false 
        [ ifelse is-patch? patch-ahead 1 and count turtles-on patch-ahead 1 < 1 and [water?] of patch-ahead 1 != true   ;it the way is clear and there is no water
            [ move-to patch-here ; move to the center of the patch and make a step
              fd 1 
              ]             
            [ set temp-target one-of (neighbors with [water? != true])  ; in the case that the turtle can not make the movement to the target, it will chose random neighbor patch and if it is possible it will move there
              set despair-index despair-index + 1 ;the index of the despair will increase
              if is-patch? temp-target and count turtles-on temp-target < 1
                [ face temp-target
                  fd 1
                  ]
              ]
          ]
       ]
    ]    
 
        
end



to go
        
  ifelse start-flood? = true and start-evacuate? = true 
    [ water_rise 
      evacuate
      tick ]
    [ move ]
  
end
@#$#@#$#@
GRAPHICS-WINDOW
314
10
968
685
-1
-1
4.0
1
5
1
1
1
0
0
0
1
0
160
0
160
0
0
1
ticks
30.0

BUTTON
198
29
300
98
NIL
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
10
340
133
409
NIL
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
7
118
191
151
max-flood-height
max-flood-height
0
1000
500
1
1
NIL
HORIZONTAL

SLIDER
7
153
191
186
flood-height-step
flood-height-step
1
100
20
1
1
NIL
HORIZONTAL

MONITOR
206
117
301
162
actual_flood_hight
actual-flood-height
2
1
11

SLIDER
7
188
191
221
rise-speed
rise-speed
1
10
1
1
1
(max speed=1)
HORIZONTAL

SLIDER
5
64
190
97
number-of-people
number-of-people
1
3000
1000
1
1
NIL
HORIZONTAL

TEXTBOX
8
13
158
31
World creation parameters:
11
0.0
1

SLIDER
5
29
189
62
number-of-hills-before-diffuse
number-of-hills-before-diffuse
100
500
400
10
1
NIL
HORIZONTAL

TEXTBOX
9
104
159
122
Flood parameters:
11
0.0
1

TEXTBOX
11
325
161
343
Simulation control center:
11
0.0
1

BUTTON
178
341
302
410
start flood & evacuate
start-flood-and-evacuate
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
246
192
279
visibility
visibility
1
160
50
1
1
NIL
HORIZONTAL

MONITOR
208
236
302
281
people in safe
count turtles
17
1
11

SLIDER
10
281
192
314
max-despair-index
max-despair-index
0
50
20
1
1
NIL
HORIZONTAL

MONITOR
207
283
303
328
dead people
number-of-people - count turtles
17
1
11

TEXTBOX
10
231
160
249
People parameters:
11
0.0
1

PLOT
10
432
305
582
% dead people
NIL
NIL
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot (number-of-people - count turtles) / number-of-people * 100"

@#$#@#$#@
## WHAT IS IT?

This project simulates the process of evacuation of people living on the coast during the coming flood.

## DESCRIPTION OF THE MODEL

####Buttons
Actual flood height - actual-flood-height represents the height of the current water level
Start flood - start-flood? boolean variable, which will starts the flood coming to the ashore
Start evacuate - start-evacuate? boolean variable, which will alarm citizens and launch the evacuation of the people
Rise count - rise-count auxiliary variable for rise-speed, to determine after how many tick the water level increase by the step
Low - low is auxiliary variable in the procedure scale-coast
High - high is auxiliary variable in the procedure scale-coast
Range - range is auxiliary variable in the procedure scale-coast
Xlow - xlow is auxiliary variable for procedure scale-coast-final
Xhigh - xhigh is auxiliary variable for procedure scale-coast-final
Xrange - xrange is auxiliary variable for procedure scale-coast-final

#####Terrain creation:
Number of hills before diffuse - number-of-hills-before-diffuse is global variable which determines how many hills before diffuse will be generated at the start of the simulation
Number of people - number-of-people is global variable which determines how many people will be generated at the start of the simulation

#####Flood parameters:
Maximal flood height - max-flood-height is global variable which determines maximal height of the flood
Flood height step - flood-height-step is global variable which determines height of the step, which the flood will make
Rise speed - rise-speed is global variable which determines the speed of the rise of the water level. Every flood step will start in the second, when there is the multiple of the tick and the rise speed. 1 represents the maximal speed

#####People parameters:
Visibility - visibility is global variable determines how far can people (turtles) see, they use it by looking for the highest situated place because of the rescue.
Maximal despair index - max-despair-index represents global variable, where the failed attempts are load by looking for the target (the highest situated place). If the index reaches its maximum value, people stop looking for that place.

#####Variables of turtles (people)
Target - target is the goal patch, where the turtle after looking around want go. It is the highest point within its visibility.
On-target - on-target? - boolean variable, which tells if the turtle reach its goal patch
Another target - another-target - it is patch, substitute goal, which turtle is looking for during the way to the to target. In case of need, can use this goal instead of the previous target.
Another target distance - another-target-distance represents the distance from the turtle to another target
Despair index- despair-index represents failed attempts on the way to target
Temp target - temp-target is used, if the turtle can not reach the original way in some reason

#####Variables of patches
Alt - alt represents altitude, how hight the patches are
Water - water? is boolean variable, which tells us if its water or not


## HOW DOES THE SIMULATION WORKS

At the beginnings, there is need to setup the whole world, where the simulation will run. Therefore there are the World creation parameters. In the first slider "number-of-hills-before-diffuse" there can be set the number of actual hills from 100 to 500. In the second slider "number-of-people" there can be the number of actual population set. It could be from the 1 to 3000 citizens.
There is also need to setup the flood parameters. There could be maximum flood height setup from 0 to 1000 and flood height step from 1 to 100. You can also setup the rise-speed from 1 to 10. Global variable rise speed works backwards it means, if you setup the rise speed as 1 the speed will be actually maximal. Rise speed = 2, 2 ticks = 1 step.
We can also set the people parameters. How far can people see tells the visibility, which is set to 50 by default. The highest visibility means the biggest chance to find the highest place, but it means the possibility of the longer way there. Despair index is set to 20 by default. So the people can have 20 difficulties, it means the bigger chance to live, but it means the longer time with looking for the way. It is directly proportional to the number of generated people.
By the pressing the Go button the world starts living. People will randomly move and when the start flood & evacuate button is pressed, water start rising and people starts evacuate.
For the new simulation stop the Go button and press the Setup button.
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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
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
