package Statistics::Controller::Searchstatistics;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::JSON qw {decode_json encode_json};
use utf8;

use Statistics::Helper::ExcelSimple;
use Data::Dumper;

sub get_statistics_hits_api{
    my $self = shift;
    
    $self->render_later;
    $self->inactivity_timeout(900);
    my $data = decode_json($self->req->body);
    say "get_statistics_hits_p";
    $self->searchstatistics->get_statistics_hits_p(
				$data->{company}, $data->{fromdate}, $data->{todate}, $data->{codestype1}, $data->{codestype2})->then(sub {
              my $moddatetime = shift;                
              my $collection = $moddatetime->hashes;
              
              say $collection->size;
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

sub create_statistics_excel_api{
	 my $self = shift;
    
    $self->render_later;
    $self->inactivity_timeout(900);
    my $data = decode_json($self->req->body);
	
	$self->searchstatistics->get_statistics_p(
			$data->{company}, $data->{fromdate}, $data->{todate}, $data->{codestype1}, $data->{codestype2})->then(sub {
              my $moddatetime = shift;                
              my $collection = $moddatetime->hashes;
              
			  my $excel = WebShop::Helper::ExcelSimple->new(
									datalist => $collection,
									header => "Bilkod, Bil, Delkod, Del, Antal sök, Antal sålda, Antal i lager, Max, Medel, Min, Totalt sålt",
									targetpath => $self->config('temppath'),
									filename => 'test.xlsx',
                                    keylist => "carcode,carcodedescription,partcode,partcodedescription,noofsearches,soldquantity,instock,max,avg,min,sum",
									);
				$excel->createExcel();
              say $collection->size;
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

sub get_statistics_api{
    my $self = shift;
    
    $self->render_later;
    $self->inactivity_timeout(900);
    my $data = decode_json($self->req->body);
    
    $self->searchstatistics->get_statistics_p(
			$data->{company}, $data->{fromdate}, $data->{todate}, $data->{codestype1}, $data->{codestype2})->then(sub {
              my $moddatetime = shift;                
              my $collection = $moddatetime->hashes;
              
              say $collection->size;
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

sub lastupdate_api{
    my $self = shift;
    
    $self->render_later;
    my $validator = $self->validation;
    $self->inactivity_timeout(6000);
    if($validator->required('statistic_type')){
     say "lastupdate after validation";
    
        my $statistic_type = $self->param('statistic_type');
       
        $self->searchstatistics->lastupdate_p($statistic_type)->then(sub {
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
 
 }
 
 
 
 1;
