use strict;
use warnings;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;
use Cicindela::Request;
use Cicindela::Config::MixIn;
use Cicindela::IncomingData;
use Carp ();
use Try::Tiny;

my $INSERTERS = {};

builder {
    enable 'Plack::Middleware::ReverseProxy';
    sub {
        my $req = Cicindela::Request->new(shift);

        my $inserters;
        if ( $req->param('set') ) {
            $inserters = $INSERTERS->{$req->param('set')};

            unless ($inserters) {
                try {
                    $inserters = new Cicindela::IncomingData(
                        set_name => $req->param('set'),
                        %{config->settings->{$req->param('set')}}
                    ) or Carp::croak();
                }
                catch {
                    Carp::carp(shift);
                    return [400,['Content-type' => 'text/plain'],['']];
                };
            }

            unless ($inserters) {
                return [400,['Content-type' => 'text/plain'],['']];
            }
            
            $inserters->{$req->param('set')} = $inserters;
        }

        try {
            if( defined $req->param('op') ) {
                if ( $req->param('op') eq 'insert_pick' and defined($req->param('user_id')) and defined($req->param('item_id')) ) { 
                    $inserters->insert_pick($req->param('user_id'), $req->param('item_id'));
                } 
                elsif ($req->param('op') eq 'insert_uninterested' and defined($req->param('user_id')) and defined($req->param('item_id'))) {
                    $inserters->insert_uninterested($req->param('user_id'), $req->param('item_id'), $req->param('rating'));
                } 
                elsif ($req->param('op') eq 'insert_rating' and defined($req->param('user_id')) and defined($req->param('item_id')) and defined($req->param('rating'))) {
                    $inserters->insert_rating($req->param('user_id'), $req->param('item_id'), $req->param('rating'));
                } 
                elsif ($req->param('op') eq 'insert_tag' and defined($req->param('tag_id')) and defined($req->param('user_id')) and defined($req->param('item_id'))) {
                    $inserters->insert_tag($req->param('tag_id'), $req->param('user_id'), $req->param('item_id'));
                } 
                elsif ($req->param('op') eq 'set_category' and defined($req->param('category_id')) and defined($req->param('item_id'))) {
                    $inserters->insert_category($req->param('category_id'), $req->param('item_id'));
                }
                # delete系
                elsif ($req->param('op') eq 'delete_pick' and defined($req->param('user_id')) and defined($req->param('item_id'))) { 
                    $inserters->delete_pick($req->param('user_id'), $req->param('item_id'));
                } 
                elsif ($req->param('op') eq 'delete_uninterested' and defined($req->param('user_id')) and defined($req->param('item_id'))) {
                    $inserters->delete_uninterested($req->param('user_id'), $req->param('item_id'));
                } 
                elsif ($req->param('op') eq 'delete_rating' and defined($req->param('user_id')) and defined($req->param('item_id'))) {
                    $inserters->delete_rating($req->param('user_id'), $req->param('item_id'));
                } 
                elsif ($req->param('op') eq 'delete_tag' and defined($req->param('tag_id')) and defined($req->param('user_id')) and defined($req->param('item_id'))) {
                    $inserters->delete_tag($req->param('tag_id'), $req->param('user_id'), $req->param('item_id'));
                } 
                elsif ($req->param('op') eq 'remove_category' and defined($req->param('category_id')) and defined($req->param('item_id'))) {
                    $inserters->delete_category($req->param('category_id'), $req->param('item_id'));
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
