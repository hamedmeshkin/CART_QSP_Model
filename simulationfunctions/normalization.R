# Function to normalize each column of a matrix between 0 and 1
encoding_0_1 <- function(mat) {
  scaled_mat <- matrix(0, nrow = nrow(mat), ncol = ncol(mat))
  min_vals <- numeric(ncol(mat))
  max_vals <- numeric(ncol(mat))

  for (i in 1:ncol(mat)) {
    col <- mat[, i]
    min_col <- min(col, na.rm = TRUE)
    max_col <- max(col, na.rm = TRUE)
    scaled_mat[, i] <- (col - min_col) / (max_col - min_col)
    min_vals[i] <- min_col
    max_vals[i] <- max_col
  }

  return(list(scaled = scaled_mat, min = min_vals, max = max_vals))
}

# Function to decode the matrix back to original values
decoding_0_1 <- function(scaled_mat, min_vals, max_vals) {
  original_mat <- matrix(0, nrow = nrow(scaled_mat), ncol = ncol(scaled_mat))

  for (i in 1:ncol(scaled_mat)) {
    original_mat[, i] <- scaled_mat[, i] * (max_vals[i] - min_vals[i]) + min_vals[i]
  }

  return(original_mat)
}