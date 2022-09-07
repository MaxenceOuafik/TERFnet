nodes_label <- planning_full %>%
  select(id_str_user, screen_name) %>%
  rename(Label = screen_name) %>%
  distinct(Label) %>%
  rowid_to_column() %>%
  mutate(Id = rowid - 1) %>%
  select(-rowid)

nodes <- edgelist %>%
  group_by(from) %>%
  summarise(Weight = n()) %>% 
  rename(Label = from) %>%
  right_join(nodes_label, by = "Label")

nodes[is.na(nodes)] = 0

write.csv(nodes, file = "./output/nodes.csv", row.names = F)
