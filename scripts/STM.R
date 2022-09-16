# Ce script vise à analyser le contenu des tweets via la technique de la STM (Structural Topic Models) 
# pour déterminer quels sont les sujets qui reviennent le plus et quelles communautés tendent à s'exprimer de la sorte

library(stm)
library(tidytext)
library(tidystopwords)
library(furrr)
library(ggthemes)


# La première étape consiste simplement à récupérer les données adéquates pour ce travail. Pour ce faire, j'ai choisi
# de n'inclure que les tweets dont l'utilisateur avait identifié dans une communauté (et donc pas les tweets
# des gens qui gravitaient autour du réseau sans lien direct) et de ne pas inclure les retweets. 
# En outre, les données ont été nettoyées de telle façon à ce que chaque ligne corresponde à un seul mot et les stopwords 
# ont été supprimés

tidy_swords <- generate_stoplist(language = "French",
                                 output_form = 1)

custom_swords <- c("planning",
                   "planningfamilial", 
                   "leplanning", 
                   "familial", 
                   "c'est", 
                   "cest", 
                   "être", 
                   "fait", 
                   "sest",
                   "dune",
                   "sait", 
                   "quand",
                   "plus",
                   "peuvent",
                   "rien",
                   "non",
                   "aussi",
                   "alors",
                   "peut",
                   "parce",
                   "comme",
                   "cétait",
                   "aton",
                   "#planningfamilial",
                   "nai",
                   "quil",
                   "jai",
                   "va",
                   "nest",
                   "là",
                   "na",
                   "peu",
                   "dit",
                   "quun",
                   "quon",
                   "quil",
                   "quils",
                   "mme",
                   "pf",
                   "homme",
                   "hommes",
                   "faut",
                   "pas",
                   "même")


remove_reg <- "&amp;|&lt;|&gt;"

tidy_tweets <- planning_full%>% 
  left_join(select(named_communities, Label, modularity_class, outdegree), by = c("screen_name" = "Label")) %>%
  filter(!grepl("RT",full_text),
         !is.na(modularity_class),
         !grepl('witheld', full_text),
         outdegree >= 1) %>%
  mutate(full_text = str_remove_all(full_text, remove_reg),
         tweet_id = row_number()) %>%
  distinct(full_text, .keep_all = TRUE) %>%
  unnest_tokens(word, full_text, token = "tweets") %>%
  filter(!word %in% tidy_swords,
         !word %in% custom_swords,
         !word %in% str_remove_all(tidy_swords, "'"),
         str_detect(word, "[a-z]"),
         !grepl("https", word),
         !grepl("@", word),
         modularity_class != "Inclassable",
         modularity_class != "Divers gauches") %>%
 select(screen_name, word, modularity_class, tweet_id) %>%
  rename(community = modularity_class,
         user = screen_name)

# On profite d'avoir des données propres pour faire un peu de data mining afin de voir quels sont les mots
# les plus fréquents dans chaque communauté

tidy_plot <- tidy_tweets %>%
  group_by(community) %>%
  count(word, sort = TRUE) %>%
  top_n(5) %>%
  mutate(word = reorder(word,n)) %>%
  ggplot(aes(n, reorder_within(word, n, community), fill = community)) +
  scale_y_reordered() +
  geom_col(show.legend = FALSE) +
  facet_wrap(vars(community), scales = "free_y") 

# Ensuite, la vraie modélisation des sujets commence. On débute par créer une matrice creuse avec le texte des tweets
# Ainsi qu'un identifiant pour voir à quel tweet chaque mot appartient.

tidy_sparse <- tidy_tweets %>%
  count(tweet_id, community, word) %>%
  cast_sparse(tweet_id, word, n)

# Le paramètre le plus important est le nombre de sujets contenus dans la modélisation. Sans forte idée a priori, 
# j'ai entraîné le modèle avec une plusieurs possibilités, de 5 à 20 sujets afin de déterminer les plus adéquats
# Après avoir déjà entraîné et testé le modèle plusieurs fois, j'avais pu constater que le nombre idéal
# était aux alentours de 5-15, avec un meilleur compromis entre la cohérence sémantique et l'exclusivité
# pour 10 ou 15. J'ai donc multiplié les résultats entre 10 et 15 pour essayer d'affiner les résultats

plan(multiprocess)
models_evaluation <- data_frame(K = c(5, 10, 11, 12, 13, 14, 15, 20)) %>%
  mutate(topic_model = future_map(K, ~ stm(tidy_sparse,
                                           K = .,
                                           data = tidy_tweets %>% distinct(user, tweet_id, community) %>% arrange(community),
                                           prevalence = ~ community,
                                           init.type = "Spectral",
                                           verbose = TRUE),
                                  .options = furrr_options(seed = 5)))

save(models_evaluation, file = "./output/models_evaluation.RData")