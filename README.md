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

## Troubleshooting

Übliche Probleme und Lösungen bei der Arbeit mit Lidar Sensoren

Bei der Arbeit mit Lidar Sensoren kam es immer wieder zu unerwarteten Fehlern. Wie mit diesen
umgegangen werden sollte steht hier.
Oft kommt es zu Problemen auf den Sensoren, hier wird immer einfach der Sensor neu gestartet.
Es kann unter Umständen auch mehrfache Neustarts brauchen.
Wenn die Sensoren 3-mal neu gestartet werden, wird das Programm automatisch von den Sensoren
entfernt und es muss neu drauf geladen werden. So können auch Programmierfehler wie
Endlosschleifen behoben werden.

**1. Appspace erkennt die Lidar Sensoren nicht**

Die Lidar Sensoren haben im Code feste IPs, damit mit diesen gearbeitet werden kann müssen sich
die Sensoren und der verbundene Computer mit Appspace in einem eigenen privaten Netzwerk
befinden.
IP des Masters ist „192.168.1.10“, die des Slaves „192.168.1.20“.
Sind beiden Sensoren über einen Switch angeschlossen und sind mit Strom versorgt, kann wenn man
genau hinhört festgestellt werden, ob sich die Sensoren tatsächlich drehen und aktiv sind.
Werden die Sensoren trotzdem nicht erkannt, sollten die Sensoren neu gestartet werden indem die
Stromverbindung getrennt und neu hergestellt wird.

**2. Anzeigen der Weboberfläche**

Der Webserver, der auf dem Master-Sensor läuft, kann auf der Adresse „192.168.1.10“ mit
beliebigen Computern im privaten Netzwerk mit beliebigen Browsern erreicht werden, wenn das
Programm auf die Sensoren aufgespielt wurde und läuft.
So kann über die Adressen des Slaves „192.168.1.20“ auch geprüft werden, ob der jeweilige Sensor
arbeitet.
Auf dem Webserver des Slaves ist lediglich der eigene Scan zu sehen. Der Master sollte beide
anzeigen können, wenn sowohl das eigene Scannen, als auch das Senden und Empfangen der Slave
Daten funktioniert.

**3. Fehlerhafte Kalibrierung nach drücken des Kalibrierungs-Buttons auf der Website**

Damit das Dreieck richtig interpretiert und die Point Clouds übereinander gelegt werden, muss
darauf geachtet werden, dass das Dreieck richtig herum vor den Sensoren liegt, es gibt eine Ober-
und Unterseite.
Es muss sich auch in dem gescannten 270 Grad Bereich befinden, also nicht direkt hinter einem der
Sensoren.
Dann muss einfach mehrfach der Kalibrierungs-Button gedrückt werden, bis das Dreieck logisch
richtig auf der Anzeige dargestellt wird, leichtes verschieben vom Dreieck oder Sensoren kann bei der
Kalibrierung helfen, da es zur Streuung des Infrarot Lights kommt wenn ein Scan genau auf eine Ecke
trifft und dies mit einer 10% Ungenauigkeit bei der Verarbeitung gelöst wurde.
Es muss darauf geachtet werden, dass innerhalb der mit dem Slider eingestellten Reichweite nichts
anderes zu sehen ist außer das Dreieck, da alle in diesem Bereich gefundenen Punkte für die Dreieck
Berechnung beachtet werden.

**4. Appspace wird langsam**

Wird die Entwicklungsumgebung immer langsamer gibt es irgendwo ein Memory Problem. Hier hilft
Appspace neu zu starten.

**5. Keine Kommunikation zwischen den beiden Sensoren**

Sind beide Sensoren richtig angeschlossen und es kommt dennoch zu fehlerhafter/keiner
Kommunikation zwischen beiden, muss die Stromversorgung der Sensoren unterbrochen werden,
um diese neu zu starten.

**6. Programm kann nicht auf die Sensoren geladen werden**

Auch hier müssen die Sensoren neu gestartet werden in dem man die Stromverbindung unterbricht.

**7. Sensoren reagieren nicht mehr**

Auch hier müssen die Sensoren neu gestartet werden in dem man die Stromverbindung unterbricht.

**8. Web Interface ist nicht mehr responsiv**

Gibt es Probleme mit der Interaktion mit der Website, hängt der Apache Webserver der auf den
Sensoren läuft. Auch hier müssen die Sensoren neu gestartet werden in dem man die
Stromverbindung unterbricht.

**9. Werte ändern sich nicht mehr**

Kommt es zu Fehlern bei der Verarbeitung von Werten im Programm, muss das Programm erst von
den Sensoren gelöscht werden, um es anschließend neu drauf zu spielen. Wird das Programm neu
kompiliert sollten die Sensoren wieder Daten liefern, wenn es sich nicht um einen Programmierfehler
handelt.
