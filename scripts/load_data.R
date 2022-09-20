# Ce script permet de récupérer les données générées par le script "get_tweets.R" et sauvegardées au format .RData. 
# Cela permet d'éviter de relancer la recherche, ce qui serait impossible au vu des limitations de l'API twitter



load("./data/hashtag_tweets.RData")
load("./data/hashtag_user_tweets.RData")

load("./data/planning_tweets_new.RData")
load("./data/planning_tweets.RData")
load("./data/planning_tweets_older.RData")
load("./data/planning_tweets_oldest.RData")

load("./data/planning_user_tweets_new.RData")
load("./data/planning_user_tweets.RData")
load("./data/planning_user_tweets_older.RData")
load("./data/planning_user_tweets_oldest.RData")
