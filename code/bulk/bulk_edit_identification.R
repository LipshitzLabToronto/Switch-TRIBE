pipeline_args <- commandArgs(trailingOnly = TRUE)
if (length(pipeline_args) < 2) {
  stop("Usage: Rscript bulk_edit_identification.R BULK_DATA_DIR OUTPUT_DIR")
}
bulk_data_dir <- normalizePath(pipeline_args[[1]], mustWork = TRUE)
output_dir <- pipeline_args[[2]]
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
output_dir <- normalizePath(output_dir, mustWork = TRUE)
library("dplyr")

# BRAT
  # input exp data 3 rep
BRAT_rep1_AtoG<-read.table(file.path(bulk_data_dir, "BRAT_BULK_REP_1_AtoG.txt"),header=T)
BRAT_rep2_AtoG<-read.table(file.path(bulk_data_dir, "BRAT_BULK_REP_2_AtoG.txt"),header=T)
BRAT_rep3_AtoG<-read.table(file.path(bulk_data_dir, "BRAT_BULK_REP_3_AtoG.txt"),header=T)
BRAT_rep1_TtoC<-read.table(file.path(bulk_data_dir, "BRAT_BULK_REP_1_TtoC.txt"),header=T)
BRAT_rep2_TtoC<-read.table(file.path(bulk_data_dir, "BRAT_BULK_REP_2_TtoC.txt"),header=T)
BRAT_rep3_TtoC<-read.table(file.path(bulk_data_dir, "BRAT_BULK_REP_3_TtoC.txt"),header=T)


BRAT_rep1_AtoG<-BRAT_rep1_AtoG[,c(3,4,5,8,10)]
BRAT_rep1_AtoG$chrcoord<-paste(BRAT_rep1_AtoG$chr,BRAT_rep1_AtoG$coord,sep=",")
BRAT_rep1_AtoG<-BRAT_rep1_AtoG[,c(4:6)]
colnames(BRAT_rep1_AtoG)<-c("G_BRAT_rep1","total_BRAT_rep1","chrcoord")
BRAT_rep2_AtoG<-BRAT_rep2_AtoG[,c(3,4,5,8,10)]
BRAT_rep2_AtoG$chrcoord<-paste(BRAT_rep2_AtoG$chr,BRAT_rep2_AtoG$coord,sep=",")
BRAT_rep2_AtoG<-BRAT_rep2_AtoG[,c(4:6)]
colnames(BRAT_rep2_AtoG)<-c("G_BRAT_rep2","total_BRAT_rep2","chrcoord")
BRAT_rep3_AtoG<-BRAT_rep3_AtoG[,c(3,4,5,8,10)]
BRAT_rep3_AtoG$chrcoord<-paste(BRAT_rep3_AtoG$chr,BRAT_rep3_AtoG$coord,sep=",")
BRAT_rep3_AtoG<-BRAT_rep3_AtoG[,c(4:6)]
colnames(BRAT_rep3_AtoG)<-c("G_BRAT_rep3","total_BRAT_rep3","chrcoord")

BRAT_rep1_TtoC$chrcoord<-paste(BRAT_rep1_TtoC$chr,BRAT_rep1_TtoC$coord,sep=",")
BRAT_rep1_TtoC<-BRAT_rep1_TtoC[,c(7,10,11)]
colnames(BRAT_rep1_TtoC)<-c("C_BRAT_rep1","total_BRAT_rep1","chrcoord")
BRAT_rep2_TtoC$chrcoord<-paste(BRAT_rep2_TtoC$chr,BRAT_rep2_TtoC$coord,sep=",")
BRAT_rep2_TtoC<-BRAT_rep2_TtoC[,c(7,10,11)]
colnames(BRAT_rep2_TtoC)<-c("C_BRAT_rep2","total_BRAT_rep2","chrcoord")
BRAT_rep3_TtoC$chrcoord<-paste(BRAT_rep3_TtoC$chr,BRAT_rep3_TtoC$coord,sep=",")
BRAT_rep3_TtoC<-BRAT_rep3_TtoC[,c(7,10,11)]
colnames(BRAT_rep3_TtoC)<-c("C_BRAT_rep3","total_BRAT_rep3","chrcoord")

  # select sites shown in at least 2 rep as potential targets
BRAT_1_2<-inner_join(BRAT_rep1_AtoG,BRAT_rep2_AtoG,by="chrcoord")
BRAT_2_3<-inner_join(BRAT_rep2_AtoG,BRAT_rep3_AtoG,by="chrcoord")
BRAT_1_3<-inner_join(BRAT_rep1_AtoG,BRAT_rep3_AtoG,by="chrcoord")

BRAT_1_2_TtoC<-inner_join(BRAT_rep1_TtoC,BRAT_rep2_TtoC,by="chrcoord")
BRAT_2_3_TtoC<-inner_join(BRAT_rep2_TtoC,BRAT_rep3_TtoC,by="chrcoord")
BRAT_1_3_TtoC<-inner_join(BRAT_rep1_TtoC,BRAT_rep3_TtoC,by="chrcoord")

BRAT_potential_site<-full_join(BRAT_1_2,BRAT_2_3,by="chrcoord")
BRAT_potential_site<-full_join(BRAT_potential_site,BRAT_1_3,by="chrcoord")
BRAT_potential_site<-as.data.frame(BRAT_potential_site$chrcoord)
colnames(BRAT_potential_site)<-"chrcoord"
BRAT_potential_site<-left_join(BRAT_potential_site,BRAT_rep1_AtoG,by="chrcoord")
BRAT_potential_site<-left_join(BRAT_potential_site,BRAT_rep2_AtoG,by="chrcoord")
BRAT_potential_site<-left_join(BRAT_potential_site,BRAT_rep3_AtoG,by="chrcoord")
BRAT_potential_site[is.na(BRAT_potential_site)]<-0

BRAT_potential_site_TtoC<-full_join(BRAT_1_2_TtoC,BRAT_2_3_TtoC,by="chrcoord")
BRAT_potential_site_TtoC<-full_join(BRAT_potential_site_TtoC,BRAT_1_3_TtoC,by="chrcoord")
BRAT_potential_site_TtoC<-as.data.frame(BRAT_potential_site_TtoC$chrcoord)
colnames(BRAT_potential_site_TtoC)<-"chrcoord"
BRAT_potential_site_TtoC<-left_join(BRAT_potential_site_TtoC,BRAT_rep1_TtoC,by="chrcoord")
BRAT_potential_site_TtoC<-left_join(BRAT_potential_site_TtoC,BRAT_rep2_TtoC,by="chrcoord")
BRAT_potential_site_TtoC<-left_join(BRAT_potential_site_TtoC,BRAT_rep3_TtoC,by="chrcoord")


  # add counts in control
     # A to G
           # remove if any site is G-rich in any control replicates
CTRL_INSC_REP_1_Gref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_1_Gref.txt"),header=T)
CTRL_INSC_REP_1_Gref$chrcoord<-paste(CTRL_INSC_REP_1_Gref$chr,CTRL_INSC_REP_1_Gref$coord,sep=",")
BRAT_potential_site<-anti_join(BRAT_potential_site,CTRL_INSC_REP_1_Gref,by="chrcoord")
rm(CTRL_INSC_REP_1_Gref)

CTRL_INSC_REP_2_Gref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_2_Gref.txt"),header=T)
CTRL_INSC_REP_2_Gref$chrcoord<-paste(CTRL_INSC_REP_2_Gref$chr,CTRL_INSC_REP_2_Gref$coord,sep=",")
BRAT_potential_site<-anti_join(BRAT_potential_site,CTRL_INSC_REP_2_Gref,by="chrcoord")
rm(CTRL_INSC_REP_2_Gref)

CTRL_INSC_REP_3_Gref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_3_Gref.txt"),header=T)
CTRL_INSC_REP_3_Gref$chrcoord<-paste(CTRL_INSC_REP_3_Gref$chr,CTRL_INSC_REP_3_Gref$coord,sep=",")
BRAT_potential_site<-anti_join(BRAT_potential_site,CTRL_INSC_REP_3_Gref,by="chrcoord")
rm(CTRL_INSC_REP_3_Gref)

CTRL_YH98_REP_1_Gref<-read.table(file.path(bulk_data_dir, "CTRL_YH98_REP_1_Gref.txt"),header=T)
CTRL_YH98_REP_1_Gref$chrcoord<-paste(CTRL_YH98_REP_1_Gref$chr,CTRL_YH98_REP_1_Gref$coord,sep=",")
BRAT_potential_site<-anti_join(BRAT_potential_site,CTRL_YH98_REP_1_Gref,by="chrcoord")
rm(CTRL_YH98_REP_1_Gref)

CTRL_YH98_REP_2_Gref<-read.table(file.path(bulk_data_dir, "CTRL_YH98_REP_2_Gref.txt"),header=T)
CTRL_YH98_REP_2_Gref$chrcoord<-paste(CTRL_YH98_REP_2_Gref$chr,CTRL_YH98_REP_2_Gref$coord,sep=",")
BRAT_potential_site<-anti_join(BRAT_potential_site,CTRL_YH98_REP_2_Gref,by="chrcoord")
rm(CTRL_YH98_REP_2_Gref)

CTRL_YH98_REP_3_Gref<-read.table(file.path(bulk_data_dir, "CTRL_YH98_REP_3_Gref.txt"),header=T)
CTRL_YH98_REP_3_Gref$chrcoord<-paste(CTRL_YH98_REP_3_Gref$chr,CTRL_YH98_REP_3_Gref$coord,sep=",")
BRAT_potential_site<-anti_join(BRAT_potential_site,CTRL_YH98_REP_3_Gref,by="chrcoord")
rm(CTRL_YH98_REP_3_Gref)

           # annotate count info in control reps
