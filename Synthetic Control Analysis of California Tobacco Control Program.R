


library(readr)
library(dplyr)
library(ggplot2)

### 1. Exploratory Analysis

df=read.csv("STRT601-ProblemSet3-DataSet-adh2010.csv")
head(df)

#California

california= df %>% filter(stfips==6)

#National Avg per year
national = df %>%
  group_by(year) %>%
  summarise(avg_cig_sales = mean(cigsales,na.rm = TRUE))

#Join the data
plot_df = california %>%
  select(year, cal_cigsales = cigsales) %>%
  left_join(national, by = "year")

#Plotting Per Capita Cigarette Sales over time

ggplot(plot_df, aes(x = year)) +
  geom_line(aes(y = cal_cigsales, color = "California"), linewidth = 1.2) +
  geom_line(aes(y = avg_cig_sales, color = "National Average"),
            linewidth = 1.2, linetype = "dashed") +
  labs(
    title = "Per-Capita Cigarette Sales: California vs. National Average",
    x = "Year", y = "Per Capita Sales", color = ""
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

#When plotting the capital purchases over time we can see a sharp decline for both California and National Average. 
#The Differences-in-differences (DID) would probably not be the best approach to recover the causal effect of California's tobacco control program. 
#The DID works only if before the policy California and the control group were moving in parallel as if they were moving the same way over time without the policy. 
#As per this data California seems to be consistently lower than the national average and before the 1988 paths aren't in parallel which would break the key DID assumption. 
#The DiD would likely be biased.


### 2. Synthetic Control Construction

install.packages("Synth")
library(Synth)

install.packages("dataprep")
library(dataprep)

summary(df)

other_states <- df %>% filter(stfips != 6) %>% distinct(stfips) %>% pull(stfips)
pre_years    <- 1980:1988
time_plot    <- 1970:1997

dataprep_out <- Synth::dataprep(
  foo = df,
  unit.variable = "stfips",
  time.variable = "year",
  treatment.identifier = 6,
  controls.identifier  = other_states,
  dependent = "cigsales",
  predictors = "price",
  predictors.op = "mean",
  time.predictors.prior = pre_years,
  special.predictors = list(
    list("cigsales", 1980, "mean"),
    list("cigsales", 1988, "mean")
  ),
  time.optimize.ssr = pre_years,
  time.plot = time_plot
)

synth_out = synth(dataprep_out)

### 3. Model Evaluation

synth_tables <- synth.tab(dataprep.res = dataprep_out,
                          synth.res =synth_out)

synth_tables


#The first table shows the average values for price, cigarette sales in 1980, and cigarette sales in 1988 over the pre teatment period. These average values are for our treated group(California), Synthetic California, and the Sample mean which is the average across all control groups, in other words, the National Average. 
#The Synthetic control group resembles California more than the National Average. We see this because the average values of our Synthetic Control and California are almost identical bar the average value for cigarette sales in 1980 which is slightly lower in our Synthetic control but much closer than the National Average.
#The second table shows the weights of each characteristic. 87.3% of the variable weight is on price. 0.08% is on cigarette sales in 1980, and 11.9% is on cigarette sales in 1988.
#The third table shows the weights on each state in our synthetic control, the state with the highest weight is FIPS code 35 which is New Mexico at 38.6%.


### 4. Treatment Effect Estimation

#Cigarette Purchases over time for California and Synthetic California. Vertical line in 1989, marking adoption of Tobacco Control Program.

path.plot(synth.res=synth_out, dataprep.res = dataprep_out,
          Ylab= "Outcome", Xlab = " ",
          Legend = c("California", "Synthetic California"),
          Legend.position = "bottomright")
abline(v = 1989,col = "red")

#Gaps plot
gaps.plot(synth_out,dataprep_out)
abline(v=1989, col = "red")


#These path plot shows us that in our pre treatment years, 1980-1988, the cigarette sales of California and Synthetic California are close together. 
#After 1989, represented by the red line and the year tobacco control program is adopted, there is a big difference in cigarette sales in California compared to our Synthetic California(the counterfactual of what if California did not adopt the program). 
#The gaps plot is a closer look at the difference and we can see that after the adoption of the policy, cigarettes sales decline and remain negative.

### 5. Inference

#install.packages("SCtools")
install.packages("furrr")
library(furrr)
library(SCtools)
placebos <- generate.placebos(dataprep_out,synth_out)
plot_placebos(placebos,discard.extreme = FALSE)

head(placebos$df)


#Post Treatment MSPEs

treat_gap <- placebos$df[20:28,"Y1"]-placebos$df[20:28,"synthetic.Y1"]
treat_mspe <- mean(treat_gap^2)

placebo_gaps<- as.matrix(placebos$df[20:28,29:56]- placebos$df[20:28,1:28])
placebo_mspe <- as.vector(colMeans(placebo_gaps^2))

print(treat_mspe)

print(sort(placebo_mspe))


#To assess statistical significance, we have to use placebos. What we are doing above is assuming that the treatment affected one control group, doing a synthetic control analysis for that group and then repeating that process on all the other control groups.
#In other words, we are pretending that each state was treated in 1989 and running the same synthetic control analysis. 
#If we see that the effects on the actual treated group are big compared to the placebo treated groups, we can say it is statistically signicant. 
#If the placebos have effects as large as what we see in our treated group then we can conclude the effects happened due to chance.

#The plot we generate shows the gap in per capita cigarette purchases(actual -synthetic) of our placebo states in gray and California in black. 
#In this plot, we can see that California is below many of the placebo states after the adoption of the program. We do see though, that there are placebo states that are not near our pre teatment outcomes for California. 
#We can use mspe.limit to exclude these plots, instead, we decided to go ahead and use the data within our placebos to look at the post treatment MSPE. Looking at our treated MSPE compared to our placebo MSPE, we see that it is much greater than all but four of our placebo states. 
#Those four states have high pre-MSPE so we would have likely excluded those states. 
#In conclusion, we have statistical significance because our treated MSPE of 349.65 is much greater than almost all of our placebo states.