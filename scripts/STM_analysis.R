library(stm)
library(furrr)
# On commence par importer le modèle généré dans le script STM.R
models_evaluation <- readRDS("./output/models_evaluation.rds")

# On calcule ensuite certaines mesures qui permettent d'évaluer les modèles
heldout <- make.heldout(tidy_sparse)

k_result <- models_evaluation %>%
  mutate(exclusivity = map(topic_model, exclusivity),
         semantic_coherence = map(topic_model, semanticCoherence, tidy_sparse),
         eval_heldout = map(topic_model, eval.heldout, heldout$missing),
         residual = map(topic_model, checkResiduals, tidy_sparse),
         bound =  map_dbl(topic_model, function(x) max(x$convergence$bound)),
         lfact = map_dbl(topic_model, function(x) lfactorial(x$settings$dim$K)),
         lbound = bound + lfact,
         iterations = map_dbl(topic_model, function(x) length(x$convergence$bound)))

# La visualisation de ces mesures permet d'estimer que le nombre de sujets idéaux se situe aux alentours de 5-10

k_result %>%
  transmute(K,
            `Lower bound` = lbound,
            Residuals = map_dbl(residual, "dispersion"),
            `Semantic coherence` = map_dbl(semantic_coherence, mean),
            `Held-out likelihood` = map_dbl(eval_heldout, "expected.heldout")) %>%
  gather(Metric, Value, -K) %>%
  ggplot(aes(K, Value, color = Metric)) +
  geom_line(size = 1.5, alpha = 0.7, show.legend = FALSE) +
  facet_wrap(~Metric, scales = "free_y") +
  scale_x_continuous(breaks = 5:20) +
  labs(x = "K (number of topics)",
       y = NULL,
       title = "Diagnostics du modèle, par nombre de sujets",
       subtitle = "Le nombre adéquat de sujets semble être aux alentours de 12-15")

# La cohérence sémantique est une mesure qui est plus élevée lorsque les mots les plus probables dans un sujet
# sont souvent présents en même temps dans un document. Cependant, vu le faible nombre de sujets dans cette analyse, 
# La valeur peut être artificiellement gonflée. Il est donc intéressant de regarder également l'exclusivité, qui 
# est plus élevée lorsque les mots dans un sujet tendent à être exclusifs à ce sujet, et de trouver le meilleur compromis

k_result %>%
  select(K, exclusivity, semantic_coherence) %>%
  filter(K %in% 10:15) %>%
  unnest() %>%
  mutate(K = as.factor(K)) %>%
  ggplot(aes(semantic_coherence, exclusivity, color = K)) +
  geom_point(size = 2, alpha = 0.7) +
  labs(x = "Semantic coherence",
       y = "Exclusivity",
       title = "Comparaison entre cohérence sémantique et exclusivité",
       subtitle = "Le meilleur compromis semble être 12")

# En prenant en compte les deux graphiques, la solution à 12 sujets a été retenue comme meilleur compromis entre 
# les différentes valeurs diagnostiques

topic_model <- k_result %>% 
  filter(K == 12) %>% 
  pull(topic_model) %>% 
  .[[1]]

# On peut ensuite évaluer le bêta, qui correspond à la probabilité qu'un mot se trouve dans un sujet particulier

td_beta <- tidy(topic_model)

# Ainsi que gamma, qui correspond à la probabilité qu'un tweet appartienne à un sujet

td_gamma <- tidy(topic_model, matrix = "gamma",
                 document_names = rownames(tidy_sparse))

# On combine ensuite les deux pour visualiser les sujets les plus présents et les mots qui ont le plus de chance
# d'en faire partie

top_terms <- td_beta %>%
  arrange(beta) %>%
  group_by(topic) %>%
  top_n(7, beta) %>%
  arrange(-beta) %>%
  select(topic, term) %>%
  summarise(terms = list(term)) %>%
  mutate(terms = map(terms, paste, collapse = ", ")) %>% 
  unnest(cols = c(terms))

gamma_terms <- td_gamma %>%
  group_by(topic) %>%
  summarise(gamma = mean(gamma)) %>%
  arrange(desc(gamma)) %>%
  left_join(top_terms, by = "topic") %>%
  mutate(topic = paste0("Topic ", topic),
         topic = reorder(topic, gamma))

gamma_plot <- gamma_terms %>%
  top_n(20, gamma) %>%
  ggplot(aes(topic, gamma, label = terms, fill = topic)) +
  geom_col(show.legend = FALSE) +
  geom_text(hjust = 0, nudge_y = 0.0005, size = 3,
            family = "IBMPlexSans") +
  coord_flip()  +
  scale_y_continuous(expand = c(0,0),
                     limits = c(0, 0.2),
                     labels = scales::percent_format()) +
  theme_tufte(base_family = "IBMPlexSans", ticks = FALSE) +
  theme(plot.title = element_text(size = 16,
                                  family="IBMPlexSans-Bold"),
        plot.subtitle = element_text(size = 13)) +
  labs(x = NULL, y = expression(gamma),
       title = "Sujets, par prévalence, dans le corpus de tweets",
       subtitle = "Accompagnés des mots principaux dans chaque sujet")

ggsave(gamma_plot, 
       file = "./output/plots/gamma_plot.png",
       device = "png",
       dpi = 300,
       scale = 2,
       bg = "white")

tweets1 <- tweets %>%
  mutate(tweet_id = as.character(tweet_id))

topic_tweets <- list()
for (i in 1:12) {
  topic_tweets[[i]] <- td_gamma %>%
    filter(topic == i) %>%
    top_n(10, gamma) %>%
    left_join(select(tweets1, full_text, tweet_id), by = c ("document" = "tweet_id"))
}
