extensions [ gis nw 
  ;palette 
  gradient]

globals [ elevation-dataset ndvi-dataset m_data p_density p_density10
          road_speed road_k
          POI road_point
          boundary polygon roads water greenland inundation
          slope aspect gradient sun
          in-out
          open ; the open list of patches
          closed ; the closed list of patches
          optimal-path ; the optimal path, list of patches from source to destination
          warning-ticks
          ]
breed [ sewer-vertices sewer-vertex]
breed [ nodes node ]
breed [ boats boat ]
breed [ buses bus ]
breed [ houses house]

breed [ city-POIs city-POI ]
city-POIs-own [types]

breed [road-POIs road-POI]
road-POIs-own [Num]

breed [ peoples people ]
peoples-own [from-node to-node next-node myhome start-time move? start? age sex speed]

boats-own [ from-node to-node next-node cur-link speed i p start? start-time]
buses-own [ from-node to-node next-node cur-link speed i p start? line]

sewer-vertices-own [ route ]
breed [ walkers walker ]
walkers-own [W_location to-node cur-link speed]
patches-own [ elevation p_slope p_aspect p_ndvi fc height landuse lu_r
              rainfall droplet pheight delta_h target Hw dH Vi v h2
              manning depth runoff runoff_c river?
              NDVI LAI Smax evap Canopy infiltration   ;P F
              r_speed r_k
              ;;;A Star parameters
              parent-patch ; patch's predecessor
              f ; the value of knowledge plus heuristic cost function f()
              g ; the value of knowledge cost function g()
              h ; the value of heuristic cost function h()
              ]

; turtle variables used
turtles-own
[
  path ; the optimal path from source to destination
  current-path ; part of the path that is left to be traversed
  recieve?
  awareness
]
links-own [ weight flow]

; setup the world 
to setup_a_star
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks ;; clear everything (the view and all the variables)
  create-source-and-destination
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup
  clear-all
  ;reset-ticks ct cp cd clear-links clear-all-plots clear-output
  ;gis:load-coordinate-system (word "./data2015/cs_albers.prj")
  ;set elevation-dataset gis:load-dataset "./data2015/dem_10m.asc"
  set elevation-dataset gis:load-dataset "./data2015/fr_dem_agree_10m_1.asc"
  
  ;set elevation-dataset gis:load-dataset "./Netlogo_data/filled_dem.asc"
  set inundation gis:load-dataset "./data2015/inundation.asc"
  
  ;set ndvi-dataset gis:load-dataset "./data2015/fr_green.asc"
  
  set road_speed gis:load-dataset "./data2015/fr_roads_speed.asc"
  set road_k gis:load-dataset "./data2015/fr_roads_k.asc"
  set p_density [0.3595  0.363  0.3666  0.3702  0.374  0.3779  0.3819  0.3861  0.3903  0.3948  0.3993  0.4041  0.409  0.414  0.4193  0.4248  0.4304  0.4363  0.4425  0.4489  0.4556  0.4626  0.4699  0.4775  0.4855  0.494  0.5028  0.5122  0.522  0.5325  0.5435  0.5553  0.5678  0.5812  0.5955  0.6109  0.6275  0.6454  0.6649  0.6861  0.7094  0.7351  0.7637  0.7955  0.8314  0.8722  0.9192  0.9737  1.0382  1.1158  1.2111  1.3315  1.4893  1.7058  2.0232  2.5358  3.506  2.9811  2.6061  2.3251  2.1066  1.9319  1.7889  1.6695  1.5683  1.4814  1.4058  1.3395  1.2808  1.2284  1.1813  1.1387  1.1  1.0646  1.0321  1.0022  0.9746  0.9489  0.9251  0.9028  0.8819  0.8623  0.8439  0.8265  0.8101  0.7946  0.7798  0.7658  0.7526  0.7399  0.7278  0.7163  0.7052  0.6947  0.6845  0.6748  0.6655  0.6565  0.6478  0.6395  0.6315  0.6237  0.6163  0.609  0.6021  0.5953  0.5887  0.5824  0.5762  0.5703  0.5645  0.5588  0.5534  0.5481  0.5429  0.5378  0.5329  0.5282  0.5235  0.519  0.5146  0.5102  0.506  0.5019  0.4979  0.494  0.4901  0.4864  0.4827  0.4791  0.4756  0.4722  0.4688  0.4655  0.4622  0.4591  0.456  0.4529  0.4499  0.447  0.4441  0.4413  0.4385  0.4358  0.4331  0.4305  0.4279  0.4254  0.4229  0.4205  0.4181  0.4157  0.4134  0.4111  0.4088  0.4066  0.4044  0.4023  0.4001  0.3981  0.396  0.394  0.392  0.39  0.3881  0.3862  0.3843  0.3825  0.3806  0.3788  0.377  0.3753  0.3736  0.3719  0.3702  0.3685  0.3669  0.3653  0.3637  0.3621  0.3605]
  set p_density10 [0.3654  0.3689  0.3725  0.3763  0.3801  0.3841  0.3881  0.3924  0.3967  0.4012  0.4058  0.4107  0.4156  0.4208  0.4261  0.4317  0.4375  0.4435  0.4497  0.4562  0.463  0.4701  0.4775  0.4853  0.4935  0.502  0.511  0.5205  0.5305  0.5412  0.5524  0.5643  0.5771  0.5907  0.6052  0.6208  0.6377  0.6559  0.6757  0.6973  0.721  0.7471  0.7761  0.8085  0.845  0.8865  0.9341  0.9896  1.0551  1.1339  1.2308  1.3533  1.5136  1.7336  2.0561  2.5772  3.5632  3.0297  2.6486  2.363  2.141  1.9634  1.818  1.6967  1.5939  1.5056  1.4288  1.3614  1.3017  1.2484  1.2005  1.1572  1.1179  1.082  1.049  1.0186  0.9905  0.9644  0.9401  0.9175  0.8963  0.8763  0.8576  0.84  0.8233  0.8075  0.7925  0.7783  0.7648  0.7519  0.7397  0.7279  0.7167  0.706  0.6957  0.6858  0.6763  0.6672  0.6584  0.6499  0.6418  0.6339  0.6263  0.619  0.6119  0.605  0.5983  0.5919  0.5856  0.5796  0.5737  0.568  0.5624  0.557  0.5517  0.5466  0.5416  0.5368  0.532  0.5274  0.5229  0.5186  0.5143  0.5101  0.506  0.502  0.4981  0.4943  0.4906  0.4869  0.4833  0.4799  0.4764  0.4731  0.4698  0.4666  0.4634  0.4603  0.4573  0.4543  0.4514  0.4485  0.4457  0.4429  0.4402  0.4375  0.4349  0.4323  0.4298  0.4273  0.4249  0.4225  0.4201  0.4178  0.4155  0.4132  0.411  0.4088  0.4067  0.4046  0.4025  0.4004  0.3984  0.3964  0.3944  0.3925  0.3906  0.3887  0.3868  0.385  0.3832  0.3814  0.3797  0.3779  0.3762  0.3745  0.3729  0.3712  0.3696  0.368  0.3664]
  
  set in-out (list node 29 node 53 node 76 node 87 node 96 node 98 node 101 node 129 node 102 node 108 node 3 node 110 node 109 node 90 node 85 node 74 node 28)
  
  set m_data gis:load-dataset "./data2015/fr_manning_10.asc"           ;;./Netlogo_data/manning.asc"

  set boundary gis:load-dataset "./data2015/boundary.shp"
  set polygon gis:load-dataset "./data2015/fr_poly.shp"
  set roads gis:load-dataset "./data2015/fr_roads0.shp"    
  set water gis:load-dataset "./data2015/water.shp"
  set greenland gis:load-dataset "./data2015/greenland.shp"
  set POI gis:load-dataset "./data2015/POI.shp"
  set road_point gis:load-dataset "./data2015/fr_roads_Point.shp"
  
  ; Set the world envelope to the union of all of our dataset's envelopes
  gis:set-world-envelope (gis:envelope-union-of (gis:envelope-of elevation-dataset)
                                                ;(gis:envelope-of polygon)
                                                ;(gis:envelope-of m_data)
                                                )

  let horizontal-gradient gis:convolve elevation-dataset 3 3 [ 1 1 1 0 0 0 -1 -1 -1 ] 1 1
  let vertical-gradient gis:convolve elevation-dataset 3 3 [ 1 0 -1 1 0 -1 1 0 -1 ] 1 1
  set slope gis:create-raster gis:width-of elevation-dataset gis:height-of elevation-dataset gis:envelope-of elevation-dataset
  set aspect gis:create-raster gis:width-of elevation-dataset gis:height-of elevation-dataset gis:envelope-of elevation-dataset

  let x 0
  repeat (gis:width-of slope)
  [ let y 0
    repeat (gis:height-of slope)
     [ let gx gis:raster-value horizontal-gradient x y
       let gy gis:raster-value vertical-gradient x y
       if ((gx <= 0) or (gx >= 0)) and ((gy <= 0) or (gy >= 0))
         [ let s sqrt ((gx * gx) + (gy * gy))
          gis:set-raster-value slope x y s
          ;gis:apply-raster slope p_slope
       ifelse (gx != 0) or (gy != 0)
         [ gis:set-raster-value aspect x y atan gy gx ]
         [ gis:set-raster-value aspect x y 0 ] ]
      set y y + 1 ]
    set x x + 1 ]
   gis:set-sampling-method aspect "NEAREST_NEIGHBOR"   ;"bilinear"  ;;BILINEAR
   ;gis:paint elevation-dataset 0

  let world (gis:envelope-of elevation-dataset) ;; [ minimum-x maximum-x minimum-y maximum-y ]
  if zoom != 1 [
    let x0 (item 0 world + item 1 world) / 2          
    let y0 (item 2 world + item 3 world) / 2
    let W0 zoom * (item 0 world - item 1 world) / 2   
    let H0 zoom * (item 2 world - item 3 world) / 2
    set world (list (x0 - W0) (x0 + W0) (y0 - H0) (y0 + H0))
  ]
  gis:set-world-envelope (world)
  
  random-seed 137
  ;init cars
  setup-paths-graph
  ;setup-boats
  
  load-attributes
  ;display-aspect-in-patches

  gis:apply-raster slope p_slope
  ask patches [
  ;  set fc (p_ndvi - 0.00177119) / (0.562732 - 0.00177119)
  ;  if fc < 0 [ set fc 0]
  ;  set lai 7.813 * p_ndvi + 0.789
  ;  set smax 0.5 * lai + 0.1
  ;  set Hw elevation
  ;  set height elevation
    set depth 0
    set pcolor gradient:scale ;palette:scale-gradient
        (list extract-rgb (yellow + 2)
          extract-rgb (yellow - 2)
          extract-rgb (lime - 1.5)
          extract-rgb (green - 2)
          extract-rgb (brown - 1.5)
          extract-rgb (gray - 2)
          extract-rgb (gray + 4) )
    elevation 15 90
  ]
  
  ;init-bus2
  ;RESET-TICKS
  ;repeat 30 [setup-boats3]


  display-POI

  
  ;ask patches gis:intersecting roads [set pcolor black]
  reset-ticks 
  init-people
  ask turtles [set awareness random-normal warning_recieve 0.05]
  set warning-ticks map [? + warning_time] [59 69 79 89 99 109 119 129 139 149 159 169 179]
  ;repeat 30 [trip]
  ;reset-ticks
  ;;  reset-ticks ct cp cd clear-links clear-all-plots clear-output
 end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to load-attributes
  ;ask patches [set pcolor white]

  ;set drawing feature shp
  ;gis:set-drawing-color 103    gis:fill water 0
  ;gis:set-drawing-color 94   gis:draw water 1

  ;gis:set-drawing-color 5    gis:fill polygon 0
  gis:set-drawing-color [150 150 130]    gis:draw polygon 1
  ask patches gis:intersecting polygon [set pcolor black set landuse 9999]
  foreach gis:feature-list-of polygon
    [ let centroid gis:location-of gis:centroid-of ?
      if not empty? centroid
        [ ;let num 0 
          create-houses 1 
          [ set xcor item 0 centroid
            set ycor item 1 centroid
            set size 1
            set shape "circle" set color blue
          ]
      
        ]
    ] 
  
  ;gis:set-drawing-color 8 gis:draw roads 1
  gis:set-drawing-color black  gis:draw roads 0.2

  ;gis:set-drawing-color 67    gis:fill greenland 0
  ;gis:set-drawing-color 67    gis:draw greenland 1

  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;gis:apply-raster ndvi-dataset p_ndvi
  gis:apply-raster elevation-dataset elevation
  ;gis:apply-raster road lu_r
  ;ask patches gis:intersecting roads [set pcolor black]
  gis:apply-raster road_speed r_speed
  gis:apply-raster road_k r_k
  
  gis:apply-raster m_data manning
  ask patches [set pcolor white]
  ;ask patches [if p_ndvi > 0 [set runoff_c 0.15]]
  ask patches [if manning = 15 [set manning 0.21 set runoff_c R2]
               if manning = 90 [set manning 0.012 set runoff_c R1]
               if manning = 60 [set manning 0.015 set runoff_c R3]
      ]
  ;ask patches [set pcolor scale-color blue rainfall 9 0]
