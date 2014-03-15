globals [
  presionA
  presionB
  presionC
  numero-verdes
  numero-pinks
  
  despidos
  num-bajadas-sueldo
  num-aumentos-dedicacion
  num-confusiones
  
  nivel-de-medida ;; variable que almacena la dureza de la medida a aplicar
  lcolor
  
  ]
breed [ AA A ]
breed [ BB B ]
breed [ CC C ]
breed [ DD D ] ;; Aquí iremos añadiendo los despedidos

turtles-own [
  categoria ;; representa el sector del PDI
  vps      ;; variables psicologicas de 0 a 10 (10 muy motivao)
  presion  ;; representa la presion a la que esta sometido el PDI.
  salto    ;; presion * vps
  ]
  
to setup
  clear-all
  set lcolor [47 46 45 56 55.5 55 65]
  set-default-shape turtles "frog top"
  setup-pdi
  setup-spatially-clustered-network
  ask turtles [ set categoria (1 + floor presion)
    set label categoria]
  reset-ticks
end

to go
  conformismo
  contagio-pasivo
  
  ;;medidas-gobierno
  ;;medidas-pink
  set despidos count DD
  
  ask turtles with [vps < 0] [set vps 0] ;; Evitamos que se desborde el VPS
  ask turtles with [vps > 10] [set vps 10]
  ask turtles [set salto presion * vps]
  ask turtles with [salto < 0] [set salto 0] ;; Evitamos que se desborde el Salto
  ask turtles with [salto > 30] [set salto 30]
 
 
  ask turtles [recolor]
  tick
end

to setup-pdi
  create-AA 0.4 * numPDIs
  create-BB 0.3 * numPDIs
  create-CC 0.3 * numPDIs
  ask turtles [
    set size 2.5
    setxy (random-xcor * 0.95) (random-ycor * 0.95) ;; por razones esteticas
    set vps random 10;; vps
    set presion ((random 29) / 10) ;; presion
    set salto presion * vps;; salto
    recolor ;; recolorea
    ]
end

to setup-spatially-clustered-network
  let num-links (average-node-degree * numPDIs) / 2
  while [count links < num-links ]
  [
    ask one-of turtles
    [
      let choice (min-one-of (other turtles with [not link-neighbor? myself])
                   [distance myself])
      if choice != nobody [ create-link-with choice ]
    ]
  ]

  ;; make the network look a little prettier
  repeat 10
  [
    layout-spring turtles links 0.3 (world-width / (sqrt numPDIs)) 1
  ]
  ask turtles with [not any? link-neighbors ][die]   ;; Elimina las tortugas que se hayan quedado aisladas
end

to recolor
   ifelse salto >= 15 [set color 135 ] [ifelse salto < 8 [set color (4 + floor (salto / 2) + 0.5 * ((floor salto) mod 2))] [set color item (salto - 8) lcolor]] 
end

to contagio-pasivo
  ask turtles [set vps (
      vps + 0.5 * (mean [vps] of link-neighbors - vps)
      )
      
  ]
end
to conformismo
  ask turtles [set vps vps - 0.05]
end


;to medidas-gobierno
;
;end

;to medidas-pink
;
;end

to-report ranas-grises
  report turtles with [salto < 7]
end

to-report ranas-rosas
  report turtles with [ salto >= 15]
end

to-report ranas-verdes
  report turtles with [salto >= 7 and salto < 15]
end

to confusion
  
  set num-confusiones num-confusiones + 1
  
  ask ranas-grises[
    set vps vps - 0.5
  ]
  ask ranas-rosas[
    set vps vps + 0.5
  ]
  ask ranas-verdes[
    if (categoria = 1 or categoria = 3) [
      set vps vps - 0.25
      ]
  ]
    
end

to aumento-dedicacion
  
  set num-aumentos-dedicacion num-aumentos-dedicacion + 1
  
  ;;Modificamos el conjunto A
  let veinticincoA n-of (0.25 * count AA) AA
  let cincuentaA n-of (0.50 * count AA) AA with [not member? self veinticincoA]
  let restoA AA with [not member? self veinticincoA and not member? self cincuentaA]
  ask veinticincoA [
    set presion presion * 0.75
    set vps vps - 1]
  ask restoA [
    set presion presion + 0.1
    set vps vps + 1]
  
  ;;Modificamos el conjunto B
  let veinticincoB n-of (0.25 * count BB) BB
  let cincuentaB n-of (0.50 * count BB) BB with [not member? self veinticincoB]
  let restoB BB with [not member? self veinticincoB and not member? self cincuentaB]
  ask veinticincoB [
    set presion presion + 0.1
    ask ranas-verdes[
      set vps vps + 0.5
    ]
    ask ranas-rosas[
      set vps vps + 1]
  ]
  ask restoB [
    set presion presion + 0.5
    ask ranas-rosas[
      set vps vps + 0.1]
    ]
  let setentaycincoC n-of (0.75 * count CC) CC
  let restoC CC with [not member? self setentaycincoC]
  ask ranas-grises[
      set vps vps + 0.5]
  ask ranas-verdes[
     set vps vps + 0.8]
  ask ranas-rosas [ 
      set vps vps + 1.5]
    
end

to bajada-sueldo
  
  set num-bajadas-sueldo num-bajadas-sueldo + 1
  
  ask turtles [
    set presion presion + 0.5]
  ask AA [
    ask ranas-grises[
      set vps vps + 0.5]
    ask (turtle-set ranas-verdes ranas-rosas)[
      set vps vps + 1]
  ]
  ask BB[
    ask ranas-grises[
      set vps vps + 0.5]
    ask ranas-verdes[
      set vps vps + 1]
     ask ranas-rosas[
      set vps vps + 1.5]
  ]
  
  ask CC[
    ask ranas-grises[
      set vps vps + 0.5]
    ask ranas-verdes[
      set vps vps + 1.5]
     ask ranas-rosas[
      set vps vps + 2]
  ]
end

to expulsion
  
  let despedidos n-of (porcentaje-despidos * count CC) CC 
  ask despedidos [set breed DD
    ask link-neighbors with [salto >= 15] [set vps vps + 1]
    ask link-neighbors with [salto >= 8 and salto < 15] [set vps vps + 0.5]
    ask link-neighbors with [salto < 8] [set vps vps + 0.1]
    ]
  ask ranas-grises[
      set vps vps - 0.5]
  
  ask AA [
    ask ranas-verdes[
      set vps vps + 0.1]
    ask ranas-rosas[
      set vps vps + 0.5]
  ]
  
   ask BB[
   
    ask ranas-verdes[
      set vps vps + 0.1]
     ask ranas-rosas[
      set vps vps + 0.5]
  ]
  
    ask CC[

    ask ranas-verdes[
      set vps vps + 0.2]
     ask ranas-rosas[
      set vps vps + 0.75]
  ] 
end