CTRL_INSC_REP_1_Aref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_1_Aref.txt"),header=T)
CTRL_INSC_REP_1_Aref$chrcoord<-paste(CTRL_INSC_REP_1_Aref$chr,CTRL_INSC_REP_1_Aref$coord,sep=",")
CTRL_INSC_REP_1_Aref<-CTRL_INSC_REP_1_Aref[,c(8,10,11)]
colnames(CTRL_INSC_REP_1_Aref)<-c("G_INSC_rep1","total_INSC_rep1","chrcoord")
BRAT_potential_site<-left_join(BRAT_potential_site,CTRL_INSC_REP_1_Aref,by="chrcoord")
rm(CTRL_INSC_REP_1_Aref)

CTRL_INSC_REP_2_Aref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_2_Aref.txt"),header=T)
CTRL_INSC_REP_2_Aref$chrcoord<-paste(CTRL_INSC_REP_2_Aref$chr,CTRL_INSC_REP_2_Aref$coord,sep=",")
CTRL_INSC_REP_2_Aref<-CTRL_INSC_REP_2_Aref[,c(8,10,11)]
colnames(CTRL_INSC_REP_2_Aref)<-c("G_INSC_rep2","total_INSC_rep2","chrcoord")
BRAT_potential_site<-left_join(BRAT_potential_site,CTRL_INSC_REP_2_Aref,by="chrcoord")
rm(CTRL_INSC_REP_2_Aref)

CTRL_INSC_REP_3_Aref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_3_Aref.txt"),header=T)
CTRL_INSC_REP_3_Aref$chrcoord<-paste(CTRL_INSC_REP_3_Aref$chr,CTRL_INSC_REP_3_Aref$coord,sep=",")
CTRL_INSC_REP_3_Aref<-CTRL_INSC_REP_3_Aref[,c(8,10,11)]
colnames(CTRL_INSC_REP_3_Aref)<-c("G_INSC_rep3","total_INSC_rep3","chrcoord")
BRAT_potential_site<-left_join(BRAT_potential_site,CTRL_INSC_REP_3_Aref,by="chrcoord")
rm(CTRL_INSC_REP_3_Aref)

CTRL_YH98_REP_1_Aref<-read.table(file.path(bulk_data_dir, "CTRL_YH98_REP_1_Aref.txt"),header=T)
CTRL_YH98_REP_1_Aref$chrcoord<-paste(CTRL_YH98_REP_1_Aref$chr,CTRL_YH98_REP_1_Aref$coord,sep=",")
CTRL_YH98_REP_1_Aref<-CTRL_YH98_REP_1_Aref[,c(8,10,11)]
colnames(CTRL_YH98_REP_1_Aref)<-c("G_YH98_rep1","total_YH98_rep1","chrcoord")
BRAT_potential_site<-left_join(BRAT_potential_site,CTRL_YH98_REP_1_Aref,by="chrcoord")
rm(CTRL_YH98_REP_1_Aref)

CTRL_YH98_REP_2_Aref<-read.table(file.path(bulk_data_dir, "CTRL_YH98_REP_2_Aref.txt"),header=T)
CTRL_YH98_REP_2_Aref$chrcoord<-paste(CTRL_YH98_REP_2_Aref$chr,CTRL_YH98_REP_2_Aref$coord,sep=",")
CTRL_YH98_REP_2_Aref<-CTRL_YH98_REP_2_Aref[,c(8,10,11)]
colnames(CTRL_YH98_REP_2_Aref)<-c("G_YH98_rep2","total_YH98_rep2","chrcoord")
BRAT_potential_site<-left_join(BRAT_potential_site,CTRL_YH98_REP_2_Aref,by="chrcoord")
rm(CTRL_YH98_REP_2_Aref)

CTRL_YH98_REP_3_Aref<-read.table(file.path(bulk_data_dir, "CTRL_YH98_REP_3_Aref.txt"),header=T)
CTRL_YH98_REP_3_Aref$chrcoord<-paste(CTRL_YH98_REP_3_Aref$chr,CTRL_YH98_REP_3_Aref$coord,sep=",")
CTRL_YH98_REP_3_Aref<-CTRL_YH98_REP_3_Aref[,c(8,10,11)]
colnames(CTRL_YH98_REP_3_Aref)<-c("G_YH98_rep3","total_YH98_rep3","chrcoord")
BRAT_potential_site<-left_join(BRAT_potential_site,CTRL_YH98_REP_3_Aref,by="chrcoord")
rm(CTRL_YH98_REP_3_Aref)



BRAT_potential_site_backup<-BRAT_potential_site
BRAT_potential_site[is.na(BRAT_potential_site)]<-0 # add zero; <30 reads: not enough; remove non-significant


     # T to C
           # remove if any site is C-rich in any control replicates (remove SNP)
CTRL_INSC_REP_1_Cref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_1_Cref.txt"),header=T)
CTRL_INSC_REP_1_Cref$chrcoord<-paste(CTRL_INSC_REP_1_Cref$chr,CTRL_INSC_REP_1_Cref$coord,sep=",")
BRAT_potential_site_TtoC<-anti_join(BRAT_potential_site_TtoC,CTRL_INSC_REP_1_Cref,by="chrcoord")
rm(CTRL_INSC_REP_1_Cref)

CTRL_INSC_REP_2_Cref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_2_Cref.txt"),header=T)
CTRL_INSC_REP_2_Cref$chrcoord<-paste(CTRL_INSC_REP_2_Cref$chr,CTRL_INSC_REP_2_Cref$coord,sep=",")
BRAT_potential_site_TtoC<-anti_join(BRAT_potential_site_TtoC,CTRL_INSC_REP_2_Cref,by="chrcoord")
rm(CTRL_INSC_REP_2_Cref)

CTRL_INSC_REP_3_Cref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_3_Cref.txt"),header=T)
CTRL_INSC_REP_3_Cref$chrcoord<-paste(CTRL_INSC_REP_3_Cref$chr,CTRL_INSC_REP_3_Cref$coord,sep=",")
BRAT_potential_site_TtoC<-anti_join(BRAT_potential_site_TtoC,CTRL_INSC_REP_3_Cref,by="chrcoord")
rm(CTRL_INSC_REP_3_Cref)

CTRL_YH98_REP_1_Cref<-read.table(file.path(bulk_data_dir, "CTRL_YH98_REP_1_Cref.txt"),header=T)
CTRL_YH98_REP_1_Cref$chrcoord<-paste(CTRL_YH98_REP_1_Cref$chr,CTRL_YH98_REP_1_Cref$coord,sep=",")
BRAT_potential_site_TtoC<-anti_join(BRAT_potential_site_TtoC,CTRL_YH98_REP_1_Cref,by="chrcoord")
rm(CTRL_YH98_REP_1_Cref)

CTRL_YH98_REP_2_Cref<-read.table(file.path(bulk_data_dir, "CTRL_YH98_REP_2_Cref.txt"),header=T)
CTRL_YH98_REP_2_Cref$chrcoord<-paste(CTRL_YH98_REP_2_Cref$chr,CTRL_YH98_REP_2_Cref$coord,sep=",")
BRAT_potential_site_TtoC<-anti_join(BRAT_potential_site_TtoC,CTRL_YH98_REP_2_Cref,by="chrcoord")
rm(CTRL_YH98_REP_2_Cref)

CTRL_YH98_REP_3_Cref<-read.table(file.path(bulk_data_dir, "CTRL_YH98_REP_3_Cref.txt"),header=T)
CTRL_YH98_REP_3_Cref$chrcoord<-paste(CTRL_YH98_REP_3_Cref$chr,CTRL_YH98_REP_3_Cref$coord,sep=",")
BRAT_potential_site_TtoC<-anti_join(BRAT_potential_site_TtoC,CTRL_YH98_REP_3_Cref,by="chrcoord")
rm(CTRL_YH98_REP_3_Cref)


           # annotate count info in control reps

CTRL_INSC_REP_1_Tref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_1_Tref.txt"),header=T)
CTRL_INSC_REP_1_Tref$chrcoord<-paste(CTRL_INSC_REP_1_Tref$chr,CTRL_INSC_REP_1_Tref$coord,sep=",")
CTRL_INSC_REP_1_Tref<-CTRL_INSC_REP_1_Tref[,c(7,10,11)]
colnames(CTRL_INSC_REP_1_Tref)<-c("C_INSC_rep1","total_INSC_rep1","chrcoord")
BRAT_potential_site_TtoC<-left_join(BRAT_potential_site_TtoC,CTRL_INSC_REP_1_Tref,by="chrcoord")
rm(CTRL_INSC_REP_1_Tref)

CTRL_INSC_REP_2_Tref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_2_Tref.txt"),header=T)
CTRL_INSC_REP_2_Tref$chrcoord<-paste(CTRL_INSC_REP_2_Tref$chr,CTRL_INSC_REP_2_Tref$coord,sep=",")
CTRL_INSC_REP_2_Tref<-CTRL_INSC_REP_2_Tref[,c(7,10,11)]
colnames(CTRL_INSC_REP_2_Tref)<-c("C_INSC_rep2","total_INSC_rep2","chrcoord")
BRAT_potential_site_TtoC<-left_join(BRAT_potential_site_TtoC,CTRL_INSC_REP_2_Tref,by="chrcoord")
rm(CTRL_INSC_REP_2_Tref)

CTRL_INSC_REP_3_Tref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_3_Tref.txt"),header=T)
CTRL_INSC_REP_3_Tref$chrcoord<-paste(CTRL_INSC_REP_3_Tref$chr,CTRL_INSC_REP_3_Tref$coord,sep=",")
CTRL_INSC_REP_3_Tref<-CTRL_INSC_REP_3_Tref[,c(7,10,11)]
colnames(CTRL_INSC_REP_3_Tref)<-c("C_INSC_rep3","total_INSC_rep3","chrcoord")
BRAT_potential_site_TtoC<-left_join(BRAT_potential_site_TtoC,CTRL_INSC_REP_3_Tref,by="chrcoord")
rm(CTRL_INSC_REP_3_Tref)

