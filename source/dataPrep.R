#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
# dataPrep.R                       damianclarke            yyyy-mm-dd:2023-10-24
#
#
#
#
#


#-------------------------------------------------------------------------------   
#--- (1a) Generate population file  
#-------------------------------------------------------------------------------   
population <- read_xls(file.path(data,"poblacionINE.xls"))
popTeens   <- filter(population, 
                     edad>=15 & edad<=19 & `Sexo (1=hombres;2=mujeres)`==2)
popTeens <- select(popTeens, Comuna, nombre_comuna, edad, a2008, a2009)
names(popTeens)<- c("Comuna","nombre_comuna","edad","2008","2009")
popTeens <- pivot_longer(popTeens, cols=`2008`:`2009`, 
                         names_to="ano_nac", values_to="population")
popTeens <- popTeens %>% group_by(Comuna,nombre_comuna, ano_nac) %>%
  summarise(
    population=sum(population), 
    .groups = "drop"
  )



#-------------------------------------------------------------------------------   
#--- (1b) A function to do this  
#-------------------------------------------------------------------------------   
gen_pop <- function(data, age1, age2, sex) {
    popTeens <- data %>% filter(edad>=age1 & edad<=age2 & 
                                      `Sexo (1=hombres;2=mujeres)`==sex) %>%
      select(Comuna, nombre_comuna, edad, a2008, a2009)
  
    names(popTeens)<- c("Comuna","nombre_comuna","edad","2008","2009")
    popTeens <- pivot_longer(popTeens, cols=`2008`:`2009`, 
                             names_to="ano_nac", values_to="population")

    popTeens <- popTeens %>% group_by(Comuna,nombre_comuna, ano_nac) %>%
      summarise(
        population=sum(population), 
        .groups = "drop"
      )
    return(popTeens)
}
population <- gen_pop(population, 15, 19, sex=2)
population$ano_nac <- as.integer(population$ano_nac)

#-------------------------------------------------------------------------------
#--- (2) Import births data and collapse to the municipal level 
#-------------------------------------------------------------------------------
nacList <- vector("list",0)

for (y in 2008:2009) {
  filename <- paste0("NAC",y,".csv")
  dfname   <- paste0("nac",y)

  nac <- read.csv(file.path(data,filename))
  nac$teenPreg <-ifelse(nac$EDAD_M>=15&nac$EDAD_M<=19,1,0)
  nac <- nac %>% group_by(COMUNA,ANO_NAC) %>% 
    summarise(
      teenPreg=sum(teenPreg),
      .groups = "drop"
    )
  nacList[[dfname]] <- nac
}
teenPregnancies <- do.call(rbind, nacList)
names(teenPregnancies)<- c("Comuna","ano_nac","teenPreg")

#-------------------------------------------------------------------------------
#--- (3) Merge in population data 
#-------------------------------------------------------------------------------
#teenPregnancies$Comuna[teenPregnancies$Comuna==5106]<-5801
#teenPregnancies$Comuna[teenPregnancies$Comuna==5108]<-5804
#teenPregnancies$Comuna[teenPregnancies$Comuna==5505]<-5802
#teenPregnancies$Comuna[teenPregnancies$Comuna==5507]<-5803

oldCodes <- c(5106,5108,5505,5507)
newCodes <- c(5801,5804,5802,5803)
for (i in 1:length(oldCodes)) {
  teenPregnancies$Comuna[teenPregnancies$Comuna==oldCodes[i]]<-newCodes[i]
}

popPreg <- full_join(population, teenPregnancies, by = c("Comuna","ano_nac"))
popPreg$teenPreg[is.na(popPreg$teenPreg)]<-0


#-------------------------------------------------------------------------------
#--- (4) Merge in information on the EC pill with information on teen pregnancy 
#-------------------------------------------------------------------------------
pill <- read_dta(file.path(data,"PAE.dta"))
names(pill)[names(pill) == "comuna"] <- "Comuna"
for (i in 1:length(oldCodes)) {
  pill$Comuna[pill$Comuna==oldCodes[i]]<-newCodes[i]
}

popPregPill <- full_join(popPreg, pill, by = "Comuna")

