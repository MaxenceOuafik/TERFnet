
# Recherche de tous les tweets contenant "planning familial" et sauvegarde dans un fichier .RData.
# La recherche a initialement été menée le 24/08/22 et a été répétée plusieurs fois de manière à récupérer 
# la totalité des tweets depuis la publication de l'article, ainsi que les tweets ultérieurs à la recherche.
# ATTENTION : vu les limites temporelles de l'API, lancer ce script à nouveau téléchera des tweets plus récents que 
# ceux coïncidant avec la période d'intérêt. L'objectif de ce script est uniquement de montrer la stratégie de

planning_tweets <- search_tweets('"planning familial"',
                                 n = Inf,
                                 include_rts = TRUE,
                                 retryonratelimit = TRUE,
                                 verbose = TRUE
              )

save(planning_tweets, file = "./data/planning_tweets.RData")

planning_tweets_new <- search_tweets('"planning familial"',
                                 n = Inf,
                                 include_rts = TRUE,
                                 retryonratelimit = TRUE,
                                 verbose = TRUE,
                                 since_id = planning_tweets$id_str
)

save(planning_tweets, file = "./data/planning_tweets.RData")


planning_tweets_older <- search_tweets('"planning familial"',
                                 n = Inf,
                                 include_rts = TRUE,
                                 retryonratelimit = TRUE,
                                 verbose = TRUE,
                                 max_id = planning_tweets$id_str
)



save(planning_tweets_older, file = "./data/planning_tweets_older.RData")


planning_tweets_oldest <- search_tweets('"planning familial"',
                                       n = Inf,
                                       include_rts = TRUE,
                                       retryonratelimit = TRUE,
                                       verbose = TRUE,
                                       max_id = planning_tweets_older$id_str
)
save(planning_tweets_oldest, file = "./data/planning_tweets_oldest.RData")


# La recherche a ensuite été répétée pour inclure les tweets avec le #PlanningFamilial

hashtag_tweets <- search_tweets('"#PlanningFamilial"',
                                 n = Inf,
                                 include_rts = TRUE,
                                 retryonratelimit = TRUE,
                                 verbose = TRUE
)

save(hashtag_tweets, file = "./data/hashtag_tweets.RData")

# Par la suite, les informations relatives aux utilisateurs ont été récupérées et sauvegardées

planning_user_tweets_new <- users_data(planning_tweets_new)
planning_user_tweets <- users_data(planning_tweets)
planning_user_tweets_older <- users_data(planning_tweets_older)
planning_user_tweets_oldest <- users_data(planning_tweets_oldest)
hashtag_user_tweets <- users_data(hashtag_tweets)


save(planning_user_tweets_new, file = "./data/planning_user_tweets_new.RData")
save(planning_user_tweets, file = "./data/planning_user_tweets.RData")
save(planning_user_tweets_older, file = "./data/planning_user_tweets_older.RData")
save(planning_user_tweets_oldest, file = "./data/planning_user_tweets_oldest.RData")
save(hashtag_user_tweets, file = './data/hashtag_user_tweets.RData')


