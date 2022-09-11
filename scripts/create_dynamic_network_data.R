library(lubridate)

timeframe_nodes <- planning_full %>%
  select(screen_name, created_at) %>%
  mutate(date = as_datetime(created_at)) %>%
  arrange(date) %>% 
  filter(as_date(date) >= as_date("2022-08-17")) %>%
  right_join(named_communities, by = c("screen_name" = "Label")) %>%
  distinct(screen_name, .keep_all = TRUE) %>%
  select(screen_name, date, Id, modularity_class, outdegree) %>%
  rename(Label = screen_name)

write.csv(timeframe_nodes, file = "./output/nodes_timeframe.csv",  row.names = F)
