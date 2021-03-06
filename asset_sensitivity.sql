
alter table resilience_variables
add column asset_type text;

-------non parcel asset definitions-------
------historic structures-------------

create or replace view historic_district_vw as
SELECT b.pinnum as pinnum
from local_historic_district_overlay as a 
join resilience_variables as b 
on st_intersects(a.geom,b.geom)
group by b.pinnum;

create or replace view historic_district_define_vw as 
select a.pinnum, (case when a.pinnum = b.pinnum then 'Historic Structure' else 
null end) as asset_type from historic_district_vw as a, resilience_variables as b 
where a.pinnum = b.pinnum;

create or replace view historic_structures_vw as
SELECT b.pinnum as pinnum
from historic_landmarks_register_properties_point as a 
join resilience_variables as b 
on st_intersects(a.geom,b.geom)
group by b.pinnum;

create or replace view historic_structures_define_vw as 
select a.pinnum, (case when a.pinnum = b.pinnum then 'Historic Structure' else 
null end) as asset_type from historic_structures_vw as a, resilience_variables as b 
where a.pinnum = b.pinnum;


update resilience_variables as a 
set asset_type = b.asset_type
from historic_structures_define_vw as b 
where a.pinnum = b.pinnum;

update resilience_variables as a 
set asset_type = b.asset_type
from historic_district_define_vw as b 
where a.pinnum = b.pinnum;


----city parks-------------------------
create or replace view coa_parks_vw as 
SELECT b.pinnum as pinnum
from coa_parks as a 
join resilience_variables as b 
on st_intersects(a.geom,b.geom)
group by b.pinnum;

create or replace view coa_parks_define_vw as 
select a.pinnum, (case when a.pinnum = b.pinnum then 'City Parks' else 
null end) as asset_type from historic_structures_vw as a, resilience_variables as b 
where a.pinnum = b.pinnum;

update resilience_variables as a 
set asset_type = b.asset_type
from coa_parks_define_vw as b 
where a.pinnum = b.pinnum;




---------------food assets definition--------------

create or replace view food_infrastructure_vw as 
select  b.pinnum, a.* from food_infrastructure_buncombe as a, resilience_variables as b 
where a.address::text like concat('%', upper(b.address), '%');

create or replace view food_infrastructure_vw_defintion AS
select a.pinnum, (case when a.pinnum = b.pinnum then 'Food' else 
null end) as asset_type from food_infrastructure_vw as a, resilience_variables as b 
where a.pinnum = b.pinnum;

create or replace view food_snap_retailers_vw as
select  b.pinnum, a.* from food_snap_retailers as a, resilience_variables as b 
where a.address::text like concat('%', upper(b.address), '%');

create or replace view food_snap_retailers_defintion_vw as 
select a.pinnum, (case when a.pinnum = b.pinnum then 'Food' else 
null end) as asset_type from food_snap_retailers_vw as a, resilience_variables as b 
where a.pinnum = b.pinnum;


update resilience_variables as a 
set asset_type =b.asset_type 
from food_snap_retailers_defintion_vw as b 
where a.pinnum = b.pinnum;

update resilience_variables as a 
set asset_type =b.asset_type 
from food_infrastructure_vw_defintion as b 
where a.pinnum = b.pinnum;
 

----parcel type asset defintion-------------

create or replace view asset_type as 
select pinnum, ( CASE
WHEN class >= '100' AND class < '200' THEN 'Residential'
WHEN class = '411' THEN 'Residential'
WHEN class = '411' THEN 'Residential'
WHEN class = '416' THEN 'Residential'
WHEN class = '476' THEN 'Residential'
WHEN class = '631' THEN 'Residential'
WHEN class = '633' THEN 'Residential'
WHEN class = '634' THEN 'Residential'
WHEN class = '635' THEN 'Residential'
WHEN class = '644' THEN 'Residential'
WHEN class = '250' THEN 'Commercial'
WHEN class >= '400' AND class < '411' THEN 'Commercial'
WHEN class >= '412' AND class < '416' THEN 'Commercial'
WHEN class >= '417' AND class < '476' THEN 'Commercial'
WHEN class >= '477' AND class < '500' THEN 'Commercial'
WHEN class = '307' THEN 'Parking'
WHEN class = '437' THEN 'Parking'
WHEN class = '438' THEN 'Parking'
WHEN class = '850' THEN 'Waste'
WHEN class = '852' THEN 'Waste'
WHEN class = '853' THEN 'Waste'
WHEN class >= '700' AND class < '800' THEN 'Industrial'
WHEN class = '830' THEN 'Communications'
WHEN class = '831' THEN 'Communications'
WHEN class = '836' THEN 'Communications'
WHEN class = '810' THEN 'Energy'
WHEN class = '812' THEN 'Energy'
WHEN class = '817' THEN 'Energy'
WHEN class = '818' THEN 'Energy'
WHEN class = '640' THEN 'Emerg Services'
WHEN class = '641' THEN 'Emerg Services'
WHEN class = '642' THEN 'Emerg Services'
WHEN class = '660' THEN 'Emerg Services'
WHEN class = '661' THEN 'Emerg Services'
WHEN class = '662' THEN 'Emerg Services'
WHEN class = '820' THEN 'Water Resources'
WHEN class = '822' THEN 'Water Resources'     
WHEN class = '853' THEN 'Water Resources'
ELSE null END) as asset_type, geom
from resilience_variables;

