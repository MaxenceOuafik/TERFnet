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



edgelist <- edgelist_label %>%
  left_join(nodes, by = c("from" = "Label")) %>%
  rename(Source = Id) %>%
  select(Source, to) %>%
  left_join(nodes, by = c("to" = "Label")) %>%
  rename(Target = Id) %>%
  select(Source, Target) %>%
  filter(!is.na(Source))

write.csv(edgelist, file = "./output/edgelist.csv", row.names = F)


