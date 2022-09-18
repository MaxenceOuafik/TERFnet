# Ce script vise à analyser le contenu des tweets via la technique de la STM (Structural Topic Models) 
# pour déterminer quels sont les sujets qui reviennent le plus et quelles communautés tendent à s'exprimer de la sorte

# Le paramètre le plus important est le nombre de sujets contenus dans la modélisation. Sans forte idée a priori, 
# j'ai entraîné le modèle avec une plusieurs possibilités, de 5 à 20 sujets afin de déterminer les plus adéquats
# Après avoir déjà entraîné et testé le modèle plusieurs fois, j'avais pu constater que le nombre idéal
# était aux alentours de 5-15, avec un meilleur compromis entre la cohérence sémantique et l'exclusivité
# pour 10 ou 15. J'ai donc multiplié les résultats entre 10 et 15 pour essayer d'affiner les résultats

library(stm)
library(furrr)

set.seed(5)
plan(multisession)
models_evaluation <- data_frame(K = c(10, 11, 12, 13, 14, 15)) %>%
  mutate(topic_model = future_map(K, ~ stm(tidy_sparse,
                                           K = .,
                                           data = tidy_tweets %>% distinct(user, tweet_id, community) %>% arrange(community),
                                           prevalence = ~ community,
                                           init.type = "Spectral",
                                           verbose = TRUE),
                                  .options = furrr_options(seed = 5)))

save(models_evaluation, file = "./output/models_evaluation.RData")