update resilience_variables as a 
set asset_type = b.asset_type 
from asset_type as b
where a.pinnum = b.pinnum;


-------------------------------if starting fresh uncomment and run the script---------------------------------
-- drop view communications_vw cascade;
-- drop view commercial_vw cascade;
-- drop view energy_vw cascade;
-- drop view industrial_vw cascade;
-- drop view city_parks_vw cascade;
-- drop view emergency_services_vw cascade;
-- drop view water_resources_vw cascade;
-- drop view historic_structures_all_vw cascade;

create or replace view communications_vw as 
select * from resilience_variables where asset_type = 'Communications';

create or replace view communications_fld_vw as 
select * from resilience_variables where asset_type = 'Communications' 
and par_fl5yr_yn = 'yes';

create or replace view communications_flooded_total as
select
(select asset_type from resilience_variables where asset_type = 'Communications' limit 1),
(select count(pinnum) from communications_fld_vw) as flooded,
(select count(pinnum) from communications_vw) as total;

create or replace view communications_fld_percentage as 
select asset_type, flooded, total, flooded/total::float * 100 as percentage from communications_flooded_total
group by flooded,total, asset_type;

create or replace view communications_ls_vw as 
select * from resilience_variables where asset_type = 'Communications' 
and par_ls_yn = 'yes';

create or replace view communications_ls_total as
select
(select asset_type from resilience_variables where asset_type = 'Communications' limit 1),
(select count(pinnum) from communications_ls_vw) as landslide,
(select count(pinnum) from communications_vw) as total;

create or replace view communications_ls_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from communications_ls_total
group by landslide,total ,asset_type;

create or replace view communications_wf_vw as 
select * from resilience_variables where asset_type = 'Communications' 
and par_wf_yn = 'yes';

create or replace view communications_wf_total as
select
(select asset_type from resilience_variables where asset_type = 'Communications' limit 1),
(select count(pinnum) from communications_wf_vw) as landslide,
(select count(pinnum) from communications_vw) as total;

create or replace view communications_wf_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from communications_wf_total
group by landslide,total ,asset_type;

------------------------------residential--------------------------------------

CREATE OR REPLACE VIEW public.residential_fld_vw AS 
 SELECT *
        CASE
            WHEN resilience_variables.bldg_fl5yr_yn = 'yes'::text AND (resilience_variables.class::text = '170'::text OR resilience_variables.class::text = '180'::text OR resilience_variables.class::text = '411'::text OR resilience_variables.class::text = '416'::text OR resilience_variables.class::text = '476'::text OR resilience_variables.class::text = '631'::text OR resilience_variables.class::text = '633'::text OR resilience_variables.class::text = '634'::text OR resilience_variables.class::text = '635'::text OR resilience_variables.class::text = '644'::text) THEN 'High'::text
            WHEN resilience_variables.bldg_fl5yr_yn = 'yes'::text AND (resilience_variables.class::text = '100'::text OR resilience_variables.class::text = '105'::text OR resilience_variables.class::text = '120'::text OR resilience_variables.class::text = '121'::text OR resilience_variables.class::text = '122'::text) THEN 'Med'::text
            ELSE 'Low'::text
        END AS sensitivity,
        CASE
            WHEN resilience_variables.buildingva > 127500::numeric AND resilience_variables.year > 1980::numeric THEN 'High'::text
            WHEN resilience_variables.buildingva <= 127500::numeric AND resilience_variables.year < 1981::numeric THEN 'Low'::text
            ELSE 'Med'::text
        END AS adapt_cap,
    resilience_variables.landvalue,
    resilience_variables.par_fldwy_yn,
    resilience_variables.bldg_fldwy_yn
   FROM resilience_variables
  WHERE resilience_variables.asset_type = 'Residential'::text AND resilience_variables.par_fl5yr_yn = 'yes'::text;


CREATE OR REPLACE VIEW public.residential_flooded_total AS 
 SELECT ( SELECT resilience_variables.asset_type
           FROM resilience_variables
          WHERE resilience_variables.asset_type = 'Residential'::text
         LIMIT 1) AS asset_type,
    ( SELECT count(residential_fld_vw.pinnum) AS count
           FROM residential_fld_vw) AS flooded,
    ( SELECT count(residential_vw.pinnum) AS count
           FROM residential_vw) AS total;


CREATE OR REPLACE VIEW public.residential_fld_percentage AS 
 SELECT residential_flooded_total.asset_type,
    residential_flooded_total.flooded,
    residential_flooded_total.total,
    residential_flooded_total.flooded::double precision / residential_flooded_total.total::double precision * 100::double precision AS percentage
   FROM residential_flooded_total
  GROUP BY residential_flooded_total.flooded, residential_flooded_total.total, residential_flooded_total.asset_type;