CTRL_YH98_REP_1_Tref<-read.table(file.path(bulk_data_dir, "CTRL_YH98_REP_1_Tref.txt"),header=T)
CTRL_YH98_REP_1_Tref$chrcoord<-paste(CTRL_YH98_REP_1_Tref$chr,CTRL_YH98_REP_1_Tref$coord,sep=",")
CTRL_YH98_REP_1_Tref<-CTRL_YH98_REP_1_Tref[,c(7,10,11)]
colnames(CTRL_YH98_REP_1_Tref)<-c("C_YH98_rep1","total_YH98_rep1","chrcoord")
BRAT_potential_site_TtoC<-left_join(BRAT_potential_site_TtoC,CTRL_YH98_REP_1_Tref,by="chrcoord")
rm(CTRL_YH98_REP_1_Tref)

CTRL_YH98_REP_2_Tref<-read.table(file.path(bulk_data_dir, "CTRL_YH98_REP_2_Tref.txt"),header=T)
CTRL_YH98_REP_2_Tref$chrcoord<-paste(CTRL_YH98_REP_2_Tref$chr,CTRL_YH98_REP_2_Tref$coord,sep=",")
CTRL_YH98_REP_2_Tref<-CTRL_YH98_REP_2_Tref[,c(7,10,11)]
colnames(CTRL_YH98_REP_2_Tref)<-c("C_YH98_rep2","total_YH98_rep2","chrcoord")
BRAT_potential_site_TtoC<-left_join(BRAT_potential_site_TtoC,CTRL_YH98_REP_2_Tref,by="chrcoord")
rm(CTRL_YH98_REP_2_Tref)

CTRL_YH98_REP_3_Tref<-read.table(file.path(bulk_data_dir, "CTRL_YH98_REP_3_Tref.txt"),header=T)
CTRL_YH98_REP_3_Tref$chrcoord<-paste(CTRL_YH98_REP_3_Tref$chr,CTRL_YH98_REP_3_Tref$coord,sep=",")
CTRL_YH98_REP_3_Tref<-CTRL_YH98_REP_3_Tref[,c(7,10,11)]
colnames(CTRL_YH98_REP_3_Tref)<-c("C_YH98_rep3","total_YH98_rep3","chrcoord")
BRAT_potential_site_TtoC<-left_join(BRAT_potential_site_TtoC,CTRL_YH98_REP_3_Tref,by="chrcoord")
rm(CTRL_YH98_REP_3_Tref)

BRAT_potential_site_TtoC_backup<-BRAT_potential_site_TtoC
BRAT_potential_site_TtoC[is.na(BRAT_potential_site_TtoC)]<-0

# process data
  # A to G
BRAT_potential_site$exp_G<-BRAT_potential_site$G_BRAT_rep1+BRAT_potential_site$G_BRAT_rep2+BRAT_potential_site$G_BRAT_rep3
BRAT_potential_site$exp_total<-BRAT_potential_site$total_BRAT_rep1+BRAT_potential_site$total_BRAT_rep2+BRAT_potential_site$total_BRAT_rep3
BRAT_potential_site$exp_notG<-BRAT_potential_site$exp_total-BRAT_potential_site$exp_G

BRAT_potential_site$ctr1_G<-BRAT_potential_site$G_INSC_rep1+BRAT_potential_site$G_INSC_rep2+BRAT_potential_site$G_INSC_rep3
BRAT_potential_site$ctr1_total<-BRAT_potential_site$total_INSC_rep1+BRAT_potential_site$total_INSC_rep2+BRAT_potential_site$total_INSC_rep3
BRAT_potential_site$ctr1_notG<-BRAT_potential_site$ctr1_total-BRAT_potential_site$ctr1_G

BRAT_potential_site$ctr2_G<-BRAT_potential_site$G_YH98_rep1+BRAT_potential_site$G_YH98_rep2+BRAT_potential_site$G_YH98_rep3
BRAT_potential_site$ctr2_total<-BRAT_potential_site$total_YH98_rep1+BRAT_potential_site$total_YH98_rep2+BRAT_potential_site$total_YH98_rep3
BRAT_potential_site$ctr2_notG<-BRAT_potential_site$ctr2_total-BRAT_potential_site$ctr2_G

BRAT_potential_site$G_rate_change_1<-(BRAT_potential_site$exp_G/BRAT_potential_site$exp_total)-(BRAT_potential_site$ctr1_G/BRAT_potential_site$ctr1_total)
BRAT_potential_site$G_rate_change_2<-(BRAT_potential_site$exp_G/BRAT_potential_site$exp_total)-(BRAT_potential_site$ctr2_G/BRAT_potential_site$ctr2_total)

BRAT_potential_site_chisq_ctr1<-BRAT_potential_site[,c(20,22,23,25)]
BRAT_potential_site_chisq_ctr2<-BRAT_potential_site[,c(20,22,26,28)]
  # T to C
BRAT_potential_site_TtoC$exp_C<-BRAT_potential_site_TtoC$C_BRAT_rep1+BRAT_potential_site_TtoC$C_BRAT_rep2+BRAT_potential_site_TtoC$C_BRAT_rep3
BRAT_potential_site_TtoC$exp_total<-BRAT_potential_site_TtoC$total_BRAT_rep1+BRAT_potential_site_TtoC$total_BRAT_rep2+BRAT_potential_site_TtoC$total_BRAT_rep3
BRAT_potential_site_TtoC$exp_notC<-BRAT_potential_site_TtoC$exp_total-BRAT_potential_site_TtoC$exp_C

BRAT_potential_site_TtoC$ctr1_C<-BRAT_potential_site_TtoC$C_INSC_rep1+BRAT_potential_site_TtoC$C_INSC_rep2+BRAT_potential_site_TtoC$C_INSC_rep3
BRAT_potential_site_TtoC$ctr1_total<-BRAT_potential_site_TtoC$total_INSC_rep1+BRAT_potential_site_TtoC$total_INSC_rep2+BRAT_potential_site_TtoC$total_INSC_rep3
BRAT_potential_site_TtoC$ctr1_notC<-BRAT_potential_site_TtoC$ctr1_total-BRAT_potential_site_TtoC$ctr1_C

BRAT_potential_site_TtoC$ctr2_C<-BRAT_potential_site_TtoC$C_YH98_rep1+BRAT_potential_site_TtoC$C_YH98_rep2+BRAT_potential_site_TtoC$C_YH98_rep3
BRAT_potential_site_TtoC$ctr2_total<-BRAT_potential_site_TtoC$total_YH98_rep1+BRAT_potential_site_TtoC$total_YH98_rep2+BRAT_potential_site_TtoC$total_YH98_rep3
BRAT_potential_site_TtoC$ctr2_notC<-BRAT_potential_site_TtoC$ctr2_total-BRAT_potential_site_TtoC$ctr2_C

BRAT_potential_site_TtoC$C_rate_change_1<-(BRAT_potential_site_TtoC$exp_C/BRAT_potential_site_TtoC$exp_total)-(BRAT_potential_site_TtoC$ctr1_C/BRAT_potential_site_TtoC$ctr1_total)
BRAT_potential_site_TtoC$C_rate_change_2<-(BRAT_potential_site_TtoC$exp_C/BRAT_potential_site_TtoC$exp_total)-(BRAT_potential_site_TtoC$ctr2_C/BRAT_potential_site_TtoC$ctr2_total)

BRAT_potential_site_TtoC_chisq_ctr1<-BRAT_potential_site_TtoC[,c(20,22,23,25)]
BRAT_potential_site_TtoC_chisq_ctr2<-BRAT_potential_site_TtoC[,c(20,22,26,28)]

  # calculate chi-square

BRAT_potential_site_chisq_ctr1$P_chisq_ctr1<-apply(BRAT_potential_site_chisq_ctr1,1,function(row){
    mtx<-data.frame(exp=row[c(1,2)],ctr=row[c(3,4)])
    test_result<-chisq.test(mtx)
    return(test_result$p.value)
    })
BRAT_potential_site_chisq_ctr2$P_chisq_ctr2<-apply(BRAT_potential_site_chisq_ctr2,1,function(row){
    mtx<-data.frame(exp=row[c(1,2)],ctr=row[c(3,4)])
    test_result<-chisq.test(mtx)
    return(test_result$p.value)
    })

BRAT_potential_site_TtoC_chisq_ctr1$P_chisq_ctr1<-apply(BRAT_potential_site_TtoC_chisq_ctr1,1,function(row){
    mtx<-data.frame(exp=row[c(1,2)],ctr=row[c(3,4)])
    test_result<-chisq.test(mtx)
    return(test_result$p.value)
    })
BRAT_potential_site_TtoC_chisq_ctr2$P_chisq_ctr2<-apply(BRAT_potential_site_TtoC_chisq_ctr2,1,function(row){
    mtx<-data.frame(exp=row[c(1,2)],ctr=row[c(3,4)])
    test_result<-chisq.test(mtx)
    return(test_result$p.value)
    })
  

  # fill table

BRAT_potential_site_chisq_ctr1$chrcoord<-BRAT_potential_site$chrcoord
BRAT_potential_site_chisq_ctr1$G_rate_change<-BRAT_potential_site$G_rate_change_1

BRAT_potential_site_chisq_ctr2$chrcoord<-BRAT_potential_site$chrcoord
BRAT_potential_site_chisq_ctr2$G_rate_change<-BRAT_potential_site$G_rate_change_2

BRAT_potential_site_TtoC_chisq_ctr1$chrcoord<-BRAT_potential_site_TtoC$chrcoord
BRAT_potential_site_TtoC_chisq_ctr1$C_rate_change<-BRAT_potential_site_TtoC$C_rate_change_1

BRAT_potential_site_TtoC_chisq_ctr2$chrcoord<-BRAT_potential_site_TtoC$chrcoord
BRAT_potential_site_TtoC_chisq_ctr2$C_rate_change<-BRAT_potential_site_TtoC$C_rate_change_2

