# Code Documentation

Lua ist keine objektorientierte Sprache. Man kann jedoch trotzdem mit Lua objektorientiert programmieren indem man Metatabellen als Klassen verwendet.

Um so zu arbeiten erstellt man eine Klasse nach dem Schema:

local Class = {}

return Class

Methoden werden dann zu dieser Tabelle so hinzugefügt:

local Class = {}
function class.method()
return Class

Um auf diese Methoden und Klassen dann in einem anderen Skript zugreifen zu können, muss man das Skript importieren: 

Class = require("Class")

Ist das Skript in einem anderen Ordner, so muss der Pfad angegeben werden.



## Communication

Variablen:
Socket: UDPSocket
Communication.isMaster: Boolean, 
Communication.masterIP: String

**receiveScans(_handleOnReceive: function): void**

	Parameter: _handleOnReceive(data: any): void
Registriert die gegebene Funktion als OnReceive-Handle auf dem Socket. Empfangene Nachrichten werden deserialisiert und als Parameter an die gegebene Funktion übergeben.

**handle(data: any):void**

	Helfer-Funktion für das Empfangen von Scans.

**stopReceiving():void**

	Entfernt den OnReceive-Handle von dem UDP-Socket und stoppt so das empfangen von Nachrichten.

**sendScans(_scanProvider: Scan.Provider.Scanner): void**

	Registriert eine OnNewScan-Funkion auf dem gegebenen _scanProvider. Die Scans werden serialisiert und an die hinterlegte masterIP(Standard-IP: 192.168.1.10) gesendet. 


## DataProcessing

**removePointsBeyond(inputCloud: PointCloud, maxDistance: double):PointCloud**

	Nimmt eine PointCloud sowie eine Distanz und entfernt alle Punkte in der PointCloud, die weiter als die Distanz vom Ursprung entfernt sind.
	Gibt die veränderte PointCloud zurück.

**getCornersAndEdgeLengths(inputCloud:PointCloud):Point, Int, Point, Int, Float, Point, Int, Float**

	Überprüft in einer übergebenen PointCloud, ob der Sensor zwei oder drei Ecken eines Dreiecks anschaut. Ist der naheliegendste Punkt an einem Ende des Dreiecks, dann werden zwei Ecken angesehen, woraufhin der erste und der letzte Punkt in der PointCloud, deren Indexe, sowie die Distanz dazwischen zurückgegeben wird. Ist der naheliegendste Punkt nicht an einem Ende des Dreiecks und eine Ecke so wird der erste, der letzte und der naheliegendste Punkt zurückgegeben, sowie die Distanz zwischen dem letzten Punkt und dem naheliegendste Punkt. Ist der naheliegendste Punkt keine Ecke und an keinem Ende des Dreiecks, so werden der erste, der letzte Punkt der PointCloud, deren Indexe, sowie die Distanz dazwischen zurückgegeben.

**getCorners(inputCloud:PointCloud):Point, Integer, Point, Point**

	Bestimmt die Ecken eines Dreiecks aus einer übergebenen PointCloud und gibt diese zurück. Gibt auch den Index des naheliegendstens Punkt zurück.

**rotateAroundPoint(originPoint:Point, pointRotate: Point, angle:number) :Point**

	Rotiert einen übergebenen Punkt um einen weiteren übergebenen Punkt um einen übergebenen Winkel in Grad. 

**getDegree(point1:Point, point2:Point):number**

	Berechnet den Winkel zweier Vektoren der Punkte zum Ursprung.

**checkEdgelength(length: double, index: int):Boolean**

	Nimmt eine Länge sowie den Index einer bekannten Länge in utils. Überprüft ob die Länge mit der bekannten Länge um mindestens 90% übereinstimmt. 

**getThirdCorner(p1:Point, p2: Point): point**

	Nimmt zwei Punkte und bestimmt den dritten Punkt eines Dreiecks. Bestimmt hierfür die betrachtete Kante und vergleicht diese mit bekannten Kanten. Wird die Kante gefunden, so wird der Punkt erstellt, an die richtige Position gesetzt und zurückgegeben. Sollte die Kante nicht erkannt werden, so wird ein Fehlermeldung in die Konsole gesetzt und null zurückgegeben.

**translatePositivePoint(originPoint:Point,vec:Point) : Point**

	Translation eines positiven Punktes um einen übergebenen Vektor. Gibt veränderten Punkt zurück.

**translateNegativePoint(originPoint:Point,vec:Point) : Point**

	Translation eines negativen Punktes um einen übergebenen Vektor. Gibt veränderten Punkt zurück.

