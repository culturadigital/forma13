
__includes["Files.nls"]

breed[nodos nodo]

globals[
  media-grado
  densidad
]

nodos-own [
  Nodo:ID 
  Nodo:Tipo
  Nodo:Nombre
]

links-own [
  link:tipo
]
to setup
  ca
  no-display
  cd
  ask patches [set pcolor white]
  file-close-all
  ; ask the user for the file with the new data
  let f "a.txt"
  load:nlg-file f

  display
  let tipos remove-duplicates [Nodo:Tipo] of Nodos
  ask nodos [set color (item (position Nodo:tipo tipos) bf base-colors)]

  reset-ticks
end
    


to go
  show-data
  if ( random-float 1 < a)[pierde_gana_amigo]
  ask nodos with [nodo:tipo = "M"][if (random-float 1 < b) [anade_arista_mismo_tipo]]
  ask nodos with [nodo:tipo = "M"][if (random-float 1 < c) [anade_arista_distinto_tipo]]
  ask nodos with [nodo:tipo = "A"][if (random-float 1 < d) [pierde_arista_mismo_tipo]]
      
  ;ask nodos [if (ticks < 450 AND random-float 1 < 1 / 20) [quita_arista]]
  tick
  if ticks = 500 [ stop ] 
  ask nodos with [nodo:tipo ="A"][set color red]
  ask nodos with [nodo:tipo = "M"][set color blue]
  
end

to anade_arista_mismo_tipo
  if(any? other nodos with [nodo:tipo = "M"])[create-link-to one-of other nodos with[nodo:tipo ="M"]]
end

to anade_arista_distinto_tipo
  if(any? other nodos with [nodo:tipo = "M"])[create-link-to one-of other nodos with[nodo:tipo ="A"]]
end


to pierde_gana_amigo
  ask one-of nodos with [nodo:tipo ="A"][set nodo:tipo "M" ask my-in-links[die] ask my-out-links[die]]
    
end

to pierde_arista_mismo_tipo
  ask one-of nodos with [nodo:tipo = "A"][if (any? out-link-neighbors) [ask one-of out-link-neighbors with [nodo:tipo = "A"][ask in-link-from myself [die]]]]
end



to show-data 
  let temp 0
  ask nodos
  [
   set temp temp + count out-link-neighbors 
  ]
  set media-grado temp / count nodos
  
  set densidad count links / 980
end



to pone_arista 
  create-link-to one-of other nodos
end

to quita_arista
  if any? links [ 
    ask one-of links [die]
  ]
end





to layout
  layout-spring nodos links muelle longitud repulsion
end

to refresca
  ask nodos [
    set size tam:nodo
    set label ifelse-value etiq:nodos? [Nodo:Nombre][""]
    ]
  ask links [
      set label ifelse-value etiq:links? [Link:Tipo][""]
    ]
end

to buscar
  rp
  let nodo-buscado user-input "Nombre del nodo?"
  if any? nodos with [member? nodo-buscado Nodo:Nombre ]
  [watch one-of nodos with [member? nodo-buscado Nodo:Nombre ]]
end
