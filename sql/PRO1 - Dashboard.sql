/*----PRO1 - Dashboard----------------------------------*/

/*----DEFAULT FILTERS----------------------------------*/
	DECLARE @dateDebut			DATE
	DECLARE @dateFin			DATE
	DECLARE @PAYS	     		NVARCHAR(4000) /*get filter from interface*/
	DECLARE @AGENCE	   		NVARCHAR(4000) /*get filter from interface*/
	DECLARE @GESTIONNAIRE 		NVARCHAR(4000) /*get filter from interface*/
	DECLARE @TYPE_D_ACCORD		NVARCHAR(4000) /*get filter from interface*/
	DECLARE @MARQUE			NVARCHAR(4000) /*get filter from interface*/
	DECLARE @MODELE			NVARCHAR(4000) /*get filter from interface*/
	DECLARE @VU_VP				NVARCHAR(4000) /*get filter from interface*/
	DECLARE @ENERGIE			NVARCHAR(4000) /*get filter from interface*/
	DECLARE @TRANSMISSION		NVARCHAR(4000) /*get filter from interface*/
	DECLARE @NB_PORTES			NVARCHAR(4000) /*get filter from interface*/

/*----SPECIFIC FILTERS FOR THIS REPORT------------------*/

	-- NONE
	
/*----GET FILTERS VALUES----------------------------------*/

		SET @dateDebut	 = '01/12/2015'
		SET @dateFin	 = GETDATE()
		/*get other filter from interface*/
		IF(@DateFin IS NOT NULL)
			SET @DateFin = DATEADD(DAY, 1, @DateFin)


/*----DROP TEMP TABLES IF EXISTS-------------------------------------------------*/
IF(object_id(N'tempdb..#CHART_DATA') is not null) 
drop table #CHART_DATA

IF(object_id(N'tempdb..#CHART_DATA_LastYear') is not null) 
drop table #CHART_DATA_LastYear

/*----SELECT DATA FROM FAIT TABLE FOR CHART----------------------*/

SELECT DimSousDossiersTypes.code	 AS short_label,
       DimSousDossiersTypes.nom	 AS long_label,
       COUNT(FaitSousDossiers.id)	 AS value

INTO #CHART_DATA
FROM FaitSousDossiers 
	LEFT OUTER JOIN DimUtilisateur			ON FaitSousDossiers.idUtilisateurCreation = DimUtilisateur.idUtilisateur
	LEFT OUTER JOIN DimSousDossiersTypes		ON FaitSousDossiers.idType = DimSousDossiersTypes.id
	LEFT OUTER JOIN DimDossiers				ON FaitSousDossiers.idDossier = DimDossiers.id
	LEFT OUTER JOIN DimVehicule				ON DimDossiers.idVehicule = DimVehicule.idVehicule
	LEFT OUTER JOIN DimMarque				ON COALESCE(DimVehicule.idMarque, DimDossiers.horsParcIdMarque) = DimMarque.idMarque
	LEFT OUTER JOIN DimModele				ON COALESCE(DimVehicule.idModele, DimDossiers.horsParcIdModele) = DimModele.idModele
	LEFT OUTER JOIN DimTypeVehicule			ON COALESCE(DimVehicule.idTypeVehicule, DimDossiers.horsParcIdType) = DimTypeVehicule.idTypeVehicule
	LEFT OUTER JOIN DimTypeEnergie			ON COALESCE(DimVehicule.idTypeEnergie, DimDossiers.horsParcIdEnergie) = DimTypeEnergie.idTypeEnergie
	LEFT OUTER JOIN DimTypeTransmission		ON DimVehicule.idTypeTransmission = DimTypeTransmission.idTypeTransmission
	LEFT OUTER JOIN DimClientCMC				ON DimDossiers.idClient = DimClientCMC.id
	LEFT OUTER JOIN DimAgence				ON DimClientCMC.idAgence = DimAgence.idAgence
	LEFT OUTER JOIN DimPays					ON DimAgence.idPays = DimPays.idPays

WHERE	  (FaitSousDossiers.dateCreation >= @dateDebut)
	AND	  (FaitSousDossiers.dateCreation <= @dateFin)
	/*AND  (DimPays.nom						  IN @PAYS )*/
	/*AND  (DimAgence						  IN @AGENCE )*/
	/*AND  (DimUtilisateur.idUtilisateur		  IN @GESTIONNAIRE )*/
	/*AND  (DimSousDossiersTypes.code			  IN @TYPE_D_ACCORD )*/
	/*AND  (DimVehicule.nNbPortes				  IN @NB_PORTES )*/
	/*AND  (DimMarque.Marque					  IN @MARQUE )*/
	/*AND  (DimModele.Modele					  IN @MODELE )*/
	/*AND  (DimTypeVehicule.TypeVehicule		  IN @VU_VP )*/
	/*AND  (DimTypeEnergie.TypeEnergie			  IN @ENERGIE )*/
	/*AND  (DimTypeTransmission.TypeTransmission	  IN @TRANSMISSION )*/

