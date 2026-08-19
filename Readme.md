# Remotino Nano Dual Rail

**Remotino Nano Dual Rail** è l'evoluzione naturale di Remotino Nano.

## Caratteristiche principali

- Controllo totale tramite telecomando a infrarossi
- Due binari indipendenti, controllati in PWM sia per velocità che per direzione
- Il controllo PWM consente velocità bassissime, realmente in scala 1:87, con partenze e fermate lente e graduali, proprio come un treno vero
- Possibilità di unire temporaneamente i due circuiti per far passare un treno da un binario all'altro (funzione speciale 9)
- Controllo di 8 relè per l'attivazione di scambi, luci o alimentazione di tronchini morti. Se usati per gli scambi, in modalità monostabile servono 2 relè per ogni scambio

## Modalità di configurazione dei relè

Gli 8 relè possono essere configurati in 4 modalità:

| Modalità | Configurazione |
|----------|-----------------|
| **MODO_A** | 8 relè monostabili per 4 scambi (il tasto 1 chiude il relè 1 finché resta premuto) |
| **MODO_B** | 8 relè bistabili ON/OFF per 8 attivazioni (il tasto 1 inverte lo stato del relè 1 ad ogni pressione) |
| **MODO_C** | 6 relè monostabili per 3 scambi + 2 relè bistabili ON/OFF per 2 attivazioni |
| **MODO_D** | 4 relè monostabili per 2 scambi + 4 relè bistabili ON/OFF per 2 attivazioni |

## Cambio binario (funzione JOIN)

Per passare dal binario 1 al binario 2 è necessario che entrambi i binari abbiano una sezione isolata su entrambe le rotaie; non serve però unirle fisicamente, perché attivando la modalità 9 le due tensioni vengono prima azzerate e poi viene applicato lo stesso comando su entrambi i circuiti, permettendo al treno di passare da un binario all'altro in modo del tutto indolore.

Quattro fusibili PTC autoripristinanti proteggono i circuiti da eventuali errori, come ad esempio il tentativo di cambiare binario senza aver prima premuto il tasto 9 — situazione che provocherebbe un cortocircuito tra le diverse tensioni.

## Remotino Display

Collegando Arduino Nano a una porta USB e lanciando l'eseguibile **Remotino Display**, è possibile visualizzare:

- Stato di motor on
- Direzione dei due binari
- Stato di JOIN (comando 9)
- Due VU meter analogici con la potenza erogata ai due motori
- Stato dei 4 scambi
