extensions [rnd]

;;;;;;;;;;;;;;;;;;;;;;;
;;;      AGENTES    ;;;
;;;;;;;;;;;;;;;;;;;;;;;

breed [productos producto]
breed [consumidores consumidor]

productos-own [
  precio
  calidad 
  unidades-vendidas
]

consumidores-own [
 sesgo-precio
 lista-gustos
 nivel-exigencia
 fuerza-influencia
 proactividad                 ;; probabilidad de transmitir mis gustos
 consume?
 producto-consumido
 num-producto-consumido
 
 
 
 node-clustering-coefficient
 distance-from-other-turtles   ;; list of distances of this node from other turtles

]

links-own
[
  rewired?                    ;; keeps track of whether the link has been rewired or not
]


globals[
  lista-productos
  factor-de-influencia
  prob-preguntar-vecinos
  velocidad                          
  umbral
  
  ;;
  ;; Small Worlds variables
  ;;
  clustering-coefficient               ;; the clustering coefficient of the network; this is the
                                       ;; average of clustering coefficients of all turtles
  average-path-length                  ;; average path length of the network
  clustering-coefficient-of-lattice    ;; the clustering coefficient of the initial lattice
  average-path-length-of-lattice       ;; average path length of the initial lattice
  infinity                             ;; a very large number.
                                         ;; used to denote distance between two turtles which
                                         ;; don't have a connected or unconnected path between them
  highlight-string                     ;; message that appears on the node properties monitor
  number-rewired                       ;; number of edges that have been rewired. used for plots.
  rewire-one?                          ;; these two variables record which button was last pushed
  rewire-all?

]


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to startup
  set highlight-string ""
end

to sm_setup
  set infinity 99999  ;; just an arbitrary choice for a large number
  
  ;; set up a variable to determine if we still have a connected network
  ;; (in most cases we will since it starts out fully connected)
  let success? false
  while [not success?] [
    ;; we need to find initial values for lattice
    wire-them
    ;;calculate average path length and clustering coefficient for the lattice
    set success? do-calculations
  ]

  ;; setting the values for the initial lattice
  set clustering-coefficient-of-lattice clustering-coefficient
  set average-path-length-of-lattice average-path-length
  set number-rewired 0
  set highlight-string ""
end

to setup
  ca
  set factor-de-influencia 0.01
  set prob-preguntar-vecinos 0.2
  set velocidad 1
 
  create-consumidores poblacion[
    set sesgo-precio random-normal media-inclinacion-sesgo-precio 0.1
    if sesgo-precio < 0 [set sesgo-precio 0]
    if sesgo-precio > 1 [set sesgo-precio 1]
    set nivel-exigencia random-normal media-nivel-exigencia 0.1  ;;El nivel de exigencia lo coge por parametro de entrada y lo distribuye segun esa normal
    if nivel-exigencia < 0 [set nivel-exigencia 0]
    if nivel-exigencia > 1 [set nivel-exigencia 1]
    set fuerza-influencia random-normal media-fuerza-influenciabilidad 0.1   
    if fuerza-influencia < 0 [set fuerza-influencia 0]
    if fuerza-influencia > 1 [set fuerza-influencia 1]
    set proactividad random-normal media-proactividad 0.1   
    if proactividad < 0 [set proactividad 0]
    if proactividad > 1 [set proactividad 1]
    
    setxy random-xcor random-ycor
    set shape "person"
    set color white
    set consume? false
    set size sesgo-precio * 4            
    
  
;    show sum lista-gustos       
  ]
  sm_setup     ;;?
  rewire-all   ;;?
  
  create-productos numero-productos [
    setxy random-xcor random-ycor
    set shape "box"
    set size 2
    set color (who - count consumidores)  * 10 + 5   
    set precio random-float 1
    let sign 1
    if random 2 != 0 [set sign -1]
    set calidad precio + random-float relacion-calidad-precio * sign   ;;sign para controlar que sea +/- 
    if calidad <= 0.01 [set calidad 0.01]
    if calidad > 1 [set calidad 1]
    
    ;show word "Precio: " precio 
    ;show word "Calidad: " calidad 

  ]
  layout-circle (sort productos) max-pxcor - 1
  
  set lista-productos sort productos 
 
  ask consumidores [
    set lista-gustos n-values length lista-productos [ random-float 1 ]
    ;set lista-gustos distribucion lista-gustos
  ]
  
   reset-ticks   
end

