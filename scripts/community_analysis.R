# Ce script permet de continuer l'analyse entamée avec Gephi en partant du fichier de noeuds exportés depuis Gephi.
# La différence la plus importante, par rapport au fichier de noeuds importés dans Gephi est que +/- 4000 noeuds ont été supprimés
# Ces noeuds étaient déconnectés du composant principal du graphique et rendait la détection des communautés moins explicite
# Ils correspondaient, en pratique, à des spectateurs externes du débat, qui faisaient un tweet et étaient retweetés par un de
# leurs rares abonnés. 
# En outre, l'algorithme de Louvain a été appliqué sur ces données afin de mettre en évidence 11 communautés. 
# À ce stade de l'analyse, ces communautés sont simplement étiquetées de 0 à 11 et se trouvent dans modularity_class

requireNamespace("scales")

exported_nodes <- read_csv("gephi/exported_nodes.csv", 
                           col_types = cols(timeset = col_skip(), 
                                            modularity_class = col_factor(levels = c("0", "1", "2", "3", "4", "5", "6","7", "8", "9", "10"))))

# On commence par récupérer le tweet original le plus retweeté pour chaque utilisateur
top_tweet <- planning_full %>%
  group_by(screen_name) %>%
  filter(!grepl("RT",full_text)) %>%
  top_n(n=1, wt=retweet_count)

# Puis on récupère les 5 utilisateurs les plus influents de chaque communauté
# Et on y ajoute le meilleur tweet et la bio twitter
top_5_nodes <- exported_nodes %>%
  group_by(modularity_class) %>%
  top_n(n=5, wt = outdegree) %>%
  left_join(select(top_tweet, full_text, screen_name, description), by = c("Label" = "screen_name"))

# Ensuite, pour s'y retrouver plus facilement, on crée une liste avec les différentes communautés bien séparées
# Les informations des différentes communautés peuvent ensuite être visualisées avec View(communities_list[["x"]])
# Où x est un nombre de 0 à 10 correspondant à la communauté non-nommée. 
# C'est l'examen des informations de cette liste qui permet de nommer les différentes communautés
communities_list <- top_5_nodes %>% 
  group_split(modularity_class) %>% 
  as.list() 
names(communities_list) <- 0:10

# Après avoir inspecté les différentes communautés une à une, le nommage se fait en modifiant le niveau des facteurs 
# des données non-nommées. 
named_communities <- exported_nodes
levels(named_communities$modularity_class) <- c("Militant·e·s féministes et LGBTQIA+", 
                                                "Personnalités et groupes de gauche", 
                                                "Divers gauches", 
                                                "Centre",
                                                "Néoconservateurs",
                                                "Extrême-droite",
                                                "Droite réactionnaire",
                                                "Alt-right",
                                                "Inclassable",
                                                "Conspirationnistes identitaires",
                                                "Rassemblement National")
communities_summary <- named_communities %>%
  group_by(modularity_class) %>%
  summarise(members = n(),
            rt_community = sum(outdegree),
            tweets_community = sum(tweets)) %>%
  mutate(pct_members = scales::percent(members/sum(members), accuracy = 0.1),
         pct_rt = scales::percent(rt_community/sum(rt_community), accuracy = 0.1),
         rrt = rt_community/tweets_community)


