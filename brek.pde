/*************** VARIABLES ***************/

// GameScreen:
// 0: Initial Screen
// 1: Game Screen
// 2: GameOver Screen
int gameScreen = 0;

// color
int score;

// timer
float timeRoundStarted;
float timePlayed;

// ball
float ballX, ballY;
int ballSize = 20;
int ballColor = color(100, 50, 135);

// gravity
float gravity = 0.1;
float ballSpeedVert = 0;
float ballSpeedHorz = 0;
float airfriction = 0.0001;
float friction = 0.1;

// racket
float racketX, racketY, pracketY;
color racketColor = color(170, 75, 0);
float racketWidth = 100;
float racketHeight = 10;
int racketBounceRate = 20;

// objects
int objectSpeed = 1;
int objectInterval = 5000;
float lastAddTime = 0;
int objectHeight = 15;
int objectWidth = 50;
color defaultObjectColor = color(0);
color coinObjectColor = color(255, 255, 0);
// {x, y, height, width, type}
// types:
// 0 = nothing
// 1 = yellow, coins
ArrayList<int[]> objects = new ArrayList<int[]>();

/*************** SETUP BLOCK ***************/

void setup() {
  size(500, 500);
}


/*************** DRAW BLOCK ***************/

void draw() {
  // Display the contents of the current screen
  if (gameScreen == 0) {
    initScreen();
  } else if (gameScreen == 1) {
    gameScreen();
  } else if (gameScreen == 2) {
    gameOverScreen();
  }
}


/*************** SCREEN CONTENTS ***************/

void initScreen() {
  background(0);
  fill(50);
  rectMode(CENTER);
  stroke(0);
  rect(250, 243, 100, 50, 5);
  fill(255);
  textAlign(CENTER);
  textSize(20);
  text("Start", height/2, width/2);
}

void gameScreen() {
  background(255);
  stroke(200);
  line(0, 400, 500, 400);

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
  text("Score", width/2, height/2 - 80);
  // score number
  stroke(255);
  fill(255);
  textSize(100);
  text(score, width/2, height/2);

  // time label
  stroke(100);
  fill(100);
  textSize(15);
  text("Time played", width/2, height/2 + 50);
  // time number
  stroke(200);
  fill(200);
  textSize(35);
  text(formatTime(timePlayed), width/2, height/2 + 85);

  // PLAY AGAIN BUTTON
  stroke(0);
  fill(50);
  rect(250, 400, 110, 50, 5);
  fill(255);
  textAlign(CENTER);
  textSize(20);
  text("Play Again", height/2, width/2 + 155);
}

/*************** SCREEN OBJECTS ***************/

/*** BALL ***/

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
  if (ballY + (ballSize/2) > height) {
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
  if (ballX + (ballSize/2) > width) {
    makeBounceRight(width);
  }
}


/*** OBJECTS ***/

void objectAdder() {
  if (millis()-lastAddTime > objectInterval) {
    int randX = round(random(0, width - objectWidth) + objectWidth/2);
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
  if (object[1] - object[3]  >= height) {
    objects.remove(index);
    return true;
  }
  return false;
}


/*** RACKET ***/

void drawRacket() {
  stroke(racketColor);
  fill(racketColor);
  rectMode(CENTER);
  racketY = min(500, max(400, mouseY));
  racketX = min(500 - racketWidth/2, max(0 + racketWidth/2, mouseX));
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


/*************** INPUTS ***************/

public void mousePressed() {
  // if the initial screen is active, start game on click
  if (gameScreen == 0) {
    if (mouseX < 200 || mouseX > 300 || mouseY < 220 || mouseY > 270) return;
    startGame();
  } else if (gameScreen == 2) {
    if (mouseX < 145 || mouseX > 355 || mouseY < 375 || mouseY > 425) return;
    startGame();
  }
}


/*************** OTHER FUNCTIONS ***************/

// This method sets the necessary variables to start the game
void startGame() {
  // gravity
  ballSpeedVert = 0;
  ballSpeedHorz = 0;

  // ball
  ballX = width/4;
  ballY = height/5;

  // screen
  gameScreen = 1;

  // objects
  objects = new ArrayList<int[]>();

  // time
  timeRoundStarted = millis();

  // score
  score = 0;
}

// This method sets the necessary variables to end the round
void gameOver() {
  gameScreen = 2;
}

/*** SCORE ***/
void drawScore() {
  stroke(0);
  fill(0);
  textAlign(RIGHT, TOP);
  text(score, width-10, 10);
}

/*** TIMER ***/

void drawTimer() {
  timePlayed = (millis()-timeRoundStarted)/1000;

  stroke(0);
  fill(0);
  textAlign(LEFT, TOP);
  text(formatTime(timePlayed), 10, 10);
}

String formatTime(float timeInSecs) {
  int minutes = floor(timeInSecs / 60);
  float seconds = timeInSecs - minutes * 60;

  String formattedMinutes = "";
  if (minutes < 10) formattedMinutes = "0";
  formattedMinutes = formattedMinutes + minutes;

  String formattedSeconds = "";
  if (seconds < 10) formattedSeconds = "0";
  formattedSeconds = formattedSeconds + seconds;

  return formattedMinutes + ":" + formattedSeconds;
}