BRAT_potential_site_chisq_ctr1$P_chisq_ctr1[is.nan(BRAT_potential_site_chisq_ctr1$P_chisq_ctr1)]<-1
BRAT_potential_site_chisq_ctr1$sig<-NA
for (i in 1:nrow(BRAT_potential_site_chisq_ctr1)){
  if(BRAT_potential_site_chisq_ctr1$P_chisq_ctr1[i]<0.025){
    BRAT_potential_site_chisq_ctr1$sig[i]=1
  }
  else{
    BRAT_potential_site_chisq_ctr1$sig[i]=-1
  }
  if(BRAT_potential_site_chisq_ctr1$ctr1_notG[i]<30){
BRAT_potential_site_chisq_ctr1$sig[i]=0
}
}

BRAT_potential_site_chisq_ctr2$P_chisq_ctr2[is.nan(BRAT_potential_site_chisq_ctr2$P_chisq_ctr2)]<-1
BRAT_potential_site_chisq_ctr2$sig<-NA
for (i in 1:nrow(BRAT_potential_site_chisq_ctr2)){
  if(BRAT_potential_site_chisq_ctr2$P_chisq_ctr2[i]<0.025){
    BRAT_potential_site_chisq_ctr2$sig[i]=1
  }
  else{
    BRAT_potential_site_chisq_ctr2$sig[i]=-1
  }
  if(BRAT_potential_site_chisq_ctr2$ctr2_notG[i]<30){
BRAT_potential_site_chisq_ctr2$sig[i]=0
}
}

     # t to c
BRAT_potential_site_TtoC_chisq_ctr1$P_chisq_ctr1[is.nan(BRAT_potential_site_TtoC_chisq_ctr1$P_chisq_ctr1)]<-1
BRAT_potential_site_TtoC_chisq_ctr1$sig<-NA
for (i in 1:nrow(BRAT_potential_site_TtoC_chisq_ctr1)){
  if(BRAT_potential_site_TtoC_chisq_ctr1$P_chisq_ctr1[i]<0.025){
    BRAT_potential_site_TtoC_chisq_ctr1$sig[i]=1
  }
  else{
    BRAT_potential_site_TtoC_chisq_ctr1$sig[i]=-1
  }
  if(BRAT_potential_site_TtoC_chisq_ctr1$ctr1_notC[i]<30){
BRAT_potential_site_TtoC_chisq_ctr1$sig[i]=0
}
}

BRAT_potential_site_TtoC_chisq_ctr2$P_chisq_ctr2[is.nan(BRAT_potential_site_TtoC_chisq_ctr2$P_chisq_ctr2)]<-1
BRAT_potential_site_TtoC_chisq_ctr2$sig<-NA
for (i in 1:nrow(BRAT_potential_site_TtoC_chisq_ctr2)){
  if(BRAT_potential_site_TtoC_chisq_ctr2$P_chisq_ctr2[i]<0.025){
    BRAT_potential_site_TtoC_chisq_ctr2$sig[i]=1
  }
  else{
    BRAT_potential_site_TtoC_chisq_ctr2$sig[i]=-1
  }
  if(BRAT_potential_site_TtoC_chisq_ctr2$ctr2_notC[i]<30){
BRAT_potential_site_TtoC_chisq_ctr2$sig[i]=0
}
}

# select 
    #G rate change > 0 in exp && chisq P < 0.025 score >0, while sig +1, not enough +0, nonsig -1

BRAT_TRIBE_site_chisq<-BRAT_potential_site_chisq_ctr1[,c(6,7,8)]
colnames(BRAT_TRIBE_site_chisq)<-c("chrcoord","G_rate_ctr1","sig_ctr1")
BRAT_TRIBE_site_chisq$G_rate_ctr2<-BRAT_potential_site_chisq_ctr2$G_rate_change
BRAT_TRIBE_site_chisq$sig_ctr2<-BRAT_potential_site_chisq_ctr2$sig
BRAT_TRIBE_site_chisq$total_sig<-BRAT_TRIBE_site_chisq$sig_ctr1+BRAT_TRIBE_site_chisq$sig_ctr2
BRAT_TRIBE_site_chisq<-BRAT_TRIBE_site_chisq[BRAT_TRIBE_site_chisq$total_sig>0,]
BRAT_TRIBE_site_chisq$G_rate_ctr1[is.nan(BRAT_TRIBE_site_chisq$G_rate_ctr1)]<-0
BRAT_TRIBE_site_chisq$G_rate_ctr2[is.nan(BRAT_TRIBE_site_chisq$G_rate_ctr2)]<-0
BRAT_TRIBE_site_chisq<-BRAT_TRIBE_site_chisq[BRAT_TRIBE_site_chisq$G_rate_ctr1>=0,]
BRAT_TRIBE_site_chisq<-BRAT_TRIBE_site_chisq[BRAT_TRIBE_site_chisq$G_rate_ctr2>=0,]

BRAT_TRIBE_site_TtoC_chisq<-BRAT_potential_site_TtoC_chisq_ctr1[,c(6,7,8)]
colnames(BRAT_TRIBE_site_TtoC_chisq)<-c("chrcoord","C_rate_ctr1","sig_ctr1")
BRAT_TRIBE_site_TtoC_chisq$C_rate_ctr2<-BRAT_potential_site_TtoC_chisq_ctr2$C_rate_change
BRAT_TRIBE_site_TtoC_chisq$sig_ctr2<-BRAT_potential_site_TtoC_chisq_ctr2$sig
BRAT_TRIBE_site_TtoC_chisq$total_sig<-BRAT_TRIBE_site_TtoC_chisq$sig_ctr1+BRAT_TRIBE_site_TtoC_chisq$sig_ctr2
BRAT_TRIBE_site_TtoC_chisq<-BRAT_TRIBE_site_TtoC_chisq[BRAT_TRIBE_site_TtoC_chisq$total_sig>0,]
BRAT_TRIBE_site_TtoC_chisq$C_rate_ctr1[is.nan(BRAT_TRIBE_site_TtoC_chisq$C_rate_ctr1)]<-0
BRAT_TRIBE_site_TtoC_chisq$C_rate_ctr2[is.nan(BRAT_TRIBE_site_TtoC_chisq$C_rate_ctr2)]<-0
BRAT_TRIBE_site_TtoC_chisq<-BRAT_TRIBE_site_TtoC_chisq[BRAT_TRIBE_site_TtoC_chisq$C_rate_ctr1>=0,]
BRAT_TRIBE_site_TtoC_chisq<-BRAT_TRIBE_site_TtoC_chisq[BRAT_TRIBE_site_TtoC_chisq$C_rate_ctr2>=0,]








  # write bed file
          # AtoG
BRAT_TRIBE_AtoG_bed<-BRAT_TRIBE_site_chisq
BRAT_TRIBE_AtoG_bed$coord<-NA
BRAT_TRIBE_AtoG_bed$chr<-NA

for (i in 1:nrow(BRAT_TRIBE_AtoG_bed)){
BRAT_TRIBE_AtoG_bed$chr[i]<-unlist(strsplit(BRAT_TRIBE_AtoG_bed$chrcoord[i],','))[1]
BRAT_TRIBE_AtoG_bed$coord[i]<-unlist(strsplit(BRAT_TRIBE_AtoG_bed$chrcoord[i],','))[2]
}

BRAT_TRIBE_AtoG_bed<-BRAT_TRIBE_AtoG_bed[,c(8,7)]
BRAT_TRIBE_AtoG_bed$coordplus<-as.numeric(BRAT_TRIBE_AtoG_bed$coord)+1
colnames(BRAT_TRIBE_AtoG_bed)<-c("chrom","chromStart","chromEnd")
BRAT_TRIBE_AtoG_bed$strand<-"+"
          # TtoC
BRAT_TRIBE_TtoC_bed<-BRAT_TRIBE_site_TtoC_chisq
BRAT_TRIBE_TtoC_bed$coord<-NA
BRAT_TRIBE_TtoC_bed$chr<-NA

for (i in 1:nrow(BRAT_TRIBE_TtoC_bed)){
BRAT_TRIBE_TtoC_bed$chr[i]<-unlist(strsplit(BRAT_TRIBE_TtoC_bed$chrcoord[i],','))[1]
BRAT_TRIBE_TtoC_bed$coord[i]<-unlist(strsplit(BRAT_TRIBE_TtoC_bed$chrcoord[i],','))[2]
}

BRAT_TRIBE_TtoC_bed<-BRAT_TRIBE_TtoC_bed[,c(8,7)]
BRAT_TRIBE_TtoC_bed$coordplus<-as.numeric(BRAT_TRIBE_TtoC_bed$coord)+1
colnames(BRAT_TRIBE_TtoC_bed)<-c("chrom","chromStart","chromEnd")
BRAT_TRIBE_TtoC_bed$strand<-"-"

         # Merge AtoG and TtoC
BRAT_TRIBE_bed<-rbind(BRAT_TRIBE_AtoG_bed,BRAT_TRIBE_TtoC_bed)
BRAT_TRIBE_bed$name<-"."
BRAT_TRIBE_bed$score<-"."
BRAT_TRIBE_bed<-BRAT_TRIBE_bed[,c(1,2,3,5,6,4)]


         # write bed file
write.table(BRAT_TRIBE_bed,file.path(output_dir, "BRAT_TRIBE_BULK_cor.bed"),quote=F,sep = "\t",row.names=F,col.names=F)



# MEI-P26: use ex4o control
  # input exp data 3 rep
MEIP26_rep1_AtoG<-read.table(file.path(bulk_data_dir, "MEIP26_BULK_REP_1_AtoG.txt"),header=T)
MEIP26_rep2_AtoG<-read.table(file.path(bulk_data_dir, "MEIP26_BULK_REP_2_AtoG.txt"),header=T)
MEIP26_rep3_AtoG<-read.table(file.path(bulk_data_dir, "MEIP26_BULK_REP_3_AtoG.txt"),header=T)