end

to display-POI
  ask city-POIs [ die ]
  foreach gis:feature-list-of POI
  [ ;gis:set-drawing-color red
    ;gis:fill ? 2.0
      let location gis:location-of (first (first (gis:vertex-lists-of ?)))
      if not empty? location
      [ create-city-POIs 1
        [ set xcor item 0 location
          set ycor item 1 location
          set size 0.5
          set shape "circle"
          set color black
          set types gis:property-value ? "Type" ] ]
  ]
  
  ask road-POIs [ die ]
  foreach gis:feature-list-of road_point
  [ ;gis:set-drawing-color red
    ;gis:fill ? 2.0
      let location gis:location-of (first (first (gis:vertex-lists-of ?)))
      if not empty? location
      [ create-road-POIs 1
        [ set xcor item 0 location
          set ycor item 1 location
          set size 1.5
          set shape "circle"
          set color red
          set Num gis:property-value ? "N" ] ]
  ] 
end

to init-people
   create-peoples (49472 * 5.7 / 100 / 180 )  [set color green set age "child" set speed (6.3 + random 2.8) set from-node one-of city-POIs with [types ="school"] move-to from-node set to-node one-of houses]
   create-peoples (49472 * 2.5 / 100 / 180 )  [set color green set from-node one-of houses move-to from-node set to-node one-of city-POIs with [types ="restaurant"]]
   create-peoples (49472 * 10.6 / 100 / 180) [set color green set from-node one-of houses move-to from-node set to-node one-of city-POIs with [types ="store"]]
   create-peoples (49472 * 64.5 / 100 / 180) [set color green set from-node one-of houses move-to from-node set to-node one-of other houses]
   create-peoples (49472 * 4 / 100 / 180)    [set color green set from-node one-of houses move-to from-node set to-node one-of city-POIs with [types ="government"]]
   create-peoples (49472 * 12.8 / 100 / 180)  [set color green set from-node one-of city-POIs with [types ="other_info"] move-to from-node set to-node one-of city-POIs with [types ="other_info"]]
   ;ask peoples [if ([landuse] of patch-here ) = 9999 [set size 6]]
   ask peoples[
     set size 0.5
     ;set start-time ticks
     ;set hidden? true
     set move? true
     face to-node
     ]
   ask n-of (3643 / 180) peoples with [speed = 0 and move? = true] [set age "senior" set speed 5.3 + random 1.2]
   ask peoples with [speed = 0 and move? = true] [set age "adult" set speed 6.3 + random 2.8]
   ;ask peoples with [ticks > start-time] [set move? true set hidden? false]
end

to trip
  init-people
  ;ask peoples with [to-node = nobody] [die]
  ask peoples with [move? = true][
    if distance to-node < speed ;; round off error fix
    [ move-to to-node die]
  ]
  ask peoples with [move? = true][face to-node fd speed]
    
  ask patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor ][
   
    ifelse ticks <= 180  [let index floor (ticks ) set rainfall (item index p_density10)]
                                      [set rainfall 6.1 / 3 / 3600 * step]   
  
    set depth max list 0 (depth + rainfall * runoff_c - Drainage / 3600 * step)
    ;set droplet droplet + rainfall ;show droplet / depth
    if depth > 0 [flow] 
   ]

  ask peoples with [move? = true][if [depth] of patch-here > 300 [set color red set move? false]]
  if ticks > 180 [stop]
  
  tick
end

to travel
  ask peoples with [to-node != nobody][
    ifelse distance to-node < 5 [move-to to-node]
                                [face to-node
                                 ifelse [on-road?] of patch-ahead 1 [move-to patch-here]
                                                                    [left 90 ifelse [on-road?] of patch-ahead 1 [move-to patch-here]
                                                                                                                [left 190 ifelse [on-road?] of patch-ahead 1 [move-to patch-here]
                                                                                                                                                             [right 90 move-to patch-here] ]]
                                  ]
    ;set next-node one-of patches with [landuse != 9999]
    face to-node
    forward 1   
    ]
end

to go-people
  init-people
  ask peoples with [to-node = nobody] [die]
  ask peoples with [speed > 0][
    ifelse distance to-node < speed    ;; round off error fix
    [move-to to-node die]
    [face to-node fd speed]
  ]
  
  ask patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor ][
   
    ifelse ticks <= 180  [let index floor (ticks ) set rainfall (item index p_density10)]
                                      [set rainfall 6.1 / 3 / 3600 * step]   
  
    set depth max list 0 (depth + rainfall * runoff_c - Drainage / 3600 * step)
    ;set droplet droplet + rainfall ;show droplet / depth
    if depth > 0 [flow] 
   ]

  ask peoples [if [depth] of patch-here > 300 [set color red set speed 0]]
  if ticks > 180 [stop]
end

to move-forward  ; turtle proc
  let n 0 let pp 0 let l 0 ;locals [n p l]
  set n neighbors with [on-road?]
  ifelse count n = 0 [die] [
    set l []
    ask patch-left-and-ahead  90 3 [if on-road? [set l lput self l]]
    ask patch-right-and-ahead 90 3 [if on-road? [set l lput self l]]
    if (length l != 0) and (0 = random 3) [ set pp one-of l ] ;random-one-of
    if pp = 0      [ set pp one-of n with [(heading-angle myself) = 0] ]
    if pp = nobody [ set pp one-of n with [(heading-angle myself) <= 45] ] ;random-one-of
    if pp = nobody [ set pp one-of n with [(heading-angle myself) <= 90] ] ;random-one-of
    if pp = nobody [ set pp min-one-of n [heading-angle myself] ]
    set heading towards pp
    forward distance pp
  ]
end

to-report on-road?
  report landuse != 9999
end

to-report heading-angle [t] ; patch proc
  let hp 0;locals [h]
  ;set h abs (heading-of t - (towards t + 180) mod 360)
  set hp (towards t + 180 - [heading] of t) mod 360
  if hp > 180 [set hp 360 - hp]
  report hp
end

to display-traffic-flow
  ;ask city-labels [ die ]
  foreach gis:feature-list-of roads
  [ gis:set-drawing-color scale-color red (gis:property-value ? "Lanes") 5000000 1000
    gis:fill ? 2.0
    let location gis:location-of (first (first (gis:vertex-lists-of ?)))
    create-boats 1
        [ set xcor item 0 location
          set ycor item 1 location
          set size 0
          set label gis:property-value ? "NAME" ] 
   ] 
end


to display-gradient-in-patches
 let horizontal-gradient gis:convolve elevation-dataset 3 3 [ 1 0 -1 2 0 -2 1 0 -1 ] 1 1
 let vertical-gradient gis:convolve elevation-dataset 3 3 [ 1 2 1 0 0 0 -1 -2 -1 ] 1 1
 set gradient gis:create-raster gis:width-of elevation-dataset gis:height-of elevation-dataset gis:envelope-of elevation-dataset
  let x 0
  repeat (gis:width-of gradient)
  [ let y 0
    repeat (gis:height-of gradient)
    [ let gx gis:raster-value horizontal-gradient x y
      let gy gis:raster-value vertical-gradient x y
      if ((gx <= 0) or (gx >= 0)) and ((gy <= 0) or (gy >= 0))
      [ gis:set-raster-value gradient x y sqrt ((gx * gx) + (gy * gy)) ]
      ;ask patches with [pxcor = x and pycor = y ] [set pcolor elevation]
      set y y + 1 ]
    set x x + 1 ]
  let min-g gis:minimum-of gradient
  let max-g gis:maximum-of gradient
  ;gis:apply-raster gradient elevation
  ;ask patches
  ;[ if (elevation <= 0) or (elevation >= 0)
  ;  [ set pcolor scale-color blue elevation (min-g / 2) (max-g / 2) ] ]
  gis:apply-raster gradient p_slope
end

to display-aspect-in-patches
 let horizontal-gradient gis:convolve elevation-dataset 3 3 [ 1 0 -1 2 0 -2 1 0 -1 ] 1 1
 let vertical-gradient gis:convolve elevation-dataset 3 3 [ 1 2 1 0 0 0 -1 -2 -1 ] 1 1

  let x 0
  repeat (gis:width-of slope)
  [ let y 0
    repeat (gis:height-of slope)
     [ let gx gis:raster-value horizontal-gradient x y
       let gy gis:raster-value vertical-gradient x y
       if ((gx <= 0) or (gx >= 0)) and ((gy <= 0) or (gy >= 0))
         [ let s sqrt ((gx * gx) + (gy * gy))
          gis:set-raster-value slope x y s
       ifelse (gx != 0) or (gy != 0)
         [ gis:set-raster-value aspect x y atan gy gx ]
         [ gis:set-raster-value aspect x y 0 ] ]
      set y y + 1 ]
    set x x + 1 ]
  gis:set-sampling-method aspect "bilinear"

  let min-g gis:minimum-of aspect
  let max-g gis:maximum-of aspect
  gis:apply-raster aspect p_aspect
  ;ask patches
  ;[if (p_aspect <= 0) or (p_aspect >= 0)
  ;  [ set pcolor scale-color grey p_aspect (min-g / 0.5) (max-g / 0.5) ]
  ;]
end


;;;;;;;;;;;;;;;;;;;;;;;;;


; Procedure to flood the landscape to a water level
to flood
  ask patches with [height <= water-level] [
    set pcolor blue]
  ask patches with [height > water-level] [
    set pcolor scale-color white height -.5 1.5]
end

;; Color the patches using more realistic terrain (and water) color palette
to real-color
  no-display
  ask patches
    [
      ; Allow some mix in colors (diffuse borders)
      let vv height + mix-colors * (random-float 1 - .5) / 10
      ; Use one palette for water, and other for land
      ifelse height <= water-level
      [ set pcolor extract-rgb scale-color blue vv 0 1 ]
      [ ;set pcolor palette:scale-gradient
        set pcolor gradient:scale
        (list extract-rgb (yellow + 2)
          extract-rgb (yellow - 2)
          extract-rgb (lime - 1.5)
          extract-rgb (green - 2)
          extract-rgb (brown - 1.5)
          extract-rgb (gray - 2)
          extract-rgb (gray + 4) )
      vv water-level 73                 ]
    ]
  display
end
to shade
  ; First, compute the higher slope angle in the landscape:
  ; Difference between heights in adjacent patches
  let M 0
  ask patches [
    ask neighbors with [pxcor >= [pxcor] of myself] [ ; we reduce the number of comparisons
      let dif abs (height - [height] of myself)
      if dif > M [set M dif]
    ]
  ]
  ; Scale will contain the amount of shade to be considered
  let scale intensity * 100 / M
  ; Add shadows to patches having higher neighbors in the direction of the sun
  ask patches with [pxcor > 1 and pycor > 2 and pxcor < 192 and pycor < 110] [
    let hh [height] of dir-sun
    if hh > height [set pcolor map [cut (? - scale * (hh - height) )] pcolor]
    ;if h < height [set pcolor map [cut (? - scale / 4 * (h - height) )] pcolor]
    ;set pcolor map [cut (? - scale * (h - height) )] pcolor
  ]
end
; Cut [0, 255]
to-report cut [x]
  ifelse x > 255 [report 255][ifelse x < 0 [report 0][report x]]
end

; Set sun direction
to-report dir-sun
  ifelse sun = "up" [report patch-at 0 1] [
    ifelse sun = "down" [report patch-at 0 -1] [
      ifelse sun = "right" [report patch-at 1 0]
      [report patch-at -1 0] ]]
end
;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;
to-report get_dH [pH]  ;;  agent0 agent1 agent2... agenti agenti+1...
  let hi []
  ifelse (length pH = 0 ) [set hi []]
                              [repeat (length pH - 1)
                                [set hi lput ([pheight] of (item 1 pH) - [pheight] of (item 0 pH)) hi
                                 set pH remove-item 0 pH]
                              ]
  report hi

end

;;返回x重复次数
to-report occurrences [x the-list]
  report reduce
    [ifelse-value (?2 = x) [?1 + 1] [?1]] (fput 0 the-list)
end
;;返回target元胞
to-report get-target [x para]
  ;if [para] of x > 0
  ;let a sort-on [(para)] patch-set list x [neighbors] of x    ;邻域+自身按照“para”属性值 从低到高排序
  ;x occurrences (min a) a
  ;show sublist a 0 3
  let t ([neighbors] of x) with-min [(para)]
  report t
  ;let cpos (position seslf a)                              ;返回cential cell的位置
  ;set target sublist a 0 cpos
end

