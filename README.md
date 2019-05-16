This repository includes all data and analysis to accompany the manuscript:

## Extensive coral mortality and critical habitat loss following dredging and their association with remotely-sensed sediment plumes
**Authors:** Ross Cunning, Rachel N. Silverstein, Brian B. Barnes, Andrew C. Baker  
**Journal:** *Marine Pollution Bulletin*  
**Link:** (pending)  

-----

This work describes impacts to coral reefs surrounding the 2013-2015 dredging of the Port of Miami based on data collected before, during, and after dredging by Dial Cordy and Associates (DCA) on behalf of Great Lakes Dredge and Dock Company, the dredging contractors for the U.S. Army Corps of Engineers (USACE) and for the Port of Miami (Miami-Dade County). A front page for this repository can be accessed at [jrcunning.github.io/pom-dredge](http://jrcunning.github.io/pom-dredge) containing rendered R Markdown detailing all analyses conducted as part of this work. 

-----

### Repository contents:
#### Data:
* **data/sediment_traps/:** Sediment trap data from DCA

* **data/CPCe/:** Benthic cover CPCe analysis data from DCA

* **data/coral_counts/:** Coral count data from DCA

* **data/sediment_depth/:** Sediment depth data from DCA

* **data/sediment_traps/:** Sediment trap data from DCA

* **data/tagged_corals/:** Tagged coral condition data from DCA

* **data/plume/:** Satellite detections of sediment plume presence

* **data/reef_area/:** Area of coral reef and colonized hardbottom from GIS analysis

* **data/processed/:** .RData objects containing processed data and statistical models for all analyses

#### Rmd:
* **Rmd/tidy_count_data.Rmd:** Code to import and tidy coral count data

* **Rmd/tidy_cpce_data.Rmd:** Code to import and tidy CPCe data

* **Rmd/tidy_sed_depth_type.Rmd:** Code to import and tidy sediment depth data

* **Rmd/tidy_sedtrap_data.Rmd:** Code to import and tidy sediment trap data

* **Rmd/tidy_tagged_corals.Rmd:** Code to import tagged coral condition data

* **Rmd/dredge_plume.Rmd:** Code to analyze dredge plume presence at permanent monitoring sites

* **Rmd/sediment_trap.Rmd:** Code to analyze sediment trap data

* **Rmd/sed_cover.Rmd:** Code to analyze sediment cover from CPCe data

* **Rmd/sed_stress.Rmd:** Code to analyze sediment stress to tagged corals

* **Rmd/partial_mortality.Rmd:** Code to analyze partial mortality of tagged corals

* **Rmd/total_mortality.Rmd:** Code to analyze total mortality of tagged corals

* **Rmd/sed_depth.Rmd:** Code to analyze sediment depth data

* **Rmd/scler_density.Rmd:** Code to analyze scleractinian coral count (density) data

* **Rmd/nonsus_scler_density.Rmd:** Code to analyze non-disease-susceptible scleractinian coral count (density) data

* **Rmd/plume_predictions.Rmd:** Code to predict/extrapolate benthic impacts from sediment plume presence

* **Rmd/Figures.Rmd:** Code to produce all final figures for manuscript

* **Rmd/SupplementaryInfo.Rmd:** Code to produce the Supplementary Information for manuscript

#### Figures:
* **figures/\*:** Figures produced by [Rmd/Figures.Rmd](Rmd/Figures.Rmd), and tables

#### Reports:
* **reports/\*.pdf:** PDFs of reports referenced in this study from Dial Cordy and Associates (DCA), Florida Department of Environmental Protection (FDEP), and National Marine Fisheries Service (NMFS).
