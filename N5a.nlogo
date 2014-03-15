; *****incomplete code – under development*****

extensions [ gis ]

globals [ xmin xmax ymin ymax 
  municipios-dataset 
  area_estudio-dataset   ;cada entero se corresponde con un municipio
  clasif2003_v03-dataset ;1-urbano; 2-urbanizable; 3-no-urbanizable; 4-sistemas generales (1 o 2)
  restriccion-dataset    ;C0  asignable como urbana "0" o prohibida "1"
  productvd-dataset      ;C1  el mayor valor, mejor para ocupar
  dist_plgro3-dataset    ;C2  lo más distante mejor
  dist_urb1-dataset      ;C3  lo más cercano mejor
  ctra1-dataset          ;C4  lo más cercano mejor 
  dist_hosp3-dataset     ;C51 lo más cercano mejor 
  dist_univ3-dataset     ;C52 lo más cercano mejor 

;para modelo2
  d0_nviv_2-dataset d0a_prcvv_2-dataset d0b_rgoprcvv_2-dataset d0c_nviv_uz-dataset
  d1_clasfc-dataset f1_distcrt-dataset f2-esttp-dataset f3_disturb-dataset f4_dsdviv_2-dataset f4a_rgodsd_2-dataset f5_rgoval-dataset f5_valsue2-dataset
  num
  ]
breed [ municipios-labels municipio-label ]
breed [tortugas tortuga]
tortugas-own [tpob adapt estado]

patches-own [ 
  
  tviv capacidad calidad_a calidad_m calidad_b ocupacion
  
   ;para datos modelo1
  area_estudio clasif2003_v03 restriccion productvd dist_plgro3 dist_urb1 ctra1 dist_hosp3 dist_univ3 
  ;para calculo modelo1
  aux_dist_plgro3 aux_productvd
  util prioridad  prioridad1
  ;para datos modelo2
  d0_nviv_2 d0a_prcvv_2 d0b_rgoprcvv_2 d0c_nviv_uz
  d1_clasfc f1_distcrt f2-esttp f3_disturb f4_dsdviv_2 f4a_rgodsd_2 f5_rgoval f5_valsue2
  ] 
;fija los limites, dibuja el fondo configurado y carga los municipios

;inicia variables de patches a partir de capas GIS y formulas de preferencias, crea tortugas 
to inicio
  gis:apply-raster d0b_rgoprcvv_2-dataset tviv
  ask patches [set tviv tviv - 1 ]
  gis:apply-raster f4_dsdviv_2-dataset  ocupacion
  ask patches  [set ocupacion round( ocupacion / 10000)]
  
  ask patches [sprout-tortugas ocupacion ]
  ask tortugas [ set tpob [tviv] of patch-here  set adapt 0 set estado true]
  
  let limb max [ocupacion] of patches with [ tviv = 0 ] 
  let limm max [ocupacion] of patches with [ tviv = 1 ]
  let lima max [ocupacion] of patches with [ tviv = 2 ]
  
  ask patches with [tviv = 0] [ set calidad_b ((0.20 * ctra1) + (0.40 * dist_hosp3) + (0.40 * f2-esttp) ) set capacidad limb]
  ask patches with [tviv = 1] [ set calidad_m ((0.33 * ctra1) + (0.33 * dist_hosp3) + (0.33 * f2-esttp) ) set capacidad limm]
  ask patches with [tviv = 2] [ set calidad_a ((0.40 * ctra1) + (0.40 * dist_hosp3) + (0.20 * f2-esttp) ) set capacidad lima]
  colorea_tortus
end

to reasigna
  let numero_seleccionados round (count tortugas * porcentaje_reasigna / 100)
  show (word "voy a cambiar " numero_seleccionados " de personas")
  let seleccion n-of numero_seleccionados tortugas
  let ii 0
  ask seleccion [set ii cambia_clase self ]
  colorea_tortus
  do-plot
end  

to do-plot
  set-current-plot "clases_sociales"
  set-current-plot-pen "alta"
  plot count tortugas with [tpob = 0]
  set-current-plot-pen "media"
  plot count tortugas with [tpob = 1]
  set-current-plot-pen "baja"
  plot count tortugas with [tpob = 2]
end

to colorea_tortus
  ask tortugas with [tpob = 0][set color red]
  ask tortugas with [tpob = 1][set color green]
  ask tortugas with [tpob = 2][set color blue]
end

to-report cambia_clase [individuo]
  if tpob = 0 [ set tpob 1 report 0]
  if tpob = 2 [set tpob 1 report 0]
  let i random 2
  if tpob = 1 [ ifelse i = 1 [set tpob 0] [set tpob 2] report 0]
  report 1
end   

to mueve_descontentos
  ask tortugas [if tpob != [tviv] of patch-here [
      let mi-clase tpob
      ifelse any? neighbors with [(tviv = mi-clase) and (capacidad > ocupacion) ][
        set ocupacion ocupacion - 1
        move-to one-of neighbors with [(tviv = mi-clase) and (capacidad > ocupacion) ]
        set ocupacion ocupacion + 1
        ]
      [if any? neighbors with [(capacidad > ocupacion)][
        set ocupacion ocupacion - 1
        move-to one-of neighbors with [(capacidad > ocupacion) ]
        set ocupacion ocupacion + 1
        ]]
]
  ] 
end

;*****to be continued!*****