to rain
  if ticks <= 180 [ ask patches [set rainfall item ticks p_density] ]
  if ticks > 180 [ ask patches [set rainfall 0] ]
   ;;calc_runoff
  ask patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor][
    set droplet rainfall / 1000 * runoff_c / 100 
    set depth depth + droplet
    set Hw elevation + depth
    let h1 min [Hw] of neighbors
    set dH (Hw - h1)
    if depth > 0 and dH > 0 [ set target neighbors with-min [Hw]
      let n count target
      ifelse n = 8 
        [set h2 Hw]
        [set h2 [Hw] of (item n sort-on [(Hw)] neighbors) ] ;cell
      ;set runoff dH ^ (2 / 3) * sqrt ((atan (dH) 30)) / manning
      set runoff min (list 10.844 (dH ^ (2 / 3) * sqrt (dH / 10) / manning))
      ;set runoff min (list 10.844 (dH ^ (2 / 3) * sqrt (p_slope * 3.14 / 180) / manning))

      set F min list (depth * 100) (list (runoff * dH * 10 * 60) ((h2 - h1) * 100) (depth * 100))    ;; F=v*dH*cellsize*t
      ask target [set depth depth + F / n / 100]
      set depth max (list 0 (depth - F / n / 100))
    ]
  ]
  tick
end

to setHW
  ask patches [set Hw elevation]
end

to flux
  ask patch 50 50 [
  let c (patch-set self neighbors4) 
    let avg mean [elevation] of c
    ask c [
      if elevation > avg [set c c with [self != myself]]
      show c show[elevation] of c
    ]
  ]

end


to flood2
  if ticks <= 180 [
    ask patch 75 75 [set rainfall 10]
    ask patches [
      set Hw Hw + rainfall
      let c (patch-set self neighbors4) 
        let avg mean [elevation] of c
        ask c [
          if elevation > avg [set c c with [self != myself]]
        ]
      ]
  ]
end

to set-rainfall
 if ticks < 180 and ticks mod M_step = 0[
   ask patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor][
     let j floor (ticks / M_step)
     let r_5 sum sublist p_density (j * M_step) (j * M_step + M_step) 
     set rainfall r_5 
     set depth max list 0 (depth + rainfall * runoff_c - Drainage / 3600 * step)
     ;if depth > 0 [flow] 
   ]
   ]
 if ticks >= 180 [stop]
 ask patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor][
  if depth > 0 [flow3]
 ]
  ;ask patch 50 50 [show rainfall]
 ;if ticks > 180 [set rainfall 5.9 / 60 ]
 tick
end

to go
 ask patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor ][
   
    ifelse ticks <= 180 * (60 / step) [let index floor (ticks / (60 / step) ) set rainfall (item index p_density10) / 60 * step]
                                      [set rainfall 6.1 / 3 / 3600 * step]   
  
    set depth max list 0 (depth + rainfall * runoff_c - Drainage / 3600 * step)
    ;set droplet droplet + rainfall ;show droplet / depth
    if depth > 0 [flow] 
 ]
   ;show (sum [droplet] of patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor]) / (sum [depth] of patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor]) 
 if ticks > 180 * (60 / step) [stop]
 
 ;set inundation gis:create-raster max-pxcor max-pycor (gis:envelope-of elevation-dataset)
 ;ask patches with [pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor][
 ;   gis:set-raster-value inundation pxcor (max-pycor - pycor) depth
 ; ]
 ;let path-name (word "./data2015/mapping01/sink_" ticks "_" (random 1000000) ".asc")
 ;if (ticks mod 30) = 0 [gis:store-dataset inundation path-name]
 tick   
end

to adapt
  ask boats []
end

to flow
  ;; find the neighboring patch where the water is lowest
  let target_cell min-one-of neighbors with [landuse != -9999][elevation * 1000 + depth]
  ;; the amount of flow is half the level difference, unless
  ;; that much water isn't available
  if target_cell != nobody[
  let amount min list depth (0.5 * (elevation * 1000 + depth - 1000 * [elevation] of target_cell - [depth] of target_cell))
  set dH amount
  ;; don't flow unless the water is higher here
  if amount > 0 [
    ;; first erode
    ;let erosion amount * (1 - soil-hardness)
    ;set elevation elevation - erosion
    ;; but now the erosion has changed the amount of flow needed to equalize the level,
    ;; so we have to recalculate the flow amount
    ;set amount min list depth (0.5 * (elevation + depth - [elevation] of target_cell - [depth] of target_cell))
    set amount min list depth (0.5 * (elevation * 1000 + depth - 1000 * [elevation] of target_cell - [depth] of target_cell))
    set depth depth - amount
    ;set runoff (dH / 1000 )^ (2 / 3) * sqrt (p_slope) / manning ;amount / step
    ;set v 10 / ( runoff + sqrt (10 * dH / 1000) )
    ;let s max [v] of patches with [v > 0]
   ; ifelse s > 60 [set step 60][set step s] 
    ask target_cell [ set depth depth + amount ]
    ;ask patch 50 50 [set h h + rainfall show h show depth]
  ]  
  ]
end

to flow2    ;;manning formule
  ;; find the neighboring patch where the water is lowest
  let target_cell min-one-of neighbors [elevation + depth]
  ;; the amount of flow is half the level difference, unless
  ;; that much water isn't available
  if target_cell != nobody[
  let amount min list depth (1 * (elevation + depth - [elevation] of target_cell - [depth] of target_cell))
  set dh amount
  ;; don't flow unless the water is higher here
  if amount > 0 [
    ;; first erode
    ;let erosion amount * (1 - soil-hardness)
    ;set elevation elevation - erosion
    ;; but now the erosion has changed the amount of flow needed to equalize the level,
    ;; so we have to recalculate the flow amount
    ;set amount min list depth (0.5 * (elevation + depth - [elevation] of target_cell - [depth] of target_cell))
    ;let s elevation - [elevation] of target_cell
    ;if s > 0 [
      set runoff (dH / 1000) ^ (2 / 3) * sqrt (abs (tan p_slope)) / manning ;amount / step
      let q min list depth (runoff * dH * step / 10)   ;; m -> mm
      ;let q min list depth (runoff * dh * M_step * 60 / 10)
      ;let q min list depth (runoff * dh * 10 * M_step * 60 / 100)
      set v 10 / ( runoff + sqrt (10 * dH / 1000) )
      set depth depth - q
      ask target_cell [ set depth depth + q ]
    ;]
  ]
  ]
end

to flow5  ;;minimization algorithm
  if ticks <= 180 * (60 / step) [
  let index floor (ticks / (60 / step) ) 
  ask patches [set rainfall (item index p_density) / 60 * step]
  ask patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor][
    set depth depth + rainfall / 1000 * runoff_c - Drainage / 3600 * step
   ]
  ]
  
  ask patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor and depth > 0 and landuse != 9999]
  [
    set dH depth + elevation
    let xx [dH] of neighbors with [landuse != 9999] 
    if not empty? xx and dH > min xx
     [
      let target_cell set-target2 neighbors with [landuse != 9999] dH
      let cells (patch-set target_cell self)
      ask cells [ set dH mean [dH] of cells] 
      ]
   ]
  ;ask patch 50 50 [set h h + rainfall show h]
  tick
end

to flow6
   set dH depth + elevation * 1000
   if dH > min [dH] of neighbors [
       let target_cell set-target2 neighbors dH
       let cells (patch-set target_cell self)
       ask cells [ set dH mean [dH] of cells] 
   ]
end

to-report set-target [cell-list a]
  let avg mean (lput a cell-list) show avg
  ifelse max cell-list < avg [  report cell-list]
  [ set cell-list filter [? < avg] cell-list
                           report set-target cell-list a]
  ;report cell-list
end

to-report set-target2 [agents dhh]
  let avg mean [dhh] of (patch-set agents self)  
  ;show [pxcor] of agents show [pycor] of agents
  ;show [dhh] of agents show avg
  ifelse (all? agents [dhh < avg]) [report agents]
                                       [set agents agents with [dhh < avg] 
                                        report set-target2 agents dhh]
  ;report cell-list
end

to rain2
if ticks <= 180 [
   ask patches [set rainfall item ticks p_density]
   ;;calc_runoff
   ask patches with [ pxcor > 1 and pycor > 1  and pxcor < 200 and pycor < 200][
    set droplet rainfall / 1000 * runoff_c / 100 
    set depth depth + droplet
    set Hw elevation + depth
    let h1 min [Hw] of neighbors
    set dH (Hw - h1)
    if depth > 0 and dH > 0 [ set target neighbors with-min [Hw]
      let n count target
      ifelse n = 8 
        [set h2 Hw]
        [set h2 [Hw] of (item n sort-on [(Hw)] neighbors) ] ;第二矮的cell
      ;set runoff dH ^ (2 / 3) * sqrt ((atan (dH) 30)) / manning
      set runoff min (list 10.844 (dH ^ (2 / 3) * sqrt (sin (atan (dH) 5)) / manning))
      ;set runoff min (list 10.844 (dH ^ (2 / 3) * sqrt (p_slope * 3.14 / 180) / manning))

      set F min (list (runoff * dH * 5 * 60) ((h2 - h1) * 25) (depth * 25))    ;; F=v*dH*cellsize*t
      ask target [set depth depth + F / n / 25]
      set depth max (list 0 (depth - F / n / 25))
    ]
  ]
  tick
]
end

to flow3
  ;; find the neighboring patch where the water is lowest
  let target_cell min-one-of neighbors with [landuse != -9999][elevation * 1000 + depth]
  ;; the amount of flow is half the level difference, unless
  ;; that much water isn't available
  if target_cell != nobody[
  let amount min list depth (0.5 * (elevation * 1000 + depth - 1000 * [elevation] of target_cell - [depth] of target_cell))
  set dH amount
  ;; don't flow unless the water is higher here
  if amount > 0 [
    ;; first erode
    ;let erosion amount * (1 - soil-hardness)
    ;set elevation elevation - erosion
    ;; but now the erosion has changed the amount of flow needed to equalize the level,
    ;; so we have to recalculate the flow amount
    ;set amount min list depth (0.5 * (elevation + depth - [elevation] of target_cell - [depth] of target_cell))
    set amount min list depth (0.5 * (elevation * 1000 + depth - 1000 * [elevation] of target_cell - [depth] of target_cell))
    set depth depth - amount
    ;set runoff (dH / 1000 )^ (2 / 3) * sqrt (p_slope) / manning ;amount / step
    ;set v 10 / ( runoff + sqrt (10 * dH / 1000) )
    ;let s max [v] of patches with [v > 0]
   ; ifelse s > 60 [set step 60][set step s] 
    ask target_cell [ set depth depth + amount ]
    ;ask patch 50 50 [set h h + rainfall show h show depth]
  ]  
  ] 
end

to flow4
  let target_cell min-one-of neighbors4 [elevation + depth]

  set dH (elevation + depth - [elevation] of target_cell - [depth] of target_cell)
  if dH > 0 [
    set runoff min list sqrt (9.8 * dH) (dH ^ (2 / 3) * sqrt (p_slope) / manning)
    ; > 1 min
    ;let amount min (list depth (0.5 * dH) (runoff * M_step * 6))   ;runoff * M_step * 60 * 10 / 100
    ; < 1 min
    let amount min (list depth (0.5 * dH) (runoff * step * dH / 10)) 
    set depth depth - amount
    ask target_cell [ set depth depth + amount ]
  ]  
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  find shortest way;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

; create the source and destination at two random locations on the view
to create-source-and-destination
  ask one-of patches with [pcolor = black]
  [ 
    set pcolor blue 
    set plabel "source"
    sprout 1 
    [ 
      set color red 
      pd
    ] 
  ]
  ask one-of patches with [pcolor = black]
  [ 
    set pcolor green 
    set plabel "destination"
  ]
end

; draw the selected maze elements on the view
to draw
  if mouse-inside?
    [
      ask patch mouse-xcor mouse-ycor
      [
        sprout 1
        [
          set shape "square"
          die
        ]        
      ]
      
      ;draw obstacles      
      if Select-element = "obstacles"
      [      
        if mouse-down?
        [         
          if [pcolor] of patch mouse-xcor mouse-ycor = black or [pcolor] of patch mouse-xcor mouse-ycor = brown or [pcolor] of patch mouse-xcor mouse-ycor = yellow
          [
            ask patch mouse-xcor mouse-ycor 
            [
              set pcolor white
            ]
          ]      
        ]
      ]
      
      ;erase obstacles      
      if Select-element = "erase obstacles"
      [
        if mouse-down?
        [ 
          if [pcolor] of patch mouse-xcor mouse-ycor = white
          [
            ask patch mouse-xcor mouse-ycor 
            [
              set pcolor black
            ]
          ]      
        ]
      ]
      
      ;draw source patch     
      if Select-element = "source"
      [   
        if mouse-down?
        [ 
          let m-xcor mouse-xcor
          let m-ycor mouse-ycor
          if [plabel] of patch m-xcor m-ycor != "destination"
          [
            ask patches with [plabel = "source"]
            [
              set pcolor black
              set plabel ""
            ]
            ask turtles
            [
              die
            ]          
            ask patch m-xcor m-ycor
            [   
              set pcolor blue 
              set plabel "source"
              sprout 1 
              [ 
                set color red 
                pd
              ] 
            ]
          ]
        ]
      ]
      
      ;draw destination patch     
      if Select-element = "destination"
        [      
          if mouse-down?
            [ 
              let m-xcor mouse-xcor
              let m-ycor mouse-ycor
              
              if [plabel] of patch m-xcor m-ycor != "source"
              [
                ask patches with [plabel = "destination"]
                [
                  set pcolor black
                  set plabel ""
                ]              
                ask patch m-xcor m-ycor 
                [   
                  set pcolor green 
                  set plabel "destination"
                ]
              ]
            ]
        ]
    ]
