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
int menuItemCount;

// Keymapping vector. 0 = Windows, 1 = Mac, 2 = Linix 
final int COMPUTER_TYPE = 0;

final int LEDCnt = 120;
StringList slLSEffect;  // light string effect in list string format
int msAdjust = 0;
int textHeight;

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
String songName = "05 - Sweet Emotion";



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
  if(k >= 'a' && k <= 'z') {
    int tmCheck = player.position() - millis() - msAdjust;
    if(tmCheck < 0) tmCheck = -tmCheck;
    if(tmCheck > 25) println("time out of sync at " + millis() + " by " + tmCheck);
  }
  processKeystroke(k);
}


void keyReleased() {
  int k = keyToInt(keyCode, key);
  if(k >= 'a' && k <= 'z') {
    // save key and time relative to start of song
    k = char(byte(k) - 32); // capitalize
    String effLine = nf(player.position(), 7) + ',' + k;
    slLSEffect.append(effLine);  
  }
}


int keyToInt(int kc, int k) {
  if(kc == k || (kc + 0x20) == k)
    kc = k;
  else {
    kc <<= 16;
    kc += k;
  }
  print("keyCode: " + hex(keyCode) + "  key: " + hex(key));
  println("  combined: " + hex(kc));
  return kc;
}


void processKeystroke(int kk) {
  switch(kk) {
  // ESC will exit program without saving data (processing default)
  case 0x00530013:  // ctrl-s: save
    saveData();
    break;
  case 0x004C000C:  // ctrl-l: load
    loadData();
    break;
  case 0x00030000:  // END: save file and end program
    saveData();
    exit();
    break;
  case 0x00930000:  // DELETE: abandon data
    slLSEffect.clear();
    break;
  case 0xD:  // ENTER: play from beginning
    player.rewind();
    player.play();
    break;
  case 0x008B002B:  // '+': increase window size
  case 0x003D002B:
    windowPercentSize += 10;
    if(windowPercentSize > 100) windowPercentSize = 100;
    break;
  case 0x008C002D:  // '-': decrease window size
  case 0x2D:
    windowPercentSize -= 10;
    if(windowPercentSize < 20) windowPercentSize = 20;
    break;
  case ' ':  // play pause
    playPause();
    break;
  default:
    break;
  }
  if(kk >= 'a' && kk <= 'z') {
    println("effect key");
    // create a generic effect to display for keystroke
    // locationStart, spread, hueStart, hueEnd, hueDirection, timeStart, duration, timeBuild
    ef = new effect(10, 8, 180, 180, 1, player.position(), 300, 0);
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

void setupMenuItems() {
  int xPos, yPos, yOffset, yPosText;
  
  menuItemCount = 0;
  xPos = 10;
  yOffset = textHeight + textHeight / 3;
  yPosText = YPosMenu + textHeight * 2;
  yPos = yPosText; 
  mItem[menuItemCount] = new menuItem("SPACE: pause / playback", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
  mItem[menuItemCount] = new menuItem("ctrl-l: load data", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
  mItem[menuItemCount] = new menuItem("ctrl-s: save data", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
  mItem[menuItemCount] = new menuItem("DELETE: abandon unsaved data", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
  mItem[menuItemCount] = new menuItem("ENTER: start from beginning", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
  mItem[menuItemCount] = new menuItem("ESC: exit", xPos, yPos);
  menuItemCount++;
  xPos = width / 2 + 10;
  yPos = yPosText;
  mItem[menuItemCount] = new menuItem("'-': decrease window size", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
  mItem[menuItemCount] = new menuItem("'+': increase window size", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
}

void drawMenus() {
  fill(255);
  for(int i = 0; i < menuItemCount; i++)
    mItem[i].itemDraw();
}