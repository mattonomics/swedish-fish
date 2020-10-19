# if this isn't an interactive session, bail
if (! interactive()) {
    quit("Not interactive.", 1)
}

# Number of random draws from the prior
n_draws <- 100000

# A counter to track how many times we need to run the priors
hist_count <- 0

# the function we're going to use to loop
create_verify_hist <- function() {
    # Increment the hist_count
    hist_count + 1

    # Priors: What information does the data have before seeing the data?
    # Analysis notes:
    #   - Assume that probabilities, from 0 to 1, are equally likely.
    #   - Creates a vector with n_draws number of randomized items.
    #   - Assumes a normal distribution of probabilities.
    # Programming notes:
    #   - `runif(number_of_times, min_value = 0, max_value = 1)`
    #   - the second and third param default to 0 and 1.
    prior <<- runif(n_draws)

    # The exercise suggests that we visually review the generated data.
    # @todo Figure out good/bad indicators I might look for in the visualization.
    #   - If the distribution doesn't appear uniform, that could be an issue…
    #   - We're going to check it, possibly a few times
    hist(
        prior,
        main = paste("Priors Distribution, v", hist_count, sep = "")
    )

    # Check to see if the histogram looks right
    if ( readline("Does the distribution appear uniform? y/N  ") != 'y' ) {
        # clear the priors
        rm(prior)
        
        # clear the visualizations
        dev.off()

        # rerun the function
        create_verify_hist()
    }
}

# The generative model will get applied to each `prior`
generative_model <- function(conversion_rate, mailers_sent = 16) {
    # 1. Assume that there is an underlying probability, `conversion_rate`, for signup.
    # 2. Ask a number of people whre the chance of each person signing up is 55%
    # 3. Count the number of successes from step 2.

    # `n` is the number of results we want
    # `size` is the sample size
    # `prob` is the rate as determined by the priors
    # This basically says:
    #   Multiply `prob` by `size` `n` number of times and give me the result.
    test = rbinom(n = 1, size = mailers_sent, prob = conversion_rate)
    
    # return the result
    test
}

# start the program and setup globals
create_verify_hist()

# Creates a vector with a length of `n_draws` with each value set to `NA`.
sim_data <- rep(NA, n_draws)

# Loop through the draws from 1 to `n_draws`.
for(i in 1:n_draws) {

    # Select a probability value from `prior`.
    sim_data[i] <- generative_model(prior[i])
}

# Here you filter off all draws that do not match the data.
# Filter `sim_data` to the values `== 6`, then use those keys to grab from `prior`
posterior <- prior[sim_data == 6] 

# I bumped the n_draws up an order of magnitude, so we will def have 1000
hist(
    posterior,
    main = paste("Posterior (n=", length(posterior),")", sep = "")    
)

# Now you can summarize the posterior, where a common summary is to take the mean
# or the median posterior, and perhaps a 95% quantile interval.
#median(posterior)
#quantile(posterior, c(0.025, 0.975))

# Q2

# A logical vector of values from the posterior >20%
better_than_telemarketing <- posterior > .2

# now figure out what % of direct mail is better than telemarketing
aggregate_percent_better <- sum(better_than_telemarketing) / length(posterior)

print(paste(aggregate_percent_better * 100, "% of direct mail efforts performed better than telemarketing.", sep = ""))

# q3

# the length of the posterior
posterior_length = length(posterior)

# Create a vector the length of `posterior`
sim_data_100 <- rep(NA, posterior_length)

# beign looping it to properly apply the probabilities
for (i in 1:posterior_length) {
    sim_data_100[i] <- generative_model(posterior[i], 100)
}

hist(
    sim_data_100,
    main = "Mailer performance of size 100 using posterior from Q1"
)