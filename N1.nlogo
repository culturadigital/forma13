
breed [nodos nodo]   ; Familia de agentes para los nodos del árbol/grafo

links-own
[  activado
   desactivado ]


nodos-own
[
  
  grado
  prob-nacer
  prob-morir
  ponderacion-nacer 
  ponderacion-morir 
  
  ]
  
to setup
  clear-all  
  create-nodos num-nodos[
 
  set shape "circle"
  layout-circle (sort nodos) max-pxcor - 1
  set grado  0
  set prob-nacer 0
  set prob-morir 0
  set ponderacion-nacer 0
  set ponderacion-morir 0
  
]
  reset-ticks
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Crear una red del tipo scale-free ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-scale-free
  clear-all  
  crear-nodo nobody
  crear-nodo nodo 0 
  ask nodos [
    set shape "circle"
  set grado  0
  set prob-nacer 0
  set prob-morir 0
  set ponderacion-nacer 0
  set ponderacion-morir 0 ]
  reset-ticks
  go-scale-free
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Crear una red con gradio medio dado ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-grafo-grado-medio
  ca
  create-nodos num-nodos[
    layout-circle (sort nodos) max-pxcor - 1
    set grado  0
    set prob-nacer 0
    set prob-morir 0
    set ponderacion-nacer 0
    set ponderacion-morir 0
    set shape "circle"
  ]

  ask nodos[
    let a (sum [grado] of nodos / count nodos)

    while [grado-medio > a][ 
      ask one-of nodos [
  
        let otro-nodo one-of other nodos
        create-link-with otro-nodo
        ask link-with otro-nodo
          [set color gray]
        set grado count my-links
        set a (sum [grado] of nodos / count nodos) ]]]
   reset-ticks
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Crear una red daleatoria ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-grafo-aleatorio
  ca
  create-nodos num-nodos[
    layout-circle (sort nodos) max-pxcor - 1
    set grado  0
    set prob-nacer 0
    set prob-morir 0
    set ponderacion-nacer 0
    set ponderacion-morir 0
    set shape "circle"
  ]
  ask nodos [
    let nodo one-of other turtles
    ask nodo [create-link-with one-of other nodos]
    
    ]
 reset-ticks  
end

;;;;;;;;;;;;;;;;;;;;;;;
;;; Main Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;

to go
  ask nodos [
  set grado count my-links 
  set ponderacion-nacer ( 1 * ( C1 + (grado)) * (N1 - grado))
  set ponderacion-morir ( 1 * ( C2 + (grado)) * (N2 - grado))
  ]

 encontrar-nodo-vivo
 encontrar-nodo-muerto
 

 
  
  
;se recorren todos los nodos y cada porcentaje se multiplica con un random,
; el de mayor nacimiento incementa su grado y se enlaza con otro al azar,aumentando el contador de ese enlace,
 ; y el de mayor muerte disminuye su grado y rompe un enlace al azar con otro nodo. finalmente se recalculan los porcenajes
  ;con los nuevos datos.  
;  update-plots
 tick 
 if plot? [do-plotting]
 if layout? [layout]
 if ticks > ticks-stop
  [stop]
end

to go-scale-free
  
  while [ticks < num-nodos - 2]
  [repeat 1
    [crear-nodo 
     encontrar-pareja
     tick ] ]
  
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Nacimiento de enlaces ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to encontrar-nodo-vivo

  let totalnacer random-float sum [ponderacion-nacer] of nodos with [grado < (num-nodos - 1)]         ;; elige nodo para crearle un enlace
  let nacer-elegido nobody
  ask nodos with [grado < (num-nodos - 1)]
    [ 
      if nacer-elegido = nobody
        [ ifelse ponderacion-nacer > totalnacer
            [ set nacer-elegido self 
              ask nacer-elegido[
                encontrar-otro-vivo] ]
            [ set totalnacer totalnacer - ponderacion-nacer ] ] ]
    
  
  end
  
to encontrar-otro-vivo

if ticks <= ticks-nacimiento [

    let otros-nodos nodos with [not link-neighbor? myself]
    let otro-nodo one-of other otros-nodos with [grado < (num-nodos - 1)]
    create-link-with otro-nodo
    ask nodos 
    [set grado count my-links]
    
    ]
end
  