GROUP BY DimSousDossiersTypes.code,
         DimSousDossiersTypes.nom

ORDER BY COUNT(FaitSousDossiers.id) DESC


SELECT * FROM #CHART_DATA


/*----SELECT DATA FROM FAIT TABLE FOR TOTAL AND TREND----------------------*/


SELECT  COUNT(FaitSousDossiers.id)  AS total_LastYear,
	   (SELECT SUM(#CHART_DATA.value) FROM #CHART_DATA) AS total_ThisYear

INTO #CHART_DATA_LastYear
FROM FaitSousDossiers
	LEFT OUTER JOIN DimUtilisateur			ON FaitSousDossiers.idUtilisateurCreation = DimUtilisateur.idUtilisateur
	LEFT OUTER JOIN DimSousDossiersTypes		ON FaitSousDossiers.idType = DimSousDossiersTypes.id
	LEFT OUTER JOIN DimDossiers				ON FaitSousDossiers.idDossier = DimDossiers.id
	LEFT OUTER JOIN DimVehicule				ON DimDossiers.idVehicule = DimVehicule.idVehicule
	LEFT OUTER JOIN DimMarque				ON COALESCE(DimVehicule.idMarque, DimDossiers.horsParcIdMarque) = DimMarque.idMarque
	LEFT OUTER JOIN DimModele				ON COALESCE(DimVehicule.idModele, DimDossiers.horsParcIdModele) = DimModele.idModele
	LEFT OUTER JOIN DimTypeVehicule			ON COALESCE(DimVehicule.idTypeVehicule, DimDossiers.horsParcIdType) = DimTypeVehicule.idTypeVehicule
	LEFT OUTER JOIN DimTypeEnergie			ON COALESCE(DimVehicule.idTypeEnergie, DimDossiers.horsParcIdEnergie) = DimTypeEnergie.idTypeEnergie
	LEFT OUTER JOIN DimTypeTransmission		ON DimVehicule.idTypeTransmission = DimTypeTransmission.idTypeTransmission
	LEFT OUTER JOIN DimClientCMC				ON DimDossiers.idClient = DimClientCMC.id
	LEFT OUTER JOIN DimAgence				ON DimClientCMC.idAgence = DimAgence.idAgence
	LEFT OUTER JOIN DimPays					ON DimAgence.idPays = DimPays.idPays

WHERE	  (FaitSousDossiers.dateCreation >= DateAdd(yy, -1, @dateDebut))
	AND	  (FaitSousDossiers.dateCreation <= DateAdd(yy, -1, @dateFin))
	/*AND  (DimPays.nom						  IN @PAYS )*/
	/*AND  (DimAgence						  IN @AGENCE )*/
	/*AND  (DimUtilisateur.idUtilisateur		  IN @GESTIONNAIRE )*/
	/*AND  (DimSousDossiersTypes.code			  IN @TYPE_D_ACCORD )*/
	/*AND  (DimVehicule.nNbPortes				  IN @NB_PORTES )*/
	/*AND  (DimMarque.Marque					  IN @MARQUE )*/
	/*AND  (DimModele.Modele					  IN @MODELE )*/
	/*AND  (DimTypeVehicule.TypeVehicule		  IN @VU_VP )*/
	/*AND  (DimTypeEnergie.TypeEnergie			  IN @ENERGIE )*/
	/*AND  (DimTypeTransmission.TypeTransmission	  IN @TRANSMISSION )*/

--SELECT * FROM #CHART_DATA_LastYear

SELECT  CASE	  WHEN total_ThisYear > total_LastYear THEN CAST(total_ThisYear AS NVARCHAR)+' /'
	   		  WHEN total_ThisYear < total_LastYear THEN CAST(total_ThisYear AS NVARCHAR)+' \'
	   		  WHEN total_ThisYear = total_LastYear THEN CAST(total_ThisYear AS NVARCHAR)+' -'
	   		  ELSE CAST(total_ThisYear AS NVARCHAR)
	   END as total,
	   CASE	  WHEN total_ThisYear > total_LastYear THEN ' green'
	   		  WHEN total_ThisYear < total_LastYear THEN ' red'
	   		  WHEN total_ThisYear = total_LastYear THEN ' black'
	   		  ELSE CAST(total_ThisYear AS NVARCHAR)
	   END as color
	   	  
FROM #CHART_DATA_LastYear