library(dplyr)
library(plyr)

data <- read.csv("data/DEP_all/NEW_Offshore_Comp_Scleractinian_Cond_All_Weeks_8_10_15-QAQC.csv",
                 stringsAsFactors = FALSE)
data <- data[, 1:11]
head(data)

data <- within(data, {
  Date <- as.Date(Date, format="%m/%d/%y")
  Condition.Code <- as.character(Condition.Code)
})
data <- droplevels(data)

# Identify rows with missing values
na_data <- data[rowSums(is.na(data)) > 0, ]
na_data
# Omit rows with missing data (only one row of all NAs...)
data <- na.omit(data)



# Look for errors in the data (date should correspond to week)
levels(droplevels(interaction(data$Date, data$Week)))
# 2014-11-25 should be 2013-11-25 because it is Week #1
data[data$Date=="2014-11-25", "Date"] <- as.Date("2013-11-25")
# Look for errors in the data (date should correspond to week)
levels(droplevels(interaction(data$Date, data$Week)))
# 2013-04-02 should be 2014-04-02
data[data$Date=="2013-04-02", "Date"] <- as.Date("2014-04-02")
# Look for errors in the data (date should correspond to week)
levels(droplevels(interaction(data$Date, data$Week)))
# Why does "Week 27" include dates fom May 22 until July 23, 2014?
# Looks like a mistake from filling down Date in Excel for Surveyor MLR 
# Change all Week 27 dates greater than May 23, 2014 to May 23, 2014
data[data$Date > "2014-05-23" & data$Week==27 & data$Surveyor=="MLR", "Date"] <- as.Date("2014-05-23")
# Look for errors in the data (date should correspond to week)
levels(droplevels(interaction(data$Date, data$Week)))
# 2020-05-29 should be 2014-05-29
data[data$Date=="2020-05-29", "Date"] <- as.Date("2014-05-29")
# Look for errors in the data (date should correspond to week)
levels(droplevels(interaction(data$Date, data$Week)))
# Change Week '66/67' to 67
data[data$Week=="66/67", "Week"] <- 67
# Change Week '69/70' to 70
data[data$Week=="69/70", "Week"] <- 70
# Rows with dat 2013-12-10 say either Week 4 or Week 7... Week 7 appears to be wrong. 
data[data$Date=="2013-12-10" & data$Week==7, "Week"] <- 4
# 2014-01-15 should be Week 9, not Week 8. (both present in data)
data[data$Date=="2014-01-15" & data$Week==8, "Week"] <- 9

# Change "SBOU " to "SBOU"
data[data$Species=="SBOU ", "Species"] <- "SBOU"

data$Week <- as.integer(data$Week)
data$Site <- factor(data$Site)
levels(data$Site)
data$Species <- factor(data$Species)
levels(data$Species)
head(data)
data$unique.id <- interaction(data$Site, data$Transect, data$Coral.ID)
levels(data$Site)
sitesused <- c("R2NC1-LR", "R2NC2-RR", "R2NC3-LR", "R3NC1-LR", "HBNC1-CP", "HBN3-CP",
               "HBS4-CR", "HBS3-CP", "HBSC1-CP", "R2SC1-RR", "R2SC2-LR", "R2S1-RR", 
               "R2S2-LR", "R2N1-RR", "R2N2-LR", "R3SC2-LR", "R3SC3-SG", "R3S2-LR",
               "R3N1-LR")
## SUBSET ONLY THE 19 SITES IN THE REPORT?
#data <- data[data$Site %in% sitesused, ]
## SUBSET ONLY REEF 2 and 3 sites?
#data <- droplevels(data[grepl("^R", data$Site), ])
##############

# Aggregate all conditions for each observed coral
data <- with(data, {
  aggregate(data.frame(Condition.Codes=Condition.Code), 
            by=list(Week=Week, Date=Date, Site=Site, Transect=Transect, 
                    Coral.ID=Coral.ID, Species=Species), 
            FUN=function(x) c(as.character(x)))
})
data <- data[with(data, order(Site, Transect, Coral.ID, Week)), ]

