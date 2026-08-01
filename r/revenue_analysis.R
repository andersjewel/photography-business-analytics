d <- read.csv("data/processed/analytics_dataset.csv")
service <- aggregate(cbind(amount_paid,gross_profit) ~ service_category,d,sum)
service$margin <- service$gross_profit/service$amount_paid
write.csv(service,"data/processed/r_service_revenue.csv",row.names=FALSE)
png("visuals/r_service_comparison.png",900,520); par(mar=c(9,4,3,1)); barplot(service$amount_paid,names.arg=service$service_category,las=2,col="#C26A4A",main="Revenue by Service",ylab="USD"); dev.off()
# R is included as an independent validation perspective; totals should match Python's booking-grain export.