CREATE OR REPLACE VIEW public.residential_ls_vw AS 
 SELECT *
   FROM resilience_variables
  WHERE resilience_variables.asset_type = 'Residential'::text AND resilience_variables.par_ls_yn = 'yes'::text;


CREATE OR REPLACE VIEW public.residential_ls_total AS 
 SELECT ( SELECT resilience_variables.asset_type
           FROM resilience_variables
          WHERE resilience_variables.asset_type = 'Residential'::text
         LIMIT 1) AS asset_type,
    ( SELECT count(residential_ls_vw.pinnum) AS count
           FROM residential_ls_vw) AS landslide,
    ( SELECT count(residential_vw.pinnum) AS count
           FROM residential_vw) AS total;

CREATE OR REPLACE VIEW public.residential_ls_percentage AS 
 SELECT residential_ls_total.asset_type,
    residential_ls_total.landslide,
    residential_ls_total.total,
    residential_ls_total.landslide::double precision / residential_ls_total.total::double precision * 100::double precision AS percentage
   FROM residential_ls_total
  GROUP BY residential_ls_total.landslide, residential_ls_total.total, residential_ls_total.asset_type;


CREATE OR REPLACE VIEW public.residential_wf_vw AS 
 SELECT *
   FROM resilience_variables
  WHERE resilience_variables.asset_type = 'Residential'::text AND resilience_variables.par_wf_yn = 'yes'::text;


CREATE OR REPLACE VIEW public.residential_wf_total AS 
 SELECT ( SELECT resilience_variables.asset_type
           FROM resilience_variables
          WHERE resilience_variables.asset_type = 'Residential'::text
         LIMIT 1) AS asset_type,
    ( SELECT count(residential_wf_vw.pinnum) AS count
           FROM residential_wf_vw) AS wildfire,
    ( SELECT count(residential_vw.pinnum) AS count
           FROM residential_vw) AS total;


  CREATE OR REPLACE VIEW public.residential_wf_percentage AS 
 SELECT residential_wf_total.asset_type,
    residential_wf_total.wildfire,
    residential_wf_total.total,
    residential_wf_total.wildfire::double precision / residential_wf_total.total::double precision * 100::double precision AS percentage
   FROM residential_wf_total
  GROUP BY residential_wf_total.wildfire, residential_wf_total.total, residential_wf_total.asset_type;



----------------------------commercial---------------------------------------------


--flood---

create or replace view commercial_vw as 
select * from resilience_variables where asset_type = 'Commercial';

create or replace view commercial_fld_vw as 
select * from resilience_variables where asset_type = 'Commercial' 
and par_fl5yr_yn = 'yes';

create or replace view commercial_flooded_total as
select
(select asset_type from resilience_variables where asset_type = 'Commercial' limit 1),
(select count(pinnum) from commercial_fld_vw) as flooded,
(select count(pinnum) from commercial_vw) as total;

create or replace view commercial_fld_percentage as 
select asset_type, flooded, total, flooded/total::float * 100 as percentage from commercial_flooded_total
group by flooded,total,asset_type;


---landslide------

create or replace view commercial_ls_vw as 
select * from resilience_variables where asset_type = 'Commercial' 
and par_ls_yn = 'yes';

create or replace view commercial_ls_total as
select
(select asset_type from resilience_variables where asset_type = 'Commercial' limit 1),
(select count(pinnum) from commercial_ls_vw) as landslide,
(select count(pinnum) from commercial_vw) as total;

create or replace view commercial_ls_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from commercial_ls_total
group by landslide,total,asset_type;


--wildfire---

create or replace view commercial_wf_vw as 
select * from resilience_variables where asset_type = 'Commercial' 
and par_wf_yn = 'yes';

create or replace view commercial_wf_total as
select
(select asset_type from resilience_variables where asset_type = 'Commercial' limit 1),
(select count(pinnum) from commercial_wf_vw) as wildfire,
(select count(pinnum) from commercial_vw) as total;

create or replace view commercial_wf_percentage as 
select asset_type, wildfire, total, wildfire/total::float * 100 as percentage from commercial_wf_total
group by wildfire,total,asset_type;




--------------------industrial-------------------------------------------

--flood-----

create or replace view industrial_vw  as 
select * from resilience_variables where asset_type = 'Industrial'; 

create or replace view industrial_fld_vw  as 
select * from resilience_variables where asset_type = 'Industrial' 
and par_fl5yr_yn = 'yes';

create or replace view industrial_flooded_total as
select
(select asset_type from resilience_variables where asset_type = 'Industrial' limit 1),
(select count(pinnum) from industrial_fld_vw) as flooded,
(select count(pinnum) from industrial_vw) as total;

create or replace view industrial_fld_percentage as 
select asset_type, flooded, total, flooded/total::float * 100 as percentage from industrial_flooded_total
group by flooded,total,asset_type;


--landslide--


create or replace view industrial_ls_vw as 
select * from resilience_variables where asset_type = 'Industrial' 
and par_ls_yn = 'yes';

create or replace view industrial_ls_total as
select
(select asset_type from resilience_variables where asset_type = 'Industrial' limit 1),
(select count(pinnum) from industrial_ls_vw) as landslide,
(select count(pinnum) from industrial_vw) as total;

