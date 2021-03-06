#' Visualize chi square distribution
#'
#' Visualize how changes in degrees of freedom affect the shape of
#' the chi square distribution. Compute & visualize quantiles out of given
#' probability and probability from a given quantile.
#'
#' @param df Degrees of freedom.
#' @param probs Probability value.
#' @param perc Quantile value.
#' @param type Lower tail or upper tail.
#' @param normal If \code{TRUE}, normal curve with same \code{mean} and
#' \code{sd} as the chi square distribution is drawn.
#' @param xaxis_range The upper range of the X axis.
#' @param print_plot logical; if \code{TRUE}, prints the plot else returns a plot object.
#'
#' @examples
#' # visualize chi square distribution
#' vdist_chisquare_plot()
#' vdist_chisquare_plot(df = 5)
#' vdist_chisquare_plot(df = 5, normal = TRUE)
#'
#' # visualize quantiles out of given probability
#' vdist_chisquare_perc(0.165, 8, 'lower')
#' vdist_chisquare_perc(0.22, 13, 'upper')
#'
#' # visualize probability from a given quantile.
#' vdist_chisquare_prob(13.58, 11, 'lower')
#' vdist_chisquare_prob(15.72, 13, 'upper')
#'
#' @seealso \code{\link[stats]{Chisquare}}
#'
#' @export
#'
vdist_chisquare_plot <- function(df = 3, normal = FALSE,
                                 xaxis_range = 25, print_plot = TRUE) {

  check_numeric(df, "df")
  check_logical(normal)

	df    <- as.integer(df)
	chim  <- round(df, 3)
	chisd <- round(sqrt(2 * df), 3)
	x     <- seq(0, xaxis_range, 0.01)
	data  <- dchisq(x, df)

	plot_data  <- data.frame(x = x, chi = data)
	poly_data  <- data.frame(y = c(0, seq(0, 25, 0.01), 25),
	                         z = c(0, dchisq(seq(0, 25, 0.01), df), 0))
	point_data <- data.frame(x = chim, y = min(data))
	nline_data <- data.frame(x = x, y = dnorm(x, chim, chisd))


	pp <-
	  ggplot(plot_data) +
	  geom_line(aes(x, chi), color = '#4682B4', size = 2) +
	  ggtitle(label    = "Chi Square Distribution",
	                   subtitle = paste("df =", df)) +
	  ylab('') +
	  xlab(paste("Mean =", chim, " Std Dev. =", chisd)) +
	  theme(plot.title = element_text(hjust = 0.5),
	                 plot.subtitle = element_text(hjust = 0.5)) +
	  scale_x_continuous(breaks = seq(0, xaxis_range, 2)) +
	  geom_polygon(data    = poly_data,
	                        mapping = aes(x = y, y = z),
	                        fill    = '#4682B4') +
	  geom_point(data    = point_data,
	                      mapping = aes(x = x, y = y),
	                      shape   = 4,
	                      color   = 'red',
	                      size    = 3)


	if (normal) {
	  pp <-
	  	pp +
	    geom_line(data = nline_data, mapping = aes(x = x, y = y),
	      color = '#FF4500')
	}

	if (print_plot) {
	  print(pp)
	} else {
	  return(pp)
	}

}

#' @rdname vdist_chisquare_plot
#' @export
#'
vdist_chisquare_perc <- function(probs = 0.95, df = 3,
                                 type = c("lower", "upper"),
                                 print_plot = TRUE) {

  check_numeric(probs, "probs")
  check_numeric(df, "df")
  check_range(probs, 0, 1, "probs")

  df     <- as.integer(df)
	method <- match.arg(type)
	chim   <- round(df, 3)
	chisd  <- round(sqrt(2 * df), 3)
	l      <- vdist_chiseql(chim, chisd)
	ln     <- length(l)

	if (method == "lower") {
	  pp  <- round(qchisq(probs, df), 3)
	  lc  <- c(l[1], pp, l[ln])
	  col <- c("#0000CD", "#6495ED")
	  l1  <- c(1, 2)
	  l2  <- c(2, 3)
	} else {
	  pp  <- round(qchisq(probs, df, lower.tail = F), 3)
	  lc  <- c(l[1], pp, l[ln])
	  col <- c("#6495ED", "#0000CD")
	  l1  <- c(1, 2)
	  l2  <- c(2, 3)
	}
	xm <- vdist_xmm(chim, chisd)

	plot_data <- data.frame(x = l, y = dchisq(l, df))
	gplot <-
	  ggplot(plot_data) +
	  geom_line(aes(x = x, y = y), color = "blue") +
	  xlab(paste("Mean =", chim, " Std Dev. =", chisd)) +
	  ylab('') +
	  theme(plot.title    = element_text(hjust = 0.5),
	                 plot.subtitle = element_text(hjust = 0.5))


	if (method == "lower") {
	  gplot <-
	    gplot +
	    ggtitle(label    = paste("Chi Square Distribution: df =", df),
	                     subtitle = paste0("P(X < ", pp, ") = ", probs * 100, "%")) +
	    annotate("text",
	                      label   = paste0(probs * 100, "%"),
	                      x       = pp - chisd,
	                      y       = max(dchisq(l, df)) + 0.02,
	                      color   = "#0000CD",
	                      size    = 3) +
	    annotate("text",
	                      label   = paste0((1 - probs) * 100, "%"),
	                      x       = pp + chisd,
	                      y       = max(dchisq(l, df)) + 0.02,
	                      color   = "#6495ED",
	                      size    = 3)

	} else {
	  gplot <-
	  	gplot +
	    ggtitle(label    = paste("Chi Square Distribution: df =", df),
	                     subtitle = paste0("P(X > ", pp, ") = ", probs * 100, "%")) +
	    annotate("text",
	                      label   = paste0((1 - probs) * 100, "%"),
	                      x       = pp - chisd,
	                      y       = max(dchisq(l, df)) + 0.02,
	                      color   = "#6495ED",
	                      size    = 3) +
	    annotate("text",
	                      label   = paste0(probs * 100, "%"),
	                      x       = pp + chisd,
	                      y       = max(dchisq(l, df)) + 0.02,
	                      color   = "#0000CD",
	                      size    = 3)
	}

	for (i in seq_len(length(l1))) {
	  pol_data <- vdist_pol_chi(lc[l1[i]], lc[l2[i]], df)
	  gplot <-
	    gplot +
	    geom_polygon(data    = pol_data,
	                          mapping = aes(x = x, y = y),
	                          fill    = col[i])
	}

	point_data <- data.frame(x = pp, y = min(dchisq(l, df)))

	gplot <-
	  gplot +
	  geom_vline(xintercept = pp,
	                      linetype   = 2,
	                      size       = 1) +
	  geom_point(data       = point_data,
	                      mapping    = aes(x = x, y = y),
	                      shape      = 4,
	                      color      = 'red',
	                      size       = 3) +
	  scale_y_continuous(breaks = NULL) +
	  scale_x_continuous(breaks = seq(0, xm[2], by = 5))

	if (print_plot) {
	  print(gplot)
	} else {
	  return(gplot)
	}

}

