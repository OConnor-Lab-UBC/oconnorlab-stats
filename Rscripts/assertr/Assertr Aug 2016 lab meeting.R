### Assertr Tutorial
### Aug 17 2016, Joey in lab meeting
### Mary's notes

library(gapminder)
library(dplyr)
library(assertr)

head(gapminder)

str(gapminder)

gapminder %>%   #take gapminder, then
  str           # stri it

gapminder %>%
  verify(nrow(.) == 1704) %>%  # each line here is an "assertion"
  verify(ncol(.) == 6) %>%
  verify(is.factor(.$continent)) %>%
  verify(length(levels(.$continent)) == 5)  ## if all of these are true, then you get the dataset you started with. 
  
gapminder %>%
  verify(lifeExp > 30) # this tells us how many rows/years had life expectancy < 30

## we want to test that assertion at life expectancy should be > 30
gapminder %>%
  assert(within_bounds(0, Inf), lifeExp:gdpPercap)  # evaluates to TRUE if the number of pop is between 0 and INF

## side note: dplyr allows you to select multiple columns (lifeExp:gdpPercap)

all_continents <- levels(gapminder$continent)

gapminder %>%   ## command shift m is the shortcut
  ## check for missing values
  assert(not_na, country:gdpPercap) %>%
  assert(in_set(all_continents), continent)  # checking whether all the entries in continent are from the list all_continents

## add a mistake to see if we can find it
gapminder_mistake <- gapminder
levels(gapminder_mistake$continent)[levels(gapminder_mistake$continent) == "Africa"] <- "Afrrica"

## now let's see if we can find the mistake
gapminder_mistake %>%   ## command shift m is the shortcut
  ## check for missing values
  assert(not_na, country:gdpPercap) %>%
  assert(in_set(all_continents), continent)  # checking whether all the entries in continent are from the list all_continents

## create a predicate function (or something that evaluates to true or false)
is_greater_than_zero <- function(x) is.numeric(x) & x > 0

gapminder %>%
  assert(is_greater_than_zero, country, continent)


## challenge

new.data <- read.csv("./Rscripts/assertr/gapminder_2016.csv", sep = ',')

new.data %>%
  assert(within_bounds(0, Inf), lifeExp:gdpPercap) 

new.data %>%   ## command shift m is the shortcut
  assert(not_na, country:gdpPercap) %>%
  assert(in_set(all_continents), continent) 


