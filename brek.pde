//-----------------------------------------
//--------------- VARIABLES ---------------
//-----------------------------------------

// GameState:
// 0: Initial Screen
// 1: Game Screen
// 2: GameOver Screen
int gameState = 0;

// color
int score;

// timer
float timeRoundStarted;
float timePlayed;

// ball
float ballX, ballY;
int ballSize = 20;
int ballColor = color(235, 186, 185);

// gravity
float gravity = 0.1;
float ballSpeedVert = 0;
float ballSpeedHorz = 0;
float airfriction = 0.0001;
float friction = 0.1;

// racket
float racketX, racketY, pracketY;
color racketColor = color(105, 137, 150);
float racketWidth = 100;
float racketHeight = 10;
int racketBounceRate = 20;
int racketZoneHeight = 100;

// objects
int objectSpeed = 1;
int originalObjectInterval = 5000;
int maxObjectIntervalOffset = 4000;
float lastAddTime = 0;
int objectHeight = 15;
int objectWidth = 50;
color defaultObjectColor = color(200, 200, 200);
color coinObjectColor = color(225, 181, 48);

// Objects
// Syntax: {x, y, height, width, type}
// Types:
// 0 = nothing
// 1 = yellow (coins)
ArrayList<int[]> objects = new ArrayList<int[]>();

// Buttons
int buttonHeight = 50;
int buttonWidth = 100;

// Display
int displayHeight, displayWidth;

//-------------------------------------------
//--------------- SETUP BLOCK ---------------
//-------------------------------------------

void setup() {
  // FOR IOS
  // comment start if on ios
  //size(screenWidth, screenHeight);
  //displayWidth = screenWidth;
  //displayHeight = screenHeight;
  // comment end

  // FOR OTHER
  // comment start if on other
  size(500, 500);
  displayWidth = 500;
  displayHeight = 500;
  // comment end
}

//------------------------------------------
//--------------- DRAW BLOCK ---------------
//------------------------------------------

void draw() {
  // Display the contents of the current screen
  if (gameState == 0) {
    initScreen();
  } else if (gameState == 1) {
    gameScreen();
  } else if (gameState == 2) {
    gameOverScreen();
  }
}

//-----------------------------------------------
//--------------- SCREEN CONTENTS ---------------
//-----------------------------------------------

void initScreen() {
  background(0);

  stroke(0);
  fill(50);
  rectMode(CENTER);
  rect(displayWidth/2, displayHeight/2, buttonWidth, buttonHeight, 5);

  fill(255);
  textAlign(CENTER);
  textSize(20);
  text("Start", displayWidth/2, displayHeight/2+7);
}

void gameScreen() {
  background(255);
  stroke(200);
  line(0, displayHeight - racketZoneHeight, displayWidth, displayHeight-100);

  // ball & racket
  drawBall();
  drawRacket();
  watchRacketBounce();
  applyGravity();
  applyHorizontalSpeed();
  keepInScreen();

  // objects
  objectAdder();
  objectHandler();

  // timer
  drawTimer();

  // score
  drawScore();
}

void gameOverScreen() {
  background(0);
  textAlign(CENTER);

  // score label
  stroke(100);
  fill(100);
  textSize(20);
  text("Score", displayWidth / 2, displayHeight / 2 - 80);
  // score number
  stroke(255);
  fill(255);
  textSize(100);
  text(score, displayWidth / 2, displayHeight / 2);

  // time label
  stroke(100);
  fill(100);
  textSize(15);
  text("Time played", displayWidth /2, displayHeight /2 + 50);
  // time number
  stroke(200);
  fill(200);
  textSize(35);
  text(formatTime(timePlayed), displayWidth /2, displayHeight /2 + 85);

  // PLAY AGAIN BUTTON
  stroke(0);
  fill(50);
  rect(displayWidth/2, displayHeight/2 + 150, buttonWidth+10, buttonHeight, 5);
  fill(255);
  textAlign(CENTER);
  textSize(20);
  text("Play Again", displayWidth /2, displayHeight /2 + 155);
}

//----------------------------------------------
//--------------- SCREEN OBJECTS ---------------
//----------------------------------------------

//------------
//--- BALL ---
//------------

void drawBall() {
  stroke(ballColor);
  fill(ballColor);
  ellipse(ballX, ballY, ballSize, ballSize);
}

void applyGravity() {
  ballSpeedVert += gravity;
  ballY += ballSpeedVert;
  ballSpeedVert -= (ballSpeedVert * airfriction);
}

void applyHorizontalSpeed() {
  ballX += ballSpeedHorz;
  ballSpeedHorz -= (ballSpeedHorz * airfriction);
}

void makeBounceBottom(float surface) {
  ballY = surface - (ballSize/2);
  ballSpeedVert *= -1;
  ballSpeedVert -= (ballSpeedVert * friction);
}

void makeBounceTop(float surface) {
  ballY = surface + (ballSize/2);
  ballSpeedVert *= 1;
  ballSpeedVert -= (ballSpeedVert * friction);
}

void makeBounceLeft(float surface) {
  ballX = surface + (ballSize/2);
  ballSpeedHorz *= -1;
  ballSpeedHorz -= (ballSpeedHorz * friction);
}

void makeBounceRight(float surface) {
  ballX = surface - (ballSize/2);
  ballSpeedHorz *= -1;
  ballSpeedHorz -= (ballSpeedHorz * friction);
}

