package Statistics::Controller::Statisticsintervals;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;


sub statisticsintervals_api{
    my $self = shift;
    
    $self->render_later;
    my $validator = $self->validation;
    
    if($validator->required('statistic_type')){
        my $statistic_type = $self->param('statistic_type');       
        $self->statisticsintervals->intervall_p($statistic_type)->then(sub {
                my $statistic_type = shift;                
                my $collection = $statistic_type->hashes;
				
                return $collection;
            })->catch (sub {
                my $err = shift;
                say "Catched = " . $err;
                
                return $err;
            })->finally (sub {
                my $coll = shift;
			
                $self->render(json => $coll);
            });
    }
 
 }

 1;
