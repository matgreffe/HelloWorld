/*----PRO1 - Report----------------------------------*/

/*----VENTILATION----------------------------------*/

	DECLARE @Type 				NVARCHAR(4000)/*get filter from interface*/
	--SET @Type = 'marque'
	--SET @Type = 'modele'

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

	SET @dateDebut	 = '01/01/2015 00:00:00'
	SET @dateFin	 = '15/03/2016 00:00:00'

	/*get other filter from interface*/
	IF(@DateFin IS NOT NULL)
		SET @DateFin = DATEADD(DAY, 1, @DateFin)

/*----DROP TEMP TABLES IF EXISTS-------------------------------------------------*/
IF(object_id(N'tempdb..#TMP') is not null) 
drop table #TMP

IF(object_id(N'tempdb..#TMP_TOTAL_COL1') is not null) 
drop table #TMP_TOTAL_COL1

IF(object_id(N'tempdb..#TMP_TOTAL_COL2') is not null) 
drop table #TMP_TOTAL_COL2


/*----SELECT DATA IN A TEMP TABLE------------------------------------*/

SELECT CASE	WHEN @Type = 'marque' THEN DimVehicule.Marque	
			WHEN @Type = 'modele' THEN DimVehicule.Modele
			ELSE CONVERT(VARCHAR(6), FaitSousDossiers.dateCreation, 112) END 
		AS col1,
		FaitSousDossiers.idType		AS col2,
		COUNT(FaitSousDossiers.id)	AS cnt

INTO #TMP
FROM FaitSousDossiers 
	LEFT OUTER JOIN DimSousDossiersEtats			ON FaitSousDossiers.idDernierEtat = DimSousDossiersEtats.id
	LEFT OUTER JOIN DimUtilisateur					ON FaitSousDossiers.idUtilisateurCreation = DimUtilisateur.idUtilisateur
	LEFT OUTER JOIN DimSousDossiersTypes			ON FaitSousDossiers.idType = DimSousDossiersTypes.id
	LEFT OUTER JOIN DimSousDossiersSousTypes		ON FaitSousDossiers.idSousType = DimSousDossiersSousTypes.id
	LEFT OUTER JOIN DimSousDossiersSousSousTypes	ON FaitSousDossiers.idSousSousType = DimSousDossiersSousSousTypes.id
	LEFT OUTER JOIN DimFournisseur					ON FaitSousDossiers.idFournisseur = DimFournisseur.idFournisseur
	LEFT OUTER JOIN DimDossiers						ON FaitSousDossiers.idDossier = DimDossiers.id
	LEFT OUTER JOIN DimVehicule						ON DimDossiers.idVehicule = DimVehicule.idVehicule
	LEFT OUTER JOIN DimMarque						ON COALESCE(DimVehicule.idMarque, DimDossiers.horsParcIdMarque) = DimMarque.idMarque
	LEFT OUTER JOIN DimModele						ON COALESCE(DimVehicule.idModele, DimDossiers.horsParcIdModele) = DimModele.idModele
	LEFT OUTER JOIN DimTypeVehicule					ON COALESCE(DimVehicule.idTypeVehicule, DimDossiers.horsParcIdType) = DimTypeVehicule.idTypeVehicule
	LEFT OUTER JOIN DimTypeEnergie					ON COALESCE(DimVehicule.idTypeEnergie, DimDossiers.horsParcIdEnergie) = DimTypeEnergie.idTypeEnergie
	LEFT OUTER JOIN DimTypeTransmission				ON DimVehicule.idTypeTransmission = DimTypeTransmission.idTypeTransmission
	LEFT OUTER JOIN DimPersonne						ON DimFournisseur.idPersonneMorale = DimPersonne.idPersonne
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

GROUP BY FaitSousDossiers.idType,
		CASE	WHEN @Type = 'marque' THEN DimVehicule.Marque	
			WHEN @Type = 'modele' THEN DimVehicule.Modele
			ELSE CONVERT(VARCHAR(6), FaitSousDossiers.dateCreation, 112) END 
	
--SELECT * FROM #TMP

/*---- TOTAL_COL1 -------------------------------------------------*/
select	col1, 
		SUM(cnt)	AS sumCnt
INTO #TMP_TOTAL_COL1
FROM #TMP
GROUP BY col1

--SELECT * FROM #TMP_TOTAL_COL1 ORDER BY 2 desc

/*---- TOTAL_COL2 -------------------------------------------------*/
select	col2, 
		SUM(cnt)	AS sumCnt
INTO #TMP_TOTAL_COL2
FROM #TMP
GROUP BY col2

--SELECT * FROM #TMP_TOTAL_COL2 ORDER BY 2 desc


/*----select data for chart-------------------------------------------------*/
SELECT	--#TMP.col1				 AS Z_labelid,
		#TMP.col1				 AS X_label,
		DimSousDossiersTypes.nom	 AS Z_label,
		#TMP.cnt				 AS Y_value

FROM #TMP
	LEFT OUTER JOIN #TMP_TOTAL_COL1					ON #TMP.col1 = #TMP_TOTAL_COL1.col1
	LEFT OUTER JOIN #TMP_TOTAL_COL2					ON #TMP.col2 = #TMP_TOTAL_COL2.col2
	LEFT OUTER JOIN DimSousDossiersTypes			ON #TMP.col2 = DimSousDossiersTypes.id

ORDER BY CASE	WHEN @Type = 'marque' THEN #TMP_TOTAL_COL1.sumCnt
				WHEN @Type = 'modele' THEN #TMP_TOTAL_COL1.sumCnt
				ELSE #TMP.col1 END DESC,
				#TMP_TOTAL_COL2.sumCnt DESC