MEIP26_rep1_TtoC<-read.table(file.path(bulk_data_dir, "MEIP26_BULK_REP_1_TtoC.txt"),header=T)
MEIP26_rep2_TtoC<-read.table(file.path(bulk_data_dir, "MEIP26_BULK_REP_2_TtoC.txt"),header=T)
MEIP26_rep3_TtoC<-read.table(file.path(bulk_data_dir, "MEIP26_BULK_REP_3_TtoC.txt"),header=T)

MEIP26_rep1_AtoG<-MEIP26_rep1_AtoG[,c(3,4,5,8,10)]
MEIP26_rep1_AtoG$chrcoord<-paste(MEIP26_rep1_AtoG$chr,MEIP26_rep1_AtoG$coord,sep=",")
MEIP26_rep1_AtoG<-MEIP26_rep1_AtoG[,c(4:6)]
colnames(MEIP26_rep1_AtoG)<-c("G_MEIP26_rep1","total_MEIP26_rep1","chrcoord")
MEIP26_rep2_AtoG<-MEIP26_rep2_AtoG[,c(3,4,5,8,10)]
MEIP26_rep2_AtoG$chrcoord<-paste(MEIP26_rep2_AtoG$chr,MEIP26_rep2_AtoG$coord,sep=",")
MEIP26_rep2_AtoG<-MEIP26_rep2_AtoG[,c(4:6)]
colnames(MEIP26_rep2_AtoG)<-c("G_MEIP26_rep2","total_MEIP26_rep2","chrcoord")
MEIP26_rep3_AtoG<-MEIP26_rep3_AtoG[,c(3,4,5,8,10)]
MEIP26_rep3_AtoG$chrcoord<-paste(MEIP26_rep3_AtoG$chr,MEIP26_rep3_AtoG$coord,sep=",")
MEIP26_rep3_AtoG<-MEIP26_rep3_AtoG[,c(4:6)]
colnames(MEIP26_rep3_AtoG)<-c("G_MEIP26_rep3","total_MEIP26_rep3","chrcoord")

MEIP26_rep1_TtoC$chrcoord<-paste(MEIP26_rep1_TtoC$chr,MEIP26_rep1_TtoC$coord,sep=",")
MEIP26_rep1_TtoC<-MEIP26_rep1_TtoC[,c(7,10,11)]
colnames(MEIP26_rep1_TtoC)<-c("C_MEIP26_rep1","total_MEIP26_rep1","chrcoord")
MEIP26_rep2_TtoC$chrcoord<-paste(MEIP26_rep2_TtoC$chr,MEIP26_rep2_TtoC$coord,sep=",")
MEIP26_rep2_TtoC<-MEIP26_rep2_TtoC[,c(7,10,11)]
colnames(MEIP26_rep2_TtoC)<-c("C_MEIP26_rep2","total_MEIP26_rep2","chrcoord")
MEIP26_rep3_TtoC$chrcoord<-paste(MEIP26_rep3_TtoC$chr,MEIP26_rep3_TtoC$coord,sep=",")
MEIP26_rep3_TtoC<-MEIP26_rep3_TtoC[,c(7,10,11)]
colnames(MEIP26_rep3_TtoC)<-c("C_MEIP26_rep3","total_MEIP26_rep3","chrcoord")

  # select sites shown in at least 2 rep as potential targets
MEIP26_1_2<-inner_join(MEIP26_rep1_AtoG,MEIP26_rep2_AtoG,by="chrcoord")
MEIP26_2_3<-inner_join(MEIP26_rep2_AtoG,MEIP26_rep3_AtoG,by="chrcoord")
MEIP26_1_3<-inner_join(MEIP26_rep1_AtoG,MEIP26_rep3_AtoG,by="chrcoord")

MEIP26_1_2_TtoC<-inner_join(MEIP26_rep1_TtoC,MEIP26_rep2_TtoC,by="chrcoord")
MEIP26_2_3_TtoC<-inner_join(MEIP26_rep2_TtoC,MEIP26_rep3_TtoC,by="chrcoord")
MEIP26_1_3_TtoC<-inner_join(MEIP26_rep1_TtoC,MEIP26_rep3_TtoC,by="chrcoord")

MEIP26_potential_site<-full_join(MEIP26_1_2,MEIP26_2_3,by="chrcoord")
MEIP26_potential_site<-full_join(MEIP26_potential_site,MEIP26_1_3,by="chrcoord")
MEIP26_potential_site<-as.data.frame(MEIP26_potential_site$chrcoord)
colnames(MEIP26_potential_site)<-"chrcoord"
MEIP26_potential_site<-left_join(MEIP26_potential_site,MEIP26_rep1_AtoG,by="chrcoord")
MEIP26_potential_site<-left_join(MEIP26_potential_site,MEIP26_rep2_AtoG,by="chrcoord")
MEIP26_potential_site<-left_join(MEIP26_potential_site,MEIP26_rep3_AtoG,by="chrcoord")
MEIP26_potential_site[is.na(MEIP26_potential_site)]<-0

MEIP26_potential_site_TtoC<-full_join(MEIP26_1_2_TtoC,MEIP26_2_3_TtoC,by="chrcoord")
MEIP26_potential_site_TtoC<-full_join(MEIP26_potential_site_TtoC,MEIP26_1_3_TtoC,by="chrcoord")
MEIP26_potential_site_TtoC<-as.data.frame(MEIP26_potential_site_TtoC$chrcoord)
colnames(MEIP26_potential_site_TtoC)<-"chrcoord"
MEIP26_potential_site_TtoC<-left_join(MEIP26_potential_site_TtoC,MEIP26_rep1_TtoC,by="chrcoord")
MEIP26_potential_site_TtoC<-left_join(MEIP26_potential_site_TtoC,MEIP26_rep2_TtoC,by="chrcoord")
MEIP26_potential_site_TtoC<-left_join(MEIP26_potential_site_TtoC,MEIP26_rep3_TtoC,by="chrcoord")


  # add counts in control
     # A to G
           # remove if any site is G-rich in any control replicates
CTRL_INSC_REP_1_Gref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_1_Gref.txt"),header=T)
CTRL_INSC_REP_1_Gref$chrcoord<-paste(CTRL_INSC_REP_1_Gref$chr,CTRL_INSC_REP_1_Gref$coord,sep=",")
MEIP26_potential_site<-anti_join(MEIP26_potential_site,CTRL_INSC_REP_1_Gref,by="chrcoord")
rm(CTRL_INSC_REP_1_Gref)

CTRL_INSC_REP_2_Gref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_2_Gref.txt"),header=T)
CTRL_INSC_REP_2_Gref$chrcoord<-paste(CTRL_INSC_REP_2_Gref$chr,CTRL_INSC_REP_2_Gref$coord,sep=",")
MEIP26_potential_site<-anti_join(MEIP26_potential_site,CTRL_INSC_REP_2_Gref,by="chrcoord")
rm(CTRL_INSC_REP_2_Gref)

CTRL_INSC_REP_3_Gref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_3_Gref.txt"),header=T)
CTRL_INSC_REP_3_Gref$chrcoord<-paste(CTRL_INSC_REP_3_Gref$chr,CTRL_INSC_REP_3_Gref$coord,sep=",")
MEIP26_potential_site<-anti_join(MEIP26_potential_site,CTRL_INSC_REP_3_Gref,by="chrcoord")
rm(CTRL_INSC_REP_3_Gref)

CTRL_EX4O_REP_1_Gref<-read.table(file.path(bulk_data_dir, "CTRL_EX4O_REP_1_Gref.txt"),header=T)
CTRL_EX4O_REP_1_Gref$chrcoord<-paste(CTRL_EX4O_REP_1_Gref$chr,CTRL_EX4O_REP_1_Gref$coord,sep=",")
MEIP26_potential_site<-anti_join(MEIP26_potential_site,CTRL_EX4O_REP_1_Gref,by="chrcoord")
rm(CTRL_EX4O_REP_1_Gref)

CTRL_EX4O_REP_2_Gref<-read.table(file.path(bulk_data_dir, "CTRL_EX4O_REP_2_Gref.txt"),header=T)
CTRL_EX4O_REP_2_Gref$chrcoord<-paste(CTRL_EX4O_REP_2_Gref$chr,CTRL_EX4O_REP_2_Gref$coord,sep=",")
MEIP26_potential_site<-anti_join(MEIP26_potential_site,CTRL_EX4O_REP_2_Gref,by="chrcoord")
rm(CTRL_EX4O_REP_2_Gref)

CTRL_EX4O_REP_3_Gref<-read.table(file.path(bulk_data_dir, "CTRL_EX4O_REP_3_Gref.txt"),header=T)
CTRL_EX4O_REP_3_Gref$chrcoord<-paste(CTRL_EX4O_REP_3_Gref$chr,CTRL_EX4O_REP_3_Gref$coord,sep=",")
MEIP26_potential_site<-anti_join(MEIP26_potential_site,CTRL_EX4O_REP_3_Gref,by="chrcoord")
rm(CTRL_EX4O_REP_3_Gref)

           # annotate count info in control reps
CTRL_INSC_REP_1_Aref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_1_Aref.txt"),header=T)
CTRL_INSC_REP_1_Aref$chrcoord<-paste(CTRL_INSC_REP_1_Aref$chr,CTRL_INSC_REP_1_Aref$coord,sep=",")
CTRL_INSC_REP_1_Aref<-CTRL_INSC_REP_1_Aref[,c(8,10,11)]
colnames(CTRL_INSC_REP_1_Aref)<-c("G_INSC_rep1","total_INSC_rep1","chrcoord")
MEIP26_potential_site<-left_join(MEIP26_potential_site,CTRL_INSC_REP_1_Aref,by="chrcoord")
rm(CTRL_INSC_REP_1_Aref)

