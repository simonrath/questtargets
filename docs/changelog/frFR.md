# Quest Targets – Notes de mise à jour

Changements pour les joueurs, de la version la plus récente à la plus ancienne. Les indications d’installation historiques s’appliquent à la version indiquée.

## 1.7.4 – Aperçu

### Polestar
- **Cibles Polestar :** Sur WoW Forever, avec Polestar installé, activez **Boutons → Barre de ciblage → Suivre les cibles Polestar**, désactivé par défaut. La boussole principale recherche les objectifs ouverts nommés de l’étape affichée ; à défaut, elle recherche les objectifs de quête. Les changements s’appliquent après le combat. Si RestedXP est aussi activé et disponible, il est prioritaire.

## 1.7.3 – 20.11.2026

### Options
- Correction d’une erreur dans les **options sociales** de Blizzard.

## 1.7.2 – 19.11.2026

### RareScanner
- **Rares les plus proches en premier :** Le bouton violet trie les rares marqués et ceux de la zone selon la distance à leur point d’apparition connu le plus proche dans RareScanner.

### Barre de ciblage
- **Position actuelle à chaque clic :** Hors combat, les boutons de ciblage relèvent ta position pour les recherches par distance uniquement lors d’un clic ou de l’utilisation d’un raccourci. Si tu as bougé, la recherche reprend au début de la liste actualisée. Si tu restes sur place, les clics suivants vérifient les noms suivants.

## 1.7.1 – 19.11.2026

### RareScanner
- **Conserver la cible :** Un rare vivant de la liste reste ciblé lorsque tu cliques de nouveau sur le bouton violet ou utilises son raccourci.

### Barre de ciblage
- **Recherches séparées :** Le bouton principal rouge recherche les cibles de quête et, si l’intégration RestedXP est active, celles de l’étape actuelle du guide. Les boutons bleu de RestedXP, jaune d’ItemTree et violet de RareScanner utilisent chacun leur propre liste.

## 1.7.0 – 19.11.2026

### RareScanner
- **WoW Forever :** Le ciblage nécessite l’addon RareScanner. Il fonctionne hors combat et à portée de ciblage.
- **Carte du monde :** Clique gauche sur un PNJ rare pour le marquer. Clique sur le **Bouton RareScanner** violet de la barre de ciblage pour rechercher tous les rares marqués. L’infobulle affiche la liste.
- **Macro RareScanner :** Selon la longueur des noms, la macro peut rechercher **2 à 4 créatures rares par clic** en général. Si la liste en contient davantage, clique de nouveau pour rechercher les suivantes.
- **Afficher le bouton RareScanner :** Tu peux masquer la boussole sous **Boutons → Barre de ciblage**. Elle est visible par défaut et grisée lorsqu’aucune cible ne peut être recherchée. Elle reste visible en combat et la recherche est désactivée.
- **Cibler les rares de RareScanner :** Attribue deux touches au bouton violet sous **Raccourcis clavier**. Chaque pression lance la même recherche qu’un clic gauche.
- **Rechercher tous les rares de la zone :** Active cette option sous **Boutons → Barre de ciblage** pour rechercher tous les PNJ rares répertoriés par RareScanner dans ta zone actuelle, y compris ceux qui ne sont pas marqués. La liste se met à jour quand tu changes de zone et inclut les rares du donjon actuel si RareScanner dispose de ces données. L’option est désactivée par défaut.
- **Minicarte :** Clique gauche sur l’icône RareScanner d’un rare pour le rechercher. Une **impulsion radar** confirme le clic. Si la minicarte intercepte le premier clic, clique de nouveau pour tenter le ciblage.

### Barre de ciblage
- **Barre de ciblage :** Sous **Boutons → Barre de ciblage**, règle la **Disposition des boutons** sur horizontale ou verticale et l’**Espacement des boutons** entre 0 et 32 px. Active **Afficher la bordure bronze** pour entourer toute la barre d’une bordure bronze aux angles biseautés inspirée des cadres d’unité de FlareUI. Par défaut, la barre est horizontale, avec un espacement de 4 px et sans bordure.
- **Afficher les séparateurs :** Affiche ou masque les lignes dégradées de l’or à l’argent et leurs étoiles indépendamment de la bordure bronze. Elles pivotent lorsque la barre est verticale.
- **Boussole de quête moderne :** Le bouton texte classique et ses options de largeur, de hauteur et de texte sont supprimés. La mise à jour remplace le bouton classique par la boussole à la position enregistrée. Règle sa taille sous **Boutons → Barre de ciblage → Taille du bouton**.

### Fenêtre des notes de mise à jour
- **Notes de mise à jour :** L’historique s’ouvre une fois par compte à la première connexion avec une nouvelle version et reste ouvert jusqu’à ce que tu le fermes. Retrouve-le sous **Options → AddOns → Quest Targets → Notes de mise à jour**. Il suit la langue de l’addon.

