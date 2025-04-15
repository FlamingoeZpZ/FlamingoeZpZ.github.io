/* @pjs preload="data/map0.png", "data/map1.png", "data/map2.png", "data/ufo0.png", "data/ufo1.png", "data/sheep0.png" , "data/sheep1.png" , "data/sheep2.png", "data/herder.png", "data/cover.png"; */
int enemyCount = 5;
ArrayList<Circle> enemies = new ArrayList<Circle>(enemyCount);

int sheepCount = 3;
ArrayList<Circle> sheeps = new ArrayList<Circle>(sheepCount);

Circle player;
float points;
float prvPoints;

PImage currentScene;
PImage startScene;
PImage gameScene;

int pointThresholdMultiplier = 250;
PImage enemyImg;

float currentRestrictedSize;
float maxRestrictedSize = 200;
int currentRestrictTime;
int endTime = 5; 

ArrayList<Circle> powerUps = new ArrayList<Circle>(enemyCount);
int currentTime;
int maxTime = 120;
PImage powerUpImg;
PImage sheepImg;

void setup()
{
  size(1080, 810);
  currentRestrictedSize =  0;
  currentRestrictTime = 0;
  currentTime = 0;
  enemies = new ArrayList<Circle>();
  powerUpImg = loadImage("data/sheep0.png");
  enemyImg = loadImage("data/ufo0.png");
  PImage playerImg = loadImage("data/herder.png");
  sheepImg = loadImage("data/sheep2.png");
  for (int index = 0; index < enemyCount; index += 1)  
  {
    enemies.add(new Circle(random(0, width), random(0, height), random(-2, 2), random(-2, 2), enemyImg));
  }

  for (int index = 0; index < sheepCount; index += 1)  
  {
    sheeps.add(new Circle(random(0, width), random(0, height), random(-2, 2), random(-2, 2), sheepImg));
  }

  player = new Circle(width/2, height/2, 0, 0, playerImg);
  //width, height
  

  prvPoints=  points;
  points = 0;

  startScene = loadImage("data/cover.png");
  gameScene = loadImage("data/map" + (int)random(3) + ".png");
  currentScene = startScene;
}

void draw()
{

  //Numbers are arbitrary, RGB (0-255), x & y (0 - 800)
  background(0, 0, 0);
  
  image(currentScene, 0, 0);
  
  if (currentScene == startScene)
  { 
    textSize(36);
    fill(0,0,0);
    text("Press anywhere to begin\nPrevious Score:" + prvPoints, 0, height-60);
    return;
  }
  DrawBorders();
  points += sheeps.size();
  
  if(points > enemies.size() * pointThresholdMultiplier)
  {
    enemies.add(new Circle(random(currentRestrictedSize, width -currentRestrictedSize), random(currentRestrictedSize, height-currentRestrictedSize), random(-2, 2), random(-2, 2), enemyImg));
  }
  
  textSize(28);
  fill(0,0,0);
  text("Current score: " + points, width/2, 50);

  if (sheeps.size() == 0)
  {
    setup(); //restart the game
    return;
  }

  for (int index = 0; index < sheeps.size(); index += 1)  
  {
    Circle mySheep = sheeps.get(index);
    mySheep.Draw();
    if (index == 0)
    {
      player.Draw();
      mySheep.TargetedMove(player);
    } else
    {
      mySheep.TargetedMove(sheeps.get(index-1));
    }

    mySheep.Draw();
    mySheep.wallBounce();
    mySheep.Move();
  }

  player.TargetedMove(null);
  player.Draw();

  for (int index = 0; index < enemies.size(); index += 1)  
  {
    Circle myEnemy = enemies.get(index);
    myEnemy.Move();
    myEnemy.Draw();
    myEnemy.wallBounce();

    for (int sheepIndex = 0; sheepIndex < sheeps.size(); sheepIndex += 1)  
    {
      Circle mySheep = sheeps.get(sheepIndex);
      if (myEnemy.isTouching(mySheep))
      {
        sheeps.remove(mySheep);
      }
    }
  }
  
  HandlePowerUps();
}

void mousePressed()
{
  currentScene = gameScene;
}

void HandlePowerUps()
{
  currentTime += 1;
  if(currentTime >= maxTime)
  {
    powerUps.add( new Circle(random(currentRestrictedSize, width -currentRestrictedSize), random(currentRestrictedSize, height-currentRestrictedSize), 0, 0, powerUpImg));
    currentTime = 0;
  }
  
  for(int i = 0; i < powerUps.size(); i++)
  {
    Circle currentPowerUp = powerUps.get(i);
    currentPowerUp.Draw();
    if(currentPowerUp.isTouching(player))
    {
      sheeps.add(new Circle(currentPowerUp.X, currentPowerUp.Y, 0, 0, sheepImg));
      powerUps.remove(i);
    }
  }
}

void DrawBorders()
{
  currentRestrictTime += 1;
  if(currentRestrictTime >= endTime)
  {
    currentRestrictedSize += 0.2;
    if(currentRestrictedSize > maxRestrictedSize)
   {
     currentRestrictedSize = maxRestrictedSize;
   }
    currentRestrictTime = 0;
  }
  fill(255,0,0);
  rect(0,0,width,currentRestrictedSize);
  rect(0,0,currentRestrictedSize,height);
  rect(0,height - currentRestrictedSize,width,currentRestrictedSize);
  rect(width - currentRestrictedSize,0,currentRestrictedSize,height);
}

class Circle
{
  float X = 400;
  float Y = 400;
  float XSpeed = 20;
  float YSpeed = 20;
  float Diameter;
  PImage img;
  Circle(float X, float Y, float XSpeed, float YSpeed, PImage img)
  {
    this.X = X;
    this.Y = Y;
    this.XSpeed = XSpeed;
    this.YSpeed = YSpeed;
    this.img = img;
    Diameter = img.width;
  }

  void wallBounce()
  {
    if (X + Diameter >= width - currentRestrictedSize)
    {
      XSpeed = -abs(XSpeed);
    } else if (X <= currentRestrictedSize)
    {
      XSpeed = abs(XSpeed);
    } else if (Y + Diameter >= height - currentRestrictedSize)
    {
      YSpeed = -abs(YSpeed);
    } else if (Y <= currentRestrictedSize)
    {
      YSpeed = abs(YSpeed);
    }
  }

  boolean isTouching(Circle other)
  {
    if (dist(other.X, other.Y, X, Y) <= Diameter/2 + other.Diameter/2)
    {
      return true;
    }
    return false;
  }
  
  void Draw()
  {
    image(img, X, Y);
  }
  
  void Move()
  {
    X += XSpeed;
    Y += YSpeed;
  }
  
  void TargetedMove(Circle target)
  {
    if(target == null)
    {
      X = mouseX - Diameter/2;
      Y = mouseY- Diameter/2;
    }
    else
    {
      XSpeed = (target.X - X) * 0.1;
      YSpeed = (target.Y - Y) * 0.1;
    }
  }
} // NO CODE BENEATH