CTRL_INSC_REP_2_Aref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_2_Aref.txt"),header=T)
CTRL_INSC_REP_2_Aref$chrcoord<-paste(CTRL_INSC_REP_2_Aref$chr,CTRL_INSC_REP_2_Aref$coord,sep=",")
CTRL_INSC_REP_2_Aref<-CTRL_INSC_REP_2_Aref[,c(8,10,11)]
colnames(CTRL_INSC_REP_2_Aref)<-c("G_INSC_rep2","total_INSC_rep2","chrcoord")
MEIP26_potential_site<-left_join(MEIP26_potential_site,CTRL_INSC_REP_2_Aref,by="chrcoord")
rm(CTRL_INSC_REP_2_Aref)

CTRL_INSC_REP_3_Aref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_3_Aref.txt"),header=T)
CTRL_INSC_REP_3_Aref$chrcoord<-paste(CTRL_INSC_REP_3_Aref$chr,CTRL_INSC_REP_3_Aref$coord,sep=",")
CTRL_INSC_REP_3_Aref<-CTRL_INSC_REP_3_Aref[,c(8,10,11)]
colnames(CTRL_INSC_REP_3_Aref)<-c("G_INSC_rep3","total_INSC_rep3","chrcoord")
MEIP26_potential_site<-left_join(MEIP26_potential_site,CTRL_INSC_REP_3_Aref,by="chrcoord")
rm(CTRL_INSC_REP_3_Aref)

CTRL_EX4O_REP_1_Aref<-read.table(file.path(bulk_data_dir, "CTRL_EX4O_REP_1_Aref.txt"),header=T)
CTRL_EX4O_REP_1_Aref$chrcoord<-paste(CTRL_EX4O_REP_1_Aref$chr,CTRL_EX4O_REP_1_Aref$coord,sep=",")
CTRL_EX4O_REP_1_Aref<-CTRL_EX4O_REP_1_Aref[,c(8,10,11)]
colnames(CTRL_EX4O_REP_1_Aref)<-c("G_EX4O_rep1","total_EX4O_rep1","chrcoord")
MEIP26_potential_site<-left_join(MEIP26_potential_site,CTRL_EX4O_REP_1_Aref,by="chrcoord")
rm(CTRL_EX4O_REP_1_Aref)

CTRL_EX4O_REP_2_Aref<-read.table(file.path(bulk_data_dir, "CTRL_EX4O_REP_2_Aref.txt"),header=T)
CTRL_EX4O_REP_2_Aref$chrcoord<-paste(CTRL_EX4O_REP_2_Aref$chr,CTRL_EX4O_REP_2_Aref$coord,sep=",")
CTRL_EX4O_REP_2_Aref<-CTRL_EX4O_REP_2_Aref[,c(8,10,11)]
colnames(CTRL_EX4O_REP_2_Aref)<-c("G_EX4O_rep2","total_EX4O_rep2","chrcoord")
MEIP26_potential_site<-left_join(MEIP26_potential_site,CTRL_EX4O_REP_2_Aref,by="chrcoord")
rm(CTRL_EX4O_REP_2_Aref)

CTRL_EX4O_REP_3_Aref<-read.table(file.path(bulk_data_dir, "CTRL_EX4O_REP_3_Aref.txt"),header=T)
CTRL_EX4O_REP_3_Aref$chrcoord<-paste(CTRL_EX4O_REP_3_Aref$chr,CTRL_EX4O_REP_3_Aref$coord,sep=",")
CTRL_EX4O_REP_3_Aref<-CTRL_EX4O_REP_3_Aref[,c(8,10,11)]
colnames(CTRL_EX4O_REP_3_Aref)<-c("G_EX4O_rep3","total_EX4O_rep3","chrcoord")
MEIP26_potential_site<-left_join(MEIP26_potential_site,CTRL_EX4O_REP_3_Aref,by="chrcoord")
rm(CTRL_EX4O_REP_3_Aref)



MEIP26_potential_site_backup<-MEIP26_potential_site
MEIP26_potential_site[is.na(MEIP26_potential_site)]<-0 # add zero; <30 reads: not enough; remove non-significant


     # T to C
           # remove if any site is C-rich in any control replicates (remove SNP)
CTRL_INSC_REP_1_Cref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_1_Cref.txt"),header=T)
CTRL_INSC_REP_1_Cref$chrcoord<-paste(CTRL_INSC_REP_1_Cref$chr,CTRL_INSC_REP_1_Cref$coord,sep=",")
MEIP26_potential_site_TtoC<-anti_join(MEIP26_potential_site_TtoC,CTRL_INSC_REP_1_Cref,by="chrcoord")
rm(CTRL_INSC_REP_1_Cref)

CTRL_INSC_REP_2_Cref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_2_Cref.txt"),header=T)
CTRL_INSC_REP_2_Cref$chrcoord<-paste(CTRL_INSC_REP_2_Cref$chr,CTRL_INSC_REP_2_Cref$coord,sep=",")
MEIP26_potential_site_TtoC<-anti_join(MEIP26_potential_site_TtoC,CTRL_INSC_REP_2_Cref,by="chrcoord")
rm(CTRL_INSC_REP_2_Cref)

CTRL_INSC_REP_3_Cref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_3_Cref.txt"),header=T)
CTRL_INSC_REP_3_Cref$chrcoord<-paste(CTRL_INSC_REP_3_Cref$chr,CTRL_INSC_REP_3_Cref$coord,sep=",")
MEIP26_potential_site_TtoC<-anti_join(MEIP26_potential_site_TtoC,CTRL_INSC_REP_3_Cref,by="chrcoord")
rm(CTRL_INSC_REP_3_Cref)

CTRL_EX4O_REP_1_Cref<-read.table(file.path(bulk_data_dir, "CTRL_EX4O_REP_1_Cref.txt"),header=T)
CTRL_EX4O_REP_1_Cref$chrcoord<-paste(CTRL_EX4O_REP_1_Cref$chr,CTRL_EX4O_REP_1_Cref$coord,sep=",")
MEIP26_potential_site_TtoC<-anti_join(MEIP26_potential_site_TtoC,CTRL_EX4O_REP_1_Cref,by="chrcoord")
rm(CTRL_EX4O_REP_1_Cref)

CTRL_EX4O_REP_2_Cref<-read.table(file.path(bulk_data_dir, "CTRL_EX4O_REP_2_Cref.txt"),header=T)
CTRL_EX4O_REP_2_Cref$chrcoord<-paste(CTRL_EX4O_REP_2_Cref$chr,CTRL_EX4O_REP_2_Cref$coord,sep=",")
MEIP26_potential_site_TtoC<-anti_join(MEIP26_potential_site_TtoC,CTRL_EX4O_REP_2_Cref,by="chrcoord")
rm(CTRL_EX4O_REP_2_Cref)

CTRL_EX4O_REP_3_Cref<-read.table(file.path(bulk_data_dir, "CTRL_EX4O_REP_3_Cref.txt"),header=T)
CTRL_EX4O_REP_3_Cref$chrcoord<-paste(CTRL_EX4O_REP_3_Cref$chr,CTRL_EX4O_REP_3_Cref$coord,sep=",")
MEIP26_potential_site_TtoC<-anti_join(MEIP26_potential_site_TtoC,CTRL_EX4O_REP_3_Cref,by="chrcoord")
rm(CTRL_EX4O_REP_3_Cref)


           # annotate count info in control reps

CTRL_INSC_REP_1_Tref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_1_Tref.txt"),header=T)
CTRL_INSC_REP_1_Tref$chrcoord<-paste(CTRL_INSC_REP_1_Tref$chr,CTRL_INSC_REP_1_Tref$coord,sep=",")
CTRL_INSC_REP_1_Tref<-CTRL_INSC_REP_1_Tref[,c(7,10,11)]
colnames(CTRL_INSC_REP_1_Tref)<-c("C_INSC_rep1","total_INSC_rep1","chrcoord")
MEIP26_potential_site_TtoC<-left_join(MEIP26_potential_site_TtoC,CTRL_INSC_REP_1_Tref,by="chrcoord")
rm(CTRL_INSC_REP_1_Tref)

CTRL_INSC_REP_2_Tref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_2_Tref.txt"),header=T)
CTRL_INSC_REP_2_Tref$chrcoord<-paste(CTRL_INSC_REP_2_Tref$chr,CTRL_INSC_REP_2_Tref$coord,sep=",")
CTRL_INSC_REP_2_Tref<-CTRL_INSC_REP_2_Tref[,c(7,10,11)]
colnames(CTRL_INSC_REP_2_Tref)<-c("C_INSC_rep2","total_INSC_rep2","chrcoord")
MEIP26_potential_site_TtoC<-left_join(MEIP26_potential_site_TtoC,CTRL_INSC_REP_2_Tref,by="chrcoord")
rm(CTRL_INSC_REP_2_Tref)

CTRL_INSC_REP_3_Tref<-read.table(file.path(bulk_data_dir, "CTRL_INSC_REP_3_Tref.txt"),header=T)
CTRL_INSC_REP_3_Tref$chrcoord<-paste(CTRL_INSC_REP_3_Tref$chr,CTRL_INSC_REP_3_Tref$coord,sep=",")
CTRL_INSC_REP_3_Tref<-CTRL_INSC_REP_3_Tref[,c(7,10,11)]
colnames(CTRL_INSC_REP_3_Tref)<-c("C_INSC_rep3","total_INSC_rep3","chrcoord")
MEIP26_potential_site_TtoC<-left_join(MEIP26_potential_site_TtoC,CTRL_INSC_REP_3_Tref,by="chrcoord")
rm(CTRL_INSC_REP_3_Tref)

