package Statistics::Model::StockStatistics;

use Mojo::Base -base;

use Data::Dumper;

has 'pg';


sub stock_totals_p{
    my $self = shift;
    my $stmt = "select company, name, quantity, calculated from companies join stocktotals on companies_pkey = companies_fkey order by name";
    
    my $result = $self->pg->db->query_p($stmt);
    return $result;
}


sub update_stocktotals_p{
    my $self = shift;
    
     my $stmt = "INSERT INTO stocktotals (companies_fkey, calculated, quantity )
                    select companies_pkey, now(),
                        (select count(*) from stockitems
                        JOIN stockitems_stock ON stockitems_pkey = stockitems_fkey 
                        WHERE companies_pkey = companies_fkey )  as quantity 
                        FROM companies ";
           
    my $result = $self->pg->db->query_p($stmt);
    
    return $result;  
}
1;
