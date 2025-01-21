# Projet en Unix sur Ubuntu 22.04.5 
## Structure du projet :
- Fichier process_suspects.log qui montre en détail le PID, le USER, le taux de CPU et de mémoire utilisé et le type de commande utilisé du processus malveillant.
- Fichier processus_ordi.log qui affiche chaque processus grâce à la commande bash `ps -aux`, mais détecte également une anomalie en détaillant son PID, le USER, le type de processus.
- Fichier processus_ordi.sh où se trouve le code à éxécuter.
- Fichier zombie.py qui initialise le processus zombie.
