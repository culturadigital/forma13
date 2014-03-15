
;;breed [ personas persona ]
breed [ dioses dios ]

dioses-own [
  contador
]

patches-own [ 
  protect? 
  ocupated?
  legal?
  typology
  impact
  energy
  sectorial?
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONFIG INICIAL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup
  ca
  ask patches [
    
    set sectorial? FALSE
    set ocupated? FALSE
    set impact    0
    set legal?    FALSE

  ]
  
  
  ;; Iniciacio de Dios
  create-dioses 1 [ set hidden? TRUE ]
  
  ;; valor inicial 
  ask dioses [ set contador 0 ]
  
  ;; CREACION DE POBLACION INICIAL
  ask n-of numPersonas patches [
    creaPoblador
    ]
   
  
  ask patches [ 
  ifelse random 100 >= PROTECTED 
    [set protect?  FALSE]
    [set protect?  TRUE]
  ]
   
   
   
  visualiza
  
  
  

  ;;  irParcela

  reset-ticks
end


;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;
to visualiza
   
   ask patches with [not ocupated?] [set pcolor white]
   ask patches with [ocupated?] [set pcolor brown]
   ask patches with [protect?] [set pcolor green]
   ask patches with [protect? and ocupated?] [set pcolor  red]
   ask patches with [ sectorial? ] [ set pcolor blue ]
   ask patches with [ legal? ] [ set pcolor yellow ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BUCLE PRINCIPAL
;;;;;;;;;;;;;;;;;;;;;;;;;;
to go

  updateimpact      ;; actualiza el impacto
  createpopulation  ;; crea poblacion nueva
  updateadmin       ;; ejecuta la administracion
  updatepopulation  ;; ejecuta la población

  visualiza

  results           ;; 
  tick
  
end   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  FUNCIONES AUXILIARES


to updateimpact
  
  ;let formula sum [impact_v] of neighbors
  ;let impv 3
  ;let impk 3
   ask patches [
     ifelse ocupated?
     [
         if typology = 1 [set impact impact + imp1] 
         if  typology = 2 [set impact impact + imp2]
         if typology = 3 [set impact impact + imp3]
     ]
     [
;;       let formula 0
;;       foreach sort neighbors4  [
;;        set formula formula + [impact] of ?
;;       ]
;;       set impact (formula * impk + impv)

     ]
     
     
     ]
  
  ask patches with [ impact < 0 ] [ set impact 0 ]
  
  
  
end

to-report impactototal
       let formula 0
       foreach sort patches[
        set formula formula + [impact] of ?
       ]


  report formula
  
end
   
   


to createpopulation
  
;; ask patches [set ocupated? not ocupated?]
 
 ask dioses [ 
   ifelse contador < numPersonas 
   [ set contador contador + 1]
   [ creaPoblador
     set contador 0]
   ] 
 
 
 
 
  
  
end

to  updateadmin
  
  let espacioocu count patches with [ ocupated? = TRUE ] * 0.10 
  let espacioprot count patches with [ protect? = TRUE ] 
  
  let resta espacioocu - espacioprot
  
  if resta > 0 [ ask n-of resta patches with [ protect? = FALSE and ocupated? = FALSE ][
      set sectorial? TRUE
      set protect?   TRUE
      ]]
  
 
 ;; ECHAR A LOS QUE ESTAN EN ESPACIO PROTEGIDO
 ask patches with [ protect? = TRUE and ocupated? = TRUE ]
 [ if random 100 > 25 [set ocupated? FALSE ]]
 
 
 ask patches with [ protect? = TRUE and ocupated? = FALSE ][
   set impact impact - 1 ]
 
 
  ask patches with [ protect? = FALSE and ocupated? = TRUE ][
    set energy energy * 0.2 
    set impact impact - 10 
    ;;set legal? TRUE 
  ]
  
  
   
  
  
end

to updatepopulation
  
  
  
  
  
  
;  ifelse cond1 
;  [ accion1]
;  [
;    ifelse cond2 
;    [accion2]
;    [
;      ifelse cond3
;      [accion3
;      ]
;      [
;        accionpor defcto
;        ]
;      
;      
;      
;      
;      
;      ]
;    
;    ]
  
  ask patches with [ocupated? = TRUE] [ 
    
    if energy > 2000 [ 
      set energy energy - 1000
      set impact impact - 100 
      ]
    
    
    
    
    
    
    
    
    
    
    
    set energy energy + 200 ]
  
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to results
  
  
  
  
  
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to creaPoblador
  
  ask one-of patches with [ ocupated? = FALSE][ 
    set ocupated? TRUE 
    set impact 100

    set typology  distribucionPoblacion
    if typology = 1 [ set energy 1000]
    if typology = 2 [ set energy 2000]
    if typology = 3 [ set energy 3000]
    

  ]

end

to-report distribucionPoblacion
  
  let numero  random 100
  
  ifelse numero < 10 
  [ report 3 ]
  [ ifelse numero < 60 
    [ report 2 ]
    [ report 1 ] 
  ]
  
end