CTRL_EX4O_REP_1_Tref<-read.table(file.path(bulk_data_dir, "CTRL_EX4O_REP_1_Tref.txt"),header=T)
CTRL_EX4O_REP_1_Tref$chrcoord<-paste(CTRL_EX4O_REP_1_Tref$chr,CTRL_EX4O_REP_1_Tref$coord,sep=",")
CTRL_EX4O_REP_1_Tref<-CTRL_EX4O_REP_1_Tref[,c(7,10,11)]
colnames(CTRL_EX4O_REP_1_Tref)<-c("C_EX4O_rep1","total_EX4O_rep1","chrcoord")
MEIP26_potential_site_TtoC<-left_join(MEIP26_potential_site_TtoC,CTRL_EX4O_REP_1_Tref,by="chrcoord")
rm(CTRL_EX4O_REP_1_Tref)

CTRL_EX4O_REP_2_Tref<-read.table(file.path(bulk_data_dir, "CTRL_EX4O_REP_2_Tref.txt"),header=T)
CTRL_EX4O_REP_2_Tref$chrcoord<-paste(CTRL_EX4O_REP_2_Tref$chr,CTRL_EX4O_REP_2_Tref$coord,sep=",")
CTRL_EX4O_REP_2_Tref<-CTRL_EX4O_REP_2_Tref[,c(7,10,11)]
colnames(CTRL_EX4O_REP_2_Tref)<-c("C_EX4O_rep2","total_EX4O_rep2","chrcoord")
MEIP26_potential_site_TtoC<-left_join(MEIP26_potential_site_TtoC,CTRL_EX4O_REP_2_Tref,by="chrcoord")
rm(CTRL_EX4O_REP_2_Tref)

CTRL_EX4O_REP_3_Tref<-read.table(file.path(bulk_data_dir, "CTRL_EX4O_REP_3_Tref.txt"),header=T)
CTRL_EX4O_REP_3_Tref$chrcoord<-paste(CTRL_EX4O_REP_3_Tref$chr,CTRL_EX4O_REP_3_Tref$coord,sep=",")
CTRL_EX4O_REP_3_Tref<-CTRL_EX4O_REP_3_Tref[,c(7,10,11)]
colnames(CTRL_EX4O_REP_3_Tref)<-c("C_EX4O_rep3","total_EX4O_rep3","chrcoord")
MEIP26_potential_site_TtoC<-left_join(MEIP26_potential_site_TtoC,CTRL_EX4O_REP_3_Tref,by="chrcoord")
rm(CTRL_EX4O_REP_3_Tref)

MEIP26_potential_site_TtoC_backup<-MEIP26_potential_site_TtoC
MEIP26_potential_site_TtoC[is.na(MEIP26_potential_site_TtoC)]<-0

# process data
  # A to G
MEIP26_potential_site$exp_G<-MEIP26_potential_site$G_MEIP26_rep1+MEIP26_potential_site$G_MEIP26_rep2+MEIP26_potential_site$G_MEIP26_rep3
MEIP26_potential_site$exp_total<-MEIP26_potential_site$total_MEIP26_rep1+MEIP26_potential_site$total_MEIP26_rep2+MEIP26_potential_site$total_MEIP26_rep3
MEIP26_potential_site$exp_notG<-MEIP26_potential_site$exp_total-MEIP26_potential_site$exp_G

MEIP26_potential_site$ctr1_G<-MEIP26_potential_site$G_INSC_rep1+MEIP26_potential_site$G_INSC_rep2+MEIP26_potential_site$G_INSC_rep3
MEIP26_potential_site$ctr1_total<-MEIP26_potential_site$total_INSC_rep1+MEIP26_potential_site$total_INSC_rep2+MEIP26_potential_site$total_INSC_rep3
MEIP26_potential_site$ctr1_notG<-MEIP26_potential_site$ctr1_total-MEIP26_potential_site$ctr1_G

MEIP26_potential_site$ctr2_G<-MEIP26_potential_site$G_EX4O_rep1+MEIP26_potential_site$G_EX4O_rep2+MEIP26_potential_site$G_EX4O_rep3
MEIP26_potential_site$ctr2_total<-MEIP26_potential_site$total_EX4O_rep1+MEIP26_potential_site$total_EX4O_rep2+MEIP26_potential_site$total_EX4O_rep3
MEIP26_potential_site$ctr2_notG<-MEIP26_potential_site$ctr2_total-MEIP26_potential_site$ctr2_G

MEIP26_potential_site$G_rate_change_1<-(MEIP26_potential_site$exp_G/MEIP26_potential_site$exp_total)-(MEIP26_potential_site$ctr1_G/MEIP26_potential_site$ctr1_total)
MEIP26_potential_site$G_rate_change_2<-(MEIP26_potential_site$exp_G/MEIP26_potential_site$exp_total)-(MEIP26_potential_site$ctr2_G/MEIP26_potential_site$ctr2_total)

MEIP26_potential_site_chisq_ctr1<-MEIP26_potential_site[,c(20,22,23,25)]
MEIP26_potential_site_chisq_ctr2<-MEIP26_potential_site[,c(20,22,26,28)]
  # T to C
MEIP26_potential_site_TtoC$exp_C<-MEIP26_potential_site_TtoC$C_MEIP26_rep1+MEIP26_potential_site_TtoC$C_MEIP26_rep2+MEIP26_potential_site_TtoC$C_MEIP26_rep3
MEIP26_potential_site_TtoC$exp_total<-MEIP26_potential_site_TtoC$total_MEIP26_rep1+MEIP26_potential_site_TtoC$total_MEIP26_rep2+MEIP26_potential_site_TtoC$total_MEIP26_rep3
MEIP26_potential_site_TtoC$exp_notC<-MEIP26_potential_site_TtoC$exp_total-MEIP26_potential_site_TtoC$exp_C

MEIP26_potential_site_TtoC$ctr1_C<-MEIP26_potential_site_TtoC$C_INSC_rep1+MEIP26_potential_site_TtoC$C_INSC_rep2+MEIP26_potential_site_TtoC$C_INSC_rep3
MEIP26_potential_site_TtoC$ctr1_total<-MEIP26_potential_site_TtoC$total_INSC_rep1+MEIP26_potential_site_TtoC$total_INSC_rep2+MEIP26_potential_site_TtoC$total_INSC_rep3
MEIP26_potential_site_TtoC$ctr1_notC<-MEIP26_potential_site_TtoC$ctr1_total-MEIP26_potential_site_TtoC$ctr1_C

MEIP26_potential_site_TtoC$ctr2_C<-MEIP26_potential_site_TtoC$C_EX4O_rep1+MEIP26_potential_site_TtoC$C_EX4O_rep2+MEIP26_potential_site_TtoC$C_EX4O_rep3
MEIP26_potential_site_TtoC$ctr2_total<-MEIP26_potential_site_TtoC$total_EX4O_rep1+MEIP26_potential_site_TtoC$total_EX4O_rep2+MEIP26_potential_site_TtoC$total_EX4O_rep3
MEIP26_potential_site_TtoC$ctr2_notC<-MEIP26_potential_site_TtoC$ctr2_total-MEIP26_potential_site_TtoC$ctr2_C

MEIP26_potential_site_TtoC$C_rate_change_1<-(MEIP26_potential_site_TtoC$exp_C/MEIP26_potential_site_TtoC$exp_total)-(MEIP26_potential_site_TtoC$ctr1_C/MEIP26_potential_site_TtoC$ctr1_total)
MEIP26_potential_site_TtoC$C_rate_change_2<-(MEIP26_potential_site_TtoC$exp_C/MEIP26_potential_site_TtoC$exp_total)-(MEIP26_potential_site_TtoC$ctr2_C/MEIP26_potential_site_TtoC$ctr2_total)

MEIP26_potential_site_TtoC_chisq_ctr1<-MEIP26_potential_site_TtoC[,c(20,22,23,25)]
MEIP26_potential_site_TtoC_chisq_ctr2<-MEIP26_potential_site_TtoC[,c(20,22,26,28)]

  # calculate chi-square

MEIP26_potential_site_chisq_ctr1$P_chisq_ctr1<-apply(MEIP26_potential_site_chisq_ctr1,1,function(row){
    mtx<-data.frame(exp=row[c(1,2)],ctr=row[c(3,4)])
    test_result<-chisq.test(mtx)
    return(test_result$p.value)
    })
MEIP26_potential_site_chisq_ctr2$P_chisq_ctr2<-apply(MEIP26_potential_site_chisq_ctr2,1,function(row){
    mtx<-data.frame(exp=row[c(1,2)],ctr=row[c(3,4)])
    test_result<-chisq.test(mtx)
    return(test_result$p.value)
    })

MEIP26_potential_site_TtoC_chisq_ctr1$P_chisq_ctr1<-apply(MEIP26_potential_site_TtoC_chisq_ctr1,1,function(row){
    mtx<-data.frame(exp=row[c(1,2)],ctr=row[c(3,4)])
    test_result<-chisq.test(mtx)
    return(test_result$p.value)
    })
MEIP26_potential_site_TtoC_chisq_ctr2$P_chisq_ctr2<-apply(MEIP26_potential_site_TtoC_chisq_ctr2,1,function(row){
    mtx<-data.frame(exp=row[c(1,2)],ctr=row[c(3,4)])
    test_result<-chisq.test(mtx)
    return(test_result$p.value)
    })
  

  # fill table

MEIP26_potential_site_chisq_ctr1$chrcoord<-MEIP26_potential_site$chrcoord
MEIP26_potential_site_chisq_ctr1$G_rate_change<-MEIP26_potential_site$G_rate_change_1

MEIP26_potential_site_chisq_ctr2$chrcoord<-MEIP26_potential_site$chrcoord
MEIP26_potential_site_chisq_ctr2$G_rate_change<-MEIP26_potential_site$G_rate_change_2

MEIP26_potential_site_TtoC_chisq_ctr1$chrcoord<-MEIP26_potential_site_TtoC$chrcoord
MEIP26_potential_site_TtoC_chisq_ctr1$C_rate_change<-MEIP26_potential_site_TtoC$C_rate_change_1

