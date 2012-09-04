use strict;
use warnings;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;
use Cicindela::Request;
use Cicindela::Recommender;
use Data::Dumper;
use DBI;
use Carp ();
use Try::Tiny;

my $RECOMMENDERS = {};

builder {
    enable 'Plack::Middleware::ReverseProxy';
    sub {
        my $req = Cicindela::Request->new(shift);

        my $d;
        if ( $req->param('set') ) {
            $d = $RECOMMENDERS->{$req->param('set')} = Cicindela::Recommender->get_instance_for_set($req->param('set'));

            unless ($d) {
                return [400,['Content-type' => 'text/plain'],['']];
            }
            
            $RECOMMENDERS->{$req->param('set')} = $d;
        }
        
        my $optional_fields = { map { $_ => $req->param($_) ||'' } qw(limit category_id) };
        my $list;
        try {
            if( defined $req->param('op') ) {
                if ( $req->param('op') eq 'for_item') {
                    $list = $d->output_recommend_for_item($req->param('item_id'), $optional_fields);
                } elsif ($req->param('op') eq 'for_user') {
                    $list = $d->output_recommend_for_user($req->param('user_id'), $optional_fields);
                } elsif ($req->param('op') eq 'similar_users') {
                    $list = $d->output_similar_users($req->param('user_id'), $optional_fields); 
                }
            } else {
                return [400,['Content-type' => 'text/plain'],['']];
            }
        } catch {
            my $err = shift;
            Carp::croak($err);
        };
        return [200,['Content-type','text/html'],[join("\n",( ref $list ) ? @$list : $list )]];
    };
};
