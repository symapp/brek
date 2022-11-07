/*************** VARIABLES ***************/

// GameScreen:
// 0: Initial Screen
// 1: Game Screen
// 2: GameOver Screen
int gameScreen = 0;

// ball
float ballX, ballY;
int ballSize = 20;
int ballColor = color(0);

// gravity
float gravity = 0.1;
float ballSpeedVert = 0;
float ballSpeedHorz = 0;
float airfriction = 0.0001;
float friction = 0.1;


// racket
float racketX, racketY, pracketY;
color racketColor = color(0);
float racketWidth = 100;
float racketHeight = 10;
int racketBounceRate = 20;

/*************** SETUP BLOCK ***************/

void setup() {
    size(500, 500);

    // ball
    ballX = width/4;
    ballY = height/5;
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
  rect(200, 220, 100, 50, 5);
  fill(255);
  textAlign(CENTER);
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
}

void gameOverScreen() {

}

/*************** SCREEN OBJECTS ***************/

/*** BALL ***/

void drawBall() {
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
    makeBounceBottom(height);
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



/*** RACKET ***/

void drawRacket() {
  fill(racketColor);
  rectMode(CENTER);
  racketY = min(500, max(400, mouseY));
  racketX = min(500 - racketWidth/2, max(0 + racketWidth/2, mouseX));
  rect(racketX, racketY, racketWidth, racketHeight);
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
    }
}


/*************** OTHER FUNCTIONS ***************/

// This method sets the necessary variables to start the game
void startGame() {
    gameScreen = 1;
}
