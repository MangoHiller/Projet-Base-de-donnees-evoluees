--1. Obtenir le nombre de startups par pays :

SELECT dg.country_code, COUNT(fs.startup_id)
FROM dim_geographique dg
JOIN fait_leve_de_fond fs ON dg.geographique_id = fs.geographique_id
GROUP BY dg.country_code;


--1. Obtenir le nombre total de levées de fond par pays et par année :

SELECT dg.country_code, dt.founded_year, COUNT(ff.funding_total_usd)
FROM dim_geographique dg
JOIN fait_leve_de_fond ff ON dg.geographique_id = ff.geographique_id
JOIN dim_temps dt ON ff.temps_id = dt.temps_id
GROUP BY dg.country_code, dt.founded_year;


--2. Obtenir le nombre total de levées de fond par pays, 
--par année et par trimestre, y compris les totaux de chaque catégorie :

SELECT dg.country_code, dt.founded_year, dt.founded_quarter, COUNT(ff.funding_total_usd)
FROM dim_geographique dg
JOIN fait_leve_de_fond ff ON dg.geographique_id = ff.geographique_id
JOIN dim_temps dt ON ff.temps_id = dt.temps_id
GROUP BY CUBE(dg.country_code, dt.founded_year, dt.founded_quarter)
HAVING GROUPING(dg.country_code) = 0 AND GROUPING(dt.founded_year) = 0;

--3. Retourner le nombre total de fonds levés par trimestre et par année:

SELECT founded_year, founded_quarter, SUM(funding_total_usd)
FROM dim_temps
JOIN fait_leve_de_fond ON dim_temps.temps_id = fait_leve_de_fond.temps_id
GROUP BY ROLLUP(founded_year, founded_quarter)
ORDER BY SUM(funding_total_usd) DESC;

--4. Obtenir le top 10 des startups ayant levé le plus de fonds :

SELECT ds.startup_name, SUM(ff.funding_total_usd) AS total_funding
FROM dim_startup ds
JOIN fait_leve_de_fond ff ON ds.startup_id = ff.startup_id
GROUP BY ds.startup_name
ORDER BY total_funding DESC
FETCH FIRST 10 ROWS ONLY;

--5. Retourner le montant total de fonds levés par trimestre et par année, avec la moyenne mobile sur 3 trimestres, en utilisant une fenêtre mobile:

