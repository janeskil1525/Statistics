


#select a.code, c.code_text, b.code,  d.code_text,  statistic->'Antal'  From statistics 
#JOIN codes as a  ON a.code = (statistic->>'Bilkod')::text AND a.type = 1
#JOIN codes as b ON b.code = (statistic->>'Delkod')::text AND   b.type = 2
#JOIN codes_trans as c ON c.codes_fkey = a.codes_pkey AND c.languages_fkey = 6
#JOIN codes_trans as d ON d.codes_fkey = b.codes_pkey AND d.languages_fkey = 6
#JOIN companies ON  companies_fkey = companies_pkey AND company = 'LA' and year = 2017 and month = 5   
#AND (statistic->>'Bilkod')::text is not null 
#AND (statistic->>'Delkod')::text is not null
#AND (statistic->>'Bilkod'):: text IN ('1125', '1124', '1115')
#AND (statistic->>'Delkod')::text IN ('1001','1003', '1007','1020')
#	 
#	 ORDER BY year, month, a.code,  b.code