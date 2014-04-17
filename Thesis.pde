import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

// Run this program only in the Java mode inside the IDE,
// not on Processing.js (web mode)!!
/* @pjs preload="blood1.png"; */
/* @pjs preload="blood3.png"; */
/* @pjs preload="blood2.png"; */
/* @pjs font="Extrue.ttf"; */

import processing.video.*;
var ctx;

PFont font;
Capture cam;
AudioPlayer backgroundOnePlayer;
AudioPlayer backgroundTwoPlayer;
AudioPlayer backgroundThreePlayer;
AudioPlayer effectPlayer;
Minim minim;//audio context
int effectPlayerOneLastLevelPlayed = -1;
int effectPlayerOneLastIndexPlayed = -1;
int lastLevelSaved;
int currentLevel = -1;
TTS tts;


int viewWidth = 1024;
int viewHeight = 768;
int cameraWidth = viewWidth - 200;
int cameraHeight = viewHeight - 100;
int cycleDuration = 4500; // Miliseconds
int currentTime;
int initialTime;

PImage bruiseLow;
PImage bruiseMedium;
PImage bruiseHigh;

String[] introMessages = {
  "WORDS ARE POWERFUL,\nSEE FOR YOURSELF...",
  "PLACE FACE",
  "PLAY"
};

String[] introEffects = {
  "start",
  "levelStart",
  "backgroundIntro"
};

String[] levelOneMessages = {
  "LEVEL 1",
  "A MAN WHO HAS LOTS OF SEX CAN BE CALLED...",
  "[REPEAT THE FOLLOWING WORDS IN YOUR HEAD]",
  "STUD",
  "PLAYER",
  "STALLION",
  "ROMEO",
  "CASANOVA",
  "DON JUAN",
  "CONGRATULATIONS"
};

String[] levelOneEffects = {
  "levelStart",
  "", // no effect
  "pulse",
  "newWord",
  "newWord",
  "newWord",
  "newWord",
  "newWord",
  "newWord",
  "congratulations"
};

String[] levelTwoMessages = {
  "LEVEL 2",
  "A WOMAN THAT HAS LOTS OF SEX IS CALLED...",
  "SLUT",
  "NYMPHOMANIAC",
  "TART",
  "TRAMP",
  "SKANK",
  "HOOCHIE MAMA",
  "SEXPOT",
  "HOOKER",
  "BITCH",
  "WHORE",
  "GAME OVER"  
};

String[] levelTwoEffects = {
  "levelStart",
  "",
  "newWord",
  "newWord",
  "newWord",
  "newWord",
  "newWord",
  "newWord",
  "newWord",
  "slapOne",
  "slapOne",
  "slapOne",
  "gameOver"  
};

color[] highSelfSteemColors = {
  color(173,221,142),  // Light green
  color(120,198,121),
  color(65,171,93),
  color(35,132,67),
  color(0,104,55),
  color(0,69,41)       // Dark green
};

color[] lowSelfSteemColors = {
  color(252,78,42),
  color(227,26,28),
  color(189,0,38),
  color(128,0,38)    // Dark Red
};


float introInitialTime = 0;
float levelOneInitialTime = introMessages.length * cycleDuration;
float levelTwoInitialTime = levelOneInitialTime + (levelOneMessages.length * cycleDuration);
float finalTime = levelTwoInitialTime + (levelTwoMessages.length * cycleDuration);
int currentIndex = -1;
int flashCount = 0;
int flashTimer;
int flashIndex = 0;
Boolean shouldFlash = true;
Boolean shouldFlashForIndex = true;
color fontGreen = color(198, 248, 66);

void setup() {
  size(1024, 768);
  
  ctx = externals.context;
 
  // Configure font
  textFont(createFont("Extrude",32));
  textAlign(CENTER);

  // configure music
  minim = new Minim(this);
  tts = new TTS(this);
  backgroundOnePlayer = minim.loadFile("level1bg");
  backgroundTwoPlayer = minim.loadFile("level2bg");
  backgroundThreePlayer = minim.loadFile("error");
    
  // configure bruises
  bruiseLow = loadImage("blood2.png");
  bruiseMedium = loadImage("blood1.png");
  bruiseHigh = loadImage("blood3.png");
  
  initialTime = millis();
}

