from <- list()
for (i in 1:50264) {
  from[i] <- planning_full[["retweeted_status"]][[i]][["user"]][["screen_name"]]
}

to <- list()
for (i in 1:50264){
  to[i] <- planning_full[["screen_name"]][[i]]
}

edgelist_label <- data.frame(unlist(from), unlist(to))%>%
  rename(from = unlist.from.,
         to = unlist.to.) %>%
  filter(!is.na(from)) 

tweets <- planning_full %>%
  group_by(screen_name) %>%
  summarise(tweets = length(unique(id_str)))

retweets <- edgelist_label %>%
  group_by(from) %>%
  mutate(retweets = n()) %>%
  distinct(from, .keep_all = T) 


nodes<- planning_full %>%
  select(screen_name) %>%
  rename(Label = screen_name) %>%
  rowid_to_column() %>%
  mutate(Id = rowid - 1) %>%
  select(-rowid) %>%
  distinct(Label, .keep_all = T) %>%
  left_join(tweets, by = c("Label" = "screen_name")) %>%
  left_join(select(retweets, c("from", "retweets")), by = c("Label" = "from")) %>%
  replace_na(list(retweets = 0)) %>%
  mutate(rRT = retweets/tweets)

edgelist <- edgelist_label %>%
  left_join(nodes, by = c("from" = "Label")) %>%
  rename(Source = Id) %>%
  select(Source, to) %>%
  left_join(nodes, by = c("to" = "Label")) %>%
  rename(Target = Id) %>%
  select(Source, Target) %>%
  filter(!is.na(Source))

write.csv(edgelist, file = "./output/edgelist.csv", row.names = F)
write.csv(nodes, file = "./output/nodes.csv", row.names = F)

rm(list = c("edgelist_label",
            "from",
            "to",
            "retweets",
            "tweets",
            "i"))
