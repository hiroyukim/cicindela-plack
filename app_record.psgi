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

        my $recommender;
        if ( $req->param('set') ) {
            $recommender = $RECOMMENDERS->{$req->param('set')} = Cicindela::Recommender->get_instance_for_set($req->param('set'));

            unless ($recommender) {
                return [400,['Content-type' => 'text/plain'],['']];
            }
            
            $RECOMMENDERS->{$req->param('set')} = $recommender;
        }

        try {
            if( defined $req->param('op') ) {
                if ( $req->param('op') eq 'insert_pick' and defined($req->param('user_id')) and defined($req->param('item_id')) ) { 
                    $recommender->insert_pick($req->param('user_id'), $req->param('item_id'));
                } 
                elsif ($req->param('op') eq 'insert_uninterested' and defined($req->param('user_id')) and defined($req->param('item_id'))) {
                    $recommender->insert_uninterested($req->param('user_id'), $req->param('item_id'), $req->param('rating'));
                } 
                elsif ($req->param('op') eq 'insert_rating' and defined($req->param('user_id')) and defined($req->param('item_id')) and defined($req->param('rating'))) {
                    $recommender->insert_rating($req->param('user_id'), $req->param('item_id'), $req->param('rating'));
                } 
                elsif ($req->param('op') eq 'insert_tag' and defined($req->param('tag_id')) and defined($req->param('user_id')) and defined($req->param('item_id'))) {
                    $recommender->insert_tag($req->param('tag_id'), $req->param('user_id'), $req->param('item_id'));
                } 
                elsif ($req->param('op') eq 'set_category' and defined($req->param('category_id')) and defined($req->param('item_id'))) {
                    $recommender->insert_category($req->param('category_id'), $req->param('item_id'));
                }
                # delete系
                elsif ($req->param('op') eq 'delete_pick' and defined($req->param('user_id')) and defined($req->param('item_id'))) { 
                    $recommender->delete_pick($req->param('user_id'), $req->param('item_id'));
                } 
                elsif ($req->param('op') eq 'delete_uninterested' and defined($req->param('user_id')) and defined($req->param('item_id'))) {
                    $recommender->delete_uninterested($req->param('user_id'), $req->param('item_id'));
                } 
                elsif ($req->param('op') eq 'delete_rating' and defined($req->param('user_id')) and defined($req->param('item_id'))) {
                    $recommender->delete_rating($req->param('user_id'), $req->param('item_id'));
                } 
                elsif ($req->param('op') eq 'delete_tag' and defined($req->param('tag_id')) and defined($req->param('user_id')) and defined($req->param('item_id'))) {
                    $recommender->delete_tag($req->param('tag_id'), $req->param('user_id'), $req->param('item_id'));
                } 
                elsif ($req->param('op') eq 'remove_category' and defined($req->param('category_id')) and defined($req->param('item_id'))) {
                    $recommender->delete_category($req->param('category_id'), $req->param('item_id'));
                }
                else {
                    return [400,['Content-type' => 'text/plain'],['']];
                }
            }         
            else {
                return [400,['Content-type' => 'text/plain'],['']];
            }
        } catch {
            my $err = shift;
            Carp::croak($err);
        };

        # HTTP_NO_CONTENT
        return [204,['Content-type','text/html'],['']];
    };
};
