calc_max_edges <- function(num_nodes) {
  if (num_nodes == 0) {
    return(0)
  }
  value <- 0
  for (i in seq(1, num_nodes)) {
    value <- value + i - 1  
  }
  
  return(2*value + num_nodes)
}
options(digits = 22)
# print(calc_max_edges(3))
print(calc_max_edges(35)) #1225
print(calc_max_edges(377123)) #142221757129
print(calc_max_edges(2000000)) #4e+10
