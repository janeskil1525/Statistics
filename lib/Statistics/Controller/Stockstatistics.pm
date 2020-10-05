package Statistics::Controller::Stockstatistics;
use Mojo::Base 'Mojolicious::Controller';


sub sumpercompany_api{
   my $self = shift;
    
   $self->render_later;
   say "sumpercompany_api";
   
   $self->stockstatistics->stock_totals_p()->then(sub {
            my $moddatetime = shift;                
            my $collection = $moddatetime->hashes;
            
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

1;