## 1.6.1 – 15.11.2026

### Nouveautés
- **EllesmereUI :** Sur Forever, des boutons de ciblage s’ajoutent au Custom Quest Tracker. Clique gauche pour rechercher une cible ou clique droit pour mettre la quête en focus.
- **Commentaires :** La fenêtre affiche un code QR pour ouvrir le formulaire.

### Améliorations
- Associe un bouton de souris, la molette ou une combinaison de touches à un raccourci de ciblage depuis n’importe où dans la fenêtre de jeu.
- Questie et EllesmereUI disposent de réglages d’espacement distincts sous **Boutons**.
- Tu peux couper le son joué lorsque la cible est désélectionnée.

## 1.6.0 – 10.11.2026

### Nouveautés
- **Intégration d’ItemTree :** Installe et active ItemTree séparément. Ouvre la vue **Sources** d’un ingrédient, déplie **Show more** au besoin et clique sur **Import mobs**. Quest Targets importe les ennemis qui fournissent cet ingrédient.
- **Ciblage ItemTree :** Active la boussole jaune sous **Boutons → Afficher le bouton ItemTree** ou attribue un raccourci à **Target ItemTree mobs**. Si le clic ne trouve aucune cible, clique de nouveau pour essayer d’autres noms.
- **Macro de barre d’action :** Si un emplacement est disponible, l’importation crée la macro de personnage **ItemTree Mobs**. Fais-la glisser de la fenêtre des macros vers la barre d’action. Le bouton et son raccourci fonctionnent même sans emplacement de macro libre.
- La **barre de ciblage** accueille le bouton principal rouge, le bouton bleu de RestedXP et le bouton jaune d’ItemTree.

### Améliorations
- Déplace et redimensionne les trois boutons ensemble et choisis lesquels afficher.
- ItemTree privilégie les cibles de ta zone et tient compte des points d’apparition connus.

## 1.5.1 – 03.11.2026

### Nouveautés
- Fais glisser le **coin inférieur droit** pour redimensionner la fenêtre des quêtes. Sa taille et sa position sont enregistrées.
- Désactive les boutons de ciblage de Questie ou ajuste leur espacement.

### Améliorations
- Le **bouton de minicarte** est mieux pris en charge par les addons qui regroupent les boutons de minicarte.
- Les options affichent la version installée. La boussole devient le bouton principal par défaut dans les nouvelles configurations.

## 1.5.0 – 03.11.2026

### Améliorations
- Un téléchargement prend en charge Classic Era, Burning Crusade Classic, Mists of Pandaria Classic, Forever et Retail.
- Quest Targets choisit les données de quête adaptées à ton client. Installe QuestieDB séparément si nécessaire.

## 1.4.2 – 03.11.2026

### Améliorations
- **QuestieDB** se télécharge et se met à jour séparément. Retail n’en a pas besoin.

## 1.4.1 – 02.11.2026

### Améliorations
- Les deux emplacements des raccourcis du bouton principal et du focus apparaissent dans les raccourcis de WoW. Quest Targets demande confirmation avant de réattribuer une touche.
- Quest Targets apparaît dans les options des addons dès la connexion. Les réglages réservés à l’autre style de bouton sont grisés.

### Corrections
- Les changements et suppressions dans les raccourcis de WoW sont conservés après un rechargement.
- Le clic droit ouvre le journal des quêtes uniquement hors combat. Les associations entre cartes et cibles sont plus fiables.

## 1.4.0 – 30.10.2026

### Nouveautés
- Le bouton principal et le focus disposent chacun de deux raccourcis pour clavier et manettes compatibles.

### Améliorations
- Modifie ou efface un raccourci sans perdre l’autre. Échap annule l’attribution.

## 1.3.0 – 29.10.2026

### Améliorations
- La version 1.3.0 publie ensemble le déplacement du bouton principal et QuestieDB 1.0.9 introduits en 1.2.9.

## 1.2.9 – 28.10.2026

### Nouveautés
- **Déplacer le bouton principal** ajoute une poignée dans les options. Confirme pour enregistrer, appuie sur Échap pour annuler ou réinitialise la position pour voir l’emplacement par défaut.

### Améliorations
- Les paquets Classic et Forever incluaient la version de QuestieDB 1.0.9 adaptée à leur client.

## 1.2.8 – 16.10.2026

### Corrections
- QuestieDB 1.0.6, inclus dans les paquets, rétablit la compatibilité avec Questie 12.1.0.

## 1.2.7 – 15.10.2026

### Nouveautés
- Utilise **/qt debug** pour voir les détails de la dernière recherche de cible.

### Corrections
- La **barre d’action** de WoW reste utilisable après avoir modifié les options de l’addon.

