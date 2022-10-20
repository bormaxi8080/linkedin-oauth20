package Net::Linkedin::OAuth2;

use strict;
use warnings;
use JSON::Any;
use LWP::UserAgent;
use Carp 'confess';
use XML::Hash;
use Digest::MD5 'md5_hex';

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);

our $VERSION = '0.32';

Show 133 lines of Pod

sub authorization_code_url {
    my ($self, %args) = @_;
    foreach(qw( redirect_uri )) {
        confess "Required '$_' was not specified" unless $args{$_};
    }
    return "https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=$self->{key}&scope=".join('+',$self->{scope})."&state=".rand()."&redirect_uri=$args{redirect_uri}";
Show 24 lines of Pod

sub get_access_token {
    my ($self, %args) = @_;
    foreach(qw( authorization_code redirect_uri )) {
        confess "Required '$_' was not specified" unless $args{$_};
    }
    my $r = $self->{class}->get("https://api.linkedin.com/uas/oauth2/accessToken?grant_type=authorization_code&code=$args{authorization_code}&redirect_uri=$args{redirect_uri}&client_id=$self->{key}&client_secret=$self->{secret}");
    if (!$r->is_success){
        my $j = JSON::Any->new;
        my $error = $j->jsonToObj($r->content());
    }
    my $file = $r->content();
    my $j = JSON::Any->new;
    my $res = $j->jsonToObj($r->content());
    return $res;
}


Show 24 lines of Pod

sub new {
    my ($class, $args) = @_;
    my $self = bless {}, $class;
    $self->{class} = LWP::UserAgent->new(
                params => $args,
        );
    $self->{ params }  = $args;
    $self->{ key }     = $args->{'key'};
    $self->{ secret }  = $args->{'secret'};
    my @e;
    for (my $n=0; $n <= 2; $n++) {
        push @e, $args->{'scope'}[$n];
    }
    $self->{ scope }   = join('+',@e);
    return $self;
}


Show 19 lines of Pod

sub request {
    my ($self, %args) = @_;
    foreach(qw( url token )) {
        confess "Required '$_' was not specified" unless $args{$_};
    }
    my $url;
    if ($args{url} =~ /\?/) {
                $url = "$args{url}&oauth2_access_token=$args{token}";
    } else {
                $url = "$args{url}?oauth2_access_token=$args{token}";
    }
    my $r = $self->{class}->get($url);
    if (!$r->is_success){
        my $j = XML::Hash->new();
        my $error = $j->fromXMLStringtoHash($r->content());
    }
    my $j = JSON::Any->new;
    return $j->jsonToObj( $r->content() );
}

1;