library(dplyr)
library(ggplot2)
library(lubridate)
library(reticulate)
library(tidyr)

use_virtualenv('/Users/riddleta/Desktop/misc_py3_env/')
source_python('/Users/riddleta/Desktop/pickel_reader.py')

pickle_data <- read_pickle_file("/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/testdat.pkl")


pickle_data %>%
  select(doi, date) %>%
  mutate(date = as_date(date)) %>%
  mutate(year = year(date),
         month = month(date)) %>%
  distinct() %>%
  group_by(year) %>%
  summarise(n_papes = n()) %>%
  select(year, n_papes) %>%
  ungroup() %>%
  ggplot(aes(x=year, y=n_papes, group=1)) + 
  geom_line()

pickle_data %>%
  select(doi, date) %>%
  mutate(date = as_date(date)) %>%
  distinct() %>%
  arrange(desc(date)) %>%
  head(.)

pickle_data %>%
  select(discipline, date, institution, doi) %>%
  distinct() %>%
  mutate(date = as_date(date)) %>%
  mutate(year = year(date)) %>%
  group_by(year, discipline, institution) %>%
  summarise(n_obs = n()) %>%
  ungroup() %>%
  group_by(year, discipline) %>%
  mutate(total_papes = sum(n_obs)) %>%
  mutate(prop_papes = n_obs/total_papes) %>%
  ungroup() %>%
  filter(year>1990, total_papes>50) -> year_disc_summaries

year_disc_summaries %>%
  group_by(discipline) %>%
  mutate(total_disc_papes = sum(n_obs)) %>%
  ungroup() %>%
  select(discipline, total_disc_papes) %>%
  distinct() -> papes_by_disc

year_disc_summaries %>%
  group_by(year, discipline) %>%
  summarise(disc_diversity = sum(prop_papes^2)) %>%
  ungroup() -> year_div

ggplot(year_div, aes(x=year, y=disc_diversity, group=discipline)) + geom_line()

year_div %>%
  filter(discipline %in% c('Artificial intelligence', 'Bioinformatics', 'Biology', 'Ecology', 
                           'Economics', 'Genetics', 'Machine learning', 'Physics', 'Psychology')) %>%
  ggplot(aes(x=year, y=disc_diversity)) + geom_line() + facet_wrap(~discipline)

papes_by_disc %>%
  filter(total_disc_papes>2000) %>%
  select(discipline) %>%
  distinct() -> disc

year_div %>%
  filter(discipline %in% disc$discipline)  %>%
  ggplot(aes(x=year, y=disc_diversity, group=discipline)) + geom_line() + facet_wrap(~discipline)

# might be worthwhile to assess how many people are working in a field. this is a proxy for competition. maybe try to associate it with grant funding?

df <- rbind(read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_01.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_02.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_03.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_04.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_05.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_06.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_07.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_08.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_09.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_10.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_11.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_12.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_13.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_14.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_15.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_16.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_17.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_18.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_19.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_20.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_21.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_22.csv'),
           read.csv('/Users/riddleta/Desktop/promethium/home/riddleta/ac_knowl/output/bionlp_23.csv'))

df %>%
  select(-X, -idx) %>%
  distinct() -> df

table(df$yr)
hist(df$yr, breaks=50)

table(df$git_hits)
table(df$osf_hits)
table(df$nda_hits)
table(df$open_neuro)
table(df$fmri)

df %>%
  filter(git_hits>0) %>%
  group_by(yr) %>%
  summarise(papes = n()) %>%
  ggplot(aes(x=yr, y=papes)) + 
  geom_bar(stat='identity')