## 1.2.6 – 12.10.2026

### Corrections
- Les boutons principal et RestedXP fonctionnent encore si la liste des cibles rétrécit ou se vide pendant une étape du guide.

## 1.2.5 – 09.10.2026

### Nouveautés
- Clique droit sur une icône de quête dans Quest Targets ou Questie pour la mettre en focus. Un raccourci dédié cherche les cibles de cette seule quête.
- Les options natives et compactes permettent de modifier directement le texte du bouton principal.

### Améliorations
- Les boutons de Questie s’affichent automatiquement. RestedXP utilise les objectifs encore ouverts de l’étape actuelle.
- La fenêtre de quêtes, le défilement et le déplacement sont plus fiables. Les objectifs terminés sont retirés des recherches.

## 1.2.4 – 04.10.2026

### Améliorations
- Si RestedXP ne fournit pas de cible valide, la recherche peut revenir aux quêtes en cours.
- Les clics successifs conservent une cible valide tant qu’aucune autre cible correspondante n’est visible.

## 1.2.3 – 03.10.2026

### Nouveautés
- RestedXP peut chercher les donneurs de quête nommés explicitement avant que tu acceptes leur quête.
- Prise en charge de Burning Crusade Classic et de Mists of Pandaria Classic.

### Améliorations
- Quest Targets apparaît dans la catégorie Quêtes de la liste des addons. Sur Classic Era, les boutons de Questie affichent la boussole.

## 1.2.2 – 03.10.2026

### Nouveautés
- L’intégration facultative de RestedXP cherche les cibles dans l’étape active du guide. Un bouton Quest Targets apparaît auprès de RestedXP.

## 1.2.1 – 02.10.2026

### Nouveautés
- Un bouton de ciblage facultatif apparaît à côté de chaque quête dans le suivi de Questie.

### Améliorations
- La prise en charge de l’interface de Forever a été mise à jour, la taille du bouton principal ajustée et le bouton de minicarte doté d’un cadre natif.
- Dans la fenêtre transparente, le survol affiche la poignée et le bouton de bascule. Les options et les commentaires sont côte à côte.

## 1.2.0 – 30.09.2026

### Nouveautés
- **Retail 12.1** est pris en charge. Quest Targets lit le journal de quêtes et les barres d’info visibles sans QuestieDB.

### Corrections
- Si le journal ne peut pas être lu, un message apparaît à la place d’une liste apparemment vide.

## 1.1.0 – 28.09.2026

### Nouveautés
- Le **mode transparent** n’affiche que la liste des quêtes. L’icône en forme d’œil change la vue et disparaît après un court instant.

### Améliorations
- Le bouton de fermeture et la barre de défilement s’adaptent à la nouvelle disposition.

## 1.0.22 – 28.09.2026

### Améliorations
- L’intégration de QuestieDB a été mise à jour. Le téléchargement public utilisait toujours le fournisseur compatible installé séparément.

## 1.0.16 – 27.09.2026

### Nouveautés
- Le **bouton Commentaires** ouvre un lien à copier pour envoyer des rapports de bugs ou des suggestions. Aucun compte GitHub n’est nécessaire.

## 1.0.15 – 27.09.2026

### Améliorations
- La **molette et la barre de défilement** remplacent les flèches de page. Un curseur dans les options règle la taille de la fenêtre.
- Les infobulles sont plus simples, les raccourcis ont leur propre section et les textes des six langues ont été mis à jour.

## 1.0.13 – 25.09.2026

### Améliorations
- Si QuestieDB manque, le message indique le bon paquet pour Classic Era ou Forever. Sélectionne le lien dans la fenêtre pour le copier.

## 1.0.12 – 25.09.2026

### Nouveautés
- Prise en charge de **WoW Classic Era** 1.15.9 en plus de la bêta de Forever.

### Corrections
- Les quêtes Classic, leur suivi et leur achèvement sont correctement lus. Le clic droit ouvre le journal et les coordonnées d’apparition Classic sont conservées.

## 1.0.11 – 25.09.2026

### Nouveautés
- Première version documentée pour la bêta de Forever. Un bouton par quête et un **bouton principal** recherchent les ennemis des quêtes actives ou les PNJ prêts à recevoir une quête.
- QuestieDB ajoute les cibles à éliminer, les cibles communes et les ennemis qui fournissent les objets requis. Les barres d’info lisibles peuvent fournir d’autres cibles.
- La liste affiche la progression, filtre les quêtes suivies et ouvre le journal par clic droit. /qt ouvre ou ferme la fenêtre.
- Configure les marqueurs, raccourcis, infobulles et les six langues dans les options de WoW.
- La boussole apparaît sur la minicarte et peut servir de bouton principal déplaçable. Le style classique prend en charge un texte personnalisé.
