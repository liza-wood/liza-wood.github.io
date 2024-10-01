library(lme4)
library(plm)
df <- data.frame('district' = rep(1:533, each = 4),
           'election_year' = rep(c(2010, 2015, 2017, 2019), 533),
           'post_el_time_per' = rep(c('2010-22014', '2015-2016',
                                      '2017-2018', '2019-2020'), 533),
           'n_proj' = sample(0:20, 533*4, replace = T),
           
           'con_share' = sample(0:100, 533*4, replace = T))
df$lab_share <- 100-df$con_share
df$lab_share <- ifelse(df$lab_share < 20, df$lab_share, df$lab_share-20)
df$n_proj_before <- ifelse(df$election_year == 2010, mean(df$n_proj),
                           NA)
for(i in 1:nrow(df)){
  if(!is.na(df$n_proj_before[i])){ next }
  df$n_proj_before[i] <- df$n_proj[(i-1)]
}

df$n_proj_before_s <- c(scale(df$n_proj_before))
df$con_share_s <- c(scale(df$con_share))

# We though pooling is just an lm
panel_pool <- plm(n_proj ~ con_share_s + n_proj_before_s, 
             data = df,
             #index = c('district', 'election_year'),
             #effect = 'twoways',
             model = 'pooling') # pooling washed out any other part
fix_ef_nt <- lm(n_proj ~ con_share_s + n_proj_before_s,
                data = df)

summary(fix_ef_nt)$coefficients
summary(panel_pool)$coefficients

# 'Within' models match lms as if you were factoring levels
# FOR district but not for time??
panel_within_t <- plm(n_proj ~ con_share_s + n_proj_before_s, 
                  data = df,
                  index = 'election_year',
                  effect = 'time',
                  model = 'within') # is fixed effects
fix_ef_t <- lm(n_proj ~ con_share_s + n_proj_before_s + 
                    factor(election_year),
                  data = df)
summary(panel_within_t)$coefficients
summary(fix_ef_t)$coefficients[1:3,]
# ^ I don't understand why these are different when they are the same
# for individuals

panel_within_i <- plm(n_proj ~ con_share_s + n_proj_before_s, 
                      data = df,
                      index = 'district',
                      effect = 'individual',
                      model = 'within') # is fixed effects
fix_ef_i <- lm(n_proj ~ con_share_s + n_proj_before_s + 
                   factor(district),
                 data = df)
summary(panel_within_i)$coefficients
summary(fix_ef_i)$coefficients[1:3,]

# What about random effects?
panel_random_i <- plm(n_proj ~ con_share_s + n_proj_before_s, 
                      data = df,
                      index = 'district',
                      effect = 'individual',
                      model = 'random')
mix_ef_i <- lmer(n_proj ~ con_share_s + n_proj_before_s + 
                    (1|district),
                  data = df)
summary(panel_random_i)$coefficients
summary(mix_ef_i)$coefficients
# ^ these are slightly different

panel_random_t <- plm(n_proj ~ con_share_s + n_proj_before_s, 
                      data = df,
                      index = 'election_year',
                      effect = 'time',
                      model = 'random') 
mix_ef_t <- lmer(n_proj ~ con_share_s + n_proj_before_s + 
                   (1|election_year),
                 data = df)
summary(panel_random_t)$coefficients
summary(mix_ef_t)$coefficients
summary(fix_ef_t)$coefficients[1:3,]
# ^ these are exactly the same

BIC(fix_ef_t)
BIC(mix_ef_t)
BIC(fix_ef_i)
BIC(mix_ef_i)
summary(panel_within_t)$r.squared[[1]]
summary(panel_random_t)$r.squared[[1]]
summary(panel_within_i)$r.squared[[1]]
summary(panel_random_i)$r.squared[[1]]

# Two-way random or within?
panel_within_tw <- plm(n_proj ~ con_share_s + n_proj_before_s, 
                       data = df,
                       index = c('district', 'election_year'),
                       effect = 'twoways',
                       model = 'within')
panel_random_tw <- plm(n_proj ~ con_share_s + n_proj_before_s, 
                       data = df,
                       index = c('district', 'election_year'),
                       effect = 'twoways',
                       model = 'random') 
summary(panel_within_tw)$coefficients
summary(panel_random_tw)$coefficients

mix_ef_tw <- lmer(n_proj ~ con_share_s + n_proj_before_s + 
                   (1|district) + (1|election_year),
                 data = df)
summary(mix_ef_tw)



panel_within_i <- plm(n_proj ~ con_share_s, 
                      data = df,
                      index = c('district', 'election_year'),
                      effect = 'individual', # this is default
                      model = 'within') # is fixed effects
summary(panel_within_i)

panel_within_tw <- plm(n_proj ~ con_share_s, 
                      data = df,
                      index = c('district', 'election_year'),
                      effect = 'twoways', # this is default
                      model = 'within') # is fixed effects
summary(panel_within_tw)