to go
  ask consumidores[
   
   pregunta-vecinos
   ifelse random-float 1 < 0.3  ;;El 30% de los días se deja influenciar
   [
      consume
      set consume? true
      muevete-hacia producto-consumido
      ]
    [
      set consume? false
      set color white
      ]
   ]
  
  ask productos [
   
    set label (word "P: "(precision  (precio * 100) 0) " C: " (precision (calidad * 100) 0)) 
    ;;set size log  (unidades-vendidas + 1) 3
  ]
  representar
  
  if acciones-de-marketing = TRUE [
    if ticks mod 30 = 0 [
    
    let minimo-ventas [unidades-vendidas] of min-one-of productos [unidades-vendidas]
    let maximo-ventas [unidades-vendidas] of max-one-of productos [unidades-vendidas]
    set umbral minimo-ventas + ((maximo-ventas - minimo-ventas) / 2 )
    
  
    ask productos[
      accion-marketing     
      ]
    ]
  ]
  
  
  
  ;ask consumidores[
  ;  if consume? 
  ;  [influye]
  ;]  
  tick
end

to accion-marketing
 if unidades-vendidas < umbral [
      ifelse random 2 = 0 [
        set precio (precio - 0.05)
        set calidad (calidad - 0.05)
        if calidad <= 0.01 [set calidad 0.01]
        if precio <= 0.01 [set precio 0.01] 
        ]
      [set calidad (calidad + 0.05)
      set precio ( precio + 0.05)
      if calidad > 1 [set calidad 1]
      if precio > 1 [set precio 1]
    ]
    ]
  
end


to pregunta-vecinos
  if random-float 1 < prob-preguntar-vecinos [
    let candidatos link-neighbors with [random-float 1 < proactividad]

    if count candidatos > 0 [
      let gustos-vecinos map [media-i ? candidatos] (n-values (length lista-gustos) [?])
      
      let nuevos-gustos []
      foreach n-values numero-productos [?] [
        set nuevos-gustos lput ((1 - fuerza-influencia) * (item ? lista-gustos) + fuerza-influencia * item ? gustos-vecinos) nuevos-gustos
      ]
      set lista-gustos nuevos-gustos

    ]
   
  ]
end

to-report media-i [index candidatos]
  report mean [item index lista-gustos] of candidatos
end

;;
;; Influye sobre sus enlaces
;;
to influye
  let np num-producto-consumido
  let p producto-consumido
  ;show lista-gustos
  ask link-neighbors [
    
    let g item np lista-gustos
    set g calcula-nuevo-gusto g p
    set lista-gustos replace-item np lista-gustos g
    ;set lista-gustos distribucion lista-gustos
    
    muevete-hacia p
  ]
  
  
end

to muevete-hacia [prod]
  let x xcor - [xcor] of prod
  let y ycor - [ycor] of prod
  
  ;show (list xcor ycor x y)
  
  ifelse x < 0 
  [set xcor xcor + 1]
  [set xcor xcor - 1]  
  
  ifelse y < 0 
  [set ycor ycor + 1]
  [set ycor ycor - 1]  
end

to-report calcula-nuevo-gusto [gusto producto]
  report gusto + factor-de-influencia 
end


to consume 
  let lista-preferencias []
  foreach n-values numero-productos [?] [
   set lista-preferencias lput (sesgo-precio * (1 - [precio] of item ? lista-productos) + (1 - sesgo-precio) * item ? lista-gustos) lista-preferencias

  ]
  set lista-preferencias distribucion lista-preferencias
  set num-producto-consumido rnd:weighted-one-of (n-values numero-productos [?]) [item ? lista-preferencias]
  set producto-consumido item num-producto-consumido lista-productos
;  show producto-consumido
;  set  [unidades-vendidas] of producto-consumido [unidades-vendidas] of producto-consumido + 1
  
  let np num-producto-consumido 
  let g item np lista-gustos
  let ne nivel-exigencia
  ask producto-consumido [ 
    set unidades-vendidas unidades-vendidas + 1  
    
    ;;modificamos el gusto de producto consumido en
    ;;en función del nivel de exigencia y la calidad
    ifelse calidad < ne
    [
      let prob (ne - calidad) / ne
      if random-float 1 < prob [set g g - 0.1]
      if g < 0.01 [set g 0.01]
    ]
    [
      ;;si la calidad esta por encima de la exigencia
      ;;directamente aumentamos el gusto por este producto
      set g g + 0.05
      if g > 1 [set g 1]
    ]
    
  ]
  set lista-gustos replace-item np lista-gustos g
  set color [color] of producto-consumido
    
   ; show lista-preferencias
  
end 

to-report distribucion [lista ]
    let suma-lista sum lista 
   
    set lista map [? / suma-lista ] lista    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    report lista
end

