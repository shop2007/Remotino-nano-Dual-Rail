# Checklist realizzazione — Remotino Nano Dual Rail

Guida pratica per chi parte da zero, basata sulle cartelle presenti nella repository.

## Software

1. Scarica e installa **Arduino IDE 2** dal sito ufficiale arduino.cc.
2. Apri Arduino IDE e carica lo sketch `.ino` che trovi nella cartella **"Arduino Sketch"**.
3. Prova a compilarlo (Verifica). Se l'IDE segnala una libreria mancante, installala dal **Library Manager** (icona libro a sinistra) e ricompila.
4. Collega l'Arduino Nano al PC via USB, seleziona la scheda **"Arduino Nano"** e la porta seriale corretta, poi carica lo sketch sulla scheda.
5. Apri il monitor seriale (velocità coerente con quella impostata nello sketch) e verifica che compaiano i messaggi diagnostici (es. `PWM1=`, `MOTN=`) quando invii un comando relè via seriale (es. `r11`, `r20`).

## Hardware e schema

6. Consulta lo schema generale nella cartella **"img"** per capire l'architettura complessiva del sistema (binari, relè, telecomando, alimentazione).
7. Se hai poca esperienza con Arduino ed elettronica, segui la guida passo-passo nella cartella **"Istruzioni semplici"**.
8. Per la realizzazione elettrica reale (o per farti fare il PCB), apri lo schema completo nella cartella **"Kicad"** — serve installare KiCad se vuoi visualizzarlo o modificarlo.
9. Realizza il cablaggio seguendo lo schema KiCad: alimentazione, i due circuiti binario, gli 8 relè, i 4 fusibili PTC.
10. Inserisci l'Arduino Nano nello zoccolo/basetta predisposta.
11. Se vuoi usare la funzione **JOIN**, taglia con un seghetto entrambe le rotaie nel punto di collegamento tra binario 1 e binario 2 (senza unirle elettricamente).

## Primo avvio e collaudo

12. Alimenta il sistema e, con il monitor seriale aperto, verifica lo stato generale prima di collegare il telecomando.
13. Alla prima accensione (o dopo un reset), premi subito **A / B / C / D** per scegliere la modalità dei relè (Banco 1‑4: monostabili per scambi, bistabili per luci, o combinazioni miste) — la scelta va fatta entro i primi tasti premuti, poi resta salvata in EEPROM.
14. Prova i comandi da telecomando: premi **GO** per abilitare i motori (nessun treno si muove prima), poi **CH+/CH−** per il binario 1 e **VOL+/VOL−** per il binario 2.
15. Prova **OK** per il boost e **0** per fermare dolcemente il binario selezionato; verifica **POWER ON** come arresto d'emergenza di tutto.
16. Se hai realizzato il taglio del binario, prova la funzione **JOIN** con il tasto **9** e verifica il passaggio del treno tra i due binari, poi disattivala con **0**.
17. Prova i tasti **1–8** per verificare l'attivazione dei relè nella modalità scelta.

## Remotino Display (opzionale ma consigliato)

18. Installa Processing usando l'eseguibile nella cartella **"Processing installer"**.
19. Apri lo sketch dentro **"Processing sketch"** e avvialo con l'Arduino collegato via USB, per visualizzare il pannello di stato (Motor On, direzione, JOIN, VU meter di potenza, stato dei 4 scambi).

## Se qualcosa non funziona

20. Usa il monitor seriale per comandare i relè manualmente (`rXY`, es. `r11` accende il relè 1, `r20` spegne il relè 2) e isolare se il problema è hardware o software.