create or replace view industrial_ls_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from industrial_ls_total
group by landslide,total,asset_type;


--wildfire-----

create or replace view industrial_wf_vw as 
select * from resilience_variables where asset_type = 'Industrial' 
and par_wf_yn = 'yes';

create or replace view industrial_wf_total as
select
(select asset_type from resilience_variables where asset_type = 'Industrial' limit 1),
(select count(pinnum) from industrial_wf_vw) as wildfire,
(select count(pinnum) from industrial_vw) as total;

create or replace view industrial_wf_percentage as 
select asset_type, wildfire, total, wildfire/total::float * 100 as percentage from industrial_wf_total
group by wildfire,total,asset_type;






--------------------energy----------------------------------------------



--flood---

create or replace view energy_vw as 
select * from resilience_variables where asset_type = 'Energy';

create or replace view energy_fld_vw as 
select * from resilience_variables where asset_type = 'Energy' 
and par_fl5yr_yn = 'yes';

create or replace view energy_flooded_total as
select
(select asset_type from resilience_variables where asset_type = 'Energy' limit 1),
(select count(pinnum) from energy_fld_vw) as flooded,
(select count(pinnum) from energy_vw) as total;

create or replace view energy_fld_percentage as 
select asset_type, flooded, total, flooded/total::float * 100 as percentage from energy_flooded_total
group by flooded,total,asset_type;


--landslide--

create or replace view energy_ls_vw as 
select * from resilience_variables where asset_type = 'Energy' 
and par_ls_yn = 'yes';

create or replace view energy_ls_total as
select
(select asset_type from resilience_variables where asset_type = 'Energy' limit 1),
(select count(pinnum) from energy_ls_vw) as landslide,
(select count(pinnum) from energy_vw) as total;

create or replace view energy_ls_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from energy_ls_total
group by landslide,total,asset_type;


--wildfire---

create or replace view energy_wf_vw as 
select * from resilience_variables where asset_type = 'Energy' 
and par_wf_yn = 'yes';

create or replace view energy_wf_total as
select
(select asset_type from resilience_variables where asset_type = 'Energy' limit 1),
(select count(pinnum) from energy_wf_vw) as wildfire,
(select count(pinnum) from energy_vw) as total;

create or replace view energy_wf_percentage as 
select asset_type, wildfire, total, wildfire/total::float * 100 as percentage from energy_wf_total
group by wildfire,total,asset_type;




------------------------emergency----------------------------------------

create or replace view emergency_services_vw as 
select * from resilience_variables where asset_type = 'Emerg Services';

--flood---

create or replace view emergency_services_fld_vw as 
select * from resilience_variables where asset_type = 'Emerg Services' 
and par_fl5yr_yn = 'yes';


create or replace view emergency_services_flooded_total as
select
(select asset_type from resilience_variables where asset_type = 'Emerg Services' limit 1),
(select count(pinnum) from emergency_services_fld_vw) as flooded,
(select count(pinnum) from emergency_services_vw) as total;

create or replace view emergency_services_fld_percentage as 
select asset_type, flooded, total, flooded/total::float * 100 as percentage from emergency_services_flooded_total
group by flooded,total,asset_type;


--landslide--

create or replace view emergency_services_ls_vw as 
select * from resilience_variables where asset_type = 'Emerg Services' 
and par_ls_yn = 'yes';

create or replace view emergency_services_ls_total as
select
(select asset_type from resilience_variables where asset_type = 'Emerg Services' limit 1),
(select count(pinnum) from emergency_services_ls_vw) as landslide,
(select count(pinnum) from emergency_services_vw) as total;

create or replace view emergency_services_ls_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from emergency_services_ls_total
group by landslide,total,asset_type;


--wildfire---

create or replace view emergency_services_wf_vw as 
select * from resilience_variables where asset_type = 'Emerg Services' 
and par_wf_yn = 'yes';

create or replace view emergency_services_wf_total as
select
(select asset_type from resilience_variables where asset_type = 'Emerg Services' limit 1),
(select count(pinnum) from emergency_services_wf_vw) as wildfire,
(select count(pinnum) from emergency_services_vw) as total;

create or replace view emergency_services_wf_percentage as 
select asset_type, wildfire, total, wildfire/total::float * 100 as percentage from emergency_services_wf_total
group by wildfire,total,asset_type;



-------------------------water resources-------------------------------

--flood--

create or replace view water_resources_vw as 
select * from resilience_variables where asset_type = 'Water Resources';

create or replace view water_resources_fld_vw as 
select * from resilience_variables where asset_type = 'Water Resources' 
and par_fl5yr_yn = 'yes';

create or replace view water_resources_flooded_total as
select
(select asset_type from resilience_variables where asset_type = 'Water Resources' limit 1),
(select count(pinnum) from water_resources_fld_vw) as flooded,
(select count(pinnum) from water_resources_vw) as total;

create or replace view water_resources_fld_percentage as 
select asset_type, flooded, total, flooded/total::float * 100 as percentage from water_resources_flooded_total
group by flooded,total,asset_type;

