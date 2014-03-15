breed[bacteria bacterium]
breed[extractors extractor]
globals[total-biomass
        total-product
        mass-total]


bacteria-own[
  mass ; masa del microorganismo de donde tomará su energía para las actividades
  latency-threshold ; minimo valor de masa para que el microorganismo quede en estado latente
  reproduction-threshold ; minimo valor de masa para que el microorganismo se reproduzca
  ]


patches-own[
  nutrient ; cantidad de alimento para los microorganismos(num entero)
  product ; cantidad de producto generado
  ]


to setup
  clear-all
  
  create-bacteria initial-bacteria [
    setxy random-xcor random-ycor
    set shape "bacterium2"
    set color red
    set mass random-normal initial-mass (initial-mass * std-mass) 
    update-size
    set reproduction-threshold mass-reproduction-threshold
    ]
  
  ask patches[
    set nutrient random-normal initial-nutrient (initial-nutrient * std-nutrient) 
    update-pcolor ;actualiza el color del patch segun la cantidad de nutriente
    set product 0 ;cantidad inicial de producto
 
    ]
  create-extractors 1[
     setxy 0 min-pycor
     set heading 0
  ]
  ask extractors[hide-turtle]
  
  set total-biomass 0
  set mass-total 0
  set total-product 0
  
  reset-ticks
  
  
  
end

;; movemos a los agentes
to go
  
   ask patch 0 max-pycor[
     salida-monitor
   ]
  
  ask bacteria [
    eat
    reproduction
    ;agitar
  ]
  ask patches [
    update-pcolor 
    
  ]
  diffuse-patches
 
 
      
  if(flow?)[
    every time[
       realimentacion
       agitar
       extract
    ]
  ]
   
  
  
  tick
 
  
end



;; metodos auxiliares(acciones)
to eat
  if( ([nutrient] of patch-here) >= 1)[
    set nutrient (nutrient - 1) ;el "1" es la ingesta de nutriente de esa bacteria
    set mass (mass + 1 * 0.15) ;calculamos el incremento de masa, como consecuencia de la ingesta de nutrientes
    update-size
    set product (product + 1 * 0.10) ; calcular incremento de producto por parte del microorganismo
    
  ]
  
  
end

to reproduction
  if( mass >= reproduction-threshold )[
    hatch 1 [
      move-to one-of neighbors
      set heading random 360
      set mass (mass / 2)
      update-size
      ] 
    set mass (mass / 2)
    update-size
  ]
    
end

to update-pcolor
  set pcolor scale-color yellow nutrient 10 0 
  
end

to update-size
  set size mass * 0.15
end

to realimentacion
  if(flow?)[
   ask patch 0 max-pycor [set nutrient (nutrient + var-nutrient)]
  ]
  diffuse-patches
  
end

to salida-monitor
  
  
  
  let cuenta 0
  
  let set-patches (patch-set patch 0 0 neighbors)
  
 
   set cuenta (sum [count bacteria-here ] of set-patches)
   
   output-show (cuenta)
   
   if( cuenta > flow-off )[
     set flow? false
   ]
 
end


to agitar
  ; para agitar nutrientes
  let nutrient-count (sum [nutrient] of patches)
  set nutrient-count (nutrient-count / count patches)
  
  ; para agitar producto
  let product-count (sum [product] of patches)
  set product-count (product-count / count patches)
  
  
  ;if(flow? = false)[
  ask bacteria[
    set heading random 360
    forward fuerza-agitacion
    ;set flow? true 
    ;]
   ]
  
  ; le pedimos a los patches que cambien su nutriente y su producto
  ask patches [set nutrient nutrient-count
               set product product-count
               update-pcolor]
  
end

;to gravity [porcentaje]


;end

  
to extract
  
  
  
  if(mass-total <= var-nutrient)[
    
     ask extractors [
    
          ask one-of patches in-cone max-pxcor 180 [
       
        set total-biomass (total-biomass + sum [mass] of bacteria-here )
        set total-product (total-product + product)
        set mass-total (mass-total + nutrient + product)
        
        set nutrient 0
        set product 0
        update-pcolor
        
        if(any? bacteria-here)[
           
          ask bacteria-here[die] 
          
          ]
        
       ]
    ]
     tick
  ]
  
   if(mass-total <= var-nutrient)[
     set mass-total 0
     agitar
     stop
   ] 
end

to diffuse-patches
  
    diffuse nutrient diffusion-coefficient
    diffuse product diffusion-coefficient
  
  
end