;;;;;;;;;;;;;;;;;;;;;;;;
;;; Muerte de enlace ;;;
;;;;;;;;;;;;;;;;;;;;;;;;
  
to encontrar-nodo-muerto
    let totalmorir random-float sum [ponderacion-morir] of nodos with [grado > 0]       ;;elige nodo para matarle un enlace
    let morir-elegido nobody
  ask nodos with [grado > 0]
    [ 
      if morir-elegido = nobody
        [ ifelse ponderacion-morir > totalmorir
            [ set morir-elegido self
              ask morir-elegido
                [encontrar-otro-muerto] 
                   ]                    ;;; Si se cumple, encuentra un enlace para esconder, 
            [ set totalmorir totalmorir - ponderacion-morir ] ] ]                              ;;; SI NO, simplemente deja al nodo en grado 0
    
  end

to encontrar-otro-muerto

if ticks >= ticks-muerte
  [ ask one-of my-links
      [die] 
  ask nodos 
    [set grado count my-links] ]
      
end

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Scale-Free Network ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
  
to crear-nodo [viejo-nodo] 

  create-nodos 1
  [set grado  0
  set prob-nacer 0
  set prob-morir 0
  set ponderacion-nacer 0
  set ponderacion-morir 0
  if viejo-nodo != nobody
      [ create-link-with viejo-nodo 
        ask link-with viejo-nodo
          [ set color gray ]
        ;; position the new node near its partner
        move-to viejo-nodo
        fd 5
      ]
  ] 
end

to-report encontrar-pareja
  let total random-float sum [count link-neighbors] of nodos
  let pareja nobody
  ask nodos
  [
    let nc count link-neighbors
    ;; if there's no winner yet...
    if pareja = nobody
    [
      ifelse nc > total
        [ set pareja self ]
        [ set total total - nc ]
    ]
  ]
  report pareja
end


;;;;;;;;;;;;;
;;; Plots ;;;
;;;;;;;;;;;;;

to do-plotting
set-current-plot "Distribucion de grados"
  let max-grado max [grado] of nodos
  plot-pen-reset  ;; erase what we plotted before
  set-plot-x-range 0 (max-grado + 1)  ;; + 1 to make room for the width of the last bar
  histogram [grado] of nodos

set-current-plot "Degree Distribution (log-log)"
  plot-pen-reset  ;; erase what we plotted before
  ;; the way we create the network there is never a zero degree node,
  ;; so start plotting at degree one
  let degree 1
  while [degree <= max-grado]
  [
    let matches nodos with [grado = degree]
    if any? matches
      [ plotxy log degree 10
               log (count matches) 10 ]
    set degree degree + 1
  ]
end

;;;;;;;;;;;;;;;
;;; Formato ;;;
;;;;;;;;;;;;;;;

to layout
 repeat 3 [
    ;; the more turtles we have to fit into the same amount of space,
    ;; the smaller the inputs to layout-spring we'll need to use
    let factor sqrt count nodos
    ;; numbers here are arbitrarily chosen for pleasing appearance
    layout-spring nodos links (0.2 / factor) (5 / factor) (10 / factor)
    display  ;; for smooth animation
  ]
  ;; don't bump the edges of the world
  let x-offset max [xcor] of nodos + min [xcor] of nodos
  let y-offset max [ycor] of nodos + min [ycor] of nodos
  ;; big jumps look funny, so only adjust a little each time
  set x-offset limit-magnitude x-offset 0.1
  set y-offset limit-magnitude y-offset 0.1
  ask nodos [ setxy (xcor - x-offset / 2) (ycor - y-offset / 2) ]
end

to-report limit-magnitude [number limit]
  if number > limit [ report limit ]
  if number < (- limit) [ report (- limit) ]
  report number
end

to resize-nodes
  ifelse all? nodos [size <= 1]
  [
    ;; a node is a circle with diameter determined by
    ;; the SIZE variable; using SQRT makes the circle's
    ;; area proportional to its degree
    ask turtles [ set size sqrt grado ]
  ]
  [
    ask turtles [ set size 1 ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;
;;; Reporters;;;;;;;;
;;;;;;;;;;;;;;;;;;,;;


;to-report camino-medio
;   nw:set-snapshot nodos links
;   ask turtles [
;      report nw:mean-path-length]
;end