--landslide---

create or replace view water_resources_ls_vw as 
select * from resilience_variables where asset_type = 'Water Resources' 
and par_wf_yn = 'yes';

create or replace view water_resources_ls_total as
select
(select asset_type from resilience_variables where asset_type = 'Water Resources' limit 1),
(select count(pinnum) from water_resources_ls_vw) as landslide,
(select count(pinnum) from water_resources_vw) as total;

create or replace view water_resources_ls_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from water_resources_ls_total
group by landslide,total,asset_type;


--wildfire---

create or replace view water_resources_wf_vw as 
select * from resilience_variables where asset_type = 'Water Resources' 
and par_wf_yn = 'yes';

create or replace view water_resources_wf_total as
select
(select asset_type from resilience_variables where asset_type = 'Water Resources' limit 1),
(select count(pinnum) from water_resources_wf_vw) as wildfire,
(select count(pinnum) from water_resources_vw) as total;

create or replace view water_resources_wf_percentage as 
select asset_type, wildfire, total, wildfire/total::float * 100 as percentage from water_resources_wf_total
group by wildfire,total,asset_type;


---------------------------city parks-------------------------------

--flood--

create or replace view city_parks_fld_vw as 
select * from coa_parks where fl5yr_exp = 'yes';

create or replace view city_parks_flooded_total as
select
(select asset_type from resilience_variables where asset_type = 'City Parks' limit 1),
(select count(gid) from city_parks_fld_vw) as flooded,
(select count(gid) from coa_parks) as total;

create or replace view city_parks_fld_percentage as 
select asset_type, flooded, total, flooded/total::float * 100 as percentage from city_parks_flooded_total
group by flooded,total,asset_type;


--landslide---


create or replace view city_parks_ls_vw as 
select * from coa_parks where ls_exp = 'yes';

create or replace view city_parks_ls_total as
select
(select asset_type from resilience_variables where asset_type = 'City Parks' limit 1),
(select count(gid) from city_parks_ls_vw) as landslide,
(select count(gid) from coa_parks) as total;

create or replace view city_parks_ls_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from city_parks_ls_total
group by landslide,total,asset_type;


--wildfire-----

create or replace view city_parks_wf_vw as 
select * from coa_parks where wf_exp = 'yes';

create or replace view city_parks_wf_total as
select
(select asset_type from resilience_variables where asset_type = 'City Parks' limit 1),
(select count(gid) from city_parks_wf_vw) as wildfire,
(select count(gid) from coa_parks) as total;

create or replace view city_parks_wf_percentage as 
select asset_type, wildfire, total, wildfire/total::float * 100 as percentage from city_parks_wf_total
group by wildfire,total,asset_type;



-----------historic structures-------------------------------------------

--flood-

create or replace view historic_structures_all_vw as 
select * from resilience_variables where asset_type = 'Historic Structure' ;

create or replace view historic_structures_fld_vw as 
select * from resilience_variables where asset_type = 'Historic Structure' 
and par_fl5yr_yn = 'yes';

create or replace view historic_structures_flooded_total as
select
(select asset_type from resilience_variables where asset_type = 'Historic Structure' limit 1),
(select count(pinnum) from historic_structures_fld_vw) as flooded,
(select count(pinnum) from historic_structures_all_vw) as total;

create or replace view historic_structures_fld_percentage as 
select asset_type,  flooded, total, flooded/total::float * 100 as percentage from historic_structures_flooded_total
group by flooded,total,asset_type;


--landslide---

create or replace view historic_structures_ls_vw as 
select * from resilience_variables where asset_type = 'Historic Structure' 
and par_ls_yn = 'yes';

create or replace view historic_structures_ls_total as
select
(select asset_type from resilience_variables where asset_type = 'Historic Structure' limit 1),
(select count(pinnum) from historic_structures_ls_vw) as landslide,
(select count(pinnum) from historic_structures_all_vw) as total;

create or replace view historic_structures_ls_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from historic_structures_ls_total
group by landslide,total,asset_type;


--wildfire---


create or replace view historic_structures_wf_vw as 
select * from resilience_variables where asset_type = 'Historic Structure' 
and par_wf_yn = 'yes';

create or replace view historic_structures_wf_total as
select
(select asset_type from resilience_variables where asset_type = 'Historic Structure' limit 1),
(select count(pinnum) from historic_structures_wf_vw) as wildfire,
(select count(pinnum) from historic_structures_all_vw) as total;

create or replace view historic_structures_wf_percentage as 
select asset_type, wildfire, total, wildfire/total::float * 100 as percentage from historic_structures_wf_total
group by wildfire,total,asset_type;

-----------------------food analysis-------------

--flood--


create or replace view food_all_vw as 
select * from resilience_variables where asset_type = 'Food' ;

create or replace view food_fld_vw as 
select * from resilience_variables where asset_type = 'Food' 
and par_fl5yr_yn = 'yes';

create or replace view food_flooded_total as
select
(select asset_type from resilience_variables where asset_type = 'Food' limit 1),
(select count(pinnum) from food_fld_vw) as flooded,
(select count(pinnum) from food_all_vw) as total;

