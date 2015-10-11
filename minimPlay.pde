/**
  * This sketch demonstrates how to play a file with Minim using an AudioPlayer.
  * It's also a good example of how to draw the waveform of the audio. Full documentation 
  * for AudioPlayer can be found at http://code.compartmental.net/minim/audioplayer_class_audioplayer.html
  * 
  * For more information about Minim and additional features, 
  * visit http://code.compartmental.net/minim/
  */
PFont font;
int globalFontSize = 18;  // starting point for font text sizing

import ddf.minim.*;

effectDisplay ed = new effectDisplay();
effParameterChange epc = new effParameterChange();

Minim minim;
AudioPlayer player;


color backgroundNormal;
color backgroundHighlight;
color fillNormal;
color fillHighlight;
// add colors for input box
color positionMarkerColor;
color waveColor;
color initialEffectColor;
color debugColor;


//menuItem[] mItem = new menuItem[20];
//int menuItemCount;

final int LEDCnt = 120;
StringList LSEffect;  // light string effect in list string format
int msAdjust = 0;
int textHeight;

int prevWindowPercentSize = 0;
int windowPercentSize = 50;
boolean sizeChange = false;

// metrics of different areas
// width and height are determined by window size
int areaOffset;
int XPosWave = 0;
int YPosWave;
int XPosMenu = 0;
int YPosMenu;
int XPosEffect = 0;
int YPosEffect;

//String songName = "07  Pink - Funhouse";
//String songName = "Mystic Rhythms";
//String songName = "CLOSE ENCOUNTERS OF THE THIRD KIND (Disco 45-) HIGH QUALITY";
//String songName = "No Cures";
String songName = "05 - Sweet Emotion";
//String songName = "Apple Loops";

void setup()
{
  size(512, 400, P3D);
  surface.setResizable(true);
  font = loadFont("Arial-BoldMT-18.vlw");
  textFont(font);
  textSize(globalFontSize);
  
  colorMode(HSB, 360, 100, 100);
  // setup color preferences
  backgroundNormal = color(0);
  backgroundHighlight = color(46, 49, 46); // for drawing rectangles behind text not background()
  fillNormal = color(255);
  fillHighlight = color(179, 99, 99);
  positionMarkerColor = color(180, 99, 99);
  waveColor = color(272, 70, 99);
  initialEffectColor = color(196, 99, 99);
  debugColor = color(60, 99, 99);

  noStroke();
  background(backgroundNormal);

  setupMenu();
  ed.setupReferenceDisplay();
  ed.setupEffectSelectAry();
  
  LSEffect = new StringList();
  minim = new Minim(this);  // to load files from data directory
  player = minim.loadFile(songName + ".mp3");
}


void draw()
{
  sizeChange = windowPercentSize != prevWindowPercentSize;
  if(sizeChange) {
    prevWindowPercentSize = windowPercentSize;
    surface.setSize(displayWidth * windowPercentSize / 100, displayHeight * windowPercentSize / 100);
    //=============================
    // this will not work if we to change the Font
    textSize(windowPercentSize/2.6);
    // ============================
    textHeight = int(textAscent()) + int(textDescent());
    areaOffset = height / 3;
    YPosWave = 0;
    YPosMenu = YPosWave + areaOffset;
    YPosEffect = YPosMenu + areaOffset;
    rePositionMenu();
    ed.rePositionEffects();
    epc.reposition();
    //epc.drplt.reposition();
  }
  background(backgroundNormal);  // clear screen
  drawWaveForm();
  ed.drawEffDisp();
  //drawMenu();
  epc.drplt.drawMe();  // effect parameter change
  stroke(debugColor);
  line(0, YPosEffect, width, YPosEffect);
}


void drawWaveForm()
{
  // draw the waveforms
  // the values returned by left.get() and right.get() will be between -1 and 1,
  // so we need to scale them up to see the waveform
  // note that if the file is MONO, left.get() and right.get() will return the same value
  
  stroke(waveColor);
  strokeWeight(2);
  int wfvs = areaOffset / 4;  // wave form vertical spacing
  int wfc1 = wfvs;  // wave form 1 center
  int wfc2 = wfvs * 3;  // wave form 2 center
  for(int i = 0; i < player.bufferSize() - 1; i++)
  {
    float x1 = map( i, 0, player.bufferSize(), 0, width );
    float x2 = map( i+1, 0, player.bufferSize(), 0, width );
    line( x1, wfc1 + player.left.get(i)*wfvs, x2, wfc1 + player.left.get(i+1)*wfvs );
    line( x1, wfc2 + player.right.get(i)*wfvs, x2, wfc2 + player.right.get(i+1)*wfvs );
  }
  // draw a line to show where in the song playback is currently located
  //stroke(positionMarkerColor);
  float posx = map(player.position(), 0, player.length(), 0, width);
  float lineWidth = width / 512;
  if(lineWidth < 1) lineWidth = 1;
  noStroke();
  fill(positionMarkerColor);
  rect(posx, 0, lineWidth, areaOffset);
}

