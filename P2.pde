PFont font01;
PFont font02;
String[] lineas;

void setup(){
  //size(2500,1400);
  size(1280,800);
  smooth();
  font01=loadFont("AngsanaUPC-24.vlw");
  font02=loadFont("AngsanaUPC-18.vlw");
  
  load();
}

void draw(){
  background(0);
  for(int i=0;i<sorted_arboles.length;i++){
    Arbol a=sorted_arboles[i];
    a.render();
    a.clicked();
    if(a.activo){
      a.renderConnections();
    }
      
  }
  //println(frameCount);
  if(frameCount>50){
    //save("img01.png");
    //exit();
  }
}

class Arbol{
  
  PVector pos;
  String ncientif;
  int nElem;
  int altura;
  HashMap mindist;
  int node;
  boolean activo;
  color mycolor;
  
  Arbol(PVector _pos, String _ncientif, int _nElem, int _altura, HashMap _mindist, int _node, boolean _activo, color _mycolor){
    pos=_pos;
    ncientif=_ncientif;
    nElem=_nElem;
    altura=_altura;
    mindist=_mindist;
    node=_node;
    activo=_activo;
    mycolor=_mycolor;
  }
  
  void drawlink(){
    //checks the n_conex attribute of each other species and draws a line with transparency according to its value
    //updates the diameter of the other species objects
  }
  
  void atract(){
    //checks the min_dist attribute of every other species and moves the object connected into the circle according to its value  
  }
  
  void renderConnections(){ // aqui vamos a pintar una nueva esfera por cada especie con sus distancias
    int counter=0;
    //float rad=20.0*log((5+nElem)/5.0);
    //ellipse(pos.x,pos.y,12,12);
    Iterator vgiter1 = mindist.entrySet().iterator(); 
    while(vgiter1.hasNext()){
      counter+=1;
      Map.Entry item = (Map.Entry)vgiter1.next();
       Float mdist = (Float) item.getValue();
       //if (counter==3){println(mdist);}
       //float mdist = float(strdist);
       String name = (String) item.getKey(); 
       //fill(rad*5,rad/2,255-5*rad,150);
       pushMatrix();
         translate(pos.x,pos.y);
         //line(counter*10,0,counter*10,-mdist/1000.0);
         rect(counter*10,0,5,-mdist/1000.0);
         rotate(PI/2.0);
         textFont(font02);
         text(name,4,-counter*10);
       popMatrix();
       noStroke();
       //vg.drawVG(zoom);
    }
  }
  
  void clicked(){
    if(mousePressed){
      if(mouseX>pos.x-10 && mouseX<pos.x+10 && mouseY>pos.y-10 && mouseY<pos.y+10){
        activo=true;
      }else{
        activo=false;
      }
    }
  }
  
  void render(){
    noStroke();
    float rad=20.0*log((5+nElem)/5.0);
    fill(rad*5,rad/2,255-5*rad,150);
    //if(rad<3){rad=2;}
    PVector heading=PVector.sub(new PVector(width/2, height/2), pos);
    
    float angle=PVector.angleBetween(heading, new PVector(1,0));
    //println(angle);
    textFont(font01);
    pushMatrix();
      translate(pos.x,pos.y);
      if(pos.y<height/2){
        rotate(angle);
      }else{
        rotate(-angle);
      }
      rect(0,0,-rad,12);
      rotate(PI);
      text(ncientif,2+rad,0);
    popMatrix();
    //ellipse(pos.x,pos.y,rad,rad);
   // println(pos.x+", "+pos.y+", "+nElem);
  
  }
}

Arbol[] arboles=new Arbol[0];
Arbol[] sorted_arboles;

void load(){
  HashMap connectionsHash = new HashMap(1500);
  lineas=loadStrings("data/thebeast.csv");
  sorted_arboles=new Arbol[lineas.length];
  int[] listpobl=new int[lineas.length];
  int[] sorted_pobl=new int[lineas.length];
  
  for(int i=0;i<lineas.length;i++){
    String[] datos_especie=split(lineas[i],";");
    String especie=datos_especie[0];
    String[] pobl=split(datos_especie[1],":");
    
    String[] relaciones=split(lineas[i],"][");
    
    for(int k=0;k<relaciones.length;k++){//en este loop llenamos el hash de cada especie con las distancias minimas y los nombres de las especies correspondientes a esas distancias
      String dirkey="";
      String strmindist=split(relaciones[k],"mindist:")[1];
      float mindist=float(split(strmindist,"]")[0]);
      if(k==0){
        String chunk=split(relaciones[k],"[")[1];
        dirkey=split(chunk,";")[0];
      }else{
        dirkey=split(relaciones[k],";")[0];
      }
      connectionsHash.put(dirkey,mindist);
    }
    
    int poblacion=int(split(pobl[1],"=")[0]);
    listpobl[i]=poblacion;
    sorted_pobl=sort(listpobl);
    
    Arbol a=new Arbol(new PVector(0,0),especie,poblacion,0,connectionsHash,0,false,color(200,2,2));
    arboles=(Arbol[]) append(arboles, a);
    println(i);
  }
  
  for(int i=0;i<sorted_pobl.length;i++){
    int count=0;
    for(int j=0;j<listpobl.length;j++){
      if(sorted_pobl[i]==listpobl[j]){
        if(count<1){
          sorted_arboles[i]=arboles[j];
          //now dump the used element from the list
          listpobl[j]=0;
        }
        count+=1;
      }
    }
    float rad=10*log(5+sorted_arboles[i].nElem/5.0);
    if(i%2==0){
      sorted_arboles[i].pos=new PVector(width/2+350*cos((i/150.5)*(1*PI)),height/2+350*sin((i/150.5)*(1*PI)));
    }else{
      sorted_arboles[i].pos=new PVector(width/2+350*cos((i/150.5)*(-1*PI)),height/2+350*sin((i/150.5)*(-1*PI)));
    }
  }  
}