SELECT founded_year, founded_quarter, SUM(funding_total_usd) AS total_funding, AVG(SUM(funding_total_usd)) OVER (ORDER BY TO_DATE(founded_year) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM dim_temps
JOIN fait_leve_de_fond ON dim_temps.temps_id = fait_leve_de_fond.temps_id
GROUP BY ROLLUP(founded_year, founded_quarter)
ORDER BY founded_year, founded_quarter;


/* Cette requête calcule le montant total de fonds levés par trimestre et par année, 
et ajoute également une colonne pour la moyenne mobile sur 3 trimestres, calculée 
en utilisant une fenêtre mobile avec la fonction AVG et l'opérateur OVER. La 
fonction TO_DATE est utilisée pour convertir l'année et le trimestre en une date, 
afin qu'ils puissent être utilisés pour ordonner les données dans la fenêtre mobile. 
La clause ROLLUP est utilisée pour inclure les totaux pour chaque année et pour 
l'ensemble des données. */

--6. Retourner le nombre de startups par région, année de fondation et trimestre de fondation, avec le total pour chaque région, trié par ordre décroissant de nombre de startups, en utilisant l'opérateur GROUPING_ID:

SELECT region, founded_year, founded_quarter, COUNT(DISTINCT startup_id) AS nb_startups, GROUPING_ID(region, founded_year, founded_quarter) AS group_id
FROM dim_geographique
JOIN fait_leve_de_fond ON dim_geographique.geographique_id = fait_leve_de_fond.geographique_id
JOIN dim_temps ON fait_leve_de_fond.temps_id = dim_temps.temps_id
GROUP BY GROUPING SETS((region, founded_year, founded_quarter), (region), ())
ORDER BY region, founded_year, founded_quarter, group_id DESC;

--7. Voici une requête utilisant l'opérateur RANK pour afficher les startups qui ont levé le plus de fonds par année de fondation:

SELECT *
FROM (
    SELECT startup_name, founded_year, funding_total_usd, RANK() OVER (PARTITION BY founded_year ORDER BY funding_total_usd DESC) AS funding_rank
    FROM dim_startup
    JOIN fait_leve_de_fond ON dim_startup.startup_id = fait_leve_de_fond.startup_id
    JOIN dim_temps ON fait_leve_de_fond.temps_id = dim_temps.temps_id
)
WHERE funding_rank <= 3
ORDER BY founded_year DESC;
/*Cette requête sélectionne les colonnes startup_name, 
founded_year et funding_total_usd, et ajoute une colonne funding_rank qui 
représente le classement de chaque startup par rapport aux autres startups ayant 
la même année de fondation, en fonction du montant total de fonds levés. 
La fonction RANK() avec l'opérateur OVER est utilisée pour calculer le classement. 

Ensuite, la requête filtre les données pour ne retourner que les startups ayant un 
classement de 3 ou moins (les 3 startups qui ont levé le plus de fonds pour chaque année de fondation). 

La clause PARTITION BY est utilisée pour partitionner les données par année de fondation, 
afin que le classement soit calculé séparément pour chaque année. L'opérateur ORDER BY est 
utilisé pour trier les startups en fonction du montant total de fonds levés, en ordre décroissant.

Notez que si plusieurs startups ont levé le même montant de fonds pour une année donnée, 
elles auront le même classement et pourront toutes être incluses dans les trois premiers résultats 
pour cette année.*/

--8. Retourner les 5 startups ayant levé le plus de fonds par trimestre et par année:
SELECT *
FROM (
  SELECT startup_name, founded_year, founded_quarter, SUM(funding_total_usd) AS total_funding, 
         NTILE(5) OVER (PARTITION BY founded_year, founded_quarter ORDER BY SUM(funding_total_usd) DESC) AS funding_rank
  FROM dim_temps
  JOIN fait_leve_de_fond ON dim_temps.temps_id = fait_leve_de_fond.temps_id
  JOIN dim_startup ON fait_leve_de_fond.startup_id = dim_startup.startup_id
  GROUP BY founded_year, founded_quarter, startup_name
)
WHERE funding_rank <= 5;

/*Cette requête utilise l'opérateur NTILE pour classer les startups en fonction du montant total de fonds 
levés par trimestre et par année. La fonction NTILE divise les startups en groupes de taille égale et attribue à 
chacun un rang en fonction de son montant de financement. Ensuite, la clause WHERE est utilisée pour ne sélectionner 
que les 5 startups ayant le rang le plus élevé (c'est-à-dire les 5 startups ayant levé le plus de fonds) pour 
chaque trimestre et chaque année. */

--9. Cette requête effectue une agrégation de données sur les tables dim_geographique, dim_startup et fait_leve_de_fond 
--pour calculer le montant total des fonds levés par marché dans chaque État des États-Unis pour les startups en activité 
--(c'est-à-dire ayant un statut 'operating').

SELECT dge.state_code, ds.market, SUM(flf.funding_total_usd) AS fond_total, DENSE_RANK() OVER (PARTITION BY dge.state_code ORDER BY SUM(flf.funding_total_usd) DESC) AS rank
FROM dim_geographique dge, fait_leve_de_fond flf, dim_startup ds 
WHERE dge.country_code = 'USA' AND ds.startup_status = 'operating' AND dge.geographique_id = flf.geographique_id AND flf.startup_id = ds.startup_id
GROUP BY GROUPING SETS ((dge.state_code, ds.market))
ORDER BY dge.state_code, rank;