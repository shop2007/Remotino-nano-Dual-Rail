/** Example of selecting a particular Serial Port

* pautax: ripete  la porta seriale selezionata sull'area nera
* gauge 3 scan continuo

 *  from the list of all possibilities returned
 *  in Serial.list().
 *
  *  Uses showInputDialog box kindly suggested to
 *  me by GoToLoop.  Thank you,  GoToLoop! 
*/
 import processing.serial.*;
 import static javax.swing.JOptionPane.*;

Serial  myPort;  // Create object from Serial class
String StringFromSerialLine;     //  Data received from the serial port
String OldStringFromSerialLine;     // Last  data Data received from the serial port
String ExtractStr;   // stringa del valore  esempi da "PWM1=20| DIR1=1 | PWM2=0 | DIR2=0 | MOTORON=1" PWM1 vale "20"
int  ExtractVal;    //come sopra ma convertito in intero 
int LenSFSL; // LenghtStringFromSerialLine

final  boolean debug = true;

Gauge Power1, Power2;
int Power1old;
int Power2old;
int Power1_val = 0;
int Power2_val = 0;

PImage img;
PImage img1;
PImage img2;

void  setup(){
  size(790, 600);
  Power1 = new Gauge(250, 0, 255, 25, "Power1");  //(width, begin, end, quotation scale, name gauge)
  Power2 = new Gauge(250,  0, 255, 25, "Power2");
  //hour = new Gauge(250, 0, 255, 25,  "Power3");
  Power1old = 100;  //val can never be 100, first run will always draw
  Power2old = 100;  //val can never be 100, first run will always draw

  
 

  String COMx, COMlist = "";
/*
  Other setup code goes here - I put this at
  the end because of the try/catch  structure.
*/
  try {
    if(debug) printArray(Serial.list());
    int  i = Serial.list().length;
    if (i != 0) {
      if (i >= 2) {
        //  need to check which port the inst uses -
        // for now we'll just let the  user decide
        for (int j = 0; j < i;) {
          COMlist += char(j+'a')  + " = " + Serial.list()[j];
          if (++j < i) COMlist += ",  ";
        }
        COMx = showInputDialog("Which COM port is correct? (a,b,..):\n"+COMlist);
        if (COMx == null) exit();
        if (COMx.isEmpty()) exit();
        i  = int(COMx.toLowerCase().charAt(0) - 'a') + 1;
      }
      String portName  = Serial.list()[i-1];
      if(debug) println(portName);
      myPort = new  Serial(this, portName, 115200); // change baud rate to your liking
      myPort.bufferUntil('\n');  // buffer until CR/LF appears, but not required..
    }
    else {
      showMessageDialog(frame,"Device  is not connected to the PC");
      exit();
    }
  }
  catch (Exception  e)
  { //Print the type of error
    showMessageDialog(frame,"COM port is  not available (may be in use by another program)");
    println("Error:",  e);
    exit();
  }  
  
  
  
  
  
  
  
  
  // I know that the first port in the serial list on my mac
  // is Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port  is the one you're using.
//  String portName = Serial.list()[0]; //change the  0 to a 1 or 2 etc. to match your port
//  myPort = new Serial(this, portName,  115200);  

  
  
//draw grid
// translate(width/2, height/2);
/*B
      for ( int i = 0 ; i < width ; i+=49) {
        for ( int j = 0 ; j < height  ; j+=49) {
          //
          line(i, j, i+25, j);
          line(i,  j, i, j+25);     
          line(i+25, j, i+25, j+25);
          line(i, j+25,  i+25, j+25);
          //line(i, j, 10, 10);
        }
      }
*/




   // spia moton
   fill( 50, 50, 50 ); // colore grigio Drives off
   //strokeWeight(  3 );
   stroke( 255 );
   ellipse( 50, 250, 40, 40 );  
   textSize(18);
   fill(0, 0, 0);
   text("MOTOR", 17, 295); 

   // spia boost
   fill(  50, 50, 50 ); // colore grigio Drives off
   ellipse( 160, 250, 40, 40 );  
   textSize(18);
   fill(0, 0, 0);
   text("1-2   JOIN", 130, 295); 



  //scambio
  img = loadImage( "../scambio.jpg" );
  image( img, 250, 250  );
  image( img, 500, 250 );
  image( img, 250, 425 );
  image( img, 500,  425 );
  text("SCAMBIO 2-1", 270, 360); 
  text("SCAMBIO 4-3", 520, 360);  
  text("SCAMBIO 6-5", 270, 535); 
  text("SCAMBIO 8-7", 520, 535); 

  img1 = loadImage( "../scambio1.jpg" );
  img2 = loadImage( "../scambio2.jpg"  );

   //frecce della direzione
   fill( 50, 50, 50 ); // colore grigio  Drives off
   
   // indietro 1
   //strokeWeight( 1 );
   beginShape();
   vertex(75,325);
   vertex(75,375);
   vertex(40,350);
   endShape(CLOSE);

   // avanti 1
   beginShape();
   vertex(100,325);
   vertex(100,375);
   vertex(135,350);
   endShape(CLOSE);

   // indietro 2
   beginShape();
   vertex(75,450);
   vertex(75,500);
   vertex(40,475);
   endShape(CLOSE);

   // avanti 2
   beginShape();
   vertex(100,450);
   vertex(100,500);
   vertex(135,475);
   endShape(CLOSE);

   fill(0, 0, 0);
   text("LINEA  1", 40, 400); 
   text("LINEA 2", 40, 525); 

   
}

