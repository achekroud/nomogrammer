## nomogram plot draft 1

odds         <- function(p){
    o <- p/(1-p)
    return(o)
}

logodds      <- function(p){
    lo <- log10(p/(1-p))
    return(lo)
}

logodds_to_p <- function(lo){
    o <- 10^lo
    p <- o/(1+o)
    return(p)
}


library(ggplot2)



## set all the theme preferences up front so the plot is legible
theme_set(theme_bw() +
              theme(axis.text.x = element_blank(),
                    axis.ticks.x = element_blank(),
                    axis.title.x = element_blank(),
                    axis.title.y = element_text(angle = 0),
                    axis.title.y.right = element_text(angle = 0),
                    axis.line = element_blank(),
                    panel.grid = element_blank(),
                    legend.position = "none"
                    )
          )




ticks_prob    <- c(0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 30,
                   40, 50, 60, 70, 80, 90, 95, 99)
ticks_odds    <- odds(ticks_prob)
ticks_logodds <- logodds(ticks_prob/100)
ticks_lrs     <- sort(c(10^(-3:3), 2*(10^(-3:2)), 5*(10^(-3:2))))
ticks_log_lrs <- log10(ticks_lrs)

 
prior_prob  <- 0.6                  # prevalence
prior_odds  <- odds(prior_prob)
sensitivity <- 0.9
specificity <- 0.9
PLR <- sensitivity/(1-specificity)
NLR <- (1-sensitivity)/specificity
post_odds_pos  <- prior_odds * PLR
post_odds_neg  <- prior_odds * NLR
post_prob_pos  <- post_odds_pos/(1+post_odds_pos)
post_prob_neg  <- post_odds_neg/(1+post_odds_neg)

left   <- 0
right  <- 1
middle <- mean(c(left, right))
    
df <- data.frame(x=c(left, right, left, right), 
                 y=c(prior_prob, post_prob_pos, prior_prob, post_prob_neg), 
                 line = c("pos", "pos", "neg", "neg"))

adj_min      <- range(ticks_logodds)[1]
adj_max      <- range(ticks_logodds)[2]
adj_diff     <- adj_max - adj_min
scale_factor <- abs(adj_min) - adj_diff/2
#df$lo_y <- ifelse(df$x==left,(10/adj_diff)*logodds(1-df$y)-1,logodds(df$y))
df$lo_y <- ifelse(df$x==left,logodds(1-df$y)-scale_factor,logodds(df$y))
zero         <- data.frame(x = c(left,right),
                           y = c(0,0),
                           line = c('pos','pos'),
                           lo_y = c(-scale_factor,0))


rescale   <- range(ticks_logodds) + abs(adj_min) - adj_diff/2
rescale_x_breaks  <- ticks_logodds + abs(adj_min) - adj_diff/2  

p <- ggplot(df) +
        geom_line(aes(x = x, y = lo_y, color = line)) +
        # geom_line(aes(x = x, y = lo_y), data=zero, color="green") +
        geom_vline(xintercept = middle) +
        annotate(geom = "text",
                 x = rep(middle+.05, length(ticks_log_lrs)),
                 y = (ticks_log_lrs-scale_factor)/2,
                 label = ticks_lrs,
                 size = 3) +
        annotate(geom="point",
                 x = rep(middle, length(ticks_log_lrs)),
                 y = (ticks_log_lrs-scale_factor)/2) +
        ylab("prior \n prob.") +
        scale_x_continuous(expand = c(0, 0)) + 
        scale_y_continuous(expand = c(0,0),
                           limits = rescale,
                           breaks = -rescale_x_breaks,
                           labels = ticks_prob,
                           sec.axis = sec_axis(trans = ~.,
                                               name = "posterior \n prob.",
                                               labels = ticks_prob,
                                               breaks = ticks_logodds))

p





### Graveyard of code that may/may not ever be useful 

# geom_segment(aes(x = middle, xend = middle, y = 1.99, yend = -2)) +
# geom_point(aes(x = rep(middle, length(ticks_log_lrs)),
#               y = ticks_log_lrs, label = "+")) +

# ticks_lrs <- c(0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 1,
#                    2, 5, 10,20, 50, 100, 200, 500, 1000)

# p + ggtitle("test main title", subtitle = "subtitle goes here")