void draw() {
  if (!video.available) return;
  
  fill(153, 51, 250);
  rect(0, 0, viewWidth, viewHeight);
   
  pushMatrix();
  translate(width,0);
  scale(-1,1);//mirror the video so that it looks like me looing back at me (not just a raw video feed)
  ctx.drawImage(video, 0, 0, cameraWidth, cameraHeight); //video is defined with video.js
  popMatrix();
  
  currentTime = millis() - initialTime;
  
  if (shouldPlayIntro()) {
    playIntro();
  }
  else if (shouldPlayLevelOne()) {
    playLevelOne();
  }
  else if (shouldPlayLevelTwo()) {
    playLevelTwo();
  }
  else {
    // Reset the timer 
    initialTime = millis();
    currentIndex = -1;
    effectPlayerOneLastLevelPlayed = -1;
    effectPlayerOneLastIndexPlayed = -1;
    lastLevelSaved = -1;
    
    backgroundTwoPlayer.pause();
    backgroundTwoPlayer.rewind();
    backgroundThreePlayer.pause();
    backgroundThreePlayer.rewind();
  }
}

boolean shouldPlayIntro() {
   return currentTime < levelOneInitialTime;
}

boolean shouldPlayLevelOne() {
   return levelOneInitialTime <= currentTime && currentTime < levelTwoInitialTime;
}

boolean shouldPlayLevelTwo() {
  return levelTwoInitialTime <= currentTime && currentTime < finalTime;
}

void playIntro() {  
  int levelIndex = floor(currentTime/cycleDuration);

  playEffectForLevel(introEffects[levelIndex], 0, levelIndex);

  if (levelIndex >= 1) {
    drawFace();
    printMiddleMessage(introMessages[levelIndex], fontGreen);
    drawSelfSteemWithLevel(0);
  }
  else {
    fill(153, 51, 250);
    rect(0, 0, viewWidth, viewHeight);
    printMiddleMessage(introMessages[levelIndex], fontGreen);
  }
  
  sayMessageForIndex(introMessages[levelIndex], levelIndex);
}

void playLevelOne() {
  if (!backgroundOnePlayer.isPlaying()) {
     backgroundOnePlayer.loop(); 
  }
  int levelIndex = floor(currentTime/cycleDuration) - introMessages.length;
  
  playEffectForLevel(levelOneEffects[levelIndex], 1, levelIndex);
  
  if (levelIndex == 2) {
    printBottomMessage(levelOneMessages[levelIndex], color(255));
  }
  else {
    printBottomMessage(levelOneMessages[levelIndex], fontGreen);
  }
  sayMessageForIndex(levelOneMessages[levelIndex], levelIndex);
  
  if (levelIndex > 2 && levelIndex < levelOneMessages.length - 1) {
    drawSelfSteemWithLevel(levelIndex - 2); 
  }
  else {
    drawSelfSteemWithLevel(0); 
  }
  
  drawFace();
}