void draw(){
  
  /*
  Power1_val++;
  if (Power1_val > 59){
      Power1_val = 0;
  }
  */
    
 // drw3gauge();
     
  if ( myPort.available() >  0) 
  {  // If data is available,
     StringFromSerialLine = myPort.readStringUntil('\n');         // read it and store it in StringFromSerialLine
  } 
  
  if (StringFromSerialLine  != null) {
  
    if (StringFromSerialLine != OldStringFromSerialLine){
       println(StringFromSerialLine); //print it out in the console
       OldStringFromSerialLine  = StringFromSerialLine; //save
       
       LenSFSL = StringFromSerialLine.length();
       //ora si decodificano i valori
       //estrae valore di PWM1 da stringa  tipo "PWM1=20| DIR1=1 | PWM2=0 | DIR2=0 | MOTORON=1  SINGLEMODE=1"
       if (LenSFSL > 3){
           ExtractStr =  StringFromSerialLine.substring(0, 4);
           print("LenSFSL  ");
           println(LenSFSL);

           switch(ExtractStr) {

             case "PWM1": 
                print(", ExtractStr ");
                print(ExtractStr);
                print(", Trovato PWM1 ");  // 
                ExtractStr =  StringFromSerialLine.substring(5);
                print(", ExtractStr ");
                print(ExtractStr);
                ExtractVal = Integer.parseInt(ExtractStr.trim());                
                //ExtractVal = int(ExtractStr);
                print("  , ExtractVal ");
                println(ExtractVal);  // 
                Power1_val  = ExtractVal;               
              break;

             case "PWM2": 
                print(", ExtractStr ");
                print(ExtractStr);
                print(", Trovato PWM2 ");  // 
                ExtractStr =  StringFromSerialLine.substring(5);
                print(", ExtractStr ");
                print(ExtractStr);
                ExtractVal = Integer.parseInt(ExtractStr.trim());                
                //ExtractVal = int(ExtractStr);
                print("  , ExtractVal ");
                println(ExtractVal);  // 
                Power2_val  = ExtractVal;               
              break;

             case "MOTN":  
                print(", ExtractStr ");
                print(ExtractStr);
                print(", Trovato MOTN ");  // 
                ExtractStr =  StringFromSerialLine.substring(5);
                print(", ExtractStr ");
                print(ExtractStr);
                ExtractVal = Integer.parseInt(ExtractStr.trim());                
                //ExtractVal = int(ExtractStr);
                print("  , ExtractVal ");
                println(ExtractVal);  // 
                if  (ExtractVal == 0){
                   fill( 50, 50, 50 ); // colore grigio Drives  off
                } else {
                   //fill( 255, 0, 0 ); // colore  rosso Drives on
                   fill( 0, 255, 0 ); // colore verde Drives  on
                }
                //strokeWeight( 3 );
                stroke(  255 );
                ellipse( 50, 250, 40, 40 ); 
              break;



             case "SMOD": 
                print(", ExtractStr ");
                print(ExtractStr);
                print(", Trovato SingleMode ");  // 
                ExtractStr  =  StringFromSerialLine.substring(5); // ESTRAE DA SMOD=1
                print(", ExtractStr ");
                print(ExtractStr);
                ExtractVal = Integer.parseInt(ExtractStr.trim());                
                //ExtractVal = int(ExtractStr);
                print("***  , ExtractVal ");
                println(ExtractVal);  // 
                if  (ExtractVal == 0){
                   fill( 50, 50, 50 ); // colore grigio Drives  off
                } else {
                   fill( 255, 0, 0 ); // colore  rosso SINGLEMODE on
                   
                }
                //strokeWeight( 3 );
                stroke(  255 );
                ellipse( 160, 250, 40, 40 );  //PIPPO
              break;

             //PROCESSA GLI SCAMBI
             case "RLON":
                //strokeWeight(  3 );
                print(", ExtractStr ");
                print(ExtractStr);
                print(", Trovato RLON ");  // 
                ExtractStr =  StringFromSerialLine.substring(5);
                print(", ExtractStr ");
                print(ExtractStr);
                ExtractVal = Integer.parseInt(ExtractStr.trim());                
                //ExtractVal = int(ExtractStr);
                print("  , ExtractVal ");
                println(ExtractVal);  // 
                if  (ExtractVal == 0){
                  image( img1, 250, 250 );
                }
                if (ExtractVal == 1){
                  image( img2, 250, 250  );
                }
                if (ExtractVal == 2){
                  image(  img1, 500, 250 );
                }
                if (ExtractVal == 3){
                  image( img2, 500, 250 );
                }

                if  (ExtractVal == 4){
                  image( img1, 250, 425 );
                }
                if (ExtractVal == 5){
                  image( img2, 250, 425  );
                }
                if (ExtractVal == 6){
                  image(  img1, 500, 425 );
                }
                if (ExtractVal == 7){
                  image( img2, 500, 425 );
                }
              break;
              
             //processa le direzioni frecce gialle
             case  "DIR1": 
                //strokeWeight( 3 );
                print(",  ExtractStr ");
                print(ExtractStr);
                print(",  Trovato DIR1 ");  // 
                ExtractStr =  StringFromSerialLine.substring(5);
                print(", ExtractStr ");
                print(ExtractStr);
                ExtractVal = Integer.parseInt(ExtractStr.trim());                
                //ExtractVal = int(ExtractStr);
                print(" , ExtractVal  ");
                println(ExtractVal);  // 

                if (ExtractVal  == 1){
                   println("Avanti 1");  // 
                   fill(  10, 3, 255 ); // colore BLU AVANTI
                   beginShape();
                   vertex(100,325);
                   vertex(100,375);
                   vertex(135,350);
                   endShape(CLOSE);

                   fill( 50, 50, 50 );  // colore grigio INDIETRO 1   
                   // indietro 1 grigio
                   beginShape();
                   vertex(75,325);
                   vertex(75,375);
                   vertex(40,350);
                   endShape(CLOSE);              
                }
                
                if (ExtractVal == 0){
                   println("Indietro 1");  // 
                   fill( 255, 255, 0 ); // colore GIALLO INDIETRO
                   // indietro 1
                   beginShape();
                   vertex(75,325);
                   vertex(75,375);
                   vertex(40,350);
                   endShape(CLOSE);

                   fill( 50, 50, 50 ); // colore grigio INDIETRO
                   //  avanti 1
                   beginShape();
                   vertex(100,325);
                   vertex(100,375);
                   vertex(135,350);
                   endShape(CLOSE);   
                }
                
                
             //processa le direzioni frecce gialle
             case  "DIR2": 
                //strokeWeight( 3 );
                print(",  ExtractStr ");
                print(ExtractStr);
                print(",  Trovato DIR2 ");  // 
                ExtractStr =  StringFromSerialLine.substring(5);
                print(", ExtractStr ");
                print(ExtractStr);
                ExtractVal = Integer.parseInt(ExtractStr.trim());                
                //ExtractVal = int(ExtractStr);
                print(" , ExtractVal  ");
                println(ExtractVal);  // 

                if (ExtractVal  == 1){
                   println("Avanti 2");  // 
                   fill(  10, 3, 255 ); // colore grigio Drives off
                   beginShape();
                   vertex(100,450);
                   vertex(100,500);
                   vertex(135,475);
                   endShape(CLOSE);

                   fill( 50, 50, 50 );  // colore grigio AVANTI 2   
                   // indietro 1 grigio
                   beginShape();
                   vertex(75,450);
                   vertex(75,500);
                   vertex(40,475);
                   endShape(CLOSE);              
                }
                
                if (ExtractVal == 0){
                   println("Indietro 1");  // 
                   fill( 255, 255, 0 ); // colore GIALLO
                   // indietro 1
                   beginShape();
                   vertex(75,450);
                   vertex(75,500);
                   vertex(40,475);
                   endShape(CLOSE);

                   fill( 50, 50, 50 ); // colore grigio Drives off
                   //  avanti 1
                   beginShape();
                   vertex(100,450);
                   vertex(100,500);
                   vertex(135,475);
                   endShape(CLOSE);   
                }                
                
              break;


            }   // switch(ExtractStr)
         } // if (LenSFSL > 3)
       } // if (StringFromSerialLine != OldStringFromSerialLine)
       
  } //if (StringFromSerialLine != null)
  
  
  //-------------------------------------------------

  
  
  
  
  drw3gauge();

}