# Add grouping factors
data$Channel <- ifelse(grepl("C", unlist(lapply(strsplit(as.character(data$Site), split = "-"), "[[", 1))), "control", "channelside")
data$reef <- substr(data$Site, 1, 2)
data$dir <- substr(data$Site, 3, 3)


# Look at sediment stress
data$sed.stress <- grepl("PBUR|SA", data$Condition.Codes)

plot(sed.stress ~ Date, data=subset(data, reef=="R2" & Channel=="channelside"))

# middle reef channelside
ch <- with(subset(data, reef=="R2" & Channel=="channelside"),
     prop.table(table(sed.stress, Week), margin=2))
barplot(ch)

# middle reef controls
ct <- with(subset(data, reef=="R2" & Channel=="control"),
           prop.table(table(sed.stress, Week), margin=2))
barplot(ct)


# Look at co-incidence of sediment stress and white plague disease
swp <- function(x) {
  # Week that PBUR or SA was first observed
  #firstsed <- x$Week[first(grep("PBUR|BUR|SA", x$Condition.Codes))]
  firstsed <- x$Week[first(grep("PBUR|BUR", x$Condition.Codes))]
  # Week that WP was first observed
  firstwp <- x$Week[first(grep("WP", x$Condition.Codes))]
  # Categorize response
  ifelse(!is.na(firstsed),  # check if sed...
         yes=ifelse(!is.na(firstwp),  # check if wp...
                    yes=ifelse(firstsed <= firstwp,
                               yes="sed, wp",
                               no="no sed, wp"),
                    no="sed, no wp"),
         no=ifelse(!is.na(firstwp),  # check if wp
                   yes="no sed, wp",
                   no="no sed, no wp"))
}

# Were corals with sed more likely to get wp than corals without sed?
#          wp after   no wp
#    sed
# no sed

# test susceptible species only

sus <- subset(data, Species %in% c("CNAT", "DSTO", "DLAB", "EFAS", "MMEA", "MCAV",
                                   "ODIF", "OFAV", "DCLI", "DSTR", "SBOU"))
wptest <- ddply(sus, ~ Site + Transect + Coral.ID, swp)
# Add grouping factors
wptest$Channel <- ifelse(grepl("C", unlist(lapply(strsplit(as.character(wptest$Site), split = "-"), "[[", 1))), "control", "channelside")
wptest$reef <- substr(wptest$Site, 1, 2)
wptest$dir <- substr(wptest$Site, 3, 3)
with(wptest, table(V1), margin=1)
with(wptest, table(V1, Channel), margin=1)   #### sed stress (PBUR|BUR) triples disease rate
nosednowp <- 38
nosedwp <- 2
sednowp <- 165
sedwp <- 34
fish <- fisher.test(cbind(c(sedwp, nosedwp), c(nosedwp, nosednowp)))
fish   #### sed increases disease 3x at channel sites
nosednowp <- 86
nosedwp <- 25
sednowp <- 43
sedwp <- 4
fish <- fisher.test(cbind(c(sedwp, nosedwp), c(nosedwp, nosednowp)))
fish   #### no sig effect of sed on disease at control
with(wptest, table(V1, Channel, reef), margin=1)

# look at connection between partial mortality and disease
pmd <- function(x) {
  # Week that Partial Mortality was first observed
  #firstsed <- x$Week[first(grep("PBUR|BUR|SA", x$Condition.Codes))]
  firstpm <- x$Week[first(grep("PM", x$Condition.Codes))]
  # Week that WP was first observed
  firstwp <- x$Week[first(grep("WP", x$Condition.Codes))]
  # Categorize response
  ifelse(!is.na(firstpm),  # check if sed...
         yes=ifelse(!is.na(firstwp),  # check if wp...
                    yes=ifelse(firstpm <= firstwp,
                               yes="pm, wp",
                               no="no pm, wp"),
                    no="pm, no wp"),
         no=ifelse(!is.na(firstwp),  # check if wp
                   yes="no pm, wp",
                   no="no pm, no wp"))
}
pmtest <- ddply(sus, ~ Site + Transect + Coral.ID, pmd)
# Add grouping factors
pmtest$Channel <- ifelse(grepl("C", unlist(lapply(strsplit(pmtest$Site, split = "-"), "[[", 1))), "control", "channelside")
pmtest$reef <- substr(pmtest$Site, 1, 2)
pmtest$dir <- substr(pmtest$Site, 3, 3)
with(pmtest, table(V1), margin=1)
with(wptest, table(V1, Channel), margin=1)
with(wptest, table(V1, Channel, reef), margin=1)

