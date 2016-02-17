/*----PRO1 - XLS Export----------------------------------*/

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

	SET @dateDebut	 = '01/01/2016 00:00:00'
	SET @dateFin	 = GETDATE()

	/*get other filter from interface*/

		
	IF(@DateFin IS NOT NULL)
		SET @DateFin = DATEADD(DAY, 1, @DateFin)

/*----SELECT DATA FROM FAIT TABLE----------------------*/

SELECT	top (1000000) /*rows limitation for excel 2007*/
		DimDossiers.id										AS Dossier
	,	DimSousDossiersEtats.nom								AS Etat
	,	DimPays.codPays									AS Pays
	,	DimAgence.VilleAgence								AS Agence
	,	DimSousDossiersTypes.nom								AS SousDossierType
	,	DimSousDossiersSousTypes.nom							AS SousDossiersSousTypes
	,	DimSousDossiersSousSousTypes.nom						AS SousDossiersSousSousTypes
	,	DimVehicule.Immatriculation							AS Immatriculation
	,	CONVERT(nvarchar, FaitSousDossiers.dateCreation, 120)		AS dateCreation
	,	DimUtilisateur.Prenom+' '+DimUtilisateur.nom 			AS cree_par
	,	CONVERT(nvarchar, FaitSousDossiers.dateSignalement, 120)	AS dateSignalement
	,	CONVERT(nvarchar, FaitSousDossiers.dateIntervention, 120)	AS dateIntervention
	,	FaitSousDossiers.idFournisseur						AS idFournisseur
	,	DimPersonne.RaisonSociale							AS Fournisseur
	,	FaitSousDossiers.idAssisteur							AS idAssisteur
	,	FaitSousDossiers.referenceACTA						AS referenceACTA
	,	FaitSousDossiers.referenceAssistanceConstructeur			AS referenceAssistanceConstructeur
	,	DimVehicule.Marque									AS V_Marque
	,	DimVehicule.Modele									AS V_Modele
	,	DimVehicule.Version									AS V_Version
	,	DimTypeVehicule.TypeVehicule					 		AS V_Type
	,	DimTypeEnergie.TypeEnergie							AS V_Energie
	,	DimTypeTransmission.TypeTransmission					AS V_Transmission
	
FROM FaitSousDossiers 
	LEFT OUTER JOIN DimSousDossiersEtats		ON FaitSousDossiers.idDernierEtat = DimSousDossiersEtats.id
	LEFT OUTER JOIN DimUtilisateur			ON FaitSousDossiers.idUtilisateurCreation = DimUtilisateur.idUtilisateur
	--LEFT OUTER JOIN DimSousDossiersTypes		ON FaitSousDossiers.idType = DimSousDossiersTypes.id
	--LEFT OUTER JOIN DimSousDossiersSousTypes	ON FaitSousDossiers.idSousType = DimSousDossiersSousTypes.id
	--LEFT OUTER JOIN DimSousDossiersSousSousTypes	ON FaitSousDossiers.idSousSousType = DimSousDossiersSousSousTypes.id
	LEFT OUTER JOIN DimFournisseur			ON FaitSousDossiers.idFournisseur = DimFournisseur.idFournisseur
	LEFT OUTER JOIN DimDossiers				ON FaitSousDossiers.idDossier = DimDossiers.id
	LEFT OUTER JOIN DimVehicule				ON DimDossiers.idVehicule = DimVehicule.idVehicule
	--LEFT OUTER JOIN DimMarque				ON COALESCE(DimVehicule.idMarque, DimDossiers.horsParcIdMarque) = DimMarque.idMarque
	LEFT OUTER JOIN DimModele				ON COALESCE(DimVehicule.idModele, DimDossiers.horsParcIdModele) = DimModele.idModele
	LEFT OUTER JOIN DimTypeVehicule			ON COALESCE(DimVehicule.idTypeVehicule, DimDossiers.horsParcIdType) = DimTypeVehicule.idTypeVehicule
	--LEFT OUTER JOIN DimTypeEnergie			ON COALESCE(DimVehicule.idTypeEnergie, DimDossiers.horsParcIdEnergie) = DimTypeEnergie.idTypeEnergie
	LEFT OUTER JOIN DimTypeTransmission		ON DimVehicule.idTypeTransmission = DimTypeTransmission.idTypeTransmission
	LEFT OUTER JOIN DimPersonne				ON DimFournisseur.idPersonneMorale = DimPersonne.idPersonne
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

ORDER BY FaitSousDossiers.dateCreation DESC