void drw3gauge(){
  //to save resource, only redraw when time has changed
  if (Power1_val != Power1old){
    Power1.update(Power1_val);
    pushMatrix();
    translate(530, 10);
    Power1.display();
    popMatrix();
    Power1old = Power1_val;
  }
  if (Power2_val != Power2old){
    Power2.update(Power2_val);
    pushMatrix();
    translate(270, 10);
    Power2.display();
    popMatrix();
    Power2old  = Power2_val;
  }

}

class Gauge{
  PVector gsize;  //width & height  gauge
  PVector gscale;  //start & end value scale
  PVector gneedle; //length  & angle needle
  int gsteps;
  float gline;
  String gname;
   
  Gauge(float tempx, float templow, float temphigh, float templine, String tempname){
    float gwidth = tempx;
    float gheight = 26*tempx/35;
    float glow  = templow;
    float ghigh = temphigh;
    gline = templine;
    gname  = tempname;
    gsteps = int(temphigh - templow) + 1;
    gsize = new PVector(gwidth,  gheight);
    gscale = new PVector(glow, ghigh);
    gneedle = new PVector(5*gsize.y/8,  map(second(), 0, 59, radians(35), radians(145)));
  }
 
  void display(){
    noStroke();
    //backcover
    fill(50);
    rect(0, 0, gsize.x, gsize.y);
    fill(255);
    textAlign(CENTER);
    textSize(14);
    text(gname,  gsize.x/2, 15);
    //scale
    stroke(255, 200);
    //strokeWeight(2);
    for (int i = 0; i < gsteps; i++){
      pushMatrix();
      translate(gsize.x/2,  11*gsize.y/12);
      rotate(PI + map(i, gscale.x, gscale.y, radians(35), radians(145)));
      if (i%gline == 0){
        line(gneedle.x-5, 0, gneedle.x+5, 0);
        translate(gneedle.x+10,  0);
        rotate(HALF_PI);
        textSize(9);
        text(i, 0, 0);
      } else {
        point(gneedle.x, 0);
      } 
      popMatrix();
    }
    noStroke();
    //needle
    stroke(255, 0, 0);
    //strokeWeight(3);
    pushMatrix();
    translate(gsize.x/2, 11*gsize.y/12);
    rotate(PI +  gneedle.y);
    line(0, 0, gneedle.x, 0);
    popMatrix();
    noStroke();
    //frontcover
    fill(150, 180);
    rect(0, 4.5*gsize.y/6, gsize.x, 1.5*gsize.y/6);
    fill(255, 0, 0);
    ellipseMode(CENTER);
    ellipse(gsize.x/2, 11*gsize.y/12,  10, 10);
  }
 
  void update(float tempgval){
    float gvalue = tempgval;
    gneedle.y = map(gvalue, gscale.x, gscale.y, radians(35), radians(145));
  }
} 

void mousePressed() {
  println("Coordinata cliccata: " + mouseX + ", " + mouseY);
}
