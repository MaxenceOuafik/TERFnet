library(tidyverse)
planning_tweets_full <- planning_tweets %>%
  bind_rows(planning_tweets_new) %>%
  bind_rows(planning_tweets_older) %>%
  bind_rows(planning_tweets_oldest) 

planning_tweets_full <- planning_tweets_full %>%
  select(- possibly_sensitive) %>%
  bind_rows(select(hashtag_tweets, - possibly_sensitive))


planning_users_full <- planning_user_tweets %>%
  bind_rows(planning_user_tweets_new) %>%
  bind_rows(planning_user_tweets_older) %>%
  bind_rows(planning_user_tweets_oldest) %>%
  rename(id_str_user = id_str,
         created_at_userV = created_at)

planning_users_full <- planning_users_full %>%
  bind_rows(hashtag_user_tweets) 


planning_full <- cbind(planning_tweets_full, planning_users_full)%>%
  select(1, 3, 4, 20, 25, 44:46, 48, 51, 52)
  

rm(list = c("planning_tweets",
           "planning_tweets_new",
           "planning_tweets_older",
           "planning_tweets_oldest",
           "planning_user_tweets",
           "planning_user_tweets_new",
           "planning_user_tweets_older",
           "planning_user_tweets_oldest",
           "hashtag_tweets",
           "hashtag_user_tweets"))
