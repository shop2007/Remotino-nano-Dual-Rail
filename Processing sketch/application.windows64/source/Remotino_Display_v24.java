import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import static javax.swing.JOptionPane.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Remotino_Display_v24 extends PApplet {




Serial myPort;  
String StringFromSerialLine;     
String OldStringFromSerialLine;  
String ExtractStr;   
int ExtractVal;    
int LenSFSL; 

final boolean debug = true;

Gauge Power1, Power2;
int Power1_val = 0;
int Power2_val = 0;

// === VARIABILI PER MANTENERE LO STATO DELLE FRECCE ===
int dir1_val = -1; // -1 = spento/iniziale, 0 = indietro (giallo), 1 = avanti (blu)
int dir2_val = -1;

// === VARIABILI PER MANTENERE LO STATO DEGLI INDICATORI ===
int motn_val = 0;
int smod_val = 0;

// === ARRAY STATO INDIPENDENTE PER I 4 SCAMBI ===
// Ogni indice gestisce uno scambio (-1 = base, 1 = img1, 2 = img2)
int[] statoScambi = {-1, -1, -1, -1};

// === GESTIONE BOOST INDIPENDENTI ===
int boost1_val = 0; // 0 = Nero, 1 = Giallo
int boost2_val = 0; // 0 = Nero, 1 = Giallo

PImage img, img1, img2;

public void setup(){
  
  Power1 = new Gauge(250, 0, 255, 25, "Power1"); 
  Power2 = new Gauge(250, 0, 255, 25, "Power2"); 

  String COMx, COMlist = "";

  try {
    if(debug) printArray(Serial.list());
    int i = Serial.list().length;
    if (i != 0) {
      if (i >= 2) {
        for (int j = 0; j < i;) {
          COMlist += PApplet.parseChar(j+'a') + " = " + Serial.list()[j];
          if (++j < i) COMlist += ", ";
        }
        COMx = showInputDialog("Which COM port is correct? (a,b,..):\n"+COMlist);
        if (COMx == null) exit();
        if (COMx.isEmpty()) exit();
        i = PApplet.parseInt(COMx.toLowerCase().charAt(0) - 'a') + 1;
      }
      String portName = Serial.list()[i-1];
      if(debug) println(portName);
      myPort = new Serial(this, portName, 115200);
      myPort.bufferUntil('\n'); 
    }
    else {
      showMessageDialog(frame,"Device is not connected to the PC");
      exit();
    }
  }
  catch (Exception e)
  {
    showMessageDialog(frame,"COM port is not available (may be in use by another program)");
    println("Error:", e);
    exit();
  }  

  img = loadImage( "scambio0.jpg" );
  img1 = loadImage( "scambioA.jpg" );
  img2 = loadImage( "scambioB.jpg" );
}

public void draw(){
  // Pulisce lo schermo ad ogni ciclo
  background(200); 

  // --- 1. RICEZIONE E DECODIFICA SERIALE ---
  if (myPort != null && myPort.available() > 0) { 
     StringFromSerialLine = myPort.readStringUntil('\n'); 
  } 

  if (StringFromSerialLine != null) {
    String cleanLine = StringFromSerialLine.trim();

    if (!cleanLine.equals(OldStringFromSerialLine)) {
        println("Ricevuto: " + cleanLine); 
        OldStringFromSerialLine = cleanLine; 

        if (cleanLine.length() >= 5) {
           ExtractStr = cleanLine.substring(0, 4);

           switch(ExtractStr) {

             case "PWM1": 
               ExtractVal = Integer.parseInt(cleanLine.substring(5).trim()); 
               Power1_val = ExtractVal;                
             break;

             case "PWM2": 
               ExtractVal = Integer.parseInt(cleanLine.substring(5).trim()); 
               Power2_val = ExtractVal;                
             break;

             case "MOTN":  
               motn_val = Integer.parseInt(cleanLine.substring(5).trim()); 
             break;

             case "SMOD": 
               smod_val = Integer.parseInt(cleanLine.substring(5).trim()); 
             break;

             case "RLON":
               int rlon_val = Integer.parseInt(cleanLine.substring(5).trim());
               // Aggiorna solo lo scambio interessato mantenendo gli altri intatti
               if (rlon_val == 0) statoScambi[0] = 1; // Scambio 2-1
               if (rlon_val == 1) statoScambi[0] = 2;
               if (rlon_val == 2) statoScambi[1] = 1; // Scambio 4-3
               if (rlon_val == 3) statoScambi[1] = 2;
               if (rlon_val == 4) statoScambi[2] = 1; // Scambio 6-5
               if (rlon_val == 5) statoScambi[2] = 2;
               if (rlon_val == 6) statoScambi[3] = 1; // Scambio 8-7
               if (rlon_val == 7) statoScambi[3] = 2;
             break;

             case "DIR1": 
               dir1_val = Integer.parseInt(cleanLine.substring(5).trim()); 
             break;

             case "DIR2": 
               dir2_val = Integer.parseInt(cleanLine.substring(5).trim()); 
             break;

           }   // switch
         } 
       } 
  } 

  // --- CONTROLLO ACCENSIONE BOOST 1 E BOOST 2 ---
  boost1_val = (Power1_val >= 250) ? 1 : 0;
  boost2_val = (Power2_val >= 250) ? 1 : 0;

  // --- 2. DISEGNO CORNICI NERE DI CONTORNO (3px) ---
  stroke(0);          // Colore Nero
  strokeWeight(3);    // Spessore 3 pixel
  noFill();           // Solo bordo trasparente

  // Cornice 1: Contorna la colonna degli scambi a sinistra
  rect(10, 15, 230, 560);

  // Cornice 2: Contorna il blocco dei Gauge, Boost, Linee, Motor e Join a destra
  rect(255, 5, 520, 410);

  // --- 3. RENDERING GRAFICO DELL'INTERFACCIA ---

  textAlign(CENTER, CENTER);

  // --- SPIE MOTOR E 1-2 JOIN ---
  
  // SPIA MOTOR (Sotto Power2, asse X = 395)
  if (motn_val == 0) fill(50, 50, 50); // Grigio OFF
  else fill(0, 255, 0);                 // Verde ON
  stroke(255);
  strokeWeight(1);
  ellipse(395, 330, 45, 45);  
  textSize(16);
  fill(0, 0, 0);
  text("MOTOR ON", 395, 370);

  // SPIA 1-2 JOIN (Sotto Power1, asse X = 655)
  if (smod_val == 0) fill(50, 50, 50); // Grigio OFF
  else fill(255, 0, 0);                 // Rosso ON
  stroke(255);
  strokeWeight(1);
  ellipse(655, 330, 45, 45);  
  textSize(16);
  fill(0, 0, 0);
  text("1-2 JOIN", 655, 370);

  // --- COLONNA UNICA SCAMBI (PARTE SINISTRA) ---
  int scaX = 20;      // Inizio immagine
  int scaTextX = 100; // Centro orizzontale immagine per testo
  
  int y1 = 30;
  int y2 = 170;
  int y3 = 310;
  int y4 = 450;

  // 1. Immagini Scambio Base
  image(img, scaX, y1);
  image(img, scaX, y2);
  image(img, scaX, y3);
  image(img, scaX, y4);

  // 2. DISEGNO STATI SCAMBI IN BASE ALL'ARRAY
  if (statoScambi[0] == 1) image(img1, scaX, y1);
  if (statoScambi[0] == 2) image(img2, scaX, y1);

  if (statoScambi[1] == 1) image(img1, scaX, y2);
  if (statoScambi[1] == 2) image(img2, scaX, y2);

  if (statoScambi[2] == 1) image(img1, scaX, y3);
  if (statoScambi[2] == 2) image(img2, scaX, y3);

  if (statoScambi[3] == 1) image(img1, scaX, y4);
  if (statoScambi[3] == 2) image(img2, scaX, y4);
  
  // 3. Testi Scambi
  fill(0);
  textSize(13);
  text("SCAMBIO 1-2", scaTextX, y1 + 100); 
  text("SCAMBIO 3-4", scaTextX, y2 + 100);  
  text("SCAMBIO 5-6", scaTextX, y3 + 100); 
  text("SCAMBIO 7-8", scaTextX, y4 + 100); 

  // --- SCRITTA IN BASSO A DESTRA ---
  textAlign(RIGHT, CENTER);
  textSize(14);
  fill(40);
  text("REMOTINO NANO DUAL ARM", 770, 570);

  // DISEGNO FRECCE DIREZIONE CENTRATE SOTTO I GAUGE
  drawFrecce();

  // STRUMENTI GAUGE
  drw3gauge();

  // --- SPIE BOOST SOTTO I GAUGE ---
  textAlign(CENTER, CENTER);
  textSize(12);

  // BOOST 2 (Sotto Gauge Power2, centrato a X=395)
  if (boost2_val == 0) fill(0, 0, 0);   // Nero OFF
  else fill(255, 255, 0);               // Giallo ON
  stroke(255);
  strokeWeight(1);
  ellipse(395, 215, 25, 25);
  fill(0);
  text("BOOST 2", 395, 235);

  // BOOST 1 (Sotto Gauge Power1, centrato a X=655)
  if (boost1_val == 0) fill(0, 0, 0);   // Nero OFF
  else fill(255, 255, 0);               // Giallo ON
  stroke(255);
  strokeWeight(1);
  ellipse(655, 215, 25, 25);
  fill(0);
  text("BOOST 1", 655, 235);
}

public void drawFrecce() {
  textAlign(CENTER, CENTER);
  textSize(14);
  strokeWeight(1);

  // --- LINEA 2 (Centrata sotto Power2: Asse X = 395) ---
  fill(0);
  text("LINEA 2", 395, 255);

  if (dir2_val == 1) { 
    fill(10, 3, 255);   drawAvanti(395);
    fill(50, 50, 50);  drawIndietro(395);
  } else if (dir2_val == 0) { 
    fill(255, 255, 0);  drawIndietro(395);
    fill(50, 50, 50);  drawAvanti(395);
  } else { 
    fill(50, 50, 50);  drawIndietro(395); drawAvanti(395);
  }

  // --- LINEA 1 (Centrata sotto Power1: Asse X = 655) ---
  fill(0);
  text("LINEA 1", 655, 255);

  if (dir1_val == 1) { 
    fill(10, 3, 255);   drawAvanti(655);
    fill(50, 50, 50);  drawIndietro(655);
  } else if (dir1_val == 0) { 
    fill(255, 255, 0);  drawIndietro(655);
    fill(50, 50, 50);  drawAvanti(655);
  } else { 
    fill(50, 50, 50);  drawIndietro(655); drawAvanti(655);
  }
}

// Disegna la freccia indietro centrata sul punto X fornito
public void drawIndietro(float centerX) { 
  beginShape(); 
  vertex(centerX - 10, 270); 
  vertex(centerX - 10, 290); 
  vertex(centerX - 35, 280); 
  endShape(CLOSE); 
}

// Disegna la freccia avanti centrata sul punto X fornito
public void drawAvanti(float centerX) { 
  beginShape(); 
  vertex(centerX + 10, 270); 
  vertex(centerX + 10, 290); 
  vertex(centerX + 35, 280); 
  endShape(CLOSE); 
}

public void drw3gauge(){
  Power1.update(Power1_val);
  pushMatrix();
  translate(530, 10);
  Power1.display();
  popMatrix();

  Power2.update(Power2_val);
  pushMatrix();
  translate(270, 10);
  Power2.display();
  popMatrix();
}

class Gauge{
  PVector gsize;  
  PVector gscale;  
  PVector gneedle; 
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
    gsteps = PApplet.parseInt(temphigh - templow) + 1;
    gsize = new PVector(gwidth, gheight);
    gscale = new PVector(glow, ghigh);
    gneedle = new PVector(5*gsize.y/8, map(second(), 0, 59, radians(35), radians(145)));
  }
 
  public void display(){
    noStroke();
    fill(50);
    rect(0, 0, gsize.x, gsize.y);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(14);
    text(gname, gsize.x/2, 15);
    stroke(255, 200);
    strokeWeight(1);
    for (int i = 0; i < gsteps; i++){
      pushMatrix();
      translate(gsize.x/2, 11*gsize.y/12);
      rotate(PI + map(i, gscale.x, gscale.y, radians(35), radians(145)));
      if (i%gline == 0){
        line(gneedle.x-5, 0, gneedle.x+5, 0);
        translate(gneedle.x+10, 0);
        rotate(HALF_PI);
        textSize(9);
        text(i, 0, 0);
      } else {
        point(gneedle.x, 0);
      } 
      popMatrix();
    }
    noStroke();
    stroke(255, 0, 0);
    strokeWeight(1);
    pushMatrix();
    translate(gsize.x/2, 11*gsize.y/12);
    rotate(PI + gneedle.y);
    line(0, 0, gneedle.x, 0);
    popMatrix();
    noStroke();
    fill(150, 180);
    rect(0, 4.5f*gsize.y/6, gsize.x, 1.5f*gsize.y/6);
    fill(255, 0, 0);
    ellipseMode(CENTER);
    ellipse(gsize.x/2, 11*gsize.y/12, 10, 10);
  }
 
  public void update(float tempgval){
    float gvalue = tempgval;
    gneedle.y = map(gvalue, gscale.x, gscale.y, radians(35), radians(145));
  }
} 

public void mousePressed() {
  println("Coordinata cliccata: " + mouseX + ", " + mouseY);
}
  public void settings() {  size(790, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Remotino_Display_v24" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