end

; call the path finding procedure, update the turtle (agent) variables, output text box
; and make the agent move to the destination via the path found
to find-shortest-path-to-destination
  reset-ticks
  ask one-of turtles 
  [
    move-to one-of patches with [plabel = "source"]
    set path find-a-path one-of patches with [plabel = "source"] one-of patches with [plabel = "destination"]
    set optimal-path path
    set current-path path
  ]
  output-show (word "Shortest path length : " length optimal-path)
  move
end


; the actual implementation of the A* path finding algorithm
; it takes the source and destination patches as inputs
; and reports the optimal path if one exists between them as output
to-report find-a-path [ source-patch destination-patch] 
  
  ; initialize all variables to default values
  let search-done? false
  let search-path []
  let current-patch 0
  set open []
  set closed []  
  
  ; add source patch in the open list
  set open lput source-patch open
  
  ; loop until we reach the destination or the open list becomes empty
  while [ search-done? != true]
  [    
    ifelse length open != 0
    [
      ; sort the patches in open list in increasing order of their f() values
      set open sort-by [[f] of ?1 < [f] of ?2] open
      
      ; take the first patch in the open list
      ; as the current patch (which is currently being explored (n))
      ; and remove it from the open list
      set current-patch item 0 open 
      set open remove-item 0 open
      
      ; add the current patch to the closed list
      set closed lput current-patch closed
      
      ; explore the Von Neumann (left, right, top and bottom) neighbors of the current patch
      ask current-patch
      [         
        ; if any of the neighbors is the destination stop the search process
        ifelse any? neighbors4 with [ (pxcor = [ pxcor ] of destination-patch) and (pycor = [pycor] of destination-patch)]
        [
          set search-done? true
        ]
        [
          ; the neighbors should not be obstacles or already explored patches (part of the closed list)          
          ;ask neighbors4 with [ pcolor != white and (not member? self closed) and (self != parent-patch) ]   
          ask neighbors4 with [ pcolor = black and (not member? self closed) and (self != parent-patch) ]    
          [
            ; the neighbors to be explored should also not be the source or 
            ; destination patches or already a part of the open list (unexplored patches list)
            if not member? self open and self != source-patch and self != destination-patch
            [
              set pcolor 45
              
              ; add the eligible patch to the open list
              set open lput self open
              
              ; update the path finding variables of the eligible patch
              set parent-patch current-patch 
              set g [g] of parent-patch  + 1
              set h distance destination-patch
              set f (g + h)
            ]
          ]
        ]
        if self != source-patch
        [
          set pcolor 35
        ]
      ]
    ]
    [
      ; if a path is not found (search is incomplete) and the open list is exhausted 
      ; display a user message and report an empty search path list.
      user-message( "A path from the source to the destination does not exist." )
      report []
    ]
  ]
  
  ; if a path is found (search completed) add the current patch 
  ; (node adjacent to the destination) to the search path.
  set search-path lput current-patch search-path
  
  ; trace the search path from the current patch 
  ; all the way to the source patch using the parent patch
  ; variable which was set during the search for every patch that was explored
  let temp first search-path
  while [ temp != source-patch ]
  [
    ask temp
    [
      set pcolor 85
    ]
    set search-path lput [parent-patch] of temp search-path 
    set temp [parent-patch] of temp
  ]
  
  ; add the destination patch to the front of the search path
  set search-path fput destination-patch search-path
  
  ; reverse the search path so that it starts from a patch adjacent to the
  ; source patch and ends at the destination patch
  set search-path reverse search-path  

  ; report the search path
  report search-path
end

; make the turtle traverse (move through) the path all the way to the destination patch
to move
  ask one-of turtles 
  [
    while [length current-path != 0]
    [
      go-to-next-patch-in-current-path
      pd
      wait 0.05
    ]
    if length current-path = 0
    [
      pu
    ]
  ]   
end

to go-to-next-patch-in-current-path  
  face first current-path
  repeat 10
  [
    fd 0.1
  ]
  move-to first current-path
  if [plabel] of patch-here != "source" and  [plabel] of patch-here != "destination"
  [
    ask patch-here
    [
      set pcolor black
    ]
  ]
  set current-path remove-item 0 current-path
end

; clear the view of everything but the source and destination patches 
to clear-view
  cd
  ask patches with[ plabel != "source" and plabel != "destination" ]
  [
    set pcolor black
  ]
end

; load a maze from the file system
to load-maze [ maze ]  
  if maze != false
  [
    ifelse (item (length maze - 1) maze = "g" and item (length maze - 2) maze = "n" and item (length maze - 3) maze = "p" and item (length maze - 4) maze = ".")
    [
      save-maze "temp.png"
      ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
      import-pcolors maze  
      ifelse count patches with [pcolor = blue] = 1 and count patches with [pcolor = green] = 1
      [
        ask patches 
        [
          set plabel ""
        ]
        ask turtles
        [
          die
        ]    
        ask one-of patches with [pcolor = blue]
        [
          set plabel "source"
          sprout 1 
          [ 
            set color red 
            pd
          ] 
        ] 
        ask one-of patches with [pcolor = green]
        [
          set plabel "destination"
        ] 
      ]
      [
        ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
        user-message "The selected image is not a valid maze."
        load-maze "temp.png"
        ;;clear-view
      ]
    ]
    [
      user-message "The selected file is not a valid image."
    ]
  ]
end

; save a maze as a PNG image into the system 
to save-maze [filename]
  if any? patches with [pcolor != black]
  [
    clear-unwanted-elements
    export-view (filename)
    restore-labels
  ]
end

; clear the view of everything but the obstacles, source and destination patches
; so that the view can be saved as a PNG image
to clear-unwanted-elements
  if any? patches with [pcolor = brown or pcolor = yellow  ]
  [
    ask patches with [pcolor = brown or pcolor = yellow  ]
    [
      set pcolor black
    ]
  ]
  if any? patches with [pcolor = blue]
  [
    ask one-of patches with [pcolor = blue]
    [
      set plabel ""
    ] 
  ]
  if any? patches with [pcolor = green]
  [
    ask one-of patches with [pcolor = green]
    [
      set plabel ""
    ] 
  ]
  clear-drawing
  ask turtles
  [
    die
  ]
end

; re-label the source and destination patches ones
; the maze image file has been saved
to restore-labels
  ask one-of patches with [pcolor = blue]
  [
    set plabel "source"
    sprout 1 
    [ 
      set color red 
      pd
    ] 
  ] 
  ask one-of patches with [pcolor = green]
  [
    set plabel "destination"
  ] 
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;                      ;;;;;;;;;;;;
;;;;;;;;   traffic  sim       ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup-cars
  ;setup-world-envelope
  setup-paths-graph
  setup-boats
  ;let h [round link-length] of links
  ;set-plot-x-range 0 (max h + 1) ;set-plot-y-range 0 count links with [round link-length = 0]
  ;histogram [round link-length] of links
end

to setup-world-envelope
  let world (gis:envelope-of polygon) ;; [ minimum-x maximum-x minimum-y maximum-y ]
  if zoom != 1 [
    let x0 (item 0 world + item 1 world) / 2          let y0 (item 2 world + item 3 world) / 2
    let W0 zoom * (item 0 world - item 1 world) / 2   let H0 zoom * (item 2 world - item 3 world) / 2
    set world (list (x0 - W0) (x0 + W0) (y0 - H0) (y0 + H0))
  ]
  gis:set-world-envelope (world)
end

to setup-paths-graph
  set-default-shape nodes "circle"
  foreach polylines-of roads node-precision [
    (foreach butlast ? butfirst ? [ if ?1 != ?2 [ ;; skip nodes on top of each other due to rounding
      let n1 new-node-at first ?1 last ?1
      let n2 new-node-at first ?2 last ?2
      ask n1 [create-link-with n2]
    ]])
  ]
  ask nodes [hide-turtle]
end

to setup-boats 
  ;set-default-shape boats "car"
  ask patches with [r_k > 0] [
    let max-speed  (( r_speed / 3.6) / 10);meters-per-patch
    let min-speed  max-speed * (1 - speed-variation) ;; max-speed - (max-speed * speed-variation)
    if random 100 < 1 [
      sprout-boats ceiling (r_k * 3) [
        set color green
        set shape "car"
        set hidden? true
        move-to min-one-of nodes [distance myself]
        set size 2 ;; use meters-per-patch??
        set speed min-speed + random-float (max-speed - min-speed)
        let l one-of links
        set-next-boat-link l [end1] of l
      ]
      ]
    ]
  
  ask boats with [color = green] [
        let fn from-node
        let tn to-node
        set p [nw:turtles-on-path-to tn] of fn
        set start-time random 180
  ]
end

to setup-boats2
  ;set-default-shape boats "car"
  let boat-size 4
  let max-speed  ((max-speed-km/h / 3.6) * 60 / 10);meters-per-patch
  let min-speed  max-speed * (1 - speed-variation) ;; max-speed - (max-speed * speed-variation)
  create-boats 224 [
    set color green
    set shape "car"
    set size boat-size ;; use meters-per-patch??
    set speed min-speed + random-float (max-speed - min-speed)
    let l one-of links
    set-next-boat-link l [end1] of l
  ]
   ask boats with [color = green] [
   let fn from-node
   let tn to-node
   set p [nw:turtles-on-path-to tn] of fn
   ;set p [nw:turtles-on-path-to to-node] of from-node
  ]
end

to setup-boats3
  ;set-default-shape boats "car"
  let boat-size 2
  let max-speed  ((max-speed-km/h / 3.6) * 60 / 10);meters-per-patch
  let min-speed  max-speed * (1 - speed-variation) ;; max-speed - (max-speed * speed-variation)
  create-boats 124 [
    set color black
    set shape "car"
    set size boat-size ;; use meters-per-patch??
    set speed min-speed + random-float (max-speed - min-speed)
    set from-node one-of nodes
    move-to from-node
    set to-node one-of other nodes
  ]
  ask boats with [color = black] [
   let fn from-node
   let tn to-node
   set p [nw:turtles-on-path-to tn] of fn
   set color green
   ;set p [nw:turtles-on-path-to to-node] of from-node
  ]
end
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;     report
;;;;;;;;;;;;;;
to-report polylines-of [dataset decimalplaces]
  let polylines gis:feature-list-of dataset                              ;; start with a features list
  set polylines map [first ?] map [gis:vertex-lists-of ?] polylines      ;; convert to virtex lists
  set polylines map [map [gis:location-of ?] ?] polylines                ;; convert to netlogo float coords.
  set polylines remove [] map [remove [] ?] polylines                    ;; remove empty poly-sets .. not visible
  set polylines map [map [map [precision ? decimalplaces] ?] ?] polylines        ;; round to decimalplaces
    ;; note: probably should break polylines with empty coord pairs in the middle of the polyline
  report polylines ;; Note: polylines with a few off-world points simply skip them.
end
to-report new-node-at [x y] ; returns a node at x,y creating one if there isn't one there.
  let n nodes with [xcor = x and ycor = y]
  ifelse any? n [set n one-of n] [create-nodes 1 [setxy x y set size 2 set n self]]
  report n
end
to-report meters-per-patch ;; maybe should be in gis: extension?
  let world (gis:envelope-of elevation-dataset); [ minimum-x maximum-x minimum-y maximum-y ]
  let x-meters-per-patch (item 1 world - item 0 world) / (max-pxcor - min-pxcor)
  let y-meters-per-patch (item 3 world - item 2 world) / (max-pycor - min-pycor)
  report mean list x-meters-per-patch y-meters-per-patch
end

to set-next-boat-link [l n]
  set from-node [end1] of l
  set to-node one-of other nodes
  ;ask from-node [report nw:path-to to-node]

  set cur-link l
  move-to n
  ;ifelse n = [end1] of l [set to-node [end2] of l] [set to-node [end1] of l]
  face to-node
end