create or replace view food_fld_percentage as 
select asset_type,  flooded, total, flooded/total::float * 100 as percentage from food_flooded_total
group by flooded,total,asset_type;


--landslide---

create or replace view food_ls_vw as 
select * from resilience_variables where asset_type = 'Food' 
and par_ls_yn = 'yes';

create or replace view food_ls_total as
select
(select asset_type from resilience_variables where asset_type = 'Food' limit 1),
(select count(pinnum) from food_ls_vw) as landslide,
(select count(pinnum) from food_all_vw) as total;

create or replace view food_ls_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from food_ls_total
group by landslide,total,asset_type;


--wildfire----

create or replace view food_wf_vw as 
select * from resilience_variables where asset_type = 'Food' 
and par_wf_yn = 'yes';

create or replace view food_wf_total as
select
(select asset_type from resilience_variables where asset_type = 'Food' limit 1),
(select count(pinnum) from food_wf_vw) as wildfire,
(select count(pinnum) from food_all_vw) as total;

create or replace view food_wf_percentage as 
select asset_type, wildfire, total, wildfire/total::float * 100 as percentage from food_wf_total
group by wildfire,total,asset_type;


--------------------------------waste---------------------------------

--flood--

create or replace view waste_vw as 
select * from resilience_variables where asset_type = 'Waste';

create or replace view waste_fld_vw as 
select * from resilience_variables where asset_type = 'Waste' 
and par_fl5yr_yn = 'yes';

create or replace view waste_flooded_total as
select
(select asset_type from resilience_variables where asset_type = 'Waste' limit 1),
(select count(pinnum) from waste_fld_vw) as flooded,
(select count(pinnum) from waste_vw) as total;

create or replace view waste_fld_percentage as 
select asset_type, flooded, total, flooded/total::float * 100 as percentage from waste_flooded_total
group by flooded,total, asset_type;


--landslide---

create or replace view waste_ls_vw as 
select * from resilience_variables where asset_type = 'Waste' 
and par_ls_yn = 'yes';

create or replace view waste_ls_total as
select
(select asset_type from resilience_variables where asset_type = 'Waste' limit 1),
(select count(pinnum) from waste_ls_vw) as landslide,
(select count(pinnum) from waste_vw) as total;

create or replace view waste_ls_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from waste_ls_total
group by landslide,total ,asset_type;

--wildfire--

create or replace view waste_wf_vw as 
select * from resilience_variables where asset_type = 'Waste' 
and par_wf_yn = 'yes';

create or replace view waste_wf_total as
select
(select asset_type from resilience_variables where asset_type = 'Waste' limit 1),
(select count(pinnum) from waste_wf_vw) as landslide,
(select count(pinnum) from waste_vw) as total;

create or replace view waste_wf_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from waste_wf_total
group by landslide,total ,asset_type;





---------------------parking-----------------------------------

--flood--

create or replace view parking_vw as 
select * from resilience_variables where asset_type = 'Parking';

create or replace view parking_fld_vw as 
select * from resilience_variables where asset_type = 'Parking' 
and par_fl5yr_yn = 'yes';

create or replace view parking_flooded_total as
select
(select asset_type from resilience_variables where asset_type = 'Parking' limit 1),
(select count(pinnum) from parking_fld_vw) as flooded,
(select count(pinnum) from parking_vw) as total;

create or replace view parking_fld_percentage as 
select asset_type, flooded, total, flooded/total::float * 100 as percentage from parking_flooded_total
group by flooded,total, asset_type;


--landslide---

create or replace view parking_ls_vw as 
select * from resilience_variables where asset_type = 'Parking' 
and par_ls_yn = 'yes';

create or replace view parking_ls_total as
select
(select asset_type from resilience_variables where asset_type = 'Parking' limit 1),
(select count(pinnum) from parking_ls_vw) as landslide,
(select count(pinnum) from parking_vw) as total;

create or replace view parking_ls_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from parking_ls_total
group by landslide,total ,asset_type;

--wildfire--

create or replace view parking_wf_vw as 
select * from resilience_variables where asset_type = 'Parking' 
and par_wf_yn = 'yes';

create or replace view parking_wf_total as
select
(select asset_type from resilience_variables where asset_type = 'Parking' limit 1),
(select count(pinnum) from parking_wf_vw) as landslide,
(select count(pinnum) from parking_vw) as total;

create or replace view parking_wf_percentage as 
select asset_type, landslide, total, landslide/total::float * 100 as percentage from parking_wf_total
group by landslide,total ,asset_type;



-----------------greenways------------
--flood
create table greenways_fld_tb as 
select a.* from greenways as a 
join fl5yr as b 
on st_intersects(a.geom, b.geom)
group by a.gid;

create or replace view greenways_fld_total as
select 
(select sum(st_length(geom::geography)) * .0006 from greenways_fld_tb) as flooded_miles,
(select sum(st_length(geom::geography))* .0006 from greenways) as total_miles;

create or replace view greenways_fld_percentage as 
select flooded_miles, total_miles, flooded_miles/total_miles * 100 as percentage 
from greenways_fld_total 
group by flooded_miles, total_miles; 


