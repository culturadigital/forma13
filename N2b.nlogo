

globals[training netBudget increment]


;propiedades de las turtles (trabajadores)
turtles-own [ salaryAgentActual salaryAgentMemory salaryAgentBase mobilityAgentActual mobilityAgentMemory level satisfactionAgentActual
              satisfactionAgentMemory trainingAgentActual trainingAgentMemory tickAccess talentActual talentMemory]



breed [executives executive]
breed [managers manager]
breed [employers employer]


to setup
  ca
  ifelse ((num-executives < num-managers) and ((num-executives + num-managers) < num-employers))
         and ((num-executives + num-managers + num-employers) = num-totalTrabajadores)
  [
    create-executives num-executives [setxy random-xcor random-ycor set size 1.5 set color red set shape "person"]
    
    create-managers num-managers [setxy random-xcor random-ycor set size 1.5 set color blue set shape "person"]
    
    create-employers num-employers [setxy random-xcor random-ycor set size 1.5 set color yellow set shape "person"]
    
   ]
  
  [
    
    user-message ("Error al introducir valores en imputs")
    
   ]
   
   
   
  ;******INICIALIZAR LAS PROPIEDADES DE LOS AGENTS POR DEFECTO**** 
  ask turtles [set talentActual 1 + random 4
               ;set salaryAgentActual 15600
               set mobilityAgentActual 1
               set satisfactionAgentActual 3
               set trainingAgentActual 1
               
              ]
  
  set increment 1.5
  
  set netBudget totalBudget - ( (count(executives) * (42000 + random 33000) ) + (count(managers) * (30000 + random 15000) ) + (count(employers) * 15600) )
  
  ;actualiza el valor de training
  set training totalBudget - salary
  
   
   
  reset-ticks
  
  ;añade trabajadores(turtles) de diferentes razas cumpliendo con unas normas. Reseteo de ticks
  
end





to go
  ;para que 5 ticks lo consideremos una unidad de tiempo(1 año) tengo que actuar solo cuando ticks sea multiplo de 5
  if ( ticks mod 5 = 0 )[
    
    ask turtles [ set salaryAgentMemory salaryAgentActual
                  set mobilityAgentMemory mobilityAgentActual
                  set satisfactionAgentMemory satisfactionAgentActual
                  set trainingAgentMemory trainingAgentActual
                  set talentMemory talentActual
                 ]   
    
    modify-talentAgent
    modify-mobility
    calcula-salaryAgentBase
    modify-salaryAgent
    modify-trainingAgent
    modify-satsfaction
    
    ask turtles [ if (talentMemory < talentActual) [set size increment + 0.2]]
    
    ask turtles [ if (satisfactionAgentActual < 10) [set color green]]
    
    ;????INTRODUCIR EN EL GO????
    
    ;sb-executives
    ;sb-managers
    ;sb-employers
    
    ]
  tick
end



;CALUCLO DEL TALENTO
to modify-talentAgent
  ask turtles [ set talentActual (trainingAgentActual * talentActual) + talentMemory]
  
  ;el talento es el valor de la formación actual del trabajador por el talento que tiene(digamos que es un valor exponencial)
  
end


;CALCULO DE MOVILIDAD
to modify-mobility
  ask turtles [ set mobilityAgentActual random-normal mobilityAgentActual (random mobility)]
  ;la movilidad del trabajador depende del valor de mobility que aplica la empresa(de 0 a 75%)
end


;CALCULA SALARIO BASE
to calcula-salaryAgentBase 
  ask turtles [ ask executives [ set salaryAgentBase ( 42000 + random 33000 ) ]]
  ask turtles [ ask managers [ set salaryAgentBase ( 30000 + random 15000 ) ]]
  ask turtles [ ask employers [ set salaryAgentBase (15600) ]]
end



;CALCULA SALARIO(NORMAL)
to modify-salaryAgent
  ask turtles [ set salaryAgentActual salaryAgentBase * (talentActual / sum [talentActual] of turtles )];relativeTalent]
end

;mean calcular media


;CALCULA FORMACION
to modify-trainingAgent
  ask turtles [ set trainingAgentActual training * (talentActual / sum [talentActual] of turtles )];relativeTalent 
end


;CALCULA SATISFACCION
to modify-satsfaction
  ask turtles [ set satisfactionAgentActual ((satisfactionAgentActual - satisfactionAgentMemory) + (mobilityAgentActual - mobilityAgentMemory) + (trainingAgentActual - trainingAgentMemory) + 
               (trainingAgentActual - mean [trainingAgentActual] of turtles) + (satisfactionAgentActual - mean [satisfactionAgentActual] of turtles))]
end





;solo son funciones para mostrar el salario base según el tipo de trabajador
to-report sb-executives
  report [salaryAgentBase] of one-of executives
end
to-report sb-managers
  report [salaryAgentBase] of one-of managers
end
to-report sb-employers
  report [salaryAgentBase] of one-of employers
end