void mouseClicked() {
  int mY = mouseY;
  if(mY >= YPosMenu && mY < YPosEffect) 
    doTask(menuItemClicked(mouseX, mouseY));
  else if(mY >= YPosEffect) 
    ed.effectClicked();
}

void mouseDragged() {
  
}

void keyPressed() {
  if(key == 27) key = 0;
  int k = keyToInt(keyCode, key);
  println(int(keyCode), int(key), keyToInt(keyCode, key));
  // time sync check
  if(k >= 'a' && k <= 'z') {
    int tmCheck = player.position() - millis() - msAdjust;
    if(tmCheck < 0) tmCheck = -tmCheck;
    if(tmCheck > 25) println("time out of sync at " + millis() + " by " + tmCheck);

    println("effect key");
    // create a generic effect to display for keystroke
    // locationStart, spread, hueStart, hueEnd, hueDirection, timeStart, duration, timeBuild
    ed.efGeneric = new effect(10, 8, 180, 180, 1, player.position(), 300, 0);
    // save key and time relative to start of song
    String effLine = nf(player.position(), 7) + ',' + char(k);
    LSEffect.append(effLine);
    return;
  }
  doTask(keyToMenuNum(k));
}


void keyReleased() {
  int k = keyToInt(keyCode, key);
  if(k >= 'a' && k <= 'z') {
    // save key and time relative to start of song
    k = char(byte(k) - 32); // capitalize
    String effLine = nf(player.position(), 7) + ',' + k;
    LSEffect.append(effLine);  
  }
}


int keyToInt(int kc, int k) {
  if(kc == k || (kc + 0x20) == k)
    kc = k;
  else {
    kc <<= 16;
    kc += k;
  }
  //print("keyCode: " + hex(keyCode) + "  key: " + hex(key));
  //println("  combined: " + hex(kc));
  return kc;
}

void doTask(int task) {
  switch(task) {
  case 0:  // play pause
    playPause();
    break;
  case 1:  // load
    loadData();
    break;
  case 2:  // save
    saveData();
    break;
  case 3:  // save file and end program
    saveData();
    exit();
    break;
  case 4:  // abandon data
    abandonData();
    break;
  case 5:  // play from beginning
    rewind();
    break;
  case 6:  // exit program without saving data (processing default)
    exit();
    break;
  case 7:  // decrease window size
  case 8:
    windowResize(0);
    break;
  case 9:  // increase window size
  case 10:
    windowResize(1);
    break;
  default:
    break;
  }
}

void playPause() {
  // play pause
  if ( player.isPlaying() )
    player.pause();
  // if the player is at the end of the file,
  // we have to rewind it before telling it to play again
  else if ( player.position() == player.length() ) {
    player.rewind();
    player.play();
  }
  else
    player.play();
  // setup to check time against millis()    
  if(player.isPlaying()) {
    msAdjust = player.position() - millis();
    println("player.position(): " + player.position() + " millis(): " + millis() + "    msAdjust: " + msAdjust);
  }
}  

void rewind() {
  player.rewind();
  if (player.isPlaying()) {
    player.play();
  }
}

void saveData() {
  LSEffect.sort();
  String[] aa = new String[LSEffect.size()];
  for(int i = 0; i < LSEffect.size(); i++) {
    println(LSEffect.get(i));
    aa[i] = LSEffect.get(i);
  }
  saveStrings(songName + ".md1", aa);
}


void loadData() {
  LSEffect.clear();
  String[] aa = loadStrings(songName + ".md1");
  for(int i = 0; i < aa.length; i++) {
    LSEffect.append(aa[i]);    
    println(aa[i]);
  }
}

void abandonData() {
  LSEffect.clear();
}


void windowResize(int direction) {
  if (direction == 0) {
    windowPercentSize -= 10;
    if(windowPercentSize < 20) windowPercentSize = 20;
  }
  else {
    windowPercentSize += 10;
    if(windowPercentSize > 100) windowPercentSize = 100;
  }
  println("WindowPercentSize", windowPercentSize);
}