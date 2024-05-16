/* ******************************* 
INPUT
*********************************/
const int potPin = A1; // analog pin used to connect the potentiometer
int potVal;  // variable to read the value from the analog pin
int angle;   // angle the potentiometer has actually rotated
int value;

const int buttonPin = 10;
int buttonState = 0;

/* ******************************* 
OUTPUT
*********************************/
// Led setup
const int led1Pin = 7;
int led1State;
const int led2Pin = 6;
int led2State;
// led1State and led2State is going to be the respective first and second bit of binOutput
int binOutput;

// Receiving data
const byte numChars = 32; // Max amount of bits we can read in one line
char receivedChars[numChars]; // an array to store the received data
boolean newData = false;
static byte ndx = 0;

void setup() {
  Serial.begin(9600); // open a serial connection to your computer
  pinMode(buttonPin, INPUT);

  pinMode(led1Pin, OUTPUT);
  pinMode(led2Pin, OUTPUT);
}

void loop() {
  potVal = analogRead(potPin); // read the value of the potentiometer
  value = potVal;

  buttonState = digitalRead(buttonPin);
  if(buttonState == 1){
    value = value | 0b10000000000; // Bitwise OR operation to set the 11th bit
  }
  value = value | 0b100000000000; // Bitwise OR operation to set the 12th bit to ensure good sending
  Serial.println(value);

  
//  recvWithEndMarker();
//  processNewData();
  char reading = Serial.read();
  if(reading == 'a'){
    digitalWrite(led1Pin, HIGH);
    digitalWrite(led2Pin, LOW);
  }
  else if(reading == 'b'){
    digitalWrite(led2Pin, HIGH);
    digitalWrite(led1Pin, LOW);
  }
  else if(reading == 'c'){
    digitalWrite(led1Pin, HIGH);
    digitalWrite(led2Pin, HIGH);
  }
  else if(reading == '/'){
    digitalWrite(led1Pin, LOW);
    digitalWrite(led2Pin, LOW);
  }
}

void recvWithEndMarker() {
    char endMarker = '\n';
    char rc;
    while (Serial.available() > 0 && newData == false) {
        rc = Serial.read();
        if (rc != endMarker) {
            receivedChars[ndx] = rc;
            ndx++;
            if (ndx >= numChars) {
                ndx = numChars - 1;
            }
        }
        else {
            receivedChars[ndx] = '\0'; // terminate the string
            ndx = 0;
            newData = true;
        }
    }
}

void processNewData(){
  if (newData == false) return;
  switch(receivedChars[0]){
    case 'a':
    {
      binOutput++;
      for(int i = 1; i < 3; i++){
        if(receivedChars[i] == 'a'){
          binOutput++;
        }
      }
      led1State = binOutput & 1;
      led2State = binOutput & 0b10;
      binOutput = 0;
      if(led1State){
        digitalWrite(led1Pin, HIGH);
      }
      else {
        digitalWrite(led1Pin, LOW);
      }
      
      if(led2State){
        digitalWrite(led2Pin, HIGH);
      } 
      else {
        digitalWrite(led2Pin, LOW);
      }
      break;
    }
    case '/':
      digitalWrite(led1Pin, LOW);
      digitalWrite(led2Pin, LOW);
      break;
    default:
      break;
  }
  newData = false;
}