to representar
  set-current-plot "grafica-ventas" 
  foreach lista-productos [ 
    create-temporary-plot-pen word "Producto " ([who] of ? - poblacion + 1)
    set-plot-pen-color [color] of ?
    plot  [unidades-vendidas] of ? 
    
    ]
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;
;;; SW Main Procedure ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

to rewire-one

  ;; make sure num-turtles is setup correctly else run setup first
  ;;if count turtles != poblacion [
  ;;  sm_setup
  ;;]

  ;; record which button was pushed
  set rewire-one? true
  set rewire-all? false

  let potential-edges links with [ not rewired? ]
  ifelse any? potential-edges [
    ask one-of potential-edges [
      ;; "a" remains the same
      let node1 end1
      ;; if "a" is not connected to everybody
      if [ count link-neighbors ] of end1 < (count consumidores - 1)
      [
        ;; find a node distinct from node1 and not already a neighbor of node1
        let node2 one-of consumidores with [ (self != node1) and (not link-neighbor? node1) ]
        ;; wire the new edge
        ask node1 [ create-link-with node2 [ set color cyan  set rewired? true ] ]

        set number-rewired number-rewired + 1  ;; counter for number of rewirings

        ;; remove the old edge
        die
      ]
    ]
    ;; plot the results
    let connected? do-calculations
    update-plots
  ]
  [ user-message "all edges have already been rewired once" ]
end

to rewire-all

  ;; make sure num-turtles is setup correctly; if not run setup first
  ;;if count turtles != poblacion [
  ;;  setup
  ;;]

  ;; record which button was pushed
  set rewire-one? false
  set rewire-all? true

  ;; set up a variable to see if the network is connected
  let success? false

  ;; if we end up with a disconnected network, we keep trying, because the APL distance
  ;; isn't meaningful for a disconnected network.
  while [not success?] [
    ;; kill the old lattice, reset neighbors, and create new lattice
    ask links [ die ]
    wire-them
    set number-rewired 0

    ask links [

      ;; whether to rewire it or not?
      if (random-float 1) < 0.5
      [
        ;; "a" remains the same
        let node1 end1
        ;; if "a" is not connected to everybody
        if [ count link-neighbors ] of end1 < (count consumidores - 1)
        [
          ;; find a node distinct from node1 and not already a neighbor of node1
          let node2 one-of consumidores with [ (self != node1) and (not link-neighbor? node1) ]
          ;; wire the new edge
          ask node1 [ create-link-with node2 [ set color cyan  set rewired? true ] ]

          set number-rewired number-rewired + 1  ;; counter for number of rewirings
          set rewired? true
        ]
      ]
      ;; remove the old edge
      if (rewired?)
      [
        die
      ]
    ]

    ;; check to see if the new network is connected and calculate path length and clustering
    ;; coefficient at the same time
    set success? do-calculations
  ]

  ;; do the plotting
  update-plots
  
  ask consumidores [rt random 10 fd 10]
end

;; do-calculations reports true if the network is connected,
;;   and reports false if the network is disconnected.
;; (In the disconnected case, the average path length does not make sense,
;;   or perhaps may be considered infinite)
to-report do-calculations

  ;; set up a variable so we can report if the network is disconnected
  let connected? true

  ;; find the path lengths in the network
  find-path-lengths

  let num-connected-pairs sum [length remove infinity (remove 0 distance-from-other-turtles)] of consumidores

  ;; In a connected network on N nodes, we should have N(N-1) measurements of distances between pairs,
  ;; and none of those distances should be infinity.
  ;; If there were any "infinity" length paths between nodes, then the network is disconnected.
  ;; In that case, calculating the average-path-length doesn't really make sense.
  ifelse ( num-connected-pairs != (count consumidores * (count consumidores - 1) ))
  [
      set average-path-length infinity
      ;; report that the network is not connected
      set connected? false
  ]
  [
    set average-path-length (sum [sum distance-from-other-turtles] of consumidores) / (num-connected-pairs)
  ]
  ;; find the clustering coefficient and add to the aggregate for all iterations
  find-clustering-coefficient

  ;; report whether the network is connected or not
  report connected?
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Clustering computations ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copyright 2005 Uri Wilensky.


to-report in-neighborhood? [ hood ]
  report ( member? end1 hood and member? end2 hood )
end


