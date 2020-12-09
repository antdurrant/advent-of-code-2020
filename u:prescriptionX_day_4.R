# Libraries and Setup####

library(utilitarian)
libraries(dplyr, readr, tidyr, stringr, purrr)

reqfields <- tibble(field = c("byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid"))

# Get Data ####

# Raw input as previewed above

# Used sed on CL to replace whitespace with a newline: sed -ibak 's/ /\n/g' 4-input.txt
#raw <- readLines("data/4-example.txt")
raw <- readLines("data/day_4data.txt")

l <- split(raw, cumsum(raw == ""))

l <-
  map(l, ~ .x[str_detect(.x, ":")] %>%
        as_tibble() %>%
        separate(value, into = c("field", "value")))


# map_int(l, nrow) %>% summary()

dat <-
  bind_rows(l, .id = "Passport") %>%
  mutate(Passport = as.numeric(Passport)+1) %>%
  full_join(reqfields, by = "field") %>%
  complete(Passport, field)  # Fill in missing fields based on what's available in field

View(dat)
tail(dat)

bad <-
  dat %>%
  filter(is.na(value)) %>%
  filter(field != "cid") %>%
  pull(Passport)

length(unique(bad))

filter(dat, Passport %in% bad) %>%
  pivot_wider(id_cols = "Passport", names_from = "field", values_from = "value") %>% View()
