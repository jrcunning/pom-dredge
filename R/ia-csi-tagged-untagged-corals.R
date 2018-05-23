
# Import data
ia <- read.csv("data/DEP_responsive_records_May_2017/permanent_sites_impact_assessment_corals_2016_CSI_QAQC.csv", skip=1)
# Subset select columns
ia <- ia[, c(1,3,4,5,20,21,22,23,24,25,26)]

# Reformat data
ia <- within(ia, {
  Date <- as.Date(Date, format="%m/%d/%y")
  Condition.Code.qaqc <- as.character(Condition.Code.qaqc)
  Visual.Estimate...Mortality <- as.numeric(as.character(Visual.Estimate...Mortality))
})
ia <- droplevels(ia)

# Aggregate all conditions for each observed coral
ia.t <- with(ia, {
  aggregate(data.frame(Condition.Codes=Condition.Code.qaqc),
            by=list(Date=Date, Site=Site, Transect=Transect, 
                    Coral.ID=Coral.ID, Tagged=Tagged.coral..Y.N., Species=Species,
                    PctMortality=Visual.Estimate...Mortality), 
            FUN=function(x) c(as.character(x)))
})
ia.t <- ia.t[with(ia.t, order(Site, Transect, Coral.ID)), ]

# Add grouping factors
ia.t$Channel <- ifelse(grepl("C", ia.t$Site), "control", "channelside")
ia.t$reef <- substr(ia.t$Site, 1, 2)
ia.t$dir <- substr(ia.t$Site, 3, 3)
ia.t$perm <- ifelse(
  grepl("[0-9]", lapply(strsplit(as.character(ia.t$Site), "-"), "[", 2)),
  FALSE, TRUE)
ia.t$sus <- ifelse(ia.t$Species %in% c("CNAT", "DSTO", "DLAB", "EFAS", "MMEA", "MCAV",
                                       "ODIF", "OFAV", "DCLI", "SBOU"),
                   yes=TRUE, no=FALSE)

# Subset tagged corals for middle and outer reefs
ia.t.r2r3 <- subset(ia.t, Tagged=="Y" & grepl("R", Site))

# Number of corals in dataset
table(ia.t.r2r3$Channel)
table(ia.t.r2r3$Site)
prop.table(table(ia.t.r2r3$Channel, ia.t.r2r3$sus), margin=1)
chisq.test(table(ia.t.r2r3$Channel, ia.t.r2r3$sus))
# test diff in prop suscept spp at diff sites
mod <- with(ia.t.r2r3, lm(sus ~ Channel * reef))
anova(mod)
prop.table(table(ia.t.r2r3$reef, ia.t.r2r3$sus), margin=1)
mod <- with(subset(ia.t.r2r3, Site %in% c("R2N1", "R2NC2")), lm(sus ~ Channel))
anova(mod)

# Analyze total mortality
ia.t.r2r3$dead <- grepl("DEAD", ia.t.r2r3$Condition.Codes)
with(ia.t.r2r3, prop.table(table(Channel, dead), margin=1))
with(ia.t.r2r3, prop.table(table(Site, dead), margin=1))

# Analyze loss of tissue
ia.t.r2r3$PctMortality <- as.matrix(ia.t.r2r3$PctMortality)
boxplot(ia.t.r2r3$PctMortality ~ ia.t.r2r3$Channel)

with(ia.t.r2r3, aggregate(PctMortality, by=list(Channel), FUN=mean))
with(ia.t.r2r3, aggregate(PctMortality, by=list(Site), FUN=mean))

mod <- with(subset(ia.t.r2r3, reef=="R2" & dir=="N"), lm(PctMortality ~ Channel))
anova(mod)
summary(mod)

mod <- with(subset(ia.t.r2r3, reef=="R2" & dir=="N"), lm(PctMortality ~ Channel * Species))
anova(mod)
summary(mod)
pairs(lsmeans(mod, specs=c("Species", "Channel")), by=c("Species"))
####SHOWS DCLI and SSID are ONLY SPP W SIG DIFFS BETWEEN CHANNEL-CONTROL a N. Mid REEF

subset(ia.t.r2r3, reef=="R2" & dir=="N" & Species=="DCLI") # only 3 dcli, so not great...
subset(ia.t.r2r3, reef=="R2" & dir=="N" & Species=="SSID") # many Ssids!
subset(ia.t.r2r3, reef=="R2" & dir=="N" & Species=="PAST") # no tagged PAST NMR channelside
subset(ia.t.r2r3, reef=="R2" & dir=="N" & Species=="CNAT")

mod <- with(subset(ia.t.r2r3, reef=="R3"), lm(PctMortality ~ Channel))
anova(mod)
summary(mod)

mod <- with(subset(ia.t.r2r3, Site %in% c("R2N2", "R2NC2")), lm(PctMortality ~ Channel))
anova(mod)
summary(mod)

# Analyze partial mortality
table(grepl("PM", ia.t.r2r3$Condition.Codes))
