####
#Objectif du script = mettre en forme le tableau de données des sondes capacitives et des stations météo
#au format de la base de données
####


#liste des packages utilisés
install.packages("dplyr")
#install.packages("tidyverse")
install.packages("readr")

#library(tidyverse)

rm(list=ls(all.names=T)) #supprime toutes les variables

#définition du répertoire de travail
mainpath <- "D:/Sauvegarde/Google Drive JB/BagAges GT1/20_Données/99_Dossier JB" #chemin du dossier principal
dataftp <- "01_data_ftp" #nom du dossier contenant les csv tels que téléchargés depuis le serveur ftp
dirData <- paste(mainpath, dataftp, sep="/")
setwd(dirData)

library(dplyr)
library(readr)

l.data <- list.files(path=dirData, pattern=".csv")

# Boucle sur les fichiers par stations
setwd(dirData)
for (i in 1:length(l.data)) 
#i=2 #pour les tests juste sur un fichier
{
  #Script Anthony
  setwd(dirData)
  raw <- read_lines(l.data[i])
  breaks <- c(0, which(grepl("^[[:space:]]*$", raw))) #renvoie 0 puis les indices des lignes vides dans un vecteur (longueur 7)
  
  #découpe au sein d'un fichier les 7 sous-tableaux
  setwd(dirData)
  for (j in 1:length(breaks))
  {
    skip = breaks[j]+1
    n_max = ifelse(j != length(breaks), breaks[j+1]-breaks[j]-2, length(raw)-breaks[j]-1)
    name = read_lines(l.data[i], skip =  breaks[j], n_max = 1)
    txt <- read_lines(file = l.data[i], skip = skip, n_max = n_max) #requiert la biliothèque readr
    con <- textConnection(txt) #ouvre une connexion
    assign(paste(name), read.table(con, header= TRUE, sep = ",", dec = ".", check.names=F))
    close(con) #ferme la connexion
  }
  
  #change les en-têtes du tableau de données avec les sondes et la station
  ESReadings <- cbind(ESReadings[,grep("DateTime",colnames(ESReadings))], ESReadings[,grep("Cooked",colnames(ESReadings))])
  colnames(ESReadings) <- c("Time", paste(substring(ESSensors$ProbeID,8,10),substring(ESSensors$Name,1,1),ESSensors$Depth,sep="_"))

  #à partir des en-têtes, repasser en variables la sonde, la profondeur et la grandeur physique mesurée
  
  #enregistrer le(s) fichier(s) csv ainsi obtenus #revoir les noms
  setwd(paste(mainpath,"02_data_analysable", sep="/"))
  sink(paste("analysable_", l.data[i], sep=""))
  write.csv(ESReadings)
  sink()
}
  