to find-clustering-coefficient
  ifelse all? consumidores [count link-neighbors <= 1]
  [
    ;; it is undefined
    ;; what should this be?
    set clustering-coefficient 0
  ]
  [
    let total 0
    ask consumidores with [ count link-neighbors <= 1]
      [ set node-clustering-coefficient "undefined" ]
    ask consumidores with [ count link-neighbors > 1]
    [
      let hood link-neighbors
      set node-clustering-coefficient (2 * count links with [ in-neighborhood? hood ] /
                                         ((count hood) * (count hood - 1)) )
      ;; find the sum for the value at turtles
      set total total + node-clustering-coefficient
    ]
    ;; take the average
    set clustering-coefficient total / count consumidores with [count link-neighbors > 1]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Path length computations ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Implements the Floyd Warshall algorithm for All Pairs Shortest Paths
;; It is a dynamic programming algorithm which builds bigger solutions
;; from the solutions of smaller subproblems using memoization that
;; is storing the results.
;; It keeps finding incrementally if there is shorter path through
;; the kth node.
;; Since it iterates over all turtles through k,
;; so at the end we get the shortest possible path for each i and j.

to find-path-lengths
  ;; reset the distance list
  ask consumidores
  [
    set distance-from-other-turtles []
  ]

  let i 0
  let j 0
  let k 0
  let node1 one-of consumidores
  let node2 one-of consumidores
  let node-count count consumidores
  ;; initialize the distance lists
  while [i < node-count]
  [
    set j 0
    while [j < node-count]
    [
      set node1 consumidor i
      set node2 consumidor j
      ;; zero from a node to itself
      ifelse i = j
      [
        ask node1 [
          set distance-from-other-turtles lput 0 distance-from-other-turtles
        ]
      ]
      [
        ;; 1 from a node to it's neighbor
        ifelse [ link-neighbor? node1 ] of node2
        [
          ask node1 [
            set distance-from-other-turtles lput 1 distance-from-other-turtles
          ]
        ]
        ;; infinite to everyone else
        [
          ask node1 [
            set distance-from-other-turtles lput infinity distance-from-other-turtles
          ]
        ]
      ]
      set j j + 1
    ]
    set i i + 1
  ]
  set i 0
  set j 0
  let dummy 0
  while [k < node-count]
  [
    set i 0
    while [i < node-count]
    [
      set j 0
      while [j < node-count]
      [
        ;; alternate path length through kth node
        set dummy ( (item k [distance-from-other-turtles] of consumidor i) +
                    (item j [distance-from-other-turtles] of consumidor k))
        ;; is the alternate path shorter?
        if dummy < (item j [distance-from-other-turtles] of consumidor i)
        [
          ask consumidor i [
            set distance-from-other-turtles replace-item j distance-from-other-turtles dummy
          ]
        ]
        set j j + 1
      ]
      set i i + 1
    ]
    set k k + 1
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;
;;; Edge Operations ;;;
;;;;;;;;;;;;;;;;;;;;;;;

;; creates a new lattice
to wire-them
  ;; iterate over the turtles
  let n 0
  while [n < count consumidores]
  [
    ;; make edges with the next two neighbors
    ;; this makes a lattice with average degree of 4
    make-edge consumidor n
              consumidor ((n + 1) mod count consumidores)
    make-edge consumidor n
              consumidor ((n + 2) mod count consumidores)
    set n n + 1
  ]
end

;; connects the two turtles
to make-edge [node1 node2]
  ask node1 [ create-link-with node2  [
    set rewired? false
  ] ]
end

;;;;;;;;;;;;;;;;
;;; Graphics ;;;
;;;;;;;;;;;;;;;;

to highlight
  ;; remove any previous highlights
  ask consumidores [ set color gray + 2 ]
  ask links [ set color gray + 2 ]
  if mouse-inside? [ do-highlight ]
  display
end

to do-highlight
  ;; getting the node closest to the mouse
  let min-d min [distancexy mouse-xcor mouse-ycor] of consumidores
  let node one-of consumidores with [count link-neighbors > 0 and distancexy mouse-xcor mouse-ycor = min-d]
  if node != nobody
  [
    ;; highlight the chosen node
    ask node
    [
      set color pink - 1
      let pairs (length remove infinity distance-from-other-turtles)
      let local-val (sum remove infinity distance-from-other-turtles) / pairs
      ;; show node's clustering coefficient
      set highlight-string (word "clustering coefficient = " precision node-clustering-coefficient 3
                                 " and avg path length = " precision local-val 3
                                 " (for " pairs " turtles )")
    ]
    let neighbor-nodes [ link-neighbors ] of node
    let direct-links [ my-links ] of node
    ;; highlight neighbors
    ask neighbor-nodes
    [
      set color blue - 1

      ;; highlight edges connecting the chosen node to its neighbors
      ask my-links [
        ifelse (end1 = node or end2 = node)
        [
          set color blue - 1 ;
        ]
        [
          if (member? end1 neighbor-nodes and member? end2 neighbor-nodes)
            [ set color yellow ]
        ]
      ]
    ]
  ]
end