MEIP26_potential_site_TtoC_chisq_ctr2$chrcoord<-MEIP26_potential_site_TtoC$chrcoord
MEIP26_potential_site_TtoC_chisq_ctr2$C_rate_change<-MEIP26_potential_site_TtoC$C_rate_change_2

MEIP26_potential_site_chisq_ctr1$P_chisq_ctr1[is.nan(MEIP26_potential_site_chisq_ctr1$P_chisq_ctr1)]<-1
MEIP26_potential_site_chisq_ctr1$sig<-NA
for (i in 1:nrow(MEIP26_potential_site_chisq_ctr1)){
  if(MEIP26_potential_site_chisq_ctr1$P_chisq_ctr1[i]<0.025){
    MEIP26_potential_site_chisq_ctr1$sig[i]=1
  }
  else{
    MEIP26_potential_site_chisq_ctr1$sig[i]=-1
  }
  if(MEIP26_potential_site_chisq_ctr1$ctr1_notG[i]<30){
MEIP26_potential_site_chisq_ctr1$sig[i]=0
}
}

MEIP26_potential_site_chisq_ctr2$P_chisq_ctr2[is.nan(MEIP26_potential_site_chisq_ctr2$P_chisq_ctr2)]<-1
MEIP26_potential_site_chisq_ctr2$sig<-NA
for (i in 1:nrow(MEIP26_potential_site_chisq_ctr2)){
  if(MEIP26_potential_site_chisq_ctr2$P_chisq_ctr2[i]<0.025){
    MEIP26_potential_site_chisq_ctr2$sig[i]=1
  }
  else{
    MEIP26_potential_site_chisq_ctr2$sig[i]=-1
  }
  if(MEIP26_potential_site_chisq_ctr2$ctr2_notG[i]<30){
MEIP26_potential_site_chisq_ctr2$sig[i]=0
}
}

     # t to c
MEIP26_potential_site_TtoC_chisq_ctr1$P_chisq_ctr1[is.nan(MEIP26_potential_site_TtoC_chisq_ctr1$P_chisq_ctr1)]<-1
MEIP26_potential_site_TtoC_chisq_ctr1$sig<-NA
for (i in 1:nrow(MEIP26_potential_site_TtoC_chisq_ctr1)){
  if(MEIP26_potential_site_TtoC_chisq_ctr1$P_chisq_ctr1[i]<0.025){
    MEIP26_potential_site_TtoC_chisq_ctr1$sig[i]=1
  }
  else{
    MEIP26_potential_site_TtoC_chisq_ctr1$sig[i]=-1
  }
  if(MEIP26_potential_site_TtoC_chisq_ctr1$ctr1_notC[i]<30){
MEIP26_potential_site_TtoC_chisq_ctr1$sig[i]=0
}
}

MEIP26_potential_site_TtoC_chisq_ctr2$P_chisq_ctr2[is.nan(MEIP26_potential_site_TtoC_chisq_ctr2$P_chisq_ctr2)]<-1
MEIP26_potential_site_TtoC_chisq_ctr2$sig<-NA
for (i in 1:nrow(MEIP26_potential_site_TtoC_chisq_ctr2)){
  if(MEIP26_potential_site_TtoC_chisq_ctr2$P_chisq_ctr2[i]<0.025){
    MEIP26_potential_site_TtoC_chisq_ctr2$sig[i]=1
  }
  else{
    MEIP26_potential_site_TtoC_chisq_ctr2$sig[i]=-1
  }
  if(MEIP26_potential_site_TtoC_chisq_ctr2$ctr2_notC[i]<30){
MEIP26_potential_site_TtoC_chisq_ctr2$sig[i]=0
}
}

# select 
    #G rate change > 0 in exp && chisq P < 0.025 score >0, while sig +1, not enough +0, nonsig -1

MEIP26_TRIBE_site_chisq<-MEIP26_potential_site_chisq_ctr1[,c(6,7,8)]
colnames(MEIP26_TRIBE_site_chisq)<-c("chrcoord","G_rate_ctr1","sig_ctr1")
MEIP26_TRIBE_site_chisq$G_rate_ctr2<-MEIP26_potential_site_chisq_ctr2$G_rate_change
MEIP26_TRIBE_site_chisq$sig_ctr2<-MEIP26_potential_site_chisq_ctr2$sig
MEIP26_TRIBE_site_chisq$total_sig<-MEIP26_TRIBE_site_chisq$sig_ctr1+MEIP26_TRIBE_site_chisq$sig_ctr2
MEIP26_TRIBE_site_chisq<-MEIP26_TRIBE_site_chisq[MEIP26_TRIBE_site_chisq$total_sig>0,]
MEIP26_TRIBE_site_chisq$G_rate_ctr1[is.nan(MEIP26_TRIBE_site_chisq$G_rate_ctr1)]<-0
MEIP26_TRIBE_site_chisq$G_rate_ctr2[is.nan(MEIP26_TRIBE_site_chisq$G_rate_ctr2)]<-0
MEIP26_TRIBE_site_chisq<-MEIP26_TRIBE_site_chisq[MEIP26_TRIBE_site_chisq$G_rate_ctr1>=0,]
MEIP26_TRIBE_site_chisq<-MEIP26_TRIBE_site_chisq[MEIP26_TRIBE_site_chisq$G_rate_ctr2>=0,]

MEIP26_TRIBE_site_TtoC_chisq<-MEIP26_potential_site_TtoC_chisq_ctr1[,c(6,7,8)]
colnames(MEIP26_TRIBE_site_TtoC_chisq)<-c("chrcoord","C_rate_ctr1","sig_ctr1")
MEIP26_TRIBE_site_TtoC_chisq$C_rate_ctr2<-MEIP26_potential_site_TtoC_chisq_ctr2$C_rate_change
MEIP26_TRIBE_site_TtoC_chisq$sig_ctr2<-MEIP26_potential_site_TtoC_chisq_ctr2$sig
MEIP26_TRIBE_site_TtoC_chisq$total_sig<-MEIP26_TRIBE_site_TtoC_chisq$sig_ctr1+MEIP26_TRIBE_site_TtoC_chisq$sig_ctr2
MEIP26_TRIBE_site_TtoC_chisq<-MEIP26_TRIBE_site_TtoC_chisq[MEIP26_TRIBE_site_TtoC_chisq$total_sig>0,]
MEIP26_TRIBE_site_TtoC_chisq$C_rate_ctr1[is.nan(MEIP26_TRIBE_site_TtoC_chisq$C_rate_ctr1)]<-0
MEIP26_TRIBE_site_TtoC_chisq$C_rate_ctr2[is.nan(MEIP26_TRIBE_site_TtoC_chisq$C_rate_ctr2)]<-0
MEIP26_TRIBE_site_TtoC_chisq<-MEIP26_TRIBE_site_TtoC_chisq[MEIP26_TRIBE_site_TtoC_chisq$C_rate_ctr1>=0,]
MEIP26_TRIBE_site_TtoC_chisq<-MEIP26_TRIBE_site_TtoC_chisq[MEIP26_TRIBE_site_TtoC_chisq$C_rate_ctr2>=0,]

  # write bed file
          # AtoG
MEIP26_TRIBE_AtoG_bed<-MEIP26_TRIBE_site_chisq
MEIP26_TRIBE_AtoG_bed$coord<-NA
MEIP26_TRIBE_AtoG_bed$chr<-NA

for (i in 1:nrow(MEIP26_TRIBE_AtoG_bed)){
MEIP26_TRIBE_AtoG_bed$chr[i]<-unlist(strsplit(MEIP26_TRIBE_AtoG_bed$chrcoord[i],','))[1]
MEIP26_TRIBE_AtoG_bed$coord[i]<-unlist(strsplit(MEIP26_TRIBE_AtoG_bed$chrcoord[i],','))[2]
}

MEIP26_TRIBE_AtoG_bed<-MEIP26_TRIBE_AtoG_bed[,c(8,7)]
MEIP26_TRIBE_AtoG_bed$coordplus<-as.numeric(MEIP26_TRIBE_AtoG_bed$coord)+1
colnames(MEIP26_TRIBE_AtoG_bed)<-c("chrom","chromStart","chromEnd")
MEIP26_TRIBE_AtoG_bed$strand<-"+"
          # TtoC
MEIP26_TRIBE_TtoC_bed<-MEIP26_TRIBE_site_TtoC_chisq
MEIP26_TRIBE_TtoC_bed$coord<-NA
MEIP26_TRIBE_TtoC_bed$chr<-NA

for (i in 1:nrow(MEIP26_TRIBE_TtoC_bed)){
MEIP26_TRIBE_TtoC_bed$chr[i]<-unlist(strsplit(MEIP26_TRIBE_TtoC_bed$chrcoord[i],','))[1]
MEIP26_TRIBE_TtoC_bed$coord[i]<-unlist(strsplit(MEIP26_TRIBE_TtoC_bed$chrcoord[i],','))[2]
}

MEIP26_TRIBE_TtoC_bed<-MEIP26_TRIBE_TtoC_bed[,c(8,7)]
MEIP26_TRIBE_TtoC_bed$coordplus<-as.numeric(MEIP26_TRIBE_TtoC_bed$coord)+1
colnames(MEIP26_TRIBE_TtoC_bed)<-c("chrom","chromStart","chromEnd")
MEIP26_TRIBE_TtoC_bed$strand<-"-"

         # Merge AtoG and TtoC
MEIP26_TRIBE_bed<-rbind(MEIP26_TRIBE_AtoG_bed,MEIP26_TRIBE_TtoC_bed)
MEIP26_TRIBE_bed$name<-"."
MEIP26_TRIBE_bed$score<-"."
MEIP26_TRIBE_bed<-MEIP26_TRIBE_bed[,c(1,2,3,5,6,4)]


         # write bed file
write.table(MEIP26_TRIBE_bed,file.path(output_dir, "MEIP26_TRIBE_BULK_ex4o_cor.bed"),quote=F,sep = "\t",row.names=F,col.names=F)
