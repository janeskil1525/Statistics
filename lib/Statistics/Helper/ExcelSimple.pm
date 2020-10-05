package WebShop::Helper::ExcelSimple;

use Mojo::Base -base;

use Excel::Writer::XLSX;
use Data::Dumper;

has 'filename' => (
    required => 1,
    is => 'ro',               
);

has 'targetpath' => (
    required => 1,
    is => 'ro',
);

has 'header' => (
    required => 1,
    is => 'ro',
);

has 'datalist' => (
    required => 1,
    is => 'ro',
);

has 'keylist' => (
    required => 1,
    is => 'ro',
);

sub createExcel{
	my $self = shift;
    
    my $row = 0;
    my $col = 0;
    
    my @header = split(',',$self->{header});
    my @keylist = split(',', $self->{keylist});
    
    my $workbook = Excel::Writer::XLSX->new($self->{targetpath} . $self->{filename});
    $workbook->set_properties(
        title    => 'Sökstatistik',
        author   => 'LagaIntern',
        comments => 'Created with Perl and Excel::Writer::XLSX',
    );
    my $format_header = $workbook->add_format();
    my $format_list = $workbook->add_format();
    $format_header->set_bold();
    #$format_header->bg_color( 'red' );
    
    my $worksheet = $workbook->add_worksheet('Sökstatistik');
    foreach my $val (@header) {
        $worksheet->write( $row ,$col, $val,$format_header);
        $col++;
    }
    
    $col = 0;
    $row++;
   
    foreach my $val (@{$self->{datalist}}){        
        foreach my $key ( @keylist ) {
            $worksheet->keep_leading_zeros();
            $worksheet->write( $row ,$col, $val->{$key}, $format_list);
            $col++;           
        }
        $col = 0;
        $row++;
    }
    $workbook->close();
}


1;