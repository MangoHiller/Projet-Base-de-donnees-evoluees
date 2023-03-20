
# Projet base de donnée évoluée

## Sources : 
Jeu de donnée issu de CrunchBase:
[Startup_investments.csv](https://data.world/datanerd/startup-venture-funding) 

## Méthodes d'intégration/nettoyage des données :
### Nettoyage des données
Nous avons utilisé le logiciel OpenRefine afin de nettoyer et préparer nos données, [![DOI](https://zenodo.org/badge/6220644.svg)](https://zenodo.org/badge/latestdoi/6220644).

[<img src="https://github.com/OpenRefine/OpenRefine/blob/master/graphics/icon/open-refine-320px.png" align="right">](https://openrefine.org)

*OpenRefine is a Java-based power tool that allows you to load data, understand it,
clean it up, reconcile it, and augment it with data coming from
the web. All from a web browser and the comfort and privacy of your own computer.*

Site officiel: **https://openrefine.org**

Community forum: **https://forum.openrefine.org**

* Création de trois colonnes : geographique_id , startup_id et temps_id.  
:arrow_lower_right: Vous pouvez ajouter une nouvelle colonne ("Add new column based on this column") avec cette formule Grel à l'intérieur :
```grel
ligne.index + 1
```


### Chargement des données
### Avec SQL Develloper :
Faire clic droit dans le dossier table à gauche dans le logiciel sur la table voulue puis faire import data.
#### Pour dim_Geographique :
1. Sélectionnez le fichier "Startup_investments.csv" puis faite suivant.
2. Méthode de chargement "insert" puis faite suivant.
3. Faire suivant
4. Changer la correspondance pour chaque tuple par exemple ```country_code avec country_code``` etc...
5. fin
#### Pour dim_startup :
1. Sélectionnez le fichier "Startup_investments.csv" faite suivant.
2. Méthode de chargement "insert" puis faite suivant.
3. Faire suivant.
4. Changer la correspondance pour chaque tuple par exemple ```startup_name avec startup_name``` etc...
5. fin
#### Pour dim_temps :
1. Sélectionnez le fichier "Startup_investments.csv" faite suivant.
2. Méthode de chargement "insert" puis faite suivant.
3. Faire suivant.
4. Changer la correspondance pour chaque tuple par exemple ```founded_year avec founded_year``` etc...  
 :warning:	 Il faudra peut être changer le format des dates nottament pour ```founded_month``` qui de base est au format ```YYYY-MM-DD``` dans le format ```MM```
5. fin


## Authors

|                                                    |                  |
| -------------------------------------------------- | ---------------- |
| [@MangoHiller](https://github.com/MangoHiller)     | Hugo LEGUILLIER  |
| [@miranovic](https://github.com/miranovic)         | Imran NAAR       |
| [@](https://github.com/miranovic)                  | Izzedine issa AHMAT|
| [@](https://github.com/miranovic)                  | Gesser RIAHI     |





