
--LES REQUETES

--5
select distinct specialite, tmedecin.nb_spe(specialite) from medecin;

--6
SELECT serv.code_service, serv.nb_inf() AS 'nb infermier'
FROM sservice serv;
SELECT pat.num_patient, pat.nb_med() AS 'nb medecin'
FROM patient pat;

--7
SELECT pat.num_patient, pat.nb_medecin() AS "nb medecin"
FROM patient pat;
--8
DECLARE
    inf TINFERMIER;
BEGIN
    SELECT value(i) INTO inf
    FROM INFERMIER i
    WHERE i.num_emp = 12;
    inf.verif_sal;
END;
/



--9

SELECT pat.nom_patient AS "nom" ,pat.prenom_patient AS "prenom"
FROM patient pat
WHERE pat.mutuelle = 'MAAF';

--10

SELECT pat.hospt.lit AS "numero lit",
    cham.num_chambre AS "numero chambre",
    DEREF(cham.cham_serv).nom_service AS "nom service",
    pat.nom_patient AS "nom patient",
    pat.prenom_patient AS "prenom patient",
    pat.mutuelle AS "mutuelle"
FROM patient pat, chambre cham
WHERE pat.mutuelle LIKE 'MN%' and DEREF(cham.cham_serv).batiment = 'B' 
      and pat.hospt IS NOT NULL and 
     DEREF(pat.hospt.hospt_cham).code_service = cham.code_service and
     DEREF(pat.hospt.hospt_cham).num_chambre = cham.num_chambre;

--11
SELECT pat.num_patient AS "NUM patient",
pat.nom_patient AS "NOM patient",
pat.prenom_patient AS "PRENOM patient",
pat.nb_medecin() AS "nb_medecin",
COUNT(DISTINCT DEREF(patMed.column_value).specialite) AS "nb_specialite"
FROM patient pat,TABLE(pat.pat_med) patMed
GROUP BY pat.num_patient,
pat.prenom_patient,pat.nom_patient,pat.nb_medecin()
HAVING pat.nb_medecin() > 3;


--12
SELECT serv.code_service AS "code_service",
serv.nom_service AS "nom service",
AVG(DEREF(servInf.column_value).salaire) AS "Moyenne par service"
FROM sservice serv,TABLE(serv.serv_inf) servInf
GROUP BY serv.code_service, serv.nom_service;


--13
SELECT serv.code_service AS "code service",
serv.nom_service AS "nom service",
serv.nb_inf() AS "nb infirmier",
serv.nb_pat() AS "nb patient",
(serv.nb_inf() / serv.nb_pat()) AS "inf/pat"
FROM sservice serv;
--GROUP BY serv.code_service,serv.nom_service,serv.nb_inf(),serv.nb_pat();

--14
SELECT med.num_emp AS "numero medecin",
med.nom_emp AS "nom medecin",
med.prenom_emp AS "prenom medecin"
FROM medecin med,TABLE(med.med_pat) medPat
WHERE DEREF(medPat.column_value).hospt IS NOT NULL
GROUP BY med.num_emp,
med.nom_emp,med.prenom_emp
HAVING COUNT(
DISTINCT DEREF(
DEREF(medPat.column_value).hospt.hospt_cham).code_service) = (
SELECT COUNT(*) FROM sservice
);



