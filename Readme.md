# Remotino Nano Dual Rail

**Remotino Nano Dual Rail** è l'evoluzione naturale di Remotino Nano.

## Caratteristiche principali

- Controllo totale tramite telecomando a infrarossi
- Due binari indipendenti, controllati in PWM sia per velocità che per direzione
- Il controllo PWM consente velocità bassissime, realmente in scala 1:87, con partenze e fermate lente e graduali, proprio come un treno vero
(VIDEO_LENTO-MP4)
- Possibilità di unire temporaneamente i due circuiti per far passare un treno da un binario all'altro (funzione speciale join tasto 9)
- Controllo di 8 relè per l'attivazione di scambi, luci o alimentazione di tronchini morti. Se usati per gli scambi, in modalità monostabile servono 2 relè per ogni scambio
- Espandibilità verso schede da 8/16 relais con protocollo I2C
<img src="img/XL9535-16rele-i2c" alt="Scheda 16 Relè IC bus Aliexp" >

## Modalità di configurazione degli 8 relè

Gli 8 relè possono essere configurati in 4 modalità:

| Modalità | Configurazione |
|----------|-----------------|
| **MODO_A** | 8 relè monostabili per 4 scambi (il tasto 1 chiude il relè 1 finché resta premuto) |
| **MODO_B** | 8 relè bistabili ON/OFF per 8 attivazioni (il tasto 1 inverte lo stato del relè 1 ad ogni pressione) |
| **MODO_C** | 6 relè monostabili per 3 scambi + 2 relè bistabili ON/OFF per 2 attivazioni |
| **MODO_D** | 4 relè monostabili per 2 scambi + 4 relè bistabili ON/OFF per 2 attivazioni |
Questa programmazione va fatta premendo i tasti A,B,C o D appena resettato, poi resta memorizzato nella EEPROM

## Cambio binario (funzione JOIN)

Per passare dal binario 1 al binario 2 è necessario che i due circuiti siano uniti da un binario con una interruzione su entramble le rotaie (io l'ho fatto con un segheto da ferro); per il passaggio non serve unirle elettricamente, perché attivando la modalità "join" con il tasto 9, le tensioni dei due circuiti vengono prima azzerate e poi viene applicato lo stesso comando su entrambi i circuiti, permettendo al treno di passare da un binario all'altro in modo del tutto indolore.
<img src="img/binario-tagliato.jpg" alt="Foto binario tagliato" >

Quattro fusibili PTC autoripristinanti proteggono i circuiti da eventuali errori, come ad esempio il tentativo di cambiare binario senza aver prima premuto il tasto 9 — situazione che provocherebbe un cortocircuito tra le diverse tensioni.

## Remotino Display

Collegando Arduino Nano a una porta USB e lanciando l'eseguibile **Remotino Display**, è possibile visualizzare:

- Stato di motor on
- Direzione dei due binari
- Stato di JOIN (comando 9)
- Due VU meter analogici con la potenza erogata ai due motori
- Stato dei 4 scambi
<img src="img/pannello-due-dir.png" alt="Pannello di controllo su PC" >

## Debug hardware

In caso di malfunzionamento dell'hardware è possibile inviare alcuni comandi da monitor seriale per attivare i relais e verificarne il funzionamento 

-  r=relay , 1=rl1, 1=on 0=off
- r11 attiva rele1
- r20 disattiva rele 2

## Schema Generale
Solo a titolo esemplificativo questo è lo schemone totale del controllo. Per realizzarlo è necessario aprire lo schema reale fatto in kicad.
<img src="img/remotino-dual-rail-schema-v09.jpg" alt="Schemone generale" >



## Istruzioni facili per i meno esperti
Ho scritto una istruzione fatta passo-per-passo, che dovrebbe consentire di replicare il progetto a chiunque abbia un minimo di dimestichezza con Arduino. Scrivimi se incontri difficoltà. Cerca la cartella "Istruzioni facili"