void playLevelTwo() {
  if (backgroundOnePlayer.isPlaying()) {
    backgroundOnePlayer.pause();
    backgroundOnePlayer.rewind(); 
  }
  
  int levelIndex = floor(currentTime/cycleDuration) - introMessages.length - levelOneMessages.length;
  
  if (levelIndex < 8) {
    if (!backgroundTwoPlayer.isPlaying()) {
      backgroundTwoPlayer.loop();
    }  
  }
  else if (levelIndex >= 9 && levelIndex <= 11){
    if (!backgroundThreePlayer.isPlaying()) {
      backgroundTwoPlayer.pause();
      backgroundThreePlayer.loop();
    } 
  }
  else {
    backgroundTwoPlayer.pause();
    backgroundThreePlayer.pause();
  }
  
  
  playEffectForLevel(levelTwoEffects[levelIndex], 2, levelIndex);
  
  if (flashIndex != levelIndex) {
    flashIndex = levelIndex;
    flashCount = 0; 
  } 
  if (levelIndex > 0 && levelIndex < levelTwoMessages.length - 1) {
    drawSelfSteemWithLevel(7 - levelIndex); 
  }
  
  // Add Buises
  if (levelIndex > 8 && levelIndex < levelTwoMessages.length - 1) {
    tint(255, 150);
    image(bruiseLow, (viewWidth / 2) + 30, (viewHeight/2) + 20, 100, 255);
    tint(255);
    saveFrameForLevel(levelIndex);
  }
  
  if (levelIndex > 9 && levelIndex < levelTwoMessages.length - 1) {
    tint(255, 150);
    image(bruiseHigh, (viewWidth / 2) - 150, (viewHeight/2) + 30, 170, 255);
    tint(255);
    saveFrameForLevel(levelIndex);
  }
  
  if (levelIndex > 10 && levelIndex < levelTwoMessages.length - 1) {
    tint(255, 190);
    image(bruiseHigh, (viewWidth / 2) - 10, (viewHeight/2) - 170, 180, 255);
    tint(255);
    saveFrameForLevel(levelIndex);
  }
  
  if (levelIndex < levelTwoMessages.length - 1) {
    printBottomMessage(levelTwoMessages[levelIndex], fontGreen);
    drawFace(); 
  }
  else {
     printMiddleMessage(levelTwoMessages[levelIndex], fontGreen); 
  }
  
  if (levelIndex > 8 && levelIndex < levelTwoMessages.length - 1) {
     flashWarning(levelIndex);
  }
  sayMessageForIndex(levelTwoMessages[levelIndex], levelIndex);
}

void printMiddleMessage(String message, color messageColor) {
  textSize(32);
  fill(messageColor);
  text(message, 0, (viewHeight/2) - 60, viewWidth, 80);
}

void printBottomMessage(String message, color messageColor) {
  textSize(32);
  fill(messageColor);
  text(message, 0, viewHeight - 80, viewWidth, viewHeight);
}

void sayMessageForIndex(String message, int index) {
  if (index == currentIndex) { return; }

  currentIndex = index;
  tts.say(message);
}

void drawFace() {
  noFill();
  ellipse(viewWidth/2, (viewHeight/2) - 60, 300, 550); 
}

void drawSelfSteemWithLevel(int level) {
  fill(114, 247, 154 );
  textSize(26);
  int originHeight = (viewHeight/4);
  text("SELF-ESTEEM LEVEL\n...............", 0, originHeight, 200, viewHeight);
  
  if (level > 0) {
    for (int i = 0; i < level; i++) {
      fill(highSelfSteemColors[i]);
      rect(50, ((5 - i) * 35) + (viewHeight/4) + 100, 100, 30);
    }
  }
  else {
    for (int i = 0; i < abs(level); i++) {
      fill(lowSelfSteemColors[i]);
      rect(50, (i * 35) + (viewHeight/4) + 310, 100, 30);
    }
  }
}

void flashWarning(int level) {
  noStroke();
  fill(color(189, 0, 38, 50 * (level - 8)));
  rect(200, 0, viewWidth - 200, viewHeight - 100);
  stroke(0);
}

void playEffectForLevel(String effect, int level, int index) {
  if (effect.length() == 0) { return; }
 
  if (effectPlayerOneLastLevelPlayed < level) {
    effectPlayerOneLastIndexPlayed = -1;
  }
  if (effectPlayerOneLastIndexPlayed < index) {
    if (effectPlayer != null) {
      effectPlayer.pause();
      effectPlayer.rewind();
    }
    
    effectPlayer = minim.loadFile(effect);
    effectPlayer.play();
    effectPlayerOneLastLevelPlayed = level;
    effectPlayerOneLastIndexPlayed = index;
  } 
}

void saveFrameForLevel(int level) {
  if (lastLevelSaved == level) { return; }
  
  lastLevelSaved = level;
//  saveFrame("line-######.jpg"); 
}

void stop() {
  backgroundOnePlayer.close();
  backgroundTwoPlayer.close();
  effectPlayer.close();
  minim.stop();
  super.stop();
}

