package Statistics::Model::Statisticsintervals;

use Mojo::Base -base;

use Data::Dumper;

has 'pg';

sub intervall_p{
    my ($self, $statistic_type) = @_;
    
	
    my $stmt = "SELECT year, month FROM statistics_intervals WHERE statistic_type = ? ORDER BY year, month";
    my $result = $self->pg->db->query_p($stmt,($statistic_type));
    
    return $result;   
    
}


1;
