package Statistics::Model::SearchStatistics;

use Mojo::Base -base;

use Data::Dumper;

has 'pg' ;

sub get_statistics_hits_p{
    my ($self, $company, $from, $to, $code1, $code2) = @_;
    
    my $stmt = qq{
                    SELECT COUNT(*)	as hits					
						FROM statistics
                        JOIN companies
                            ON companies_pkey = companies_fkey and company = '$company'
                        JOIN codes as a 
                            ON statistic->>'Bilkod' = a.code and a.type = 1 AND a.subtype = 0
                        JOIN codes_trans as b
                            ON a.codes_pkey = b.codes_fkey AND b.languages_fkey = 6
                        JOIN codes as c 
                            ON statistic->>'Delkod' = c.code and c.type = 2 AND c.subtype = 0
                        JOIN codes_trans as d
                            ON c.codes_pkey = d.codes_fkey AND d.languages_fkey = 6
						LEFT OUTER JOIN sales_statistics_basedata
							ON  salesstats->'CarCode' = statistic->'Bilkod'
								AND salesstats->'PartCode' = statistic->'Delkod'
								AND salesstats->>'Period' = year::text || '-' || RIGHT('0' || month::text,2)
                            WHERE (year::text || month::text)::integer between $from AND $to
                                AND statistic->>'Bilkod'
                                    IN (SELECT code FROM codes WHERE codes_pkey IN ($code1))
                                AND statistic->>'Delkod'
                                    IN (SELECT code FROM codes WHERE codes_pkey IN ($code2))
                    };
   
    my $result = $self->pg->db->query_p($stmt);
    say $stmt;
    return $result;   
    
}

sub get_statistics_p{
    my ($self, $company, $from, $to, $code1, $code2) = @_;
    
	#Mind hits above
    my $stmt = qq{
                    select c.code as partcode,
							a.code as carcode,
							b.code_text as carcodedescription, d.code_text as partcodedescription,
							max(maxprice) as max, 
							min(minprice) as min,
							CAST(avg(averageprice) as DECIMAL(10,2)) as avg,
                            sum(quantity) as instock,
							sum(CAST((salesstats->>'Price') as NUMERIC)) as sum,
							sum(CAST((salesstats->>'Quantity') as NUMERIC)) as soldquantity,
							sum(CAST((statistic->>'Antal') as NUMERIC)) as noofsearches							
						FROM statistics as f
                        JOIN companies
                            ON companies_pkey = companies_fkey and company = '$company'
                        JOIN codes as a 
                             ON a.codes_pkey = f.codes1_fkey
                        JOIN codes_trans as b
                            ON a.codes_pkey = b.codes_fkey AND b.languages_fkey = 6
                        JOIN codes as c 
                            ON c.codes_pkey = f.codes2_fkey
                        JOIN codes_trans as d
                            ON c.codes_pkey = d.codes_fkey AND d.languages_fkey = 6
                        JOIN warehouse_pricing_stats AS e
                            ON f.codes1_fkey = e.codes1_fkey AND  f.codes2_fkey = e.codes2_fkey
						LEFT OUTER JOIN sales_statistics_basedata
							ON  salesstats->'CarCode' = statistic->'Bilkod'
								AND salesstats->'PartCode' = statistic->'Delkod'
								AND salesstats->>'Period' = year::text || '-' || RIGHT('0' || month::text,2)
                            WHERE (year::text || month::text)::integer between $from AND $to
                                AND f.codes1_fkey IN ($code1)
                                AND f.codes2_fkey IN ($code2)
						GROUP BY c.code , a.code, b.code_text,  d.code_text
						ORDER BY c.code , a.code
                    };
   say $stmt;
    my $result = $self->pg->db->query_p($stmt);
    return $result;   
}

sub lastupdate_p{
    my ($self, $statistic_type) = @_;
    
    my $stmt = "SELECT MAX(moddatetime) as moddatetime FROM statistics WHERE statistic_type = ?";
    my $result = $self->pg->db->query_p($stmt, $statistic_type);
    
    return $result;    
}



1;
