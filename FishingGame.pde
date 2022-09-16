/*
TITLE: Fishing Game
AUTHOR: Kyle Koon
DATE DUE: 1/28/21
DATE SUBMITTED: 1/28/21
COURSE TITLE: Game Design
MEETING TIME(S): Mon. and Wed. at 2pm
DESCRIPTION: This program creates the Fishing Game. In this game, the user left clicks on a tile, which represents casting a fishing line. 
A left click will reveal a fish, empty water, or an obstruction. Your score is dependent on the number and type of fish you catch.
The objective of the game is to catch as many high value fish as possible without casting onto an obstruction.
HONOR CODE: On my honor, I neither gave nor received unauthorized aid on this assignment. Signature: Kyle Koon
*/

import java.util.*;

PImage[] safe = new PImage[6]; //this array will store the 6 fish images
int[] safeWeights = {20, 60, 15, 10, 5, 1}; //these are the weights corresponding to how often each fish should appear
PImage[] danger = new PImage[3]; //this array will store the 2 obstruction images and 1 shark image
int[] dangerWeights = {30, 15, 5}; //these are the weights corresponding to how often each fish should appear
int safeSum; //this will be the sum of the safe weights
int dangerSum; //this will be the sum of the danger weights
int attempts; //this will store the number of tiles the user has clicked
int score; //this will keep track of the player's score
int[] clickedTiles = {-1, -1, -1}; //this will keep track of the tile numbers that the user has clicked
int[] scores = {1, 0, 5, 10, 25, 50}; //these are the scores corresponding to the different fish and water
//these booleans are used to monitor the state of the game
boolean gameStarted = false; 
boolean gameOver = false;
boolean gameWin = false;

class tile {
  //these instance variables will store the coordinates and dimensions of the tiles and the associated image 
  float x;
  float y;
  float w;
  float h;
  PImage img;
  
  //this initializes all of the instance variables
  tile(PImage tempImg, float tempX, float tempY, float tempW, float tempH){
    img = tempImg;
    x = tempX;
    y = tempY;
    w = tempW;
    h = tempH;
  }
  
  //this will display the image associated with the current tile on the screen at the tile location
  void showImg(){
    image(img,x,y,150,150); 
  }
  
  //this will create a rectangle on the screen at the tile's coordinates and with the correct dimensions
  void createTile(){
    rect(x, y, w, h);
  }
}

int numTiles = 36; //this is the number of tiles that will be on the board
tile[] tiles = new tile[numTiles]; //this will store the tile objects that are created
void setup(){
  size(900,900); //creates a 900x900 window
  
  safeSum = 0; //initializes the sum of the safe image weights to 0
  //calculates the sum of the safe image weights and updates safeSum
  for(int i = 0; i < safeWeights.length; i++){
    safeSum += safeWeights[i];
  }
  
  //puts the safe fish images in the safe array
  safe[0] = loadImage("bonita.png");
  safe[1] = loadImage("water.png");
  safe[2] = loadImage("kingfish.png");
  safe[3] = loadImage("mahi.png");
  safe[4] = loadImage("swordfish.png");
  safe[5] = loadImage("blue_marlin.png");
  
  //repeats previous process with the dangerous images
  dangerSum = 0;
  for(int i = 0; i < dangerWeights.length; i++){
    dangerSum += safeWeights[i];
  }
  
  danger[0] = loadImage("rocks.png");
  danger[1] = loadImage("shark.png");
  danger[2] = loadImage("wreck.png");
  
  
  int numInRow = (int)Math.sqrt(numTiles); //the number of tiles in a row will be the square root of the number of tiles
  float xIncrement = width/numInRow; //calculates the distance between left edges of adjacent tiles
  int numInColumn = (int)Math.sqrt(numTiles); //the number of tiles in a column will be the square root of the number of tiles
  float yIncrement = height/numInColumn; //calculates the distance between the top edges of vertical tiles
  
  int q = 0; //the index of the tiles array
  for(int i = 0; i < numInColumn; i++){ //iterate through each row
    for(int j = 0; j < numInRow; j++){ //iterate through each column
      tiles[q] = new tile(selectImg(),xIncrement*j,yIncrement*i,xIncrement,yIncrement); //create new tiles with randomly assigned images through the use of the selectImg() function
      q++; //increase index so we can create a new tiles
    }
  }
}

void draw(){
  if(!keyPressed && key != ENTER){ //exit the splash screen once the user presses the enter key
    //creates the splash screen with the rules and scoring
    background(0);
    textSize(80);
    text("Welcome to the \n Fishing Game",50,150);
    textSize(20);
    text("Rules: \n -left click on a square to cast your line and reveal your catch \n -you only get three casts \n -landing on an obstruction or shark will remove one of your remaining casts", 0, 400);
    text("The points are as follows: \n -Marlin: 50pts \n -Swordfish: 25pts \n -Mahi: 10pts \n -Kingfish: 5pts \n -Bonita: 1pt", 0,600);
    text("Press Enter to play", 0, 800);
  }
  else if(!gameOver){ //runs as long as the game is in process
    gameStarted = true; //true because we have exited the splash screen
    background(255); //creates a blank background
    int i = 0; //keeps track of the tile number
    while(i < numTiles){ //checks the following for every tile
      boolean clicked = false; //assume that the tile has not been clicked yet
      for(int q = 0; q < 3; q++){ //iterates through the three indeces of the clickedTiles array
        if(i == clickedTiles[q]){ //checks if the current tile has been clicked
          tiles[i].showImg(); //if the tile has been clicked, the image associated with the tile is shown
          clicked = true; //this tile has been clicked
        }
        if(!clicked){ //if we've checked the clickedTiles array and find that the current tile has not been clicked, we draw the tile rectangle again
          tiles[i].createTile(); //draws the tile on screen
        }
      }
      i++; //checks the next tile
    }
  }
  else{ //runs once the game has ended
    revealTiles(); //all fish and obstruction images are revealed in their tile locations
    if(!mousePressed){ //runs once the user presses the mouse button
      delay(2000); //the images remain revealed for 2 seconds
      background(0); //then the background is set to black
      if(gameWin){ //runs if the player has a score > 0
        textSize(50);
        text("You won with a score of " + calculateScore(), 75,250); //displays a message with the player's score
      }
      else{ //runs if the player has a score of 0
        textSize(80);
        text("You lost", 250,250); //displays a message that the player has lost
      }
      
    }
  }
}

