d <- read.csv("data/processed/analytics_dataset.csv")
client <- aggregate(cbind(amount_paid,booking_id) ~ client_id,d,function(x) c(sum=sum(x),count=length(x)))
client <- data.frame(client_id=client$client_id,revenue=client$amount_paid[,"sum"],bookings=client$booking_id[,"count"])
client$segment <- ifelse(client$bookings>1,"Repeat",ifelse(client$revenue>=quantile(client$revenue,.75),"High-value first-time","First-time"))
write.csv(client,"data/processed/r_customer_segments.csv",row.names=FALSE)
png("visuals/r_customer_segments.png",800,500); barplot(table(client$segment),col=c("#D7A86E","#2F6F73","#C26A4A"),main="Customer Segments",ylab="Clients"); dev.off()