to walk
  
  ask patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor ][
   
    ifelse ticks <= 180 * (60 / step) [let index floor (ticks / (60 / step) ) set rainfall (item index p_density10) / 60 * step]
                                      [set rainfall 6.1 / 3 / 3600 * step]   
  
    set depth max list 0 (depth + rainfall * runoff_c - Drainage / 3600 * step)
    ;set droplet droplet + rainfall ;show droplet / depth
    if depth > 0 [flow] 
 ]
   ;show (sum [droplet] of patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor]) / (sum [depth] of patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor]) 
 if ticks > 180 * (60 / step) [stop]
 
 ;set inundation gis:create-raster max-pxcor max-pycor (gis:envelope-of elevation-dataset)
 ;ask patches with [pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor][
 ;   gis:set-raster-value inundation pxcor (max-pycor - pycor) depth
 ; ]
 ;if (ticks mod 30) = 0 [gis:store-dataset inundation (word "./data2015/mapping/sink_" ticks ".asc")]

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
 ;;;;bus
 if ticks mod 21 = 20 [init-bus2]
 ;ask patches with [r_k > 0][if random 100 < 1 [sprout-boats r_k / 60]]
 
 ;;;;cars
 setup-boats3
 ask boats with [(length p) = 0] [die]
 ask buses with [(length p) = 0] [die]  
 ;let n min-one-of nodes [distancexy mouse-xcor mouse-ycor]
  ;  while [mouse-down?] [ ask n [setxy mouse-xcor mouse-ycor] ]
   ; ask boats with [to-node = n or from-node = n] [ set to-node n move-to n ] 
  ;ask boats [if next-node = to-node [die]]
  
  ;ask boats [if start-time <= ticks [set hidden? false set color green]]
 ask (turtle-set boats buses) 
  [ set next-node item i p
    face next-node
    fd min list speed distance next-node
    if distance next-node < .0001 ;; round off error fix
    [ move-to next-node 
      ;set next-node [end2] of cur-link face next-node
      ifelse next-node != to-node [set i i + 1] 
                                  [move-to next-node die]
    ]
  ]
  
  ask boats [if [depth] of patch-here > 300 [set color red set speed 0]]
  ask buses [if [depth] of patch-here > 300 [set color red set speed 0]]
  ;if count boats = 0 [stop]
  ask patches with [depth > 300] [ask min-one-of nodes [distance myself] [set color 119]]
  ask boats with [color = green] [if member? (one-of nodes with [color = 119]) p [set start? true] ]
  ask buses with [color = green] [if member? (one-of nodes with [color = 119]) p [set start? true] ]
  

  if (ticks = warning-ticks) [warning]


  ;;;;peopele
  
  init-people
  ;ask peoples with [to-node = nobody] [die]
  ask peoples with [move? = true][
    ;if distance to-node < speed                     ;; round off error fix
    ;[ move-to to-node die]
    ;set speed speed * (random 1.5 + 1.5)
    ifelse distance to-node > speed
    [ ;face to-node
       if patch-ahead speed != nobody[
        ifelse [depth] of patch-ahead speed * 10 < 300
        [Your-Move-Function]
        [Your-Bounce-Function]
       ]
    ]
    [move-to to-node die] 
  ]  

  ;ask peoples with [move? = true][face to-node fd speed]

  ask peoples with [move? = true][if [depth] of patch-here > 300 [set color red set move? false set speed  0]]
  if ticks > 180 [stop]
  tick
end

to warning
    let danger nodes with [[depth] of patch-here > 300 ]
    ask danger [set color 119]
    ask (turtle-set boats buses) with [color = green and (member? to-node in-out)] [
    if random 1000 < 786 and random 1 < awareness and ( member? (one-of nodes with [color = 119]) p )
      [ set start? true     ;;warned
        set to-node min-one-of in-out [distance myself]
       if member? next-node (nodes with [color != 119]) [set from-node next-node        
                                                         move-to from-node]
      ]
      let fn from-node
      let tn to-node
      set p [nw:turtles-on-path-to tn] of fn          ;;0.765 recieve info
    ]
    ask peoples [ 
       set start? true      ;;warned
       set speed speed * (random 1.5 + 1.5)
       if random 1000 < 786 and random 1 < awareness [
          set next-node to-node move-to min-one-of city-POIs [distance myself]
          set speed speed / 1000    ;stop       
       ]
      if [rainfall] of patch-here < 0.05
         [set speed speed * 1000 set to-node next-node ]
       ]
    
end

to m-p
  init-people
  ask peoples [set size 6 set color black
    ifelse distance to-node > speed
    [
      ;face to-node
      if patch-ahead speed != nobody[
        ifelse [depth] of patch-ahead 5 * speed < 300
        [Your-Move-Function]
        [Your-Bounce-Function]
      ]
      ]
    [move-to to-node die]
    
    ]
  tick
end

to init-cars
 ask boats with [(length p) = 0] [die]
 ask buses with [(length p) = 0] [die]  
 ;let n min-one-of nodes [distancexy mouse-xcor mouse-ycor]
  ;  while [mouse-down?] [ ask n [setxy mouse-xcor mouse-ycor] ]
   ; ask boats with [to-node = n or from-node = n] [ set to-node n move-to n ] 
  ;ask boats [if next-node = to-node [die]]
  
  ;ask boats [if start-time <= ticks [set hidden? false set color green]]
 ask (turtle-set boats buses) 
  [ set next-node item i p
    face next-node
    fd min list speed distance next-node
    if distance next-node < .0001 ;; round off error fix
    [ move-to next-node 
      ;set next-node [end2] of cur-link face next-node
      ifelse next-node != to-node [set i i + 1] 
                                  [move-to next-node die]
    ]
  ]
  tick
end

to reroute
  ask patches with [depth > 300] [ask min-one-of nodes [distance myself] [die]]
  ask boats [
    if [speed] of boats in-cone 3 45 = 0 [set start? false set speed 0 set color yellow]
  ]
  ask boats with [color = yellow][
   let fn next-node
   let tn to-node
   set p [nw:turtles-on-path-to tn] of fn
    ]
end
;;;;;;;;;;;;;;;;;;;;;;;

to flow7
  if ticks <= 180 * (60 / step) [
  let index floor (ticks / (60 / step) ) 
  ask patches [set rainfall (item index p_density) / 60 * step]
  ask patches [if ticks < (360 * 60 / step) [set rainfall 6.1 / 3 / 3600 * step]  ]  
      
  ask patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor][
    set depth max list 0 (depth + rainfall * runoff_c - Drainage / 3600 * step)
    ;set droplet droplet + rainfall
    set dH depth + elevation * 1000
    let xx [dH] of neighbors4 with [landuse != 9999] 
    if depth > 0 and not empty? xx and dH > min xx
      [
      let target_cell set-target2 neighbors4 with [landuse != 9999] dH
      let cells (patch-set target_cell self)
      ask cells [ set dH mean [dH] of cells] 
      ]
   ]
  ]
  ;show (sum [runoff_c * droplet] of patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor]) / (sum [depth] of patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor]) 
  ;ask patch 50 50 [set h h + rainfall show h]
  if ticks > (360 * 60 / step) [stop]
  tick
end

to pump
  ask patches with [ pxcor > 1 and pycor > 1  and pxcor < max-pxcor and pycor < max-pycor][
    set depth max list 0 (depth - Drainage / 3600 * step)
  ]
end

to init-bus
   ;[node 76 node 58 node 62 node 78 node 11 node 137 node 138 node 61 node 60 node 59 node 47 node 63 node 62 node 58 node 76]    ;lv3 line
   let lv3 [76 58 62 78 11 137 138 61 60 59 47 63 62 58 76]    ;lv3 line
   let lv3_1_501 [53 52 36 37 31 32 33 34 35 23 46 26 49 50 22 44 45 27 43 42 41 40 39 38 73 74]     
   let lv3_2 [90 17 16 15 14 13 12 127 83 5 134 133 132 131 99 130 129] 
   let lv2_2_l2 [87 86 77 79 121 122 5 134 133 132 131 99 130 129] 
   let lv2_1_l2 [24 23 35 34 33 32 31 37 36 52 53]
   let lv1 [87 86 77 79 121 122 5 83 127 12 13 14 15 16 17 90]
   let l9_908 [25 26 136 51 65 66 80 81 82 83 123 93 94 95 119 2 1 0 106 92 109 ]
   let l908e [129 130 99 105 120 119 2 1 0 106 92 91 17 75 38 73 74]
   let l907 [29 30 31 32 33 34 35 23 46 26 49 50 22 44 45 27 28]
   let l907b [25 26 49 50 22 44 45 27 28]
   let l901p [24 23 48 47 63 62 79 89 101]
   let l901_1 [24 23 48 57 56 55 54 36 52 53]      
   let l901_2 [87 86 77 79 89 101]
   let l808 [36 37 31 32 33 34 35 23 46 26 49 50 22 44 45 27 43 42 41 40 39 38 73 74]
   let l804 [87 86 77 79 89 101]
   let l803_1 [87 86 77 79 89 101]    
   let l803_2 [58 52 36 37 31 32 33 34 35 23 46 26 49 50 22 44 117 116 115 114 68 72 75 85]
   let l7_602_104 [110 92 91 17 90]
   let l707 [96 88 97 89 100 99 105 120 119 2 1 0 106 92 109]
   let l701 [110 92 91 17 75 38 73 74]
   let l6 [76 58 62 78 11 66 20 84 72 75 17 91 92 110]
   let l405 [25 26 136 51 65 66 20 84 72 75 85]
   let l402_159_115 [25 26 136 51 65 66 80 81 82 83 128 123 93 94 95 119 107 108]
   let l401_317_312_12_118_117 [76 58 62 78 11 66 20 84 72 75 85]
   let l368_138 [87 86 77 79 121 122 5 83 127 12 13 14 15 16 17 90]
   let l348 [25 26 136 51 65 66 80 81 82 83 128 123 93 94 95 119 2 1 0 106 92 91 17 90]
   let l314 [76 58 62 78 11 66 80 81 82 83 123 93 94 95 2 119 120 105 104 103]
   let l303 [76 58 62 78 11 66 65 51 136 26 49 50 22 21]
   let l302_168_136 [21 22 44 117 116 115 114 68 71 38 73 74]
   let l301_p_1 [87 86 77 79 121 122 5 134 133 132 131 99 105 120 119 1 0 106 92 109]
   let l301_p_2 [76 58 62 79 121 122 5 134 133 132 131 99 105 120 119 1]
   let l202_1 [76 58 62 79 121 122 5 134 133 132 131 99 130 129]
   let l202_2 [110 92 91 17 75 85]
   let l1 [53 52 36 54 55 56 57 47 59 60 61 118 51 64 67 68 71 38 73 74]
   let l18 [87 86 77]
   let l150 [21 22 50 49 26 136 51 65 66 80 81 82 83 128 123 93 94 95 119 107 108]
   let l146 [21 22 44 117 116 115 114 68 72 75 17 91 92 110]
   let l145 [87 86 77 79 89 101]
   let l143_1 [101 89 97 88 96] 
   let l143_2 [53 52 36 37 31 32 33 34 35 23 24]
   let l142 [24 23 48 47 59 60 61 118 51 64 67 68 71 38 73 74]
   let l139 [102 103 104 105 128 93 124 125 126 12 13 14 15 16 17 90]
   let l103 [21 22 44 117 116 115 114 68 72 75 17 91 92 109]
   let l128 [36 37 31 30 29]
   let l124 [79 121 122 5 83 127 12 13 14 15 16 17 91 92 110]
   let l122 [102 103 104 105 120 119 2 1 0 106 92 109]
   let l11 [87 86 77 79 121 122 5 134 133 132 131 99 105 120 119 2 1 0 4 3]
   let l116 [25 26 136 51 65 66 80 81 82 83 128 123 93 94 95 119 2 1 0 4 3]
   let l113 [21 22 44 117 116 115 114 68 72 75 85]
   let l112_1 [21 22 50 49 26 46 23 48 47 57 56 55 54 36 52 53] 
   let l112_2 [87 86 77 79 121 122 5 83 127 12 13 14 15 16 17 90]
   let l111 [24 23 46 26 49 50 22 44 117 116 115 114 68 72 75 85]
   let l109 [25 26 136 51 65 66 11 78 62 58 76]
   let l106 [24 23 48 47 63 62 58 76]
   let l105 [108 107 2 95 94 93 123 83 82 81 80 66 20 84 72 75 85]
   let l102 [82 83 123 93 94 95 2 1 0 106 92 109]
   let l101 [3 4 0 106 92 109]
end

