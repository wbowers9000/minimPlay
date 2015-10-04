/**
  * This sketch demonstrates how to play a file with Minim using an AudioPlayer. <br />
  * It's also a good example of how to draw the waveform of the audio. Full documentation 
  * for AudioPlayer can be found at http://code.compartmental.net/minim/audioplayer_class_audioplayer.html
  * <p>
  * For more information about Minim and additional features, 
  * visit http://code.compartmental.net/minim/
  */
PFont font;

import ddf.minim.*;

Minim minim;
AudioPlayer player;

Combineeffect ce = new Combineeffect();
render rnder = new render();

menuItem[] mItem = new menuItem[20];
effect[] effects = new effect[12];

final int LEDCnt = 120;
final int heightOfLine = 10;
int waveWindowHeight;
int xPos, yPos;
int inKey;
StringList slLSEffect;  // light string effect in list string format
int msAdjust = 0;
int textHeight;

String keyString, modString, tmpString;

int prevWindowPercentSize = 0;
int windowPercentSize = 50;

int areaOffset;
int YPosWave;
int YPosMenu;
int YPosEffect;

//String songName = "07  Pink - Funhouse";
//String songName = "Mystic Rhythms";
//String songName = "CLOSE ENCOUNTERS OF THE THIRD KIND (Disco 45-) HIGH QUALITY";
//String songName = "No Cures";
//String songName = "05 - Sweet Emotion";
String songName = "Apple Loops";



void setup()
{
  size(512, 400, P3D);
  surface.setResizable(true);
  font = loadFont("Arial-BoldMT-18.vlw");
  textFont(font);
  
  colorMode(HSB, 360, 100, 100);
  stroke(255);
  background(0);
  
  slLSEffect = new StringList();
  minim = new Minim(this);  // to load files from data directory
  player = minim.loadFile(songName + ".mp3");
  // setup refence bar
  refDisp = new HSBColor[LEDCnt];
  for(int i = 0; i < refDisp.length; i++) refDisp[i] = new HSBColor();
  for(int i = 0; i < refDisp.length; i += 2) refDisp[i].set((i * 5) % 360, 100, 100);
}


void draw()
{
  if(windowPercentSize != prevWindowPercentSize) {
    prevWindowPercentSize = windowPercentSize;
    surface.setSize(displayWidth * windowPercentSize / 100, displayHeight * windowPercentSize / 100);
  
    textHeight = int(textAscent()) + int(textDescent());
    areaOffset = height / 3;
    YPosWave = 0;
    YPosMenu = YPosWave + areaOffset;
    YPosEffect = YPosMenu + areaOffset;
    setupMenuItems();
    rnder.displaySetup(LEDCnt);
  }
  background(0);
  stroke(270, 100, 100);
  drawWaveForm();
  drawEffDisp();
  drawMenus();
}


void drawWaveForm()
{
  // draw the waveforms
  // the values returned by left.get() and right.get() will be between -1 and 1,
  // so we need to scale them up to see the waveform
  // note that if the file is MONO, left.get() and right.get() will return the same value
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
  stroke(180, 100, 100);
  float posx = map(player.position(), 0, player.length(), 0, width);
  float lineWidth = width / 512;
  if(lineWidth < 1) lineWidth = 1;
  stroke(0,100,100);
  rect(posx, 0, lineWidth, areaOffset);

}


void keyPressed() {
  int k = keyToInt(keyCode, key);
  // time sync check
  if (k >= 'a' && k <= 'z') {
    int tmCheck = player.position() - milis() - msAdjust;
    if (tmCheck < 0) tmCheck = -tmCheck;
    if (tmCheck > 25) println("Time async at "+millis()+" by "+tmCheck);
  }
  processKeystroke(k);
}


void keyReleased() {
  char k;
  if(key != CODED) {
    k = key;
    if(k >= 'a' && k <= 'z') {
      // save key and time relative to start of song
      k = char(byte(k) - 32); // capitalize
      String effLine = nf(player.position(), 7) + ',' + k;
      slLSEffect.append(effLine);  
    }
  }
}

int keyToInt(int kc, int k) {
  if (kc == k || (kc + 0x20) == k) kc = k;
  else {
    kc <<= 16;
    kc += k;
  }
  print("keyCode: "+hex(keyCode)+", key: "+hex(key));
  println(", combined: "+hex(kc));
  return kc;
}

void processKeystroke(int kk) {
  switch(kk) {
  case 63245: // F11: save
    saveData();
    break;
  case 63246: // F10: load
    loadData();
    break;
  case 8:     // backspace: abandon data
    clearData();
    break;
  case 13:    // enter: play from beginning
    rewind();
    break;
  case '=':    // +: increase window size
    increaseSize();
    break;
  case '-':    // -: decrease window size
    decreaseSize();
    break;
  case ' ':   // space: play pause
    playPause();
    break;
  default:
    break;
  }
  if(kk >= 'a' && kk <= 'z') {
    // create a generic effect to display for keystroke
    // locationStart, spread, hueStart, hueEnd, hueDirection, timeStart, duration, timeBuild
    ef = effectCreate(char(kk), player.position());
    // save key and time relative to start of song
    String effLine = nf(player.position(), 7) + ',' + char(kk);
    slLSEffect.append(effLine);
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


void saveData() {
  slLSEffect.sort();
  String[] aa = new String[slLSEffect.size()];
  for(int i = 0; i < slLSEffect.size(); i++) {
    println(slLSEffect.get(i));
    aa[i] = slLSEffect.get(i);
  }
  saveStrings(songName + ".md1", aa);
}


void loadData() {
  slLSEffect.clear();
  String[] aa = loadStrings(songName + ".md1");
  for(int i = 0; i < aa.length; i++) {
    slLSEffect.append(aa[i]);    
    println(aa[i]);
  }
}

void clearData() {
  slLSEffect.clear();
}

void rewind() {
  player.cue(0);
}

void increaseSize() {
  windowPercentSize += 10;
  if(windowPercentSize > 100) windowPercentSize = 100;
}

void decreaseSize() {
  windowPercentSize -= 10;
  if(windowPercentSize < 20) windowPercentSize = 20;
}