//this function will select a random safe or dangerous image
PImage selectImg(){
  PImage pickedImg; //this will store the resulting picked image
  Random rand = new Random(); //creates an object of the Random class that we will use to generate random numbers
  int randNum = rand.nextInt(100); //creates a random integer from 0 to 99
  if(randNum < 80){ //if the number is less than 80 a safe image will be picked
    int rnd = rand.nextInt(safeSum); //another random number is generated between 0 and the sum of the weights for the safe images
    int goodIndex = 0; //this will be the index of the image we select
    for(int i = 0; i < safe.length; i++){ //iterates through the weights for the safe images
      if(rnd < safeWeights[i]){ //if the random number we generated is less than the current weight, we select the image corresponding to this index in the safe array
        goodIndex = i; //assigns the index of the image we will select to goodIndex
        break; //breaks out of the for loop
      }
      rnd -= safeWeights[i];
    }
    pickedImg = safe[goodIndex]; //the picked image is located in the safe array at the goodIndex we just found
  }
  else{ //if the initial random number is greater than or equal to 80, we will pick an obstruction image
    //the same process is repeated from above but with the danger weights and danger image array
    int rnd = rand.nextInt(dangerSum);
    int badIndex = 0;
    for(int i = 0; i < danger.length; i++){
      if(rnd < dangerWeights[i]){
        badIndex = i;
        break;
      }
      rnd -= dangerWeights[i];
    }
    pickedImg = danger[badIndex];
  }
  return pickedImg; //the selected image is returned
}



void mousePressed(){ //runs if the user presses a mouse button
    if(gameStarted && mouseButton==LEFT){ //will only run if the player has started the game and the player clicks the left mouse button
      attempts++; //the number of attempts the player has used is incremented
      if(attempts < 4){ //runs as long as the user has attempted less than 4 times
        int i = 0; //keeps track of the current tile number
        while(i < numTiles){ //iterates through the tiles
            if(mouseX > tiles[i].x && mouseX < tiles[i].x + tiles[i].w) { //if the x position of where the user clicked is within the current tile
                if(mouseY > tiles[i].y && mouseY < tiles[i].y + tiles[i].h){ //if the y position of where the user clicked is within the current tile
                        tiles[i].showImg(); //the user has selected the current tile, so we display the image corresponding to this tile.
                        clickedTiles[attempts-1] = i; //we add this tile number to the clickedTiles array
                        if(checkIfBad(tiles[i].img)){ //we check if the image is an obstruction or shark
                          attempts++; //if the user selected an obstruction or shark they a lose an attempt.
                        } 
                }
            }
            i+=1; //we check the next tile
        }
      }
      else{ //runs if the user has clicked 4 times
        gameOver=true; //the game is terminated
        int finalScore = calculateScore(); //we calculate the player's final score
        if(finalScore == 0){ //runs if the player finished with a score of 0
          gameWin = false; //the player has not won the game
        }
        else{ //runs if the player finished with a score greater than 0
          gameWin = true; //the player has won the game
        }
      }
    }
}


int calculateScore(){ //calculates the player's score depending on what type of fish they caught
  int score = 0; //their score starts at 0
  for(int i = 0; i < clickedTiles.length; i++){ //iterates through the clicked tiles array
    int tileNum = clickedTiles[i]; //a clicked tile number is retrieved from the clicked tiles array
    if(tileNum != -1){ //makes sure that the tile number is not -1, which occurs when the player can only select 1 or 2 tiles due to landing on obstructions.
      PImage x = tiles[tileNum].img; //the image corresponding to the clicked tile is retrieved
      for(int j = 0; j < safe.length; j++){ //iterates through the safe image array
        if(x == safe[j]){ //checks if the current image is at the current index in the safe image array
          score+=scores[j]; //if the images are the same, the score is incremented by the score corresponding to the image selected
        }
      }
    }
  }
  return score; //the total score is returned
}


void revealTiles(){ //this will reveal all of the images corresponding to each of the tiles
  background(255); //the background is cleared
  for(int i = 0; i < numTiles; i++){ //iterates through each of the tiles
    tiles[i].showImg(); //draws the current image onto the screen
  }
}


boolean checkIfBad(PImage img){ //this will check if the image selected is an obstruction or shark
  for(int i = 0; i < danger.length; i++){ //iterates through the danger image array
    if(img == danger[i]){ //runs if the image selected is at the current index in the danger array
      return true; //returns true signifying that the user selected an obstruction or shark
    }
  }
  return false; //runs if the image was not found in the danger image array, signifying that the user has not selected an obstruction or shark
}
