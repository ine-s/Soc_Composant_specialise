Projet DE0-nano — Commande moteurs via reg32 et PWM_generation

Résumé
- Ce dépôt contient le design FPGA pour la DE0-nano (Nios II + gestion moteurs). Nous avons ajouté un composant 32 bits (`reg32`) et un générateur PWM (`PWM_generation`) pour piloter les moteurs du robot.

Nouveau composant: reg32
- Rôle : registre mémoire 32 bits mappé pour stocker les commandes moteurs.
- Organisation recommandée : 32 bits organisés en deux champs 16 bits : [31:16] = commande gauche, [15:0] = commande droite.
- Usage des 16 bits par moteur :
	- bits [13:0] : valeur de duty (0 = 0% .. 2^14-1 = 100%)
	- bit 14 : sens (0 = avant, 1 = arrière)
	- bit 15 : enable / flags (frein)


Module PWM (PWM_generation)
- Emplacement : [PWM_generation.vhd](PWM_generation.vhd#L1)
- Rôle : convertir une valeur de duty en signaux PWM pour la sortie H-bridge.
- Entrées : `s_writedataR`, `s_writedataL` (dans le design actuel, on connecte les 14 LSB : `cmd_motor_x_sig(13 downto 0)`).
- Sorties : `dc_motor_p_R`, `dc_motor_n_R`, `dc_motor_p_L`, `dc_motor_n_L` — signaux à relier à l'étage de puissance.

Interfaçage (existant dans lights.vhd)
- Fichier top : [lights.vhd](lights.vhd#L1)
- Le Nios exporte des vecteurs 16 bits par moteur (dans ce projet `moteur_l_export` et `moteur_r_export`) qui alimentent les signaux internes `cmd_motor_R_sig` et `cmd_motor_L_sig`.
- Le `PWM_generation` est instancié ainsi (extrait) :

	s_writedataR => cmd_motor_R_sig(13 DOWNTO 0)
	s_writedataL => cmd_motor_L_sig(13 DOWNTO 0)


Fichiers clés
- [lights.vhd](lights.vhd#L1) — top-level, branche les exports Nios et l'instance PWM.
- [PWM_generation.vhd](PWM_generation.vhd#L1) — générateur PWM utilisé par `lights.vhd`.


