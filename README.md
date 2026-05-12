# DE1 Basic Computer - V0


Le design repose sur trois blocs principaux :

1. `reg16` : un registre 16 bits synchrone avec remise a zero.
2. `reg16_avalon_interface` : une couche d'adaptation Avalon/MM qui expose le registre au systeme.
3. `component_tutorial.vhd` : le top-level qui instancie `nios_system` et affiche une valeur 16 bits sur les afficheurs HEX.

Le fichier `hex7seg.vhd` sert de decodeur 7 segments pour afficher chaque nibble sur `HEX0` a `HEX3`.

## Comment le composant a ete cree

### 1. Creation du registre de base

Le fichier `ip_module/reg16/reg16.vhd` implemente un registre 16 bits.
Il fonctionne sur front montant de l'horloge et prend en compte `byteenable` pour ecrire seulement les octets autorises.

Comportement principal :

- si `resetn = '0'`, alors `Q` est remis a zero;
- si `byteenable(0) = '1'`, l'octet de poids faible est charge;
- si `byteenable(1) = '1'`, l'octet de poids fort est charge.

### 2. Ajout de l'interface Avalon/MM

Le fichier `ip_module/reg16/reg16_avalon_interface.vhd` encapsule `reg16` pour le rendre utilisable dans Qsys/Platform Designer.

Cette couche fait le lien entre le bus et le registre :

- `writedata` alimente l'entree `D`;
- `chipselect` et `write` valident l'ecriture;
- `byteenable` pilote les octets;
- `readdata` renvoie l'etat du registre;
- `Q_export` expose la valeur du registre vers l'exterieur du systeme.

### 3. Integration dans le systeme Nios

Le systeme `nios_system` a ete genere avec le composant exporte `Q_export`.
Dans le top-level `component_tutorial.vhd`, le signal `to_HEX` recupere `to_hex_export` de `nios_system`.

Ensuite, `hex7seg` decompose `to_HEX` en 4 digits de 4 bits :

- `to_HEX(3 downto 0)` -> `HEX0`
- `to_HEX(7 downto 4)` -> `HEX1`
- `to_HEX(11 downto 8)` -> `HEX2`
- `to_HEX(15 downto 12)` -> `HEX3`

## Fichiers importants

- `component_tutorial.vhd` : top-level de la carte DE1.
- `hex7seg.vhd` : decodeur pour les afficheurs 7 segments.
- `ip_module/reg16/reg16.vhd` : registre 16 bits de base.
- `ip_module/reg16/reg16_avalon_interface.vhd` : wrapper Avalon/MM du registre.
- `nios_system.qsys` : configuration du systeme Nios et de ses peripheriques.

## Lecture du montage

Le chemin des donnees est le suivant :

`bus Avalon/MM` -> `reg16_avalon_interface` -> `reg16` -> `Q_export` -> `nios_system` -> `component_tutorial.vhd` -> `hex7seg` -> `HEX0..HEX3`

Autrement dit, le processeur Nios peut ecrire une valeur 16 bits dans le composant, puis cette valeur est affichee directement sur les 4 afficheurs HEX.

## Remarque

Cette V0 garde uniquement la partie VHDL du projet, mais les fichiers sont presents directement a la racine pour simplifier la consultation dans GitHub.