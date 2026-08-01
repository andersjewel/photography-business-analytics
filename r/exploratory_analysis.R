# Independent portfolio case study using synthetic data inspired by common photography-business workflows.
d <- read.csv("data/processed/analytics_dataset.csv")
stopifnot(all(d$amount_paid >= 0), nrow(d) > 0)
monthly <- aggregate(amount_paid ~ month, d, sum)
png("visuals/r_monthly_revenue.png",900,500); plot(monthly$amount_paid,type="l",col="#2F6F73",lwd=3,xaxt="n",main="Monthly Revenue (R validation)",ylab="USD",xlab="Month"); axis(1,seq_len(nrow(monthly)),monthly$month,las=2,cex.axis=.65); dev.off()

