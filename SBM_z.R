source('create_network.R')
source('judge_bankrupt.R')
source('simulate_bankrupt.R')
source('plot_figuer.R')

network_size <- 1000
simulation_times <- 100 
average_degree = 5
cat('The average degree cosnsidered here is:')
cat(average_degree)
cat('\n')

p_cc <- seq(get_low_bound_cc(average_degree), get_up_bond_cc(average_degree), 0.0005)

contagion_threshould <- 0.05
threshould <- network_size * contagion_threshould


main <- function(){
  y_prob = list()
  y_exte = list()
  for (j in p_cc) {
    count_contagion <- 0
    sum_percentages <- 0
    cat('Doing simulation on p_cc: ')
    cat(j)
    cat('\n')
    
    for (i in 1:simulation_times){
      # print('Doing No:')
      # print(i+1)
      # print('At average degree:')
      # print(round(j*(network_size-1)))
      G <- create_network(network_size, parameter = average_degree, 
                          p_cc = j,  type = 'sbm')
      r <- simulate_bankrupt(G, type = 'num')
      r <- as.numeric(r)
      # print('Here in this simulation have bankrupt banks:')
      # print(r)
      if (r > threshould){
        count_contagion <- count_contagion +1
        percentage_cont <- r/network_size
        sum_percentages <- sum_percentages + percentage_cont
      }
    }
    
    proba_contagion <- count_contagion / simulation_times
    if (count_contagion != 0){
      exten_contagion <- sum_percentages / count_contagion
    } else{
      exten_contagion <- 0
    }
    y_prob <- cbind(y_prob, proba_contagion)
    y_exte <- cbind(y_exte, exten_contagion)
  }
  return(do.call(rbind, Map(data.frame, y_prob=y_prob, y_exte=y_exte)))
}


system.time({
  results <- main()
  write.table(results,file="results_sbm.csv",quote=F,col.name=F,row.names=F)
  plot_the_figure(p_cc, results$y_prob, results$y_exte, 
                  network_name = 'SBM Network',
                  notes = 'at z=5')
})
