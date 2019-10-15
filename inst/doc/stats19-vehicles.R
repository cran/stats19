## ---- include = FALSE----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message=FALSE------------------------------------------------
library(stats19)
library(dplyr)

## ------------------------------------------------------------------------
v = get_stats19(year = 2017, type = "vehicles")
v

## ------------------------------------------------------------------------
v = v %>% mutate(vehicle_type2 = case_when(
  grepl(pattern = "motorcycle", vehicle_type, ignore.case = TRUE) ~ "Motorbike",
  grepl(pattern = "Car", vehicle_type, ignore.case = TRUE) ~ "Car",
  grepl(pattern = "Bus", vehicle_type, ignore.case = TRUE) ~ "Bus",
  grepl(pattern = "cycle", vehicle_type, ignore.case = TRUE) ~ "Cycle",
  # grepl(pattern = "Van", vehicle_type, ignore.case = TRUE) ~ "Van",
  grepl(pattern = "Goods", vehicle_type, ignore.case = TRUE) ~ "Goods",
  
  TRUE ~ "Other"
))
# barplot(table(v$vehicle_type2))

## ------------------------------------------------------------------------
table(v$vehicle_type2)
summary(v$age_of_driver)
summary(v$engine_capacity_cc)
table(v$propulsion_code)
summary(v$age_of_vehicle)

## ------------------------------------------------------------------------
a = get_stats19(year = 2017, type = "accidents")
va = dplyr::inner_join(v, a)

## ------------------------------------------------------------------------
dim(v)
dim(va)

## ---- out.width="100%"---------------------------------------------------
xtabs(~vehicle_type2 + accident_severity, data = va) %>% prop.table()
xtabs(~vehicle_type2 + accident_severity, data = va) %>% prop.table() %>% plot()

## ---- echo=FALSE, eval=FALSE---------------------------------------------
#  table_vehicle_type = xtabs(cbind(accident_severity, vehicle_type) ~ accident_severity, data = va)
#  va %>%
#    group_by(accident_severity) %>%
#    summarise()
#  
#  fit = glm(data = va, factor(accident_severity) ~
#              engine_capacity_cc +
#              age_of_driver +
#              engine_capacity_cc +
#              factor(propulsion_code) +
#              age_of_vehicle
#            )
#  nnet::multinom(formula = accident_severity ~
#              engine_capacity_cc +
#              age_of_driver +
#              engine_capacity_cc +
#              propulsion_code +
#              age_of_vehicle, data = va)
#  mnl

