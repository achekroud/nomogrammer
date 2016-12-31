## Plot simple nomograms as ggplot objects
##   Based on Perl web-implementation (https://araw.mede.uic.edu/cgi-bin/testcalc.pl)
##   Authors: AM. Chekroud* & A. Schwartz (* adam dot chekroud at yale . edu)
##   December 2016


######################################
########## Libraries & Functions #####
######################################

## Libraries
require(ggplot2)
require(scales)






## Helper functions
##   (defined inside nomogrammer, so remain local only & wont clutter user env)
odds         <- function(p){
    # Function converts probability into odds
    o <- p/(1-p)
    return(o)
}

logodds      <- function(p){
    # Function returns logodds for a probability
    lo <- log10(p/(1-p))
    return(lo)
}

logodds_to_p <- function(lo){
    # Function goes from logodds back to a probability
    o <- 10^lo
    p <- o/(1+o)
    return(p)
}

p2percent <- function(p){
    # Function turns numeric probability into string percentage
    # e.g. 0.6346111 -> 63.5% 
    scales::percent(signif(p, digits = 3))}


######################################
########## Calculations     ##########
######################################

## Checking inputs

## Prevalence
# needs to exist
if(missing(input_prev)){
    stop("Prevalence is missing")
}
# needs to be numeric
if(!is.numeric(input_prev)){stop("Prevalence should be numeric")}
# needs to be a prob not a percent
if((input_prev > 1) | (input_prev <= 0)){stop("Prevalence should be a probability (did you give a %?)")}

# Did user give sens & spec?
if(missing(input_sens) | missing(input_spec)){
    sensspec <- FALSE
} else{ sensspec <- TRUE}


# Did user give PLR & NLR?
if(missing(input_PLR) | missing(input_NLR)){
    plrnlr <- FALSE
} else{ plrnlr <- TRUE}





input_prev
input_sens
input_spec
input_PLR
input_NLR
# input_TP
# input_FP
# input_FN
# input_TN
detail = TRUE ## optionally exclude 
nullLine = FALSE ## optionally include


#                            Obs
#                   present       absent
#            +----------------+----------------+
#      pos   | True Positive  | False Positive |
# Pred       +----------------+----------------+
#      neg   | False Negative | True Negative  |
#            +----------------+----------------+





prior_prob  <- 0.5                # prevalence
prior_odds  <- odds(prior_prob)
sensitivity <- 0.9
specificity <- 0.9
PLR <- sensitivity/(1-specificity)
NLR <- (1-sensitivity)/specificity


post_odds_pos  <- prior_odds * PLR
post_odds_neg  <- prior_odds * NLR
post_prob_pos  <- post_odds_pos/(1+post_odds_pos)
post_prob_neg  <- post_odds_neg/(1+post_odds_neg)







######################################
########## Plotting (prep)  ##########
######################################




## Set common theme preferences up front
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

## Setting up the points of interest along the y-axes

# Select probabilities of interest (nb as percentages)
ticks_prob    <- c(0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 30,
                   40, 50, 60, 70, 80, 90, 95, 99)
# Convert % to odds
ticks_odds    <- odds(ticks_prob/100)
# Convert % to logodds 
ticks_logodds <- logodds(ticks_prob/100)

# Select the likelihood ratios of interest (for the middle y-axis)
ticks_lrs     <- sort(c(10^(-3:3), 2*(10^(-3:2)), 5*(10^(-3:2))))
# Log10 them since plot is in logodds space
ticks_log_lrs <- log10(ticks_lrs)




## Fixing particular x-coordinates
left     <- 0
right    <- 1
middle   <- 0.5
midright <- 0.75

## Lay out the four key plot points
##  (the start and finish of the positive and negative lines)

df <- data.frame(x=c(left, right, left, right), 
                 y=c(prior_prob, post_prob_pos, prior_prob, post_prob_neg), 
                 line = c("pos", "pos", "neg", "neg"))

adj_min      <- range(ticks_logodds)[1]
adj_max      <- range(ticks_logodds)[2]
adj_diff     <- adj_max - adj_min
scale_factor <- abs(adj_min) - adj_diff/2
#df$lo_y <- ifelse(df$x==left,(10/adj_diff)*logodds(1-df$y)-1,logodds(df$y))
df$lo_y  <- ifelse(df$x==left,logodds(1-df$y)-scale_factor,logodds(df$y))
# zero         <- data.frame(x = c(left,right),
#                            y = c(0,0),
#                            line = c('pos','pos'),
#                            lo_y = c(-scale_factor,0))
uninformative  <- data.frame(x = c(left,right),
                             lo_y = c( (logodds(1-prior_prob) - scale_factor) , logodds(prior_prob)) )


rescale   <- range(ticks_logodds) + abs(adj_min) - adj_diff/2
rescale_x_breaks  <- ticks_logodds + abs(adj_min) - adj_diff/2  



######################################
########## Plot             ##########
######################################


p <- ggplot(df) +
        geom_line(aes(x = x, y = lo_y, color = line), size = 1) +
        geom_vline(xintercept = middle) +
        annotate(geom = "text",
                 x = rep(middle+.075, length(ticks_log_lrs)),
                 y = (ticks_log_lrs-scale_factor)/2,
                 label = ticks_lrs,
                 size = rel(14/5)) +
        annotate(geom="point",
                 x = rep(middle, length(ticks_log_lrs)),
                 y = (ticks_log_lrs-scale_factor)/2) +
        scale_x_continuous(expand = c(0,0)) + 
        scale_y_continuous(expand = c(0,0),
                           limits = rescale,
                           breaks = -rescale_x_breaks,
                           labels = ticks_prob,
                           name = "prior \n prob.",
                           sec.axis = sec_axis(trans = ~.,
                                               name = "posterior \n prob.",
                                               labels = ticks_prob,
                                               breaks = ticks_logodds))

## Optional: add or remove details in the top right 
##   overlay includes prevalence, PLR/NLR, and posterior probabilities
detailedAnnotation <- paste(
    paste0("prevalence = ", p2percent(prior_prob)),
    paste("PLR =", signif(PLR, 3),", NLR =", signif(NLR, 3)),
    paste("post. pos =", p2percent(post_prob_pos),
          ", neg =", p2percent(post_prob_neg)),
    sep = "\n")


## Optional amendments to the plot

## Do we add the null line i.e. LR = 1, illustrating an uninformative model

if(nullLine == TRUE){
    p <- p + geom_line(aes(x = x, y = lo_y), data = uninformative,
                       color = "gray", 
                       lty = 2,
                       inherit.aes = FALSE)
}


## Do we add the detailed stats to the top right?
if(detail == TRUE){
    p <- p + annotate(geom = "text",
                      x = midright,
                      y = 2,
                      label = detailedAnnotation,
                      size = rel(14/5))
    }









### Graveyard of code that may/may not ever be useful 

# geom_segment(aes(x = middle, xend = middle, y = 1.99, yend = -2)) +
# geom_point(aes(x = rep(middle, length(ticks_log_lrs)),
#               y = ticks_log_lrs, label = "+")) +

# ticks_lrs <- c(0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 1,
#                    2, 5, 10,20, 50, 100, 200, 500, 1000)

# p + ggtitle("test main title", subtitle = "subtitle goes here")