#' @rdname vdist_chisquare_plot
#' @export
#'
vdist_chisquare_prob <- function(perc = 13, df = 11, type = c("lower", "upper"),
                                 print_plot = TRUE) {


  check_numeric(df, "df")
  check_numeric(perc, "perc")

  method <- match.arg(type)
  chim   <- round(df, 3)
  chisd  <- round(sqrt(2 * df), 3)

  l <- if (perc < 25) {
    seq(0, 25, 0.01)
  } else {
    seq(0, (perc + (3 * chisd)), 0.01)
  }
  ln <- length(l)

  if (method == "lower") {
    pp  <- round(pchisq(perc, df), 3)
    lc  <- c(l[1], perc, l[ln])
    col <- c("#0000CD", "#6495ED")
    l1  <- c(1, 2)
    l2  <- c(2, 3)
  } else {
    pp  <- round(pchisq(perc, df, lower.tail = F), 3)
    lc  <- c(l[1], perc, l[ln])
    col <- c("#6495ED", "#0000CD")
    l1  <- c(1, 2)
    l2  <- c(2, 3)
  }

  plot_data <- data.frame(x = l, y = dchisq(l, df))
	gplot <-
	  ggplot(plot_data) +
	  geom_line(aes(x = x, y = y), color = "blue") +
	  xlab(paste("Mean =", chim, " Std Dev. =", chisd)) +
	  ylab('') +
	  theme(plot.title = element_text(hjust = 0.5),
	                 plot.subtitle = element_text(hjust = 0.5))


  if (method == "lower") {
	  gplot <-
	    gplot +
	    ggtitle(label = paste("Chi Square Distribution: df =", df),
	      subtitle = paste0("P(X < ", perc, ") = ", pp * 100, "%")) +
	    annotate("text", label = paste0(pp * 100, "%"),
	      x = perc - chisd, y = max(dchisq(l, df)) + 0.02, color = "#0000CD",
	      size = 3) +
	    annotate("text", label = paste0((1 - pp) * 100, "%"),
	      x = perc + chisd, y = max(dchisq(l, df)) + 0.02, color = "#6495ED",
	      size = 3)

	} else {
	  gplot <-
	  	gplot +
	    ggtitle(label = paste("Chi Square Distribution: df =", df),
	      subtitle = paste0("P(X > ", perc, ") = ", pp * 100, "%")) +
	    annotate("text", label = paste0((1 - pp) * 100, "%"),
	      x = perc - chisd, y = max(dchisq(l, df)) + 0.02, color = "#6495ED",
	      size = 3) +
	    annotate("text", label = paste0(pp * 100, "%"),
	      x = perc + chisd, y = max(dchisq(l, df)) + 0.02, color = "#0000CD",
	      size = 3)
	}


  for (i in seq_len(length(l1))) {
	  pol_data <- vdist_pol_chi(lc[l1[i]], lc[l2[i]], df)
	  gplot <-
	    gplot +
	    geom_polygon(data    = pol_data,
	                          mapping = aes(x = x, y = y),
	                          fill    = col[i])
	}

	point_data <- data.frame(x = perc,
	                         y = min(dchisq(l, df)))

	gplot <-
	  gplot +
	  geom_vline(xintercept = perc,
	                      linetype   = 2,
	                      size       = 1) +
	  geom_point(data       = point_data,
	                      mapping    = aes(x = x, y = y),
	                      shape      = 4,
	                      color      = 'red',
	                      size       = 3) +
	  scale_y_continuous(breaks = NULL) +
	  scale_x_continuous(breaks = seq(0, l[ln], by = 5))

	if (print_plot) {
	  print(gplot)
	} else {
	  return(gplot)
	}

}


vdist_chiseql <- function(mean, sd) {
  lmin <- mean - (5 * sd)
  lmax <- mean + (5 * sd)
  seq(lmin, lmax, 0.01)
}


vdist_xmm <- function(mean, sd) {
  xmin <- mean - (5 * sd)
  xmax <- mean + (5 * sd)
  c(xmin, xmax)
}

vdist_pol_chi <- function(l1, l2, df) {
  x   <- c(l1, seq(l1, l2, 0.01), l2)
  y   <- c(0, dchisq(seq(l1, l2, 0.01), df), 0)
  data.frame(x = x, y = y)
}