**computeAngle:(p1Scan1:Point, p1Scan2:Point, p2Scan1:Point, p2Scan2:Point) : number**

	Berechnet den Winkel zweier Punkte zueinander anhand zweier Referenzpunkte. Gibt den Winkel zurück

**computeMatrix(p1Scan1:Point, p2Scan1:Point, angle:number):Matrix**

	Berechnet eine Rotationsmatrix zur Drehung und Translation aller Punkte von Scan2 zu Scan1 durch die Verwendung von identischen Punkten in verschiedenen Koordinatensystemen sowie den Winkel zwischen diesen und gibt die Matrix dann zurück.

**getMatrix(p1Scan1:Point, p2Scan1:Point, angle:number):Matrix, Matrix, Matrix**

	Berechnet drei Matrizen für zwei Translationen und eine Rotation aller Punkte von Scan2 zu Scan1 durch die Verwendung von identischen Punkten in  verschiedenen Koordinatensystemen sowie den Winkel zwischen diesen und gibt die Matrizen dann zurück.


## Main
DataProcessing, Viewer, Communication, provider: Scan.Provider.Scanner, utils, slaveScans: Array, tempIsMaster: Boolean, tempMasterIP: String

**removeScansAndShapes():void**

	Entfernt alle OnNewScan-Handles aus provider und entfernt alle Formen aus dem viewer.

**addShapes():void**

	Fügt dem viewer Formen für die cutOffDistance, den Blindspot und den Lidar hinzu.

**showOwnScans():void**

	Zeigt im Viewer die eigenen Scans des LIDAR. Zusätzlich werden formen und Flags gesetzt.

**showSlavesScans():void**

	Zeigt die empfangen Scans an. Zusätzlich werden formen und Flags gesetzt.

**calibrate():void**

	Blendet Punkte die weiter entfernt als die cutOffDistance sind aus und ruft die Funktionen getCornersAndEdgeLengts plus die Funktion getThirdCorner auf, falls nur zwei Punkte sichtbar sind. Speichert die Daten in utils je nach master oder slave calibrate. 3D-Gittermodelle des Prismas werden an der berechneten Position eingefügt.

**showMergedScans():void**

	Started die Routine für das anzeigen der fusionierten Scans. Die benötigte Transformationsmatrix wird berechnet, die empfangenen Scans werden über Viewer.addSlaveScans() im Viewer hinterlegt und Viewer.showMergedScans() als OnNewScan-Handle auf provider registriert.

**setTempIsMaster(isMaster: boolean):void**

	Viewer-Hilfsfunktion. Setzt tempIsMaster auf den übergebenen Wert.

**setTempMasterIP(masterIP: String): void**

	Viewer-Hilfsfunktion. Setzt tempMasterIP auf den übergebenen Wert.

**setSettings():void**

	Setzt die Werte die eingestellten Werte und startet die entsprechenden Routinen. Zeigt die Slaves Scans an falls der LIDAR als Slave eingestellt wird. Sendet die eigenen Scans an die gegebene IP falls der LIDAR als Slave eingestellt wird.

**main():void**

	Funktionen für die Pages werden zur Verfügung gestellt.


## utils

Beinhaltet fest definierte Variablen die in verschiedenen Funktionen verwendet werden. Zur vereinfachten Refaktorisierung wurden diese ausgelagert um Änderungen zu vereinfachen.
Beinhaltet die Dimensionen des Kalibrierungsobjektes sowie globale Flags und Koordinaten.

Variablen: predefinedSideLengths, predefinedAngle, masterPoint1, masterPoint2, masterPoint3, slavePoint1, slavePoint2, slavePoint3, degreeSlaveMaster, triangleMaster, triangleSlave, degreeSlaveMaster, originPoint, showMaster, cutOffDistance, slaveActive, masterActive, transformation, blueShapeDecoration, greenShapeDecoration, redShapeDecoration

## ViewerModule

**showScans(scan: Scan): void**

	Zeigt nach jedem 4. Scan eine cloud mit den Letzten 4 Scans an. 

**showMergedCloud(scan): void**

	Fusioniert die empfangenen Scans mit denen des LIDAR. Berechnet die Transformationsmatrix falls diese Fehlt. Es werden dann jeweils 4 Scans des Slaves und 4 Scans des Masters fusioniert und angezeigt. Zusätzlich werden Formen für die LIDAR-Positionen und das Dreieck eingefügt.

**addSlaveScan(slaveScan): void**

	Fügt den gegeben scan zum slaveScans-Array hinzu. Teil der Routine zum Anzeigen von fusionierten Scans.

