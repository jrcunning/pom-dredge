seddepth <- read.csv("data/DEP_responsive_records_May_2017/Copy of Cross_site_sediment_data_Port_Miami_Impact_Assessment _2-6-17.csv")

seddepth <- seddepth[, c(2,3,6,8,9,10,11,12)]
colnames(seddepth) <- c("Site", "Transect", "Position", "SedDepth", "Exposed.HB", "Sed.over.HB", "Sed.Only", "SedType")
seddepth$Site <- as.character(seddepth$Site)

seddepth$reef <- substr(seddepth$Site, 1, 2)

# Correct site labels
seddepth[seddepth$Site=="R2N1-350-RR", "Site"] <- "R2N-350-RR"
seddepth$dist <- do.call(rbind, lapply(strsplit(seddepth$Site, "-"), "[", 2))
seddepth


# Only permanent sites
perm <- subset(seddepth, !grepl("[0-9]", seddepth$dist))
perm <- droplevels(perm)
levels(factor(perm$Site))
mod <- lm(SedDepth ~ Site, data=perm)
anova(mod)
res <- cld(lsmeans(mod, specs="Site"))
res
contrast(lsmeans(mod, specs="Site"), "del.eff")

lsmeans(mod, specs="Site", contr="del.eff")

plot(lsmeans(mod, specs="Site"), xlab="Sediment depth (cm)")
write.csv(data.frame(res), file="seddepth.csv", row.names=F, quote=F)
png("seddepth.png", width=3, height=3, units="in", res=300)
plot(lsmeans(mod, specs="Site"), xlab="Sediment depth (cm)")
dev.off()


# Distance sites
dist <- subset(seddepth, grepl("[0-9]", seddepth$dist))
dist <- droplevels(dist)
levels(factor(dist$dist))
mod <- lm(SedDepth ~ Site, data=dist)
res <- cld(lsmeans(mod, specs="Site"))
res
plot(res)


mod <- lm(SedDepth ~ Site, data=seddepth)
res <- cld(lsmeans(mod, specs="Site"))
res
plot(res)



# texture
seddepth$SedType <- as.character(seddepth$SedType)
seddepth[which(seddepth$SedType==""), "SedType"] <- NA
seddepth[which(seddepth$SedType=="Corse"), "SedType"] <- "Coarse"
sedtex <- seddepth[!is.na(seddepth$SedType), ]

plot(table(sedtex$Site, sedtex$SedType)[,c(2,3,1)])

st <- prop.table(table(sedtex$Site, sedtex$SedType), margin=1)

stord <- st[c(10,11,7,8,1,2,3,4,5,6,9,12,13,14),]

png("texture.png", width=5, height=5, units="in", res=300)
par(mar=c(6,5,5,2))
barplot(t(stord[c(1,2,12,13,14), ]), col=c("white", "black", "gray"), las=2,
        ylab="Proportion of observations")
legend("top", pch=22, pt.cex=3, legend=c("Coarse", "Mixed", "Fine"),
       pt.bg=c("white", "gray", "black"), inset=c(0,-0.3), xpd=NA)
dev.off()

barplot(t(stord), col=c("white", "black", "gray"), las=2,
        ylab="Proportion of observations")
legend("top", pch=22, pt.cex=3, legend=c("Coarse", "Mixed", "Fine"),
       pt.bg=c("white", "gray", "black"), inset=c(0,-0.3), xpd=NA)
