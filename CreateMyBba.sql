--1 creation des TBS
create tablespace SQL3_TBS  datafile 'C:\Users\HP\Documents\PYTHON CODECADEMY\TP S2\TP\TPBDA\SQL3_TBS.dat' size 100M autoextend on online;
create temporary tablespace SQL3_TempTBS tempfile 'C:\Users\HP\Documents\PYTHON CODECADEMY\TP S2\TP\TPBDA\SQL3_TempBS.dat' size 100M autoextend on;

--2 creation de l'utilisateur
create user DBAHOPITAL identified by 123 default tabelspace SQL3_TBS temporary tabelspace SQL3_TEMPTBS; 

--3 donner tous les privileges
connect dbahopital/123;
grant all privileges to DBAHOPITAL;


--4 definition des types
CREATE OR REPLACE TYPE temploye;
/
CREATE OR REPLACE TYPE tmedecin;
/
CREATE OR REPLACE TYPE tinfirmier;
/
CREATE OR REPLACE TYPE tservice;
/
CREATE OR REPLACE TYPE tchambre;
/
CREATE OR REPLACE TYPE tpatient;
/
CREATE OR REPLACE TYPE thospitalisation;
/

--creation des types imbriques
CREATE OR REPLACE TYPE tset_ref_medecin as table of ref tmedecin;
/

create or replace type tset_ref_infermier as table of ref tinfermier;
/

create or replace type tset_ref_service as table of ref tservice;
/

create or replace type tset_ref_chambre as table of ref tchambre;
/

create or replace type temploye as object (
    num_emp INTEGER,
    nom_emp varchar2(50),
    prenom_emp varchar2(50),
    adresse_emp varchar2(100),
    tel_emp varchar2(100)
    ) not final;
/

create or replace type tmedecin under temploye (
  specialite varchar2(30),
    med_pat tset_ref_patient,
    chef_serv tset_ref_service
    );
/

create or replace type tinfermier under temploye(
    rotation varchar2(4),
    salaire float(2),
    inf_serv ref tservice,
    inf_survaillant_cham tset_ref_chambre
    );
/

create or replace type tservice as object (
    code_service varchar2(3),
    nom_service varchar2(50),
  batiment varchar2(1),
  serv_chef ref tmedecin,
   serv_inf tset_ref_infermier,
  serv_cham tset_ref_chambre
   );
/


create or replace type tpatient as object (
 num_patient INTEGER,
  nom_patient varchar2(50),
  prenom_patient varchar2(50),
   adresse_patient varchar2(100),
  tel_patient varchar2(12),
  mutuelle varchar2(10),
  pat_med tset_ref_medecin,
  hospt thospitalisation
  );
/

create or replace type thospitalisation as object (
 lit INTEGER,
 hospt_cham ref tchambre
 );
/

--4 creation des table
create table medecin of tmedecin (
  constraint pk_med primary key(num_emp))
  nested table med_pat store as table_med_pat,
  nested table chef_serv store as table_chef_serv;

create table sservice of tservice (
  constraint pk_serv primary key(code_service),
  constraint fk_serv foreign key (serv_chef) references medecin)
  nested table serv_inf store as table_serv_inf,
 nested table serv_cham store as table_serv_cham;

create table infermier of tinfermier (
  constraint pk_inf primary key(num_emp),
  constraint fk_inf foreign key(inf_serv) references sservice,
  check (rotation in ('NUIT','JOUR')))
  nested table inf_survaillant_cham store as table_inf_survaillant_cham;

create table chambre of tchambre (
  constraint pk_cham primary key(code_service,num_chambre),
  constraint fk_cham_inf foreign key(cham_inf_survaillant) references infermier,
  constraint fk_cham_serv foreign key(cham_serv) references sservice)
 nested table cham_hospt store as table_cham_hospt;

alter table chambre add constraint ck_lit check (lit>0);

create table patient of tpatient (
constraint pk_pat primary key(num_patient),
constraint fk_pat foreign key(hospt.hospt_cham) references chambre)
nested table pat_med store as table_pat_med;

--Les methodes
SET SERVEROUTPUT ON
--5 nb specialite
alter type tmedecin add static function nb_spe(spec varchar2) return INTEGER cascade;

create or replace type BODY tmedecin as static function nb_spe(spec varchar2)
return integer is nb_med integer;
Begin
select count(med.num_emp) into nb_med
from medecin med
where med.specialite = spec
group by med.specialite;
return nb_med;
end;
end;
/


--6 nb patient et nb infermier
alter type tservice add member function nb_pat return INTEGER cascade;
alter type tservice add member function nb_inf return INTEGER cascade;

create or replace type BODY tservice as member function nb_inf
  return integer is result integer;
  Begin
  select count(Distinct serInf.column_value) into result
  from table(self.serv_inf) serInf;
  return result;
  end nb_inf;
  member function nb_pat return integer is result1 integer;
  Begin
  select count(distinct chamHospt.column_value) into result1
  from table(self.serv_cham) servCham, chambre cham, table(cham.cham_hospt) chamHospt
  where servCham.column_value = REF(cham);
  return result1;
  end nb_pat;
  end;
/

--7 nb medecin par patient
alter type tpatient add member function nb_medecin return integer cascade;

create or replace type BODY tpatient as member function nb_medecin
return integer is nbMedResult integer;
Begin
select count(distinct pat.column_value) into nbMedResult
from table(self.pat_med) pat;
return nbMedResult;
end nb_medecin;
end;
/

--8 salaire infermier
alter type tinfermier add member procedure verif_sal cascade;

create or replace type BODY tinfermier as member procedure verif_sal is
 BEGIN if self.salaire BETWEEN 10000 and 30000 then
 DBMS_output.put_line('verification positive');
 else DBMS_output.put_line('verification negative');
  end if;
end verif_sal;
 end;
/