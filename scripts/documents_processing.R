library(tidytext)
library(tidystopwords)
library(ggthemes)

# Ce script vise à préparer les tweets pour la modélisation du sujet du script STM.R
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
                   "même",
                   "affiche",
                   "affiches",
                   "femme",
                   "femmes",
                   "Mme",
                   "enceint",
                   "enceints",
                   "très")

remove_reg <- '&amp;|&lt;|&gt;|[\"]'

titre_articles <- 'Élisabeth Borne, féministes, nous nous inquiétons de ce que devient le Planning familial'


tweets <- planning_full%>% 
  left_join(select(named_communities, Label, modularity_class, outdegree), by = c("screen_name" = "Label")) %>%
  filter(!grepl("RT",full_text),
         !is.na(modularity_class),
         !grepl('withheld', full_text),
         outdegree >= 1,
         lang == "fr") %>%
  mutate(full_text = str_remove_all(full_text, remove_reg),
         full_text = str_remove_all(pattern = titre_articles, full_text),
         tweet_id = row_number()) %>%
  distinct(full_text, .keep_all = TRUE)

tidy_tweets <- tweets  %>%
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

# Ensuite, en vue d'entamer la modélisation des sujets, on débute par créer une matrice creuse avec le texte des tweets
# Ainsi qu'un identifiant pour voir à quel tweet chaque mot appartient.

tidy_sparse <- tidy_tweets %>%
  count(tweet_id, community, word) %>%
  cast_sparse(tweet_id, word, n)