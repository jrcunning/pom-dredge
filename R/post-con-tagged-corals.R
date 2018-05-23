
# Import data
postcon <- read.csv("data/DEP_responsive_records_May_2017/NEW_Offshore_Compliance_Scleractinian_Cond_R2_R3_IMPACT_ASSESS_data TAGGED CORALS.csv")
# Subset only columns containing raw data and no NAs
postcon <- na.omit(postcon[, c(1,4,5,7,9,10,11)])
# Reformat data
postcon <- within(postcon, {
  Date <- as.Date(Date, format="%m/%d/%y")
  Condition.Code <- as.character(Condition.Code)
})
postcon <- droplevels(postcon)

# Aggregate all conditions for each observed coral
postcon <- with(postcon, {
  aggregate(data.frame(Condition.Codes=Condition.Code), 
            by=list(Date=Date, Site=Site, Transect=Transect, 
                    Coral.ID=Coral.ID, Species=Species), 
            FUN=function(x) c(as.character(x)))
})
postcon <- postcon[with(postcon, order(Site, Transect, Coral.ID)), ]

# Add grouping factors
postcon$Channel <- ifelse(grepl("C", postcon$Site), "control", "channelside")
postcon$reef <- substr(postcon$Site, 1, 2)
postcon$dir <- substr(postcon$Site, 3, 3)
postcon$perm <- ifelse(
  grepl("[0-9]", lapply(strsplit(as.character(postcon$Site), "-"), "[", 2)),
  FALSE, TRUE)

# -----------
# PERMANENT MONITORING SITES ANALYSIS
#
# Subset tagged corals at permanent monitoring sites only
postcon.perm <- droplevels(subset(postcon, postcon$perm==TRUE))
postcon.perm$Site2 <- gsub("-.*$", "", postcon.perm$Site)

# List sites and count corals per site
table(postcon.perm$Site)       # 16 sites -- only 14 in report (report is missing *-CP and R3S3-SG)
sum(table(postcon.perm$Site))  # 413 total tagged corals @ R2/R3 with postcon data
                              # (only 333 in report)
table(postcon.perm$Channel)

# Analyze partial mortality (INCLUDES 'PM' and 'UPM' and 'DEAD' condition codes)
postcon.perm$PM <- grepl("PM|DEAD|PBUR|BUR", postcon.perm$Condition.Codes)

pm.mod <- glm(PM ~ Channel * reef * dir, family="binomial", data=postcon.perm)
anova(pm.mod, test="Chisq")
library(lsmeans)
lsmeans(pm.mod, specs=c("Channel", "reef", "dir"), type="response")

aggregate(postcon.perm$PM, by=list(postcon.perm$Site), FUN=mean)
## this partial mortality data does not match up with the tables in the reports. this is
## because the reports count cumulative partial mortality, i.e., if it was ever observed
## for a coral at any time. it reports more PM than we have in this dataset, because
## this dataset is only the observations from may 2015, does not include PM from other times.



# Analyze total mortality
postcon.perm$dead <- grepl("DEAD", postcon.perm$Condition.Codes)
with(postcon.perm, prop.table(table(Channel, dead), margin=1))



# Analyze white plague incidence
postcon.perm$wp <- grepl("WP", postcon.perm$Condition.Codes)
with(postcon.perm, prop.table(table(Channel, wp), margin=1))
postcon.perm

