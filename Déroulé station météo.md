# station mémtéo

Mise en place :

logiciels :

ESPCUT : http://espcut.com/ à installer sur les postes.
Driver si CH340 : https://sparks.gogo.co.nz/ch340.html (ou sur le dépot)
Driver si CP210 : https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers (ou sur le dépot)

Firmware : https://nodemcu-build.com avec les modules :

- bit
- bme280
- cron
- file
- GPIO
- HTTP
- I2C
- net
- node
- SJSON
- SPI
- timer
- TSL2561
- U8G
- UART
- WIFI

Le firmware déjà fait est dispo dans le dépot git.

Connexion du node > upgrade du firmware via la fleche en haut à gauche > restart du node via le bouton rouge en bas à coté de "send".

# Station V2 simplifiée - Blynk

- Utilisation de l'Arduino IDE
- Plus d'écran
- Visualisation en local via un smartphone
- Passage par l'app Blynk

On va tester ce tuto : https://www.instructables.com/id/DIY-Weather-Station-Using-DHT11-BMP180-Nodemcu-Ove/

installer la bibliothèque blynk : https://github.com/blynkkk/blynk-library/releases/tag/v0.5.0

Ne pas oublier les bibliothèques qui vont bien :

* Adafruit_BMP180
* DHT
* ESP8266Wifi
* SPI
* Simple Timer
* Blynk Simple ESP8266



# Schéma de câblage

![](..\station_meteo\Schéma électrique\schéma station météo_bb.jpg)









* Sur l'aperçu
  * Possibilité de zoomer sur l'aperçu
  * afficher le point de départ  et d'arrivée 
  * Mettre une graduation (pour avoir une idée de la taille du dessin)
* général
  * problème de téléversement sur windows 7 (fonctionne pas)
* "Gameplay"
  * trouver des moyens de rendre les boucles conditionnelles intéressantes à utiliser (pour l'instant on utilise juste de l'aléatoire)
  * 