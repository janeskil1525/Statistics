package Statistics::Controller::Login;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub showlogin{
	my $self = shift;

	my $is_logged_in = $self->app->yancy->auth->require_user;

	return $self->redirect_to('/yancy')
		if ($self->yancy->auth->current_user);
	$self->render(template => 'logon/logon');
}


1;