to init-bus2
   let max-speed  ((max-speed-km/h / 3.6) * 60 / 10);; step = 60s, 1 min
   let min-speed  max-speed * (1 - speed-variation) ;; max-speed - (max-speed * speed-variation)
  
   let lv3 (list node 76 node 58 node 62 node 78 node 11 node 137 node 138 node 61 node 60 node 59 node 47 node 63 node 62 node 58 node 76)
   create-buses 1 [set size 5 set shape "bus" set line "lv3" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p lv3 
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p)) 
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "lv3" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse lv3 
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let lv3p_1_501 (list node 53 node 52 node 36 node 37 node 31 node 32 node 33 node 34 node 35 node 23 node 46 node 26 node 49 node 50 node 22 node 44 node 45 node 27 node 43 node 42 node 41 node 40 node 39 node 38 node 73 node 74)  
   create-buses 1 [set size 5 set shape "bus" set line "lv3p" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p lv3p_1_501 
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "lv3p" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse lv3p_1_501
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "501" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p lv3p_1_501 
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "501" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse lv3p_1_501
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
    
   let lv3p_2 (list node 90 node 17 node 16 node 15 node 14 node 13 node 12 node 127 node 83 node 5 node 134 node 133 node 132 node 131 node 99 node 130 node 129) 
   create-buses 1 [set size 5 set shape "bus" set line "lv3p2" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p lv3p_2 
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "lv3p2" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse lv3p_2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let lv2_2_l2 (list node 87 node 86 node 77 node 79 node 121 node 122 node 5 node 134 node 133 node 132 node 131 node 99 node 130 node 129)
   create-buses 2 [set size 5 set shape "bus" set line one-of (list "lv2_2" "l2") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p lv2_2_l2 
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 2 [set size 5 set shape "bus" set line one-of (list "lv2_2" "l2") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse lv2_2_l2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let lv2_1_l2 (list node 24 node 23 node 35 node 34 node 33 node 32 node 31 node 37 node 36 node 52 node 53)
   create-buses 2 [set size 5 set shape "bus" set line one-of (list "lv2_1" "l2") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p lv2_1_l2 
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 2 [set size 5 set shape "bus" set line one-of (list "lv2_1" "l2") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse lv2_1_l2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
      
   let lv1 (list node 87 node 86 node 77 node 79 node 121 node 122 node 5 node 83 node 127 node 12 node 13 node 14 node 15 node 16 node 17 node 90)
   create-buses 1 [set size 5 set shape "bus" set line "lv1" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p lv1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "lv1" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse lv1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
      
   let l9_908 (list node 25 node 26 node 136 node 51 node 65 node 66 node 80 node 81 node 82 node 83 node 123 node 93 node 94 node 95 node 119 node 2 node 1 node 0 node 106 node 92 node 109)
   create-buses 2 [set size 5 set shape "bus" set line one-of (list "9" "908") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l9_908 
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 2 [set size 5 set shape "bus" set line one-of (list "9" "908") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l9_908
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l908e (list node 129 node 130 node 99 node 105 node 120 node 119 node 2 node 1 node 0 node 106 node 92 node 91 node 17 node 75 node 38 node 73 node 74)
   create-buses 1 [set size 5 set shape "bus" set line "908e" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l908e
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "908e" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l908e
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l907 (list node 29 node 30 node 31 node 32 node 33 node 34 node 35 node 23 node 46 node 26 node 49 node 50 node 22 node 44 node 45 node 27 node 28)
   create-buses 1 [set size 5 set shape "bus" set line "907" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l907
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "907" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l907
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l907b (list node 25 node 26 node 49 node 50 node 22 node 44 node 45 node 27 node 28)
   create-buses 1 [set size 5 set shape "bus" set line "907b" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l907b
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "907b" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l907b
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
      
   let l901p (list node 24 node 23 node 48 node 47 node 63 node 62 node 79 node 89 node 101)
   create-buses 1 [set size 5 set shape "bus" set line "901p" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l901p
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "901p" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l901p
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l901_1 (list node 24 node 23 node 48 node 57 node 56 node 55 node 54 node 36 node 52 node 53)
   create-buses 1 [set size 5 set shape "bus" set line "901_1" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l901_1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "901_1" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l901_1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
         
   let l901_2 (list node 87 node 86 node 77 node 79 node 89 node 101)
   create-buses 1 [set size 5 set shape "bus" set line "901_2" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l901_2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "901_2" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l901_2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
      
   let l808 (list node 36 node 37 node 31 node 32 node 33 node 34 node 35 node 23 node 46 node 26 node 49 node 50 node 22 node 44 node 45 node 27 node 43 node 42 node 41 node 40 node 39 node 38 node 73 node 74)
   create-buses 1 [set size 5 set shape "bus" set line "808" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l808
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "808" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l808
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
      
   let l804 (list node 87 node 86 node 77 node 79 node 89 node 101)
   create-buses 1 [set size 5 set shape "bus" set line "804" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l804
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "804" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l804
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
    
   let l803_1 (list node 87 node 86 node 77 node 79 node 89 node 101)
   create-buses 1 [set size 5 set shape "bus" set line "803" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l803_1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "803" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l803_1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
        
   let l803_2 (list node 58 node 52 node 36 node 37 node 31 node 32 node 33 node 34 node 35 node 23 node 46 node 26 node 49 node 50 node 22 node 44 node 117 node 116 node 115 node 114 node 68 node 72 node 75 node 85)
   create-buses 1 [set size 5 set shape "bus" set line "802" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l803_2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "802" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l803_2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l7_602_104 (list node 110 node 92 node 91 node 17 node 90)
   create-buses 3 [set size 5 set shape "bus" set line one-of (list "7" "602" "104") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l7_602_104
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 3 [set size 5 set shape "bus" set line one-of (list list "7" "602" "104") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l7_602_104
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l707 (list node 96 node 88 node 97 node 89 node 100 node 99 node 105 node 120 node 119 node 2 node 1 node 0 node 106 node 92 node 109)
   create-buses 1 [set size 5 set shape "bus" set line "707" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l707
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "707" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l707
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
      
   let l701 (list node 110 node 92 node 91 node 17 node 75 node 38 node 73 node 74)
   create-buses 1 [set size 5 set shape "bus" set line "701" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l701
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "701" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l701
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l6 (list node 76 node 58 node 62 node 78 node 11 node 66 node 20 node 84 node 72 node 75 node 17 node 91 node 92 node 110)
   create-buses 1 [set size 5 set shape "bus" set line "6" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l6
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "6" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l6
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l405 (list node 25 node 26 node 136 node 51 node 65 node 66 node 20 node 84 node 72 node 75 node 85)
   create-buses 1 [set size 5 set shape "bus" set line "405" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l405
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line "405" set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l405
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l402_159_115 (list node 25 node 26 node 136 node 51 node 65 node 66 node 80 node 81 node 82 node 83 node 123 node 93 node 94 node 95 node 119 node 107 node 108)
   create-buses 3 [set size 5 set shape "bus" set line one-of (list "402" "159" "115") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l402_159_115
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 3 [set size 5 set shape "bus" set line one-of (list "402" "159" "115") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l402_159_115
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
      
   let l401_317_312_12_118_117 (list node 76 node 58 node 62 node 78 node 11 node 66 node 20 node 84 node 72 node 75 node 85)
   create-buses 6 [set size 5 set shape "bus" set line one-of (list "401" "317" "312" "12" "118" "117") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l401_317_312_12_118_117
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 6 [set size 5 set shape "bus" set line one-of (list "401" "317" "312" "12" "118" "117") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l401_317_312_12_118_117
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l368_138 (list node 87 node 86 node 77 node 79 node 121 node 122 node 5 node 83 node 127 node 12 node 13 node 14 node 15 node 16 node 17 node 90)
   create-buses 2 [set size 5 set shape "bus" set line one-of (list "368" "138") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l368_138
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 2 [set size 5 set shape "bus" set line one-of (list "368" "138") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l368_138
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
      
   let l348 (list node 25 node 26 node 136 node 51 node 65 node 66 node 80 node 81 node 82 node 83 node 128 node 123 node 93 node 94 node 95 node 119 node 2 node 1 node 0 node 106 node 92 node 91 node 17 node 90)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "348") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l348
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "348") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l348
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
      
   let l314 (list node 76 node 58 node 62 node 78 node 11 node 66 node 80 node 81 node 82 node 83 node 123 node 93 node 94 node 95 node 2 node 119 node 120 node 105 node 104 node 103)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "314") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l314
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "314") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l314
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
      
   let l303 (list node 76 node 58 node 62 node 78 node 11 node 66 node 65 node 51 node 136 node 26 node 49 node 50 node 22 node 21)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "303") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l303
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "303") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l303
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l302_168_136 (list node 21 node 22 node 44 node 117 node 116 node 115 node 114 node 68 node 71 node 38 node 73 node 74)
   create-buses 3 [set size 5 set shape "bus" set line one-of (list "302" "168" "136") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l302_168_136
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 3 [set size 5 set shape "bus" set line one-of (list "302" "168" "136") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l302_168_136
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l301_p_1 (list node 87 node 86 node 77 node 79 node 121 node 122 node 5 node 134 node 133 node 132 node 131 node 99 node 105 node 120 node 119 node 1 node 0 node 106 node 92 node 109)
   create-buses 2 [set size 5 set shape "bus" set line one-of (list "301p" "301") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l301_p_1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 2 [set size 5 set shape "bus" set line one-of (list "301p" "301") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l301_p_1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ] 
   
   let l301_p_2 (list node 76 node 58 node 62 node 79 node 121 node 122 node 5 node 134 node 133 node 132 node 131 node 99 node 105 node 120 node 119 node 1)
   create-buses 2 [set size 5 set shape "bus" set line one-of (list "301p" "301") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l301_p_2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 2 [set size 5 set shape "bus" set line one-of (list "301p" "301") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l301_p_2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ] 
      
   let l202_1 (list node 76 node 58 node 62 node 79 node 121 node 122 node 5 node 134 node 133 node 132 node 131 node 99 node 130 node 129)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "202") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l202_1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "202") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l202_1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l202_2 (list node 110 node 92 node 91 node 17 node 75 node 85)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "202") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l202_2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "202") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l202_2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
      
   let l1 (list node 53 node 52 node 36 node 54 node 55 node 56 node 57 node 47 node 59 node 60 node 61 node 118 node 51 node 64 node 67 node 68 node 71 node 38 node 73 node 74)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "1") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "1") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l18 (list node 87 node 86 node 77)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "18") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l18
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "18") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l18
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l150 (list node 21 node 22 node 50 node 49 node 26 node 136 node 51 node 65 node 66 node 80 node 81 node 82 node 83 node 128 node 123 node 93 node 94 node 95 node 119 node 107 node 108)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "150") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l150
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "150") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l150
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]   
   
   let l146 (list node 21 node 22 node 44 node 117 node 116 node 115 node 114 node 68 node 72 node 75 node 17 node 91 node 92 node 110)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "146") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l146
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "146") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l146
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l145 (list node 87 node 86 node 77 node 79 node 89 node 101)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "145") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l145
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "145") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l145
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l143_1 (list node 101 node 89 node 97 node 88 node 96)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "143") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l143_1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "143") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l143_1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
    
   let l143_2 (list node 53 node 52 node 36 node 37 node 31 node 32 node 33 node 34 node 35 node 23 node 24)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "143") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l143_2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "143") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l143_2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l142 (list node 24 node 23 node 48 node 47 node 59 node 60 node 61 node 118 node 51 node 64 node 67 node 68 node 71 node 38 node 73 node 74)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "142") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l142
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "142") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l142
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l139 (list node 102 node 103 node 104 node 105 node 128 node 93 node 124 node 125 node 126 node 12 node 13 node 14 node 15 node 16 node 17 node 90)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "139") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l139
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "139") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l139
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
      
   let l103 (list node 21 node 22 node 44 node 117 node 116 node 115 node 114 node 68 node 72 node 75 node 17 node 91 node 92 node 109)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "103") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l103
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "103") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l103
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l128 (list node 36 node 37 node 31 node 30 node 29)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "128") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l128
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "128") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l128
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l124 (list node 79 node 121 node 122 node 5 node 83 node 127 node 12 node 13 node 14 node 15 node 16 node 17 node 91 node 92 node 110)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "124") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l124
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "124") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l124
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l122 (list node 102 node 103 node 104 node 105 node 120 node 119 node 2 node 1 node 0 node 106 node 92 node 109)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "122") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l122
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "122") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l122
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l11 (list node 87 node 86 node 77 node 79 node 121 node 122 node 5 node 134 node 133 node 132 node 131 node 99 node 105 node 120 node 119 node 2 node 1 node 0 node 4 node 3)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "11") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l11
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "11") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l11
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l116 (list node 25 node 26 node 136 node 51 node 65 node 66 node 80 node 81 node 82 node 83 node 128 node 123 node 93 node 94 node 95 node 119 node 2 node 1 node 0 node 4 node 3)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "116") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l116
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "116") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l116
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l113 (list node 21 node 22 node 44 node 117 node 116 node 115 node 114 node 68 node 72 node 75 node 85)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "113") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l113
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "113") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l113
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l112_1 (list node 21 node 22 node 50 node 49 node 26 node 46 node 23 node 48 node 47 node 57 node 56 node 55 node 54 node 36 node 52 node 53)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "112") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l112_1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "112") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l112_1
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ] 
   
   let l112_2 (list node 87 node 86 node 77 node 79 node 121 node 122 node 5 node 83 node 127 node 12 node 13 node 14 node 15 node 16 node 17 node 90)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "112") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l112_2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "112") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l112_2
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ] 
      
   let l111 (list node 24 node 23 node 46 node 26 node 49 node 50 node 22 node 44 node 117 node 116 node 115 node 114 node 68 node 72 node 75 node 85)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "111") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l111
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "111") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l111
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l109 (list node 25 node 26 node 136 node 51 node 65 node 66 node 11 node 78 node 62 node 58 node 76)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "109") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l109
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "109") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l109
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
      
   let l106 (list node 24 node 23 node 48 node 47 node 63 node 62 node 58 node 76)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "106") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l106
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "106") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l106
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l105 (list node 108 node 107 node 2 node 95 node 94 node 93 node 123 node 83 node 82 node 81 node 80 node 66 node 20 node 84 node 72 node 75 node 85)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "105") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l105
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "105") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l105
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l102 (list node 82 node 83 node 123 node 93 node 94 node 95 node 2 node 1 node 0 node 106 node 92 node 109)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "102") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l102
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "102") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l102
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   
   let l101 (list node 3 node 4 node 0 node 106 node 92 node 109)
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "101") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p l101
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]
   create-buses 1 [set size 5 set shape "bus" set line one-of (list "101") set color green set speed min-speed + random-float (max-speed - min-speed)
                   set p reverse l101
                   set cur-link (link [who] of (item 0 p) [who] of (item 1 p))  
                   move-to first p
                   set from-node first p
                   set to-node last p
                   ]   
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to Your-Move-Function
  let t to-node 
  face min-one-of all-possible-moves [distance t]
  fd speed
