
#list(fval,out[idxPeaktime2,"time"], out[idxPeaktime1,"time"],y_CART,P_CART, y_IL6, P_IL6, clinicaldata_CART,clinicaldata_IL6,out)
# the 5 elements are: fval, out[idxPeaktime,"time"], yO, yP, out
plot_data_y_CART <- data.frame(yO_times = forplotting[[2]]$Days,
									yO = forplotting[[2]]$CART)

plot_data_P_CART <- data.frame(yP_time = forplotting[[4]][,"time"],
									yP = forplotting[[4]][,"CT"])


plot_data_y_IL6 <- data.frame(yO_times = forplotting[[3]]$Days,
									yO = forplotting[[3]]$IL6)

plot_data_P_IL6 <- data.frame(yP_time = forplotting[[4]][,"time"],
									yP = forplotting[[4]][,"IL6"])


plot_data_P_Tumor <- data.frame(yP_time = forplotting[[4]][,"time"],
									yP = forplotting[[4]][,"T_pop"])

fit_plot_CART <- ggplot() +
	  geom_point(data = plot_data_y_CART, aes(x = yO_times, y = yO, color = "Observed data"),size = 4.2) +
	  geom_line(data = plot_data_P_CART, aes(x = yP_time, y = yP, color = "Model prediction"),size = 1.5) +
	 scale_color_manual(
	    name = "",  # legend title (leave empty if you want)
	    values = c(
	      "Observed data"    = "black",
	      "Model prediction" = "blue"
	    )
	  ) +
	  xlab("Time (days)") +
	  ylab("CAR-T cells (log scale)") +
	  scale_y_log10() + 
	  coord_cartesian(ylim = c(1e4, max(plot_data_P_CART$yP+1000,1e10))) +
	  ggtitle(paste0("Model simulations CAR-T for patient ", patientID)) +
	  theme(
	    axis.title.x = element_text(size = 40, face = "bold"),
	    axis.title.y = element_text(size = 40, face = "bold"),
	    axis.text.x  = element_text(size = 36, face = "bold"),
	    axis.text.y  = element_text(size = 36, face = "bold"),
	    plot.title   = element_text(size = 30, face = "bold", hjust = 0.5),
	    axis.ticks = element_line(size = 1.2),
	    axis.ticks.length = unit(0.25, "cm"),
	    legend.title = element_text(size = 28, face = "bold"),
	    legend.text  = element_text(size = 26),
	    legend.background = element_rect(fill = alpha("white", 0.8), color = "black"),
	    legend.key = element_rect(fill = "white"),
	    legend.position = c(0.80, 0.85),  # (x,y) coordinates inside plot
	    legend.justification = c(1, 1),   # anchor top-right corner
	    text = element_text(family = "sans")
	  )
		
fit_plot_IL6 <- ggplot() +
	  geom_point(data = plot_data_y_IL6, aes(x = yO_times, y = yO, color = "Observed data"),size = 4.2) +
	  geom_line(data = plot_data_P_IL6, aes(x = yP_time, y = yP, color = "Model prediction"),size = 1.5) +
	 scale_color_manual(
	    name = "",  # legend title (leave empty if you want)
	    values = c(
	      "Observed data"    = "black",
	      "Model prediction" = "blue"
	    )
	  ) +
	  xlab("Time (days)") +
	  ylab("IL6 (pg/mL)") +
	  coord_cartesian(xlim = c(0, max(plot_data_y_IL6$yO_times)*2)) +
	  ggtitle(paste0("Model simulations of IL6 for patient ", patientID)) +
	  theme(
	    axis.title.x = element_text(size = 40, face = "bold"),
	    axis.title.y = element_text(size = 40, face = "bold"),
	    axis.text.x  = element_text(size = 36, face = "bold"),
	    axis.text.y  = element_text(size = 36, face = "bold"),
	    plot.title   = element_text(size = 30, face = "bold", hjust = 0.5),
	    axis.ticks = element_line(size = 1.2),
	    axis.ticks.length = unit(0.25, "cm"),
	    legend.title = element_text(size = 28, face = "bold"),
	    legend.text  = element_text(size = 26),
	    legend.background = element_rect(fill = alpha("white", 0.8), color = "black"),
	    legend.key = element_rect(fill = "white"),
	    legend.position = c(0.80, 0.85),  # (x,y) coordinates inside plot
	    legend.justification = c(1, 1),   # anchor top-right corner
	    text = element_text(family = "sans")
	  )
		
 fit_plot_Tumor <- ggplot() +
	  #geom_point(data = plot_data_y_IL6, aes(x = yO_times, y = yO), color = "black") +
	  geom_line(data = plot_data_P_Tumor, aes(x = yP_time, y = yP, color = "Model prediction"),size = 1.5) +
	  xlab("Time (days)") +
	  ylab("Total tumor") +
	 # coord_cartesian(xlim = c(0, max(plot_data_y_IL6$yO_times)*2)) +
	  ggtitle(paste0("Model simulations of total tumor cells for patient ", patientID)) +
	  theme(
	    axis.title.x = element_text(size = 30, face = "bold"),
	    axis.title.y = element_text(size = 30, face = "bold"),
	    axis.text.x  = element_text(size = 16, face = "bold"),
	    axis.text.y  = element_text(size = 16, face = "bold"),
	    plot.title   = element_text(size = 22, face = "bold", hjust = 0.5),
	    axis.ticks = element_line(size = 1.2),
	    axis.ticks.length = unit(0.25, "cm"),
	    legend.title = element_text(size = 18, face = "bold"),
	    legend.text  = element_text(size = 16),
	    legend.background = element_rect(fill = alpha("white", 0.8), color = "black"),
	    legend.key = element_rect(fill = "white"),
	    legend.position = c(0.80, 0.85),  # (x,y) coordinates inside plot
	    legend.justification = c(1, 1),   # anchor top-right corner
	    text = element_text(family = "sans")
	  )

figdir<-paste0(outdir1,"/figs")
ggsave(paste0(figdir,"/Fitting_results.pdf"), c(fit_plot_CART,fit_plot_IL6,fit_plot_Tumor), width=12, height=12)



