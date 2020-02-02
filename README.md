# Fusionierung von Lidar-Messdaten in AppSpace

## Einrichtung der Entwicklungsumgebung:
1. Erstellung eines Kontos, Freischaltung erfolgt von Referenzpartner bei SICK:
https://supportportal.sick.com/register/

2. Download der LIDAR-AppSpace Software unter und Ausführung folgender Schritte von SICK:
https://supportportal.sick.com/downloads/latest-appstudio-versions/
   a. Download the file installation.exe
   b. Execute the installation.exe file with administrator rights
   c. Follow the on-screen instructions to complete the installation
   d. Start SICK AppStudio from the Desktop shortcut or from the Start menu
   e. If your license is invalid, outdated, or not located in the correct folder, a license dialog appears (also
reachable from HelpàLicense). Click the “Apply License” button to browse for and apply your license
file.

3. Download und Installation von SOPAS Engineering Tool unter:
https://www.sick.com/de/de/sopas-engineering-tool-2020/p/p36724

4. Im Dateimanager navigieren in den Ordner:
C:\Users\User\AppData\Local\SICK\AppStudio\workspace\work

5. Dort das git-Repository einfügen, auffindbar unter dem Link:
https://github.com/BilelSpannagel/Fusionierung-von-Lidar-Messdaten-in-AppSpace

## Einrichtung der LIDAR-Sensoren:

1. LIDAR-Sensoren an Netzteil anschließen, 12 Volt und 1 Ampere pro Sensor sollten gegeben sein
2. LIDAR-Sensoren per Ethernet an Switch anschließen
3. Im SOPAS Engineering Tool können die IP-Adressen der LIDAR-Sensoren angepasst werden und
werden ansonsten auch nach Neustarts beibehalten
4. Eigene IP-Adresse muss sich im gleichen Subnetz befinden, wenn nötig von DHCP auf statische IP-
Adresse wechseln und passende IP-Adresse vergeben
5. AppStudio starten und mit einem der LIDAR-Sensoren verbinden
6. Programm wird automatisch gefunden werden und kann per &quot;Play&quot;-Button auf den Sensor gespielt
werden
7. Aufspielen der Software für beide Sensoren durchführen
8. Unter der jeweiligen IP-Adresse kann ein Webserver im Browser erreicht werden und Einstellungen
wie die Belegung von Master oder Slave vorgenommen werden