end

to Your-Bounce-Function 
  let t to-node 
  face min-one-of all-possible-moves [distance t]
  end

to-report all-possible-moves
  report patches in-radius 1 with [pcolor != red and distance myself  <= 1 and distance myself  > 0 and plabel = "" ]
end

to leave-a-trail
  ask patch-here [set plabel ticks]
end
@#$#@#$#@
GRAPHICS-WINDOW
5
10
555
535
-1
-1
2.0
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
269
0
246
1
1
1
ticks
1.0

BUTTON
1100
10
1172
43
setup_
setup\nimport-drawing \"./data2015/riskmap.png\"\n\n
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
1520
565
1640
598
display-slope
;gis:paint slope 1\ngis:apply-raster slope p_slope
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
1400
565
1520
598
display-aspect
display-aspect-in-patches\n;ask patches [set pcolor gradient:scale  [[ 255 255 255 ] [245 135 48] [25 175 47] [0 0 0]] p_aspect 360 0]\n
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
1280
565
1400
598
display-rainfall
ask patches [\n  set pcolor gradient:scale ;palette:scale-gradient \n  [[255 255 255] [0 0 255]] rainfall 0 15\n  ]
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
1010
240
1100
273
DEM color
;set pcolor palette:scale-gradient [[ 0 255 64 ] [ 0 255 0] [ 0 192 0] [ 0 96 0] [255 255 0] [255 165 0] [255 0 32] [255 64 128] [255 255 255]] elevation 0 73\n;gradient:scale [[r g b] [r g b]] value range1 range2\nset pcolor gradient:scale ;palette:scale-gradient\n        (list extract-rgb (yellow + 2)\n          extract-rgb (yellow - 2)\n          extract-rgb (lime - 1.5)\n          extract-rgb (green - 2)\n          extract-rgb (brown - 1.5)\n          extract-rgb (gray - 2)\n          extract-rgb (gray + 4) )\n    elevation 33 73
NIL
1
T
PATCH
NIL
NIL
NIL
NIL
1

