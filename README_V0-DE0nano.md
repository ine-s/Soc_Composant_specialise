# V0-DE0nano — README

Ce document décrit la branche `V0-DE0nano` : le composant matériel spécialisé, le modèle de programmation, les signaux exposés et des explications d'utilisation.

## 1. But général

La branche `V0-DE0nano` cible une implémentation pour la carte DE0-Nano. Elle contient un composant matériel spécialisé (IP) conçu pour s'intégrer au système Nios/Altera via une interface mémoire-mappée (Avalon-MM). Le composant gère la logique spécifique du projet (capteurs, PWM, seuils, etc.) et expose des registres de contrôle/statut et flux de données.

## 2. Description du composant spécialisé

- Type : IP Avalon-MM (esclave)
- Rôle : interface entre le matériel spécifique (capteurs, PWM, entrées/sorties) et le processeur Nios ou la logique système.
- Capacités principales :
  - Registres de configuration (contrôle, seuils, modes)
  - Registres d'état (flags, compteurs, erreurs)
  - FIFO/Buffer pour échange de données en flux
  - Sorties PWM ou lignes de commande vers périphériques externes
  - Optionnel : interruption matérielle pour notifier le processeur


## 3. Modèle de programmation

Le composant suit le modèle de périphérique mémoire-mappé suivant :

- Le processeur lit/écrit des registres via l'interface Avalon-MM.
- Les accès en lecture retournent l'état courant ; les écritures modifient la configuration ou mettent des données dans un buffer.
- Les éventuels transferts continus (données capteur → FIFO) doivent être consommés régulièrement pour éviter débordement.
- Si une interruption est implémentée, le périphérique peut lever une IRQ pour signaler : donnée disponible, FIFO presque plein/vide, condition d'erreur, fin d'opération.


## 4. Signaux et registres (exemples et explications)

Les noms ci‑dessous sont des conventions courantes pour un IP Avalon-MM ;

- `clk` : horloge système du composant. Toutes les logiques synchrones se basent sur ce signal.
- `reset_n` / `rst` : reset asynchrone actif bas ou niveau selon implémentation.
- Avalon-MM (esclave) :
  - `avs_address` : adresse du registre sélectionné (word-aligned)
  - `avs_read` / `avs_write` : strobes de lecture/écriture
  - `avs_writedata` : données en écriture par le maître
  - `avs_readdata` : données lues renvoyées par l'esclave
  - `avs_waitrequest` : indique que l'esclave n'est pas prêt (back-pressure)

- Signaux de données et contrôle internes :
  - `data_out` / `data_in` : bus de données point-à-point (usage dépend du module)
  - `data_valid` : indique que `data_out` contient une donnée valide
  - `data_ready` : handshake côté consommateur

- Interruption :
  - `irq` : ligne d'interruption active haut (ou selon convention) pour notifier le processeur.
  - Bits d'état d'IRQ dans le registre `STATUS` / `INT_MASK` pour permettre masque/unmasque.

- Registres :
  - `0x00` — `CTRL` : bit0 = enable, bit1 = reset logiciel, bit[7:2] = réservés
  - `0x04` — `STATUS` : bit0 = ready, bit1 = data_available, bit2 = fifo_full, bit3 = error
  - `0x08` — `THRESHOLD` : valeur de seuil pour capteur
  - `0x0C` — `PWM_PERIOD` : période PWM
  - `0x10` — `DATA` : lecture des données de capteur / écriture de commande
  - `0x14` — `FIFO_LEVEL` : lecture profondeur FIFO
  - `0x18` — `INT_MASK` : masque des sources d'interruption



## 6. Intégration et build

- Générer le QSys/Platform Designer `.qsys` avec le périphérique ajouté et vérifier les adresses.
- Régénérer le système et relancer la génération de la FPGA (fichiers `.qsf`, `.sopcinfo`, `.sof`).
- Valider les GPIO/PWM physiques sur la carte DE0-Nano en suivant le schéma de brochage.

