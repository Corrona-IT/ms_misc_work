nmo_dir <- "~/../../Corrona LLC/Biostat Data Files - NMO/"


df.inc <- read_rds(glue("{analytic_data}/exinstances.rds"))
df.exp <- read_rds(glue("{analytic_data}/exdrugexp.rds"))


uplizna.inc <- df.inc %>% 
  select(id, enrolldate, drug, instance, init, drug_dt, rectype,
         dose,
         dose_units, freq,freq_units) %>% 
  filter(drug == "uplizna")
uplizna.w2doses <- subset_function(df.exp, "uplizna")

uplizna.inc <- df.inc %>% 
  select(id, enrolldate, drug, instance, init, drug_dt, rectype,
         dose,
         dose_units, freq,freq_units) %>% 
  filter(drug == "uplizna")
uplizna.inc <- df.inc %>% 
  select(id, enrolldate, drug, instance, init, drug_dt, rectype,
         dose,
         dose_units, freq,freq_units) %>% 
  filter(drug == "uplizna") %>% 
  filter(id %in% uplizna.exp$id)


uplizna.exp.sub <- df.exp %>% 
  select(id, enrolldate, drug, st_dt, stp_dt,
         dose,freq,freq_units) %>% 
  filter(drug == "uplizna") %>% 
  filter(id %in% uplizna.exp$id)
uplizna.exp <- df.exp %>% 
  select(id, enrolldate, drug, st_dt, stp_dt,
         dose,freq,freq_units) %>% 
  filter(drug == "uplizna")

uplizna.inc.multi.row <- uplizna.inc %>% 
  mutate(
    .by = c(id),
    tot = n(),
    rn  = row_number()
  ) %>% 
  filter(tot > 1) %>% 
  mutate(
    w2d = ifelse(id %in% uplizna$id,
                 1,
                 0)
  ) %>% 
  select(w2d, everything())

uplizna.inc.multi.row %>% filter(!id %in% uplizna.exp.sub$id) %>% View()


write.csv(uplizna, file = "~/../Desktop/temp/uplizna.csv")

write.csv(uplizna.inc.multi.row, file = "~/../Desktop/temp/uplizna.all.csv")