BUTTON
1450
285
1570
318
depth color
ask patches [\n  ;set pcolor palette:scale-gradient [[255 255 255] [255 255 0] [255 165 0] [255 128 0] [255 0 0]] depth 0 1\n  set pcolor gradient:scale ;palette:scale-gradient \n  [[255 255 255][ 0 192 0] [ 0 96 0] [255 255 0] [255 165 0] [255 0 32] ] depth 0 1\n  \n  ;set pcolor palette:scale-gradient [89 88 87 86 85 95 105] depth 0 1\n    ;set pcolor scale-color red depth 100 0\n  ]\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1470
635
1542
668
R_plot
;(r:putagentdf \"simdata\" patches \"pcolor\" \"runoff\" \"depth\") \n;let evalstring (word \"write.table(simdata ,file='\" path \"')\")\n;r:eval evalstring
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
1450
320
1570
353
runoff color
ask patches [\n  set pcolor gradient:scale ;palette:scale-gradient  \n  [[255 255 255] [0 0 255] ] runoff 0 10\n  ;set pcolor scale-color blue depth 128 0\n]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1010
205
1095
238
>= 30 cm
ask patches with [depth < 100] [set pcolor white]\nask patches with [depth >= 300] [set pcolor red]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
1445
220
1580
280
file_path
D:/NetLogo/Pre_Runoff/output/simdata.txt
1
0
String

SLIDER
1100
45
1220
78
zoom
zoom
0.1
2
1
0.1
1
NIL
HORIZONTAL

PLOT
560
10
970
205
Depth
time(min)
Depth(mm)
0.0
60.0
0.0
1.0
true
true
"" ""
PENS
"Maxdepth" 30.0 0 -13345367 true "" "plotxy (ticks)  (max [depth] of patches )"
"Furong-51" 10.0 0 -8630108 true "" "plotxy ticks ([depth] of patch 130 120)"
"POI1" 30.0 0 -2674135 true "" "plotxy ticks ([depth] of patch 112 156)"
"芙蓉广场" 10.0 0 -7500403 true "" "plotxy ticks ([depth] of patch 119 130)"
"八一桥" 10.0 0 -4699768 true "" "plotxy ticks ([depth] of patch 122 154)"
"迎宾路" 10.0 0 -1184463 true "" "plotxy ticks ([depth] of patch 182 149)"
"芙蓉-人民" 10.0 0 -14439633 true "" "plotxy ticks ([depth] of patch 136 23)"
"pen-7" 1.0 0 -955883 true "" "plotxy ticks ([depth] of patch 120 146)"
"pen-8" 1.0 0 -6459832 true "" "plotxy ticks ([depth] of patch 129 120)"

PLOT
560
205
865
405
Mean Precipitation
time(min)
rainfall(mm)
0.0
480.0
0.0
5.0
true
false
"" ""
PENS
"rainfall density" 5.0 0 -13345367 true "" "plotxy (ticks )  [rainfall] of patch 10 10"
"accumulated rainfall" 5.0 1 -7500403 true "" "plotxy (ticks ) [droplet] of patch 10 10"

PLOT
1365
370
1560
525
Mean Runoff
NIL
NIL
0.0
60.0
0.0
3.0
true
false
"" ""
PENS
"runoff" 1.0 0 -13791810 true "" "plotxy ticks max [runoff] of patches"
"min-tick" 1.0 0 -2674135 true "" "plotxy ticks 10 / (max [runoff] of patches + sqrt (10 * max [dh] of patches) + 0.000001)"
"pen-2" 1.0 0 -7500403 true "" "plotxy (ticks * Ts / 60) ([runoff] of patch 46 44)"
"pen-3" 1.0 0 -14439633 true "" "plotxy (ticks * Ts / 60) ([runoff] of patch 57 68)"
"pen-4" 1.0 0 -6459832 true "" "plotxy (ticks * Ts / 60) ([runoff] of patch 91 69)"
"dh" 1.0 0 -1184463 true "" "plotxy ticks  max [dh] of patches"

BUTTON
1160
10
1225
43
zoom-in
  reset-ticks ct cp cd clear-links clear-all-plots clear-output\n  ;clear-drawing\n  let world (gis:envelope-of polygon) ;; [ minimum-x maximum-x minimum-y maximum-y ]\n  if zoom != 1 [\n    let x0 (item 0 world + item 1 world) / 2          \n    let y0 (item 2 world + item 3 world) / 2\n    let W0 zoom * (item 0 world - item 1 world) / 2   \n    let H0 zoom * (item 2 world - item 3 world) / 2\n    set world (list (x0 - W0) (x0 + W0) (y0 - H0) (y0 + H0))\n  ]\n  gis:set-world-envelope (world)\n  \n  load-attributes\n  ;display-aspect-in-patches\n\n  gis:apply-raster slope p_slope\n  ask patches [\n  ;  set fc (p_ndvi - 0.00177119) / (0.562732 - 0.00177119)\n  ;  if fc < 0 [ set fc 0]\n  ;  set lai 7.813 * p_ndvi + 0.789\n  ;  set smax 0.5 * lai + 0.1\n  ;  set Hw elevation\n  ;  set height elevation\n    set depth 0\n    set pcolor gradient:scale ;palette:scale-gradient\n        (list extract-rgb (yellow + 2)\n          extract-rgb (yellow - 2)\n          extract-rgb (lime - 1.5)\n          extract-rgb (green - 2)\n          extract-rgb (brown - 1.5)\n          extract-rgb (gray - 2)\n          extract-rgb (gray + 4) )\n    elevation 29 97\n  ]\n  random-seed 137\n \n  ask patches gis:intersecting roads [set pcolor black]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
1445
190
1580
223
Ts
Ts
1
60
40
1
1
s/step
HORIZONTAL

BUTTON
1280
530
1377
563
NIL
real-color
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
1285
600
1395
633
water-level
water-level
0
50
25
1
1
NIL
HORIZONTAL

SLIDER
1400
600
1515
633
mix-colors
mix-colors
0
1
0.6
0.1
1
NIL
HORIZONTAL

SLIDER
1520
600
1630
633
Intensity
Intensity
0
10
3
1
1
NIL
HORIZONTAL

BUTTON
1525
530
1602
563
NIL
shade
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
1495
50
1557
83
NIL
rain
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1494
15
1556
48
d*v
ask patches [\n  let hv depth * runoff\n  set pcolor gradient:scale ;palette:scale-gradient \n  [[255 255 255][ 0 192 0] [ 0 96 0] [255 255 0] [255 165 0] [255 0 32] ] hv 0 1\n  ]\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1495
120
1558
153
test
    ask patch 50 50 [\n      let c (patch-set self neighbors4) \n        let avg mean [elevation] of c\n        ask c [\n          if elevation > avg [set c c with [self != myself]]\n          show c show[elevation] of c\n        ]\n      ]
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
1495
85
1557
118
test2
let l (list 30 17 13 7 3)\n;show reduce - l\n\n;show reduce [if  ( ?1 > (mean l)) [remove ?1 l] ] l\nshow l
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
1495
155
1557
188
test3
    ask patch 50 50 [\n      let c (patch-set self neighbors) \n        let avg mean [elevation] of c\n        ask c [\n          if elevation > avg [set c c with [self != myself]]\n          show c show[elevation] of c\n        ]\n      ]
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
615
495
670
528
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

BUTTON
1415
90
1495
124
depth-color
ask turtles [die]\nask patches with [depth > 0][\n\n if depth < 1.5 [set pcolor 15]\n\n if depth < 1 [set pcolor 25] \n\n if depth < 0.75 [set pcolor 45]\n\n if depth < 0.5 [set pcolor 47]\n\n if depth < 0.25 [set pcolor 66]\n \n if depth < 0.10 [set pcolor 65]\n \n if depth < 0.05 [set pcolor 68]\n \n if depth < 0.025 [set pcolor 69]\n  ]\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
675
425
760
458
depth-area
ask patches [\n  ;set pcolor palette:scale-gradient [[255 255 255] [255 255 0] [255 165 0] [255 128 0] [255 0 0]] depth 0 1\n  set pcolor gradient:scale ;palette:scale-gradient \n  [[255 255 255]\n   [0 0 245]\n   [0 0 235]\n   [0 0 225] \n   [0 0 215] \n   [0 0 205] \n   [0 0 195] \n   [0 0 185] \n   [0 0 175] \n   [0 0 165]\n   [0 0 155] \n   [0 0 145] \n   [0 0 135] \n   [0 0 125]\n   [0 0 115] \n   [0 0 105] \n   [0 0 95] \n   [0 0 85] \n   [0 0 75] \n   [0 0 65]\n   [0 0 55]\n   [0 0 45] \n   [0 0 35] \n   [0 0 25] \n   [0 0 15]\n   [0 0 05]\n  ] depth 50 3000\n  \n  ;set pcolor palette:scale-gradient [89 88 87 86 85 95 105] depth 0 1\n    ;set pcolor scale-color red depth 100 0\n  ]\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1425
15
1491
49
blue2
ask turtles [die]\nask patches with [depth > 0][\n\n if depth < 2.5 [set pcolor 124]\n if depth < 2.0 [set pcolor 114]\n if depth < 1.75 [set pcolor 115] \n if depth < 1.5 [set pcolor 104]\n if depth < 1.25 [set pcolor 105]\n if depth < 1.0 [set pcolor 106]\n if depth < 0.95 [set pcolor 94]\n if depth < 0.85 [set pcolor 95]\n if depth < 0.75 [set pcolor 96]\n if depth < 0.65 [set pcolor 85]\n if depth < 0.55 [set pcolor 86]\n if depth < 0.45 [set pcolor 87]\n if depth < 0.35 [set pcolor 88]\n if depth < 0.25 [set pcolor 89]\n if depth < 0.1 [set pcolor white]\n ;set pcolor 123\n  ]\n
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
1100
80
1224
113
R1
R1
0.85
0.95
0.85
0.01
1
NIL
HORIZONTAL

SLIDER
1100
116
1225
149
R2
R2
0.1
0.2
0.15
0.01
1
NIL
HORIZONTAL

SLIDER
1102
152
1226
185
R3
R3
0.55
0.65
0.65
0.1
1
NIL
HORIZONTAL

SLIDER
1470
350
1590
383
R4
R4
0.25
0.35
0.29
0.01
1
NIL
HORIZONTAL

SLIDER
1100
185
1228
218
Drainage
Drainage
10
40
18
1
1
mm/h
HORIZONTAL

SLIDER
1099
225
1224
258
Peak_interval
Peak_interval
-30
30
-30
10
1
min
HORIZONTAL

BUTTON
1426
55
1492
89
blue3
ask patches [\n  ;set pcolor palette:scale-gradient [[255 255 255] [255 255 0] [255 165 0] [255 128 0] [255 0 0]] depth 0 1\n  set pcolor gradient:scale ;palette:scale-gradient \n  [[255 255 255]\n   [0 0 245]\n   [0 0 235]\n   [0 0 225] \n   [0 0 215] \n   [0 0 205] \n   [0 0 195] \n   [0 0 185] \n   [0 0 175] \n   [0 0 165]\n   [0 0 155] \n   [0 0 145] \n   [0 0 135] \n   [0 0 125]\n   [0 0 115] \n   [0 0 105] \n   [0 0 95] \n   [0 0 85] \n   [0 0 75] \n   [0 0 65]\n   [0 0 55]\n   [0 0 45] \n   [0 0 35] \n   [0 0 25] \n   [0 0 15]\n   [0 0 05]\n  ] depth 0.1 3\n  \n  ;set pcolor palette:scale-gradient [89 88 87 86 85 95 105] depth 0 1\n    ;set pcolor scale-color red depth 100 0\n  ]\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
1097
275
1222
320
Select-element
Select-element
"source" "destination" "obstacles" "erase obstacles"
0

BUTTON
1165
320
1220
353
NIL
draw
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1130
355
1220
388
Demo of A*
find-shortest-path-to-destination
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
1100
320
1160
353
creat_OD
create-source-and-destination
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
565
495
620
528
setup
setup\nask links [set thickness 2 set color black]
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
565
460
665
493
step
step
1
60
60
1
1
second
HORIZONTAL

SLIDER
930
10
1090
43
communication_rate
communication_rate
0
1
0.2
0.2
1
NIL
HORIZONTAL

SLIDER
930
45
1090
78
warning_time
warning_time
5
30
5
5
1
NIL
HORIZONTAL

SLIDER
930
80
1090
113
warning_cover_rate
warning_cover_rate
0.9
1
0.9
0.8
1
NIL
HORIZONTAL

SLIDER
930
115
1090
148
warning_recieve
warning_recieve
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
1235
270
1407
303
node-precision
node-precision
1
6
4
3
1
NIL
HORIZONTAL

SLIDER
1235
300
1407
333
boat-meters
boat-meters
1
10
4
1
1
NIL
HORIZONTAL

SLIDER
1235
200
1407
233
max-speed-km/h
max-speed-km/h
0
60
20
1
1
km/h
HORIZONTAL

SLIDER
1235
235
1407
268
speed-variation
speed-variation
0
1
0.9
0.1
1
NIL
HORIZONTAL

SLIDER
1235
165
1407
198
num-boats
num-boats
20
5000
122
20
1
NIL
HORIZONTAL

BUTTON
1200
475
1280
508
setup-cars
setup-cars\ninit-bus2\nask boats with [(length p) = 0] [die]\nask buses with [(length p) = 0] [die]\n\nask boats [set color yellow set size 3]\nask links [set color black set thickness 3]\nrepeat 15 [walk]\nreset-ticks
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
680
495
742
528
walk
walk\n;reroute
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1100
440
1162
473
stats
ask patches with [depth > 0.01] [if count boats-here > 0 [show self]]\n\nask nodes [if [depth] of patch-here > 0 [set size 10 set hidden? false]]\n\nask boats with [color = red] [ask cur-link [set color red set thickness 4]]
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
1160
440
1222
473
stat2
ask boats [if [depth] of patch-here > 0.3 [set color red]]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1115
390
1217
439
affected cars
count boats with [color = red]
17
1
12

SLIDER
1178
518
1270
551
num-car
num-car
0
0
0
0
1
NIL
HORIZONTAL

BUTTON
1100
475
1200
508
diffuse
ask patches [set dH elevation + depth]\n\ndiffuse depth 0.5
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
567
420
662
453
NIL
set-rainfall
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
935
150
1027
183
M_step
M_step
1
20
1
1
1
min
HORIZONTAL

BUTTON
1550
635
1613
668
NIL
rain
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1561
475
1711
524
dH
max [dh] of patches
17
1
12

MONITOR
1566
430
1708
479
max_runoff
max [runoff] of patches
17
1
12

MONITOR
1561
375
1711
424
min_tick
min [v ] of patches with [ v  > 0]
17
1
12

BUTTON
1290
460
1352
493
NIL
flow5
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1290
495
1352
528
NIL
flow7
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1285
340
1347
389
traffic
count turtles-on patch 128 120
17
1
12

PLOT
765
260
1075
425
traffic flow
time
flow
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 60.0 1 -10649926 true "" ";plotxy ticks [h] of patch 128 120"
"pen-1" 1.0 0 -7500403 true "" ";plotxy ticks count boats with [hidden? = false]"
"pen-2" 1.0 0 -2674135 true "" ";plotxy ticks count buses"
"pen-3" 1.0 0 -955883 true "" "plotxy ticks count boats with [speed = 0]"
"pen-4" 1.0 0 -1184463 true "" "plotxy ticks count boats with [start? = true]"
"pen-5" 1.0 0 -5825686 true "" "plotxy ticks count peoples with [color = red and start? = false]"
"pen-6" 1.0 0 -6459832 true "" "plotxy ticks count peoples"

BUTTON
1095
520
1180
553
count-cars
ask patch 128 120[ \nifelse ticks mod 5 != 0 \n[set g g + count turtles-here]\n[set g 0]\n]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
985
465
1092
498
engineering
ask patches with [runoff_c = 0.65][set runoff_c (random 5 + 35) / 100]\nset Drainage 55
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
915
470
987
503
move_1
ask peoples with [to-node != nobody][\n  face to-node fd 1\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1230
340
1287
389
node20
count turtles-on node 20
17
1
12

BUTTON
910
435
987
468
volumes
;ask node 2 [set h h + count turtles-here]\nask patch 128 120\n[set h h + count turtles-here]\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1232
390
1347
439
volume
;[h] of node 2\n[h] of patch 128 120
17
1
12

MONITOR
915
500
977
549
speed=0
count boats with [speed = 0]
17
1
12

MONITOR
915
560
987
609
color=red
count buses with [color = red and speed = 0]
17
1
12

MONITOR
1060
565
1165
614
s=0 and c=yellow
count boats with [start? = true]
17
1
12

BUTTON
680
465
743
498
NIL
trip
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
990
430
1082
463
go-people
go-people
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1030
155
1093
188
mp
m-p\n;ask people 7512 [set size 10 set color yellow]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
985
500
1092
533
node-remove
ask nodes [if [depth] of patch-here > 300 [die]]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
995
560
1082
609
NIL
count nodes
17
1
12

@#$#@#$#@
## WHAT IS IT?

This model was built to test and demonstrate the functionality of the GIS NetLogo extension.

## HOW IT WORKS

This model loads a raster file of surface elevation for a small area near Cincinnati, Ohio. It uses a combination of the `gis:convolve` primitive and simple NetLogo code to compute the slope (vertical angle) and aspect (horizontal angle) of the earth surface using the surface elevation data. Then it simulates raindrops flowing downhill over that surface by having turtles constantly reorient themselves in the direction of the aspect while moving forward at a constant rate.

## HOW TO USE IT

Press the setup button, then press the go button. You may press any of the "display-..." buttons at any time; they don't affect the functioning of the model.

## EXTENDING THE MODEL

It could be interesting to extend the model so that the "raindrop" turtles flow more quickly over steeper terrain. You could also add land cover information, and adjust the speed with which the turtles flow based on the land cover.

## RELATED MODELS

The other GIS code example, GIS General Examples, provides a greater variety of examples of how to use the GIS extension.

## CREDITS AND REFERENCES
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

bus
false
0
Polygon -7500403 true true 15 206 15 150 15 135 30 120 270 120 285 135 285 150 285 206 270 210 30 210
Circle -16777216 true false 240 195 30
Circle -16777216 true false 210 195 30
Circle -16777216 true false 60 195 30
Circle -16777216 true false 30 195 30
Rectangle -16777216 true false 30 140 268 165
Line -7500403 true 60 135 60 165
Line -7500403 true 60 135 60 165
Line -7500403 true 90 135 90 165
Line -7500403 true 120 135 120 165
Line -7500403 true 150 135 150 165
Line -7500403 true 180 135 180 165
Line -7500403 true 210 135 210 165
Line -7500403 true 240 135 240 165
Rectangle -16777216 true false 5 195 19 207
Rectangle -16777216 true false 281 195 295 207
Rectangle -13345367 true false 15 165 285 173
Rectangle -2674135 true false 15 180 285 188

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
NetLogo 5.0.5
@#$#@#$#@
setup
repeat 20 [ go ]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="false">
    <setup>setup
zoom-in</setup>
    <go>Storm Simulation</go>
    <metric>mean [depth] of patches</metric>
    <enumeratedValueSet variable="Ke">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>[depth] of patch 129 120</metric>
    <metric>[depth] of patch 136 26</metric>
    <metric>[depth] of patch 188 118</metric>
    <metric>[depth] of patch 118 154</metric>
    <steppedValueSet variable="R1" first="0.85" step="0.025" last="0.95"/>
    <steppedValueSet variable="R2" first="0.1" step="0.025" last="0.2"/>
    <steppedValueSet variable="R3" first="0.55" step="0.025" last="0.65"/>
    <steppedValueSet variable="Drainage" first="18" step="6" last="36"/>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>[depth] of patch 129 120</metric>
    <metric>[depth] of patch 136 26</metric>
    <metric>[depth] of patch 120 146</metric>
    <steppedValueSet variable="R1" first="0.85" step="0.05" last="0.95"/>
    <steppedValueSet variable="R2" first="0.1" step="0.05" last="0.2"/>
    <steppedValueSet variable="R3" first="0.55" step="0.05" last="0.65"/>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>walk</go>
    <metric>count boats with [color = red]</metric>
    <metric>count buses with [color = red]</metric>
    <steppedValueSet variable="Drainage" first="18" step="6" last="55"/>
    <steppedValueSet variable="R3" first="0.35" step="0.1" last="0.65"/>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>walk</go>
    <metric>count peoples with [color = red]</metric>
    <metric>count buses with [speed = 0]</metric>
    <metric>count boats with [speed = 0]</metric>
    <metric>count boats with [start? = true]</metric>
    <metric>count buses with [start? = true]</metric>
    <steppedValueSet variable="Drainage" first="36" step="4" last="55"/>
    <steppedValueSet variable="R3" first="0.35" step="0.05" last="0.6"/>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <steppedValueSet variable="Drainage" first="18" step="0.0010" last="18.095"/>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>trip</go>
    <metric>count peoples with [color = red]</metric>
    <steppedValueSet variable="Drainage" first="18" step="0.0010" last="18.099"/>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>walk</go>
    <metric>count peoples with [color = red and speed = 0]</metric>
    <metric>count buses with [speed = 0 ]</metric>
    <metric>count boats with [speed = 0 ]</metric>
    <metric>count boats with [start? = true]</metric>
    <metric>count buses with [start? = true]</metric>
    <steppedValueSet variable="warning_recieve" first="0.2" step="0.55" last="0.95"/>
    <steppedValueSet variable="warning_time" first="5" step="15" last="30"/>
  </experiment>
</experiments>
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
1
@#$#@#$#@