// keep ball in the screen
void keepInScreen() {
  // ball hits floor
  if (ballY + (ballSize/2) > displayHeight) {
    gameOver();
  }
  // ball hits ceiling
  if (ballY - (ballSize/2) < 0) {
    makeBounceTop(0);
  }
  // ball hits left
  if (ballX - (ballSize/2) < 0) {
    makeBounceLeft(0);
  }
  // ball hits right
  if (ballX + (ballSize/2) > displayWidth) {
    makeBounceRight(width);
  }
}

//---------------
//--- OBJECTS ---
//---------------

void objectAdder() {
  int objectInterval = originalObjectInterval + int(random(-maxObjectIntervalOffset, maxObjectIntervalOffset));
  if (millis()-lastAddTime > objectInterval) {
    int randX = round(random(0, displayWidth - objectWidth) + objectWidth/2);
    int[] randObject = {randX, -objectHeight, objectWidth, objectHeight, round(random(0, 1))};
    objects.add(randObject);
    lastAddTime = millis();
  }
}

void objectHandler() {
  for (int i = 0; i < objects.size(); i++) {
    if (objectRemover(i)) {
      return;
    }

    objectMover(i);
    objectDrawer(i);
    watchObjectCollision(i);
  }
}

void watchObjectCollision(int index) {
  int[] object = objects.get(index);

  int objectX = object[0];
  int objectY = object[1];

  // ball in object
  if (
    (ballX + (ballSize/2) > objectX - objectWidth/2) &&
    (ballX - (ballSize/2) < objectX - objectWidth/2 + objectWidth) &&
    (ballY + (ballSize/2) > objectY - objectHeight/2) &&
    (ballY - (ballSize/2) < objectY - objectHeight/2 + objectHeight)
    ) {
    if (object[4] == 1) score++;
    objects.remove(index);
  }
}

void objectDrawer(int index) {
  int[] object = objects.get(index);
  if (object[4] == 1) {
    stroke(coinObjectColor);
    fill(coinObjectColor);
  } else {
    stroke(defaultObjectColor);
    fill(defaultObjectColor);
  }
  rect(object[0], object[1], object[2], object[3]);
}

void objectMover(int index) {
  int[] object = objects.get(index);
  object[1] += objectSpeed;
}

boolean objectRemover(int index) {
  int[] object = objects.get(index);
  if (object[1] - object[3]  >= displayHeight) {
    objects.remove(index);
    return true;
  }
  return false;
}

//--------------
//--- RACKET ---
//--------------

void drawRacket() {
  stroke(racketColor);
  fill(racketColor);
  rectMode(CENTER);
  racketY = min(displayHeight, max(displayHeight-100, mouseY));
  racketX = min(displayWidth - racketWidth/2, max(0 + racketWidth/2, mouseX));
  rect(racketX, racketY, racketWidth, racketHeight, 2);
}

void watchRacketBounce() {
  float overhead = racketY - pracketY;
  pracketY = racketY;
  if ((ballX + (ballSize/2) > racketX - (racketWidth/2)) && (ballX - (ballSize/2) < racketX + (racketWidth/2))) {
    if (dist(ballX, ballY, ballX, racketY - racketHeight/2) <= (ballSize/2) + abs(overhead)) {
      makeBounceBottom(racketY - racketHeight/2);
      // racket moving up
      if (overhead < 0) {
        ballY += overhead;
        ballSpeedVert += overhead;
        ballSpeedHorz = (ballX - racketX)/5;
      }
    }
  }
}

//--------------------------------------
//--------------- INPUTS ---------------
//--------------------------------------

public void mousePressed() {
  // if the initial screen is active, start game on click
  if (gameState == 0) {
    if (mouseX < displayWidth/2 - buttonWidth/2 || mouseX > displayWidth/2 + buttonWidth/2 ||
      mouseY < displayHeight/2 - buttonHeight/2 || mouseY > displayHeight/2 + buttonHeight/2) return;
    startGame();
  } else if (gameState == 2) {
    if (mouseX < displayWidth/2 - (buttonWidth+10)/2 || mouseX > displayWidth/2 + (buttonWidth+10)/2 ||
      mouseY < displayHeight/2 + 150 - buttonHeight/2 || mouseY > displayHeight/2 + 150 + buttonHeight/2) return;
    startGame();
  }
}

//----------------------------------------------------
//--------------- OTHER FUNCTIONS --------------------
//----------------------------------------------------

// This method sets the necessary variables to start the game
void startGame() {
  // gravity
  ballSpeedVert = 0;
  ballSpeedHorz = 0;

  // ball
  ballX = displayWidth/4;
  ballY = displayHeight/5;

  // screen
  gameState = 1;

  // objects
  objects = new ArrayList<int[]>();

  // time
  timeRoundStarted = millis();

  // score
  score = 0;
}

// This method sets the necessary variables to end the round
void gameOver() {
  gameState = 2;
}

//-------------
//--- SCORE ---
//-------------

void drawScore() {
  stroke(0);
  fill(0);
  textAlign(RIGHT, TOP);
  text(score, displayWidth -10, 10);
}


//-------------
//--- TIMER ---
//-------------

void drawTimer() {
  timePlayed = (millis()-timeRoundStarted)/1000;

  stroke(0);
  fill(0);
  textAlign(LEFT, TOP);
  text(formatTime(timePlayed), 10, 10);
}

String formatTime(float timeInSecs) {
  int minutes = floor(timeInSecs / 60);
  float seconds = round((timeInSecs - minutes * 60)*1000);
  seconds /= 1000;

  String formattedMinutes = "";
  if (minutes < 10) formattedMinutes = "0";
  formattedMinutes = formattedMinutes + minutes;

  String formattedSeconds = "";
  if (seconds < 10) formattedSeconds = "0";
  formattedSeconds = formattedSeconds + seconds;

  return formattedMinutes + ":" + formattedSeconds;
}
