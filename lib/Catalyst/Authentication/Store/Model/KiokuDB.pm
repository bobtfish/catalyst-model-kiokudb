package Catalyst::Authentication::Store::Model::KiokuDB;
use Moose;

use Carp;

use Catalyst::Authentication::Store::Model::KiokuDB::UserWrapper;

use namespace::clean -except => 'meta';

sub BUILDARGS {
    my ($class, $conf, $app, $realm) = @_;

    return {
        app => $app,
        realm => $realm,
        %$conf,
    }
}

has realm => (
    is => "ro",
);

has model_name => (
    isa => "Str",
    is  => "ro",
    required => 1,
);

sub get_model {
    my ( $self, $c ) = @_;

    $c->model($self->model_name);
}

sub wrap {
    my ( $self, $c, $user ) = @_;

    croak "No user object" unless ref $user;

    return Catalyst::Authentication::Store::Model::KiokuDB::UserWrapper->new(
        directory   => $self->get_model($c)->directory,
        user_object => $user,
    );
}

sub from_session {
    my ( $self, $c, $id ) = @_;

    my $user = $self->get_model($c)->lookup($id);

    $self->wrap($c, $user);
}

sub find_user {
    my ( $self, $userinfo, $c ) = @_;

    my $id = $userinfo->{id} || croak "No user ID specified";

    my $model = $self->get_model($c);

    my $user = $model->can("find_user")
        ? $model->find_user($userinfo)
        : $model->lookup("user:$id"); # KiokuX::User convention... FIXME also support ->search?

    if ( $user ) {
        return $self->wrap($c, $user);
    } else {
        return;
    }
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__