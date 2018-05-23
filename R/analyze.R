load("data/scler.RData")

# Data cleaning
scler[scler$species=="Colophyllia natans", "species"] <- "Colpophyllia natans"
scler[scler$species=="Pseudoiploria strigosa", "species"] <- "Pseudodiploria strigosa"
scler[scler$species=="Stephanocoenia intercepta", "species"] <- "Stephanocoenia intersepta"

# Add categories for reef, channel-proximity
scler <- within(scler, {
  reef <- factor(substr(site, 1, 2))
  prox <- factor(ifelse(grepl(pattern="[NS]C", site), yes="control", no="channelside"))
  dir  <- factor(ifelse(grepl(pattern="S", site), yes="south", no="north"))
})

scler <- na.omit(scler)

head(scler)

##### REEF 2
R2 <- subset(scler, reef=="R2")

# Calculate density - the way they did in the report.
r2scler <- aggregate(data.frame(count=R2$count),
                     by=list(time=R2$time, site=R2$site, 
                             week=R2$week, transect=R2$transect), FUN=sum)
r2scler$density <- r2scler$count/20

mod <- lm(density ~ time * site, data=r2scler)  # not what they got
anova(mod)

r2scler2 <- aggregate(data.frame(count=r2scler$count, density=r2scler$density),
                    by=list(time=r2scler$time, site=r2scler$site), FUN=mean)
r2scler2  # THESE ARE THE DENSITIES THEY REPORT

r2scler3 <- aggregate(data.frame(density=r2scler$density),
                      by=list(time=r2scler$time, site=r2scler$site, transect=r2scler$transect), FUN=mean)
r2scler3
mod <- lm(density ~ time * site, data=r2scler3)
anova(mod)  # this is close to what they got but not exact  -- but same degrees of freedom
plot(effect("time:site", mod), x.var="time")
pairs(lsmeans::lsmeans(mod, specs="time", by="site"))



mod <- lm(density ~ time * site, data=r2scler2)

mod <- lm(density ~ time * site, data=droplevels(subset(scler3, grepl("R2", site))))
anova(mod)




# THIS IS HOW DIAL-CORDY REPORTS COLONY ABUNDANCE
# TOTAL NUMBER OF COLONIES COUNTED ON ALL THREE TRANSECTS WITHIN A WEEK - AVERAGED ACROSS WEEKS
sum(r2bl[r2bl$site=="R2S2-LR" & r2bl$week=="w1", "count"])
sum(r2bl[r2bl$site=="R2S2-LR" & r2bl$week=="w2", "count"])
sum(r2bl[r2bl$site=="R2S2-LR" & r2bl$week=="w3", "count"])
sum(r2bl[r2bl$site=="R2S2-LR" & r2bl$week=="w4", "count"])

mod <- lm(count ~ prox * time, data=R2)

aggregate(R2$count, by=list(R2$site, R2$time), FUN=sum)

head(R2)

# Summing counts of all corals in all transects at each site at each week/time
R2ag <- aggregate(R2$count, FUN=sum,
                  by=list(week=R2$week, time=R2$time, site=R2$site, 
                          dir=R2$dir, prox=R2$prox, reef=R2$reef))

mod <- lm(x ~ time * prox * dir, data=R2ag)
plot(effect("time:prox:dir", mod), x.var="time")
anova(mod)

dcmod <- lm(x ~ time * site, data=R2ag)
anova(dcmod)
pairs(lsmeans::lsmeans(dcmod, specs="time", by="site"))

# HARDBOTTOM
HB <- subset(scler, reef=="HB")
HBag <- aggregate(HB$count, FUN=sum,
                  by=list(week=HB$week, time=HB$time, site=HB$site, 
                          dir=HB$dir, prox=HB$prox, reef=HB$reef))
mod <- lm(x ~ time * prox * dir, data=HBag)
plot(effect("time:prox:dir", mod), x.var="time")
anova(mod)


# REEF 3
R3 <- subset(scler, reef=="R3")
R3ag <- aggregate(R3$count, FUN=sum,
                  by=list(week=R3$week, time=R3$time, site=R3$site, 
                          dir=R3$dir, prox=R3$prox, reef=R3$reef))
mod <- lm(x ~ time * prox * dir, data=R3ag)
plot(effect("time:prox:dir", mod), x.var="time")
anova(mod)

