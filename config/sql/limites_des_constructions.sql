SELECT l.t_id as id,
    l.id_lc as id_lc,
    c.dispname as categorie,
    q.dispname as qualite,
    b1.dispname as foi_publ,
    l.id_plan as plan,
    b2.dispname as radiee,
    p.num_dgmr as num_dgmr,
    p.date_approbation as date_appro,
    p.nom_plan as nom_plan,
    l.geometrie as geometrie
FROM limites_des_constructions.limite_construction_segment l
JOIN limites_des_constructions.lc_categorie c on l.categorie = c.t_id
JOIN limites_des_constructions.lc_precision_donnee q on l.qualitee_donnee = q.t_id
JOIN limites_des_constructions.lc_oui_non b1 on l.foi_publique = b1.t_id 
JOIN limites_des_constructions.lc_oui_non b2 on l.radiee = b2.t_id
JOIN limites_des_constructions.plan_lc p on l.id_plan = p.id_plan