---landslide

create table greenways_ls_tb as 
select a.* from greenways as a 
join debris_flow as b 
on st_intersects(a.geom, b.geom);

create or replace view greenways_ls_total as
select 
(select sum(st_length(geom::geography)) * .0006 from greenways_ls_tb) as ls_miles,
(select sum(st_length(geom::geography))* .0006 from greenways) as total_miles;

create or replace view greenways_ls_percentage as 
select ls_miles, total_miles, ls_miles/total_miles * 100 as percentage 
from greenways_ls_total 
group by ls_miles, total_miles; 

----------------------------------roads-----------------------------------------------
--------roads-------------
---------flood-------------
create table roads_fld_tb as 
select a.gid, a.full_stree, a.geom from roads_coa as a 
join fl5yr as b 
on st_intersects(b.geom, a.geom)
group by a.gid, a.full_stree, a.geom;

create or replace view roads_fld_total as
select 
(select sum(st_length(geom::geography)) * .0006 from roads_fld_tb) as flooded_miles,
(select sum(st_length(geom::geography))* .0006 from roads_coa) as total_miles;

create or replace view roads_fld_percentage as 
select flooded_miles, total_miles, flooded_miles/total_miles * 100 as percentage 
from roads_fld_total 
group by flooded_miles, total_miles; 


-----------landslide------------------
create table roads_ls_tb as 
select a.gid, a.full_stree, a.geom from roads_coa as a 
join debris_flow as b 
on st_intersects(b.geom, a.geom)
group by a.gid, a.full_stree, a.geom;

create or replace view roads_ls_total as
select 
(select sum(st_length(geom::geography)) * .0006 from roads_ls_tb) as landslide_miles,
(select sum(st_length(geom::geography))* .0006 from roads_coa) as total_miles;

create or replace view roads_ls_percentage as 
select landslide_miles, total_miles, landslide_miles/total_miles * 100 as percentage 
from roads_ls_total 
group by landslide_miles, total_miles; 


-----dams---
--flood---
create table dams_fld_tb as 
select a.* from dams as a 
join fl5yr as b
on st_intersects(a.geom,b.geom)
group by a.gid, a.dam, a.lat, a.lon, a.geom;


create or replace view dams_flooded_total as
select
(select count(gid) from dams_fld_tb) as flooded,
(select count(gid) from dams) as total;

create or replace view dams_fld_percentage as 
select flooded, total, flooded/total::float * 100 as percentage from dams_flooded_total
group by flooded,total;


---landslide---
create table dams_ls_tb as 
select a.* from dams as a 
join debris_flow as b
on st_intersects(a.geom,b.geom)
group by a.gid, a.dam, a.lat, a.lon, a.geom;


create or replace view dams_ls_total as
select
(select count(gid) from dams_ls_tb) as landslide,
(select count(gid) from dams) as total;

create or replace view dams_ls_percentage as 
select landslide, total, landslide/total::float * 100 as percentage from dams_ls_total
group by landslide,total;



------------------bridges----------------------------

----fld-----------

create table bridges_fld_tb as 
select a.* from bridges_coa12ft as a 
join fl5yr as b
on st_intersects(a.geom,b.geom)
group by a.gid;


create or replace view  bridges_flooded_total as
select
(select count(gid) from bridges_fld_tb) as flooded,
(select count(gid) from bridges_coa12ft) as total;

create or replace view dams_fld_percentage as 
select flooded, total, flooded/total::float * 100 as percentage from bridges_flooded_total
group by flooded,total;


---landslide---
create table bridges_ls_tb as 
select a.* from bridges_coa12ft as a 
join debris_flow as b
on st_intersects(a.geom,b.geom)
group by a.gid;

create or replace view bridges_ls_total as
select
(select count(gid) from bridges_ls_tb) as landslide,
(select count(gid) from bridges_coa12ft) as total;

create or replace view bridges_ls_percentage as 
select landslide, total, landslide/total::float * 100 as percentage from bridges_ls_total
group by landslide,total; 

--------------------------------begin the summaries from each of the asset analysis-----------------------------


create or replace view landslide_summary_vw as 
select * from historic_structures_ls_percentage 
union all
select * from city_parks_ls_percentage 
union all
select * from water_resources_ls_percentage 
union all
select * from emergency_services_ls_percentage 
union all
select * from energy_ls_percentage 
union all
select * from industrial_ls_percentage 
union all
select * from commercial_ls_percentage 
union all
select * from communications_ls_percentage
union all 
select * from food_ls_percentage
union all 
select * from waste_ls_percentage
union all 
select * from parking_ls_percentage;

create or replace view flood_summary_vw as 
select * from historic_structures_fld_percentage 
union all
select * from city_parks_fld_percentage 
union all
select * from water_resources_fld_percentage 
union all
select * from emergency_services_fld_percentage 
union all
select * from energy_fld_percentage 
union all
select * from industrial_fld_percentage 
union all
select * from commercial_fld_percentage 
union all
select * from communications_fld_percentage
union all 
select * from food_fld_percentage
union all 
select * from waste_fld_percentage
union all 
select * from parking_fld_percentage;

