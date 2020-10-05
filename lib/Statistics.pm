package Statistics;
use Mojo::Base 'Mojolicious';

use Mojo::Pg;
use Mojo::File;
use File::Share;
use Statistics::Model::Menu;
use Statistics::Helper::Settings;;
use Statistics::Helper::Translations;

$ENV{STATISTICS_HOME} = '/home/jan/Project/Statistics/'
    unless $ENV{STATISTICS_HOME};

has dist_dir => sub {
  return Mojo::File->new(
      File::Share::dist_dir('Statistics')
  );
};

has home => sub {
  Mojo::Home->new($ENV{STATISTICS_HOME});
};

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from config file
  my $config = $self->plugin('Config');

  # Configure the application
  $self->secrets($config->{secrets});

  $self->helper(pg => sub {state $pg = Mojo::Pg->new->dsn(shift->config('pg'))});
  $self->log->path($self->home() . $self->config('log'));

  $self->helper(menu => sub {
    state $menu = Statistics::Model::Menu->new(pg => shift->pg)}
  );
  $self->helper(translations => sub {
    state $translations = Statistics::Helper::Translations->new(pg => shift->pg)}
  );
  $self->helper(settings => sub {
    state $settings = Statistics::Helper::Settings->new(pg => shift->pg)}
  );

  $self->renderer->paths([
      $self->dist_dir->child('templates'),
  ]);
  $self->static->paths([
      $self->dist_dir->child('public'),
  ]);
  say "Statistics " . $self->pg->db->query('select version() as version')->hash->{version};

  my $schema = from_json(Mojo::File->new($self->dist_dir->child('schema/statistics.json'))->slurp) ;

  $self->plugin('Minion'  => { Pg => $self->pg });

  $self->pg->migrations->name('statistics')->from_file(
      $self->dist_dir->child('migrations/statistics.sql')
  )->migrate(1);

  my $auth_minion = $self->routes->under( '/minion', sub {
    my ( $c ) = @_;

    return 1 if ($c->session('auth') // '') eq '1';
    $c->redirect_to('/');
    return undef;
  } );

  my $auth_yancy = $self->routes->under( '/yancy', sub {
    my ( $c ) = @_;
    my $is_logged_in = $self->app->yancy->auth->require_user;

    return 1 if $is_logged_in;
    return 1 if ($c->session('auth') // '') eq '1';
    $c->redirect_to('/');
    return undef;
  } );

  $self->plugin('Minion::Admin' => {
      route => $auth_minion,
      return_to   => '/app/menu/show/',
  });

  $self->plugin(
      'Yancy' => {
          route                 => $auth_yancy,
          backend               => {Pg => $self->pg},
          schema                => $schema,
          read_schema           => 0,
          'editor.return_to'    => '/app/menu/show/',
          'editor.require_user' => { is_admin => 1 },
      }
  );

  $self->yancy->plugin( 'Auth' => {
      schema => 'users',
      plugins => [
          [
              Password => {
                  username_field  => 'userid',
                  password_field  => 'passwd',
                  password_digest => {
                      type => 'SHA-1',
                  },
              }
          ]
      ]
  }
  );

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('login#showlogin');


}

1;
