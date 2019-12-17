

#define BLYNK_PRINT Serial    // A mettre en commentaire une fois en prod

#include <SPI.h>
#include <ESP8266WiFi.h>
#include <BlynkSimpleEsp8266.h>
#include <SimpleTimer.h>
#include <Adafruit_BMP085.h>
#include <Wire.h>
#include <DHTesp.h>

//pin du DHT
#define DHT11_PIN 2

//pression à la surface de la mer
#define PRESSION 100000


// On crée l'obet bmp
Adafruit_BMP085 bmp;

// On crée l'objet dht
DHTesp dht;

// Code d'authentification Blynk
char auth[] = "nNXsLHLAhlMb6K4i9ol7RPQw0oEsf2Js"; 

// Mise place du wifi.
// Laissez "" si pas de mots de passe.
char ssid[] = "Fablab";  //Le nom du wifi
char pass[] = "youpimatin";  //Mot de passe du wifi



SimpleTimer timer;

void setup()
{
  Serial.begin(9600);
  Blynk.begin(auth, ssid, pass);

  dht.setup(2, DHTesp::DHT11);
  Wire.begin();

  if (!bmp.begin()) {
    Serial.println("Bordel il est ou le barometre ?? tu las cable avec le cul ?");
    while (1) {}
  }
  // Setup a function to be called every second
  timer.setInterval(1000L, sendSensor);
}

void loop()
{
  Blynk.run(); // Initiates Blynk
  timer.run(); // Initiates SimpleTimer
}

void sendSensor()
{
  delay(dht.getMinimumSamplingPeriod());
  float h = dht.getHumidity();
  float t = dht.getTemperature(); // or dht.readTemperature(true) for Fahrenheit
  float tBmp = bmp.readTemperature();
  int p = bmp.readPressure();
  // Altitude, en fonction de la pression à 0m actuelle (récupérée sur Internet)
  float alti = bmp.readAltitude(PRESSION);

  // pour le DHT
  

  // afficher la température
  Serial.print("Temperature = ");
  Serial.print(tBmp);
  Serial.println(" *C");
 // afficher la ression
  Serial.print("Pression = ");
  Serial.print(p);
  Serial.println(" Pa");
//afficher la température
  Serial.print("Altitude du coin = ");
  Serial.print(alti);
  Serial.println(" meters");

//afficher la température et l'humidité du DHT11
Serial.print("humidite DHT = ");
  Serial.print(h);
  Serial.println(" %");

  Serial.print("Temperature DHT = ");
  Serial.print(t);
  Serial.println(" *C");

  Serial.println();
  delay(500);

  //On envoie les valeurs sur Blynk
  Blynk.virtualWrite(V2, tBmp); //V2 pour la température du BMP180
  Blynk.virtualWrite(V3, p); //V3 pour la pression
  Blynk.virtualWrite(V4, alti); //V4 pour l'altitude
  Blynk.virtualWrite(V5, h);  //V5 pour l'humidité
  Blynk.virtualWrite(V6, t);  //V6 pour la température
}