create or replace view wildfire_summary_vw as 
select * from historic_structures_wf_percentage 
union all
select * from city_parks_wf_percentage 
union all
select * from water_resources_wf_percentage 
union all
select * from emergency_services_wf_percentage 
union all
select * from energy_wf_percentage 
union all
select * from industrial_wf_percentage 
union all
select * from commercial_wf_percentage 
union all
select * from communications_wf_percentage
union all 
select * from food_wf_percentage
union all 
select * from waste_wf_percentage
union all 
select * from parking_wf_percentage;

select * from flood_summary_vw;  

select 
   blockgroup_geoid10 as blockgroup,
   SUM (CASE WHEN sensitivity = 'Low' then 1 else 0 END ) as Sensitivity_Low,
   SUM (CASE WHEN sensitivity = 'Med' then 1 else 0 END ) as Sensitivity_Medium,
   SUM (CASE WHEN sensitivity = 'High' then 1 else 0 END ) as Sensitivity_High,
   SUM (CASE WHEN adapt_cap = 'Low' then 1 else 0 END ) as AdaptCap_Low,
   SUM (CASE WHEN adapt_cap = 'Med' then 1 else 0 END ) as AdaptCap_Medium,
   SUM (CASE WHEN adapt_cap = 'High' then 1 else 0 END ) as AdaptCap_High,
   SUM (CASE WHEN vuln_cat = 'Low' then 1 else 0 END ) as Vulnerability_Low,
   SUM (CASE WHEN vuln_cat = 'Med' then 1 else 0 END ) as Vulnerability_Medium,
   SUM (CASE WHEN vuln_cat = 'High' then 1 else 0 END ) as Vulnerability_High,
   SUM (CASE WHEN risk_tot = 'Low' then 1 else 0 END ) as Risk_Low,
   SUM (CASE WHEN risk_tot = 'Med' then 1 else 0 END ) as Risk_Medium,
   SUM (CASE WHEN risk_tot = 'High' then 1 else 0 END ) as Risk_High, 
   SUM(vuln_num) as Vulnerability_score,
   SUM(risk_num) as Risk_score
 from residential_fld_assessment_vw
 group by blockgroup;

-------------being census summaries-------------------
create table resilience_variables_bunc as 
select * from resilience_variables;

create or replace view resilience_variables_cbg as 
select a.* from resilience_variables as a, coa_census_block_groups as b
where a.blockgroup_geoid10 = substring(b.geo_id, 10, 21);

delete from resilience_variables as a 
where a.pinnum not in (select b.pinnum from resilience_variables_cbg as b);

drop view stormwater_cbg if exists;

drop view stormwater_cbg if exists;

create or replace view stormwater_cbg as 
select  
   SUM (CASE WHEN category = 'High Priority' then 1 else 0 END ) as High_Priority,
   SUM (CASE WHEN category = 'High Consequence of Failure' then 1 else 0 END ) as High_Consequence,
   SUM (CASE WHEN category = 'High Likelihood of Failure' then 1 else 0 END ) as High_Likelihood,
   a.geo_id,
   st_length(b.geom::geography) * .0006 as length,
   a.geom
from coa_census_block_groups as a
join coa_stormwater_criticality as b
on st_contains(a.geom, b.geom)
group by a.geo_id, a.geom, b.geom;

create or replace view stormwater_sum as 
select a.geo_id, 
sum(length),
sum(high_priority) as priority, 
sum(high_consequence) as consequence, 
sum(high_likelihood) as likelihood,
a.geom
from stormwater_cbg as a
group by a.geo_id, a.geom;

create or replace view stormwater_priority as 
select  
   a.geo_id,
   st_length(b.geom::geography) * .0006 as length,
   a.geom
from coa_census_block_groups as a
join coa_stormwater_criticality as b
on st_contains(a.geom, b.geom)
where category = 'High Priority'
group by a.geo_id, a.geom, b.geom;


create or replace view stormwater_priority_sum as 
select a.geo_id, 
sum(length),
a.geom
from stormwater_priority as a
group by a.geo_id, a.geom;




create or replace view stormwater_hcf as 
select  
   a.geo_id,
   st_length(b.geom::geography) * .0006 as length,
   a.geom
from coa_census_block_groups as a
join coa_stormwater_criticality as b
on st_contains(a.geom, b.geom)
where category = 'High Consequence of Failure'
group by a.geo_id, a.geom, b.geom;


create or replace view stormwater_hcf_sum as 
select a.geo_id, 
sum(length),
a.geom
from stormwater_hcf as a
group by a.geo_id, a.geom;




create or replace view stormwater_hlf as 
select  
   a.geo_id,
   st_length(b.geom::geography) * .0006 as length,
   a.geom
from coa_census_block_groups as a
join coa_stormwater_criticality as b
on st_contains(a.geom, b.geom)
where category = 'High Likelihood of Failure'
group by a.geo_id, a.geom, b.geom;


create or replace view stormwater_hlf_sum as 
select a.geo_id, 
sum(length),
a.geom
from stormwater_hlf as a
group by a.geo_id, a.geom;



