
#include <DHT.h>
#include <Thread.h>

#define DHTPIN 2
#define DHTPIN1 4

#define DHTTYPE DHT11

DHT dht1(DHTPIN, DHTTYPE);
DHT dht2(DHTPIN1, DHTTYPE);

Thread thrBlink1 = Thread();
Thread thrBlink2 = Thread();
Thread thrBlink3 = Thread();

float tempC;
int pinLM35 =A0;
int pinPot = A3;  
int pinPot1 = A2; 
int pinPot2 = A1; 
int parpadeo;  
int valorPot;  
int parpadeo1; 
int valorPot1; 
int parpadeo2; 
int valorPot2; 


void setup() {

  Serial.begin(9600);
 

   dht1.begin();
   dht2.begin();

  thrBlink1.enabled = true;
  thrBlink1.setInterval(1000);
  thrBlink1.onRun(sensor1);

  thrBlink2.enabled = true;
  thrBlink2.setInterval(2000);
  thrBlink2.onRun(sensor2);

  thrBlink3.enabled = true;
  thrBlink3.setInterval(3000);
  thrBlink3.onRun(sensor3);

}
void blink() {

}
void loop() {

  thrBlink1.run();

  thrBlink3.run();
}
void sensor1(){  

  valorPot = analogRead(pinPot);
  parpadeo = map(valorPot, 0, 1023, 100, 500);
  
  float t = dht2.readTemperature();
  if (isnan(t)) {
    Serial.println("Error obteniendo los datos del sensor DHT11");
    return;
  }
  
  Serial.print(t);
  Serial.print(",");
  Serial.print(parpadeo);
  delay(1);
 
}
void sensor2(){  

  valorPot1 = analogRead(pinPot1); 
  parpadeo1 = map(valorPot1, 0, 1023, 100, 500);
  float t = dht2.readTemperature();
  if (isnan(t)) {
    Serial.println("Error obteniendo los datos del sensor DHT11");
    return;
  }
  Serial.print(",");
  Serial.print(t);
  Serial.print(",");
  Serial.print(parpadeo1);
  delay(1);
  
}
void sensor3(){  
  valorPot2 = analogRead(pinPot2);
  parpadeo2 = map(valorPot2, 0, 1023, 100, 500); 
  tempC = analogRead(pinLM35); 
  tempC = (5.0 * tempC * 100.0)/1024.0; 
  Serial.print(",");
  Serial.print(tempC);
  Serial.print(",");
  Serial.println(parpadeo2);
  delay(100);
}
