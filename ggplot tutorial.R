### lab meeting June 3

install.packages("gapminder")
library(ggplot2)
library(gapminder)
head(gapminder)

ggplot(data=gapminder, aes(x = lifeExp, y = gdpPercap)) + geom_point()


ggplot(data=gapminder, aes(x = year, y = lifeExp)) + geom_point()
ggplot(data=gapminder, aes(x = year, y = lifeExp, by = country)) + 
  geom_line(aes(color = continent)) + 
  geom_point()

plot1 <- ggplot(data = gapminder, aes(x = lifeExp, y = gdpPercap)) +
  geom_point(color = "blue", size = 1) + 
  scale_y_log10() +
  geom_smooth(method = "lm", size = 1.5, color = "seagreen")

ggplot(data = gapminder, aes(x = year, y = lifeExp, group = country, color = continent)) +
  geom_line() +
  facet_wrap( ~ continent) +
  xlab("Year") + 
  ylab("Life expectancy") +
  ggtitle("Figure 1") +
  theme_bw() + 
  theme(axis.text=element_text(size=8), 
        axis.title=element_text(size=16, face = "bold"))
ggsave("figure1.png")


notes: 
  dplyr::select()
group_by(variables)
summarise_each(funs(mean, meadian)))
