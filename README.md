# LISEZ-MOI

## Contexte

Récemment, le Planning Familial avait fait une campagne de prévention représentant un homme enceint, [ce qui avait déclenché une polémique vive au sein des milieux réactionnaires](https://www.mediapart.fr/journal/france/240822/affiche-du-planning-familial-ce-n-est-pas-une-question-de-genre-c-est-une-question-de-droit), polémique alimentée par de nombreuses TERF (ou *femellistes* comme elles semblent désormais vouloir être appelées). Ces attaques sont allées jusqu'à des menaces téléphoniques et des dégradations de locaux.

Considérant l'opposition claire de l'extrême-droite vis-à-vis des plannings familiaux et prenant en compte le rôle des TERF dans cette polémique, j'ai souhaité étudier comment la polémique s'était développée sur les réseaux sociaux et qui en avait été les acteur·ice·s.

## Objectifs et questions de recherche

L'objectif de cette analyse de réseau social est de mieux comprendre la polémique entourant le planning familial en analysant le réseau des personnes ayant participé aux échanges de tweets sur ce sujet. Plus spécifiquement, on retiendra 2 objectifs principaux :

1.  Établir le réseau de retweets autour de la polémique transphobe sur l'affiche du planning familial

2.  Déterminer les communautés présentes dans le réseau

3.  Déterminer les compte Twitter ayant eu le plus d'influence dans cette polémique, à la fois au sein de leur communauté mais également dans le réseau en entier

Ces trois objectifs permettront de répondre à la question de recherche de cet article : *"les personnes ayant manifesté une attitude hostile lors de la polémique du planning familial sont-elles proches de l'extrême droite ?"*.

## Description du répertoire

-   assets comprend les images utilisées dans l'article et ne provenant pas de ce projet

-   data comporte les données téléchargées depuis l'API Twitter et sauvegardées

-   gephi comprend l'exportation du graphe généré par Gephi à partir des données récupérées et traitées dans ce projet

-   renv comporte les packages ayant été utilisé pour mener à bien ce projet

-   scripts comprend les différents scripts ayant permis la récupération et le traitement des données. Chaque script comporte des explications sur leur fonctionnement.

## Reproduire ce travail

1.  Télécharger le contenu du dépôt

2.  Ouvrir le fichier TERNET.Rproj pour ouvrir le projet

3.  Utiliser la commande renv::restore() pour restaurer tous les packages nécessaires dans la version utilisée pour générer le projet

4.  Utiliser la commande rmarkdown::render("TERFnet.Rmd") pour lancer tous les scripts, hormis ceux ayant permis la recherche Twitter, générer le tableau, et créer l'article au format .html