# look at connection between bleaching and disease
bld <- function(x) {
  # Week that partial bleaching (PB) or bleaching (BL) was first observed
  #firstsed <- x$Week[first(grep("PBUR|BUR|SA", x$Condition.Codes))]
  firstbl <- x$Week[first(grep("P$|PB$|BL$", x$Condition.Codes))]
  # Week that WP was first observed
  firstwp <- x$Week[first(grep("WP", x$Condition.Codes))]
  # Categorize response
  ifelse(!is.na(firstbl),  # check if sed...
         yes=ifelse(!is.na(firstwp),  # check if wp...
                    yes=ifelse(firstbl <= firstwp,
                               yes="bl, wp",
                               no="no bl, wp"),
                    no="bl, no wp"),
         no=ifelse(!is.na(firstwp),  # check if wp
                   yes="no bl, wp",
                   no="no bl, no wp"))
}
bltest <- ddply(sus, ~ Site + Transect + Coral.ID, bld)
# Add grouping factors
bltest$Channel <- ifelse(grepl("C", unlist(lapply(strsplit(bltest$Site, split = "-"), "[[", 1))), "control", "channelside")
bltest$reef <- substr(bltest$Site, 1, 2)
bltest$dir <- substr(bltest$Site, 3, 3)
with(bltest, table(V1), margin=1)
with(bltest, table(V1, Channel), margin=1)
with(bltest, table(V1, Channel, reef, dir), margin=1)

# WP prevalence channelside vs. control
wp <- function(x) {
  wp <- x$Week[first(grep("WP", x$Condition.Codes))]
  # Categorize response
  ifelse(!is.na(wp),  # check if wp
         yes="wp", no="no wp")
}
wptest <- ddply(sus, ~ Site + Transect + Coral.ID, wp)
# Add grouping factors
wptest$Channel <- ifelse(grepl("C", unlist(lapply(strsplit(as.character(wptest$Site), split = "-"), "[[", 1))), "control", "channelside")
wptest$reef <- substr(wptest$Site, 1, 2)
wptest$dir <- substr(wptest$Site, 3, 3)
with(wptest, table(V1), margin=1)
with(wptest, table(V1, reef), margin=1)
with(wptest, table(V1, Channel), margin=1)
with(wptest, table(V1, reef, Channel), margin=1)












##################
# R2NC3-LR is apparently missing from this dataset?
data.f <- data[data$Site %in% c("HBN3-CP", "HBNC1-CP", "HBS3-CP", "HBS4-CR", "HBSC1-CP",
                                "R2N1-RR", "R2N2-LR", "R2NC1-LR", "R2NC2-RR", "R2NC3-LR",
                                "R2S1-RR", "R2S2-LR", "R2SC1-RR", "R2SC2-LR", "R3N1-LR",
                                "R3NC1-LR", "R3S2-LR", "R3SC2-LR", "R3SC3-SG"), ]

with(data.f, unique(droplevels(interaction(Site, Transect, Coral.ID))))
# 468 tagged corals in this filtered subset.

sedwptest <- ddply(data.f, ~ Site + Transect + Coral.ID, sedwp)
# Add grouping factors
sedwptest$Channel <- ifelse(grepl("C", sedwptest$Site), "control", "channelside")
sedwptest$reef <- substr(sedwptest$Site, 1, 2)
sedwptest$dir <- substr(sedwptest$Site, 3, 3)
head(sedwptest)

with(sedwptest, table(V1))

