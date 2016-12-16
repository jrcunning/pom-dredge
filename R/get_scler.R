library(tabulizer)
library(reshape2)
library(stringr)
options(stringsAsFactors = FALSE)

# Extract tables from each page of pdf for scleractinian corals
for (p in 1:52) {  # for the first 52 pages of pdf (=scleractinian data)
  columns <- ifelse(p %in% c(43, 47),  # create custom column coordinates for certain pages of pdf
                    list(seq(165, 700, 44)),
                    list(seq(150,750,48)))
  columns <- ifelse(p %in% c(37, 38, 39, 40), # create custom column coordinates for certain pages of pdf
                    list(seq(170, 750, 45)), columns)
  columns <- ifelse(p %in% c(48), # create custom column coordinates for certain pages of pdf
                    list(seq(160,750,48)), columns)
  tab <- extract_tables("data/raw/Appendix D. Counts of Scleractinians, Octocorals and Sponges during Base....pdf",
                        columns=columns, pages=p, guess=F)[[1]]  # extract table from pdf
  site <- strsplit(paste0(tab[grep("SITE", tab),], collapse=""), " ")[[1]][2]  # get site
  time <- strsplit(paste0(tab[grep("SITE", tab)-1,], collapse=""), " ")[[1]][1]  # get time (baseline vs. post-construction)
  headrows <- grep(pattern="TRANSECT", tab[,1])  # identify number of header rows in extracted table
  tailrows <- grep(pattern="Grand", tab[,1])  # identify tail rows, including total row
  tab <- tab[(headrows+1):(tailrows-1), -ncol(tab)]  # get rid of header and totals rows
  tab[tab==""] <- 0  # set blank cells to zero (no data is indicated by "-" in pdf)
  df <- setNames(data.frame(matrix(str_trim(tab), ncol=13)),
                 nm=c("species","w1t1","w1t2","w1t3","w2t1","w2t2","w2t3","w3t1","w3t2","w3t3","w4t1","w4t2","w4t3"))
  # Clean up tables that have errors
  if (p==39) {df <- df[-16,]; df[16,1] <- "Stephanocoenia intersepta"}
  df.m <- melt(df, id.vars="species")
  df.m <- cbind(df.m[,1],  # split variable column into week and transect
                matrix(unlist(strsplit(as.character(df.m$variable), "(?<=.{2})", perl = TRUE)), ncol=2, byrow=T),
                df.m[,3])
  df.m <- data.frame(df.m)
  colnames(df.m) <- c("species","week","transect","count")
  df.m$time <- time
  df.m$site <- site
  df.m
  assign(paste(site, time, sep="."), df.m)
}

# Merge all data together
scler <- do.call(rbind, lapply(ls(pattern="*BASELINE|*POST-CONSTRUCTION"), get))
# Convert to numeric and factor values
scler$count <- as.numeric(scler$count)
scler$week <- factor(scler$week)
scler$transect <- factor(scler$transect)
scler$time <- factor(scler$time)
scler$site <- factor(scler$site)
scler$species <- factor(scler$species)

# Save as RData
save(scler, file="data/scler.RData")
