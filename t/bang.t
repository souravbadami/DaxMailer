use strict;
use warnings;

BEGIN {
    $ENV{DAXMAILER_BANG_SECRET} = 'yZVIhAFiKvEeDbeAvCkm3GAK4c1Od71rSu';
    $ENV{DAXMAILER_DB_DSN} = 'dbi:SQLite:dbname=:memory:';
    $ENV{DAXMAILER_MAIL_TEST} = 1;
}


use Plack::Test;
use Plack::Builder;
use HTTP::Request::Common;
use Test::More;
use DaxMailer::Web::App::Bang;
use t::lib::DaxMailer::TestUtils;
use DaxMailer::Base::Web::Common;

t::lib::DaxMailer::TestUtils::deploy( { drop => 1 }, schema );

my $app = builder {
    mount '/nb' => DaxMailer::Web::App::Bang->to_app;
};

test_psgi $app => sub {
    my ( $cb ) = @_;

    my $newbang = sub {
        my ( $command, $url, $email, $site,
             $comments, $category, $subcategory ) = @_;
        ok( $cb->( POST '/nb/newbang',
                [   bang_command  => $command,
                    bang_url      => $url,
                    from          => $email,
                    bang_site     => $site,
                    bang_comments => $comments,
                    bang_cat      => $category,
                    bang_subcat   => $subcategory,
                ]
            )->is_success,
            "POSTing new bang $command"
        );
    };

    $newbang->(qw'
        foo http://example.com/q={{{s}}}
        submitter@example.com
        example.com example.com Tech Example
    ');

    $newbang->(qw'
        bar http://example.com/
        submitter@example.com
        example.com example.com Tech Example
    ');

    $newbang->( 'baz', 'http://example.com/q={{{s}}}', undef, undef, 'Hello!', 'Tech', 'Programming' );

    is( $cb->( POST '/nb/newbangs.txt' )->code, 401, 'Cannot access newbangs without secret');

    my $bangs = $cb->(
        POST '/nb/newbangs.txt', [ secret => $ENV{DAXMAILER_BANG_SECRET} ]
    );
    ok( $bangs->is_success, 'Retrieved bang content with shared secret' );
    is(
        $bangs->content,
        'foo	example.com	http://example.com/q={{{s}}}	submitter@example.com	Tech	Example	example.com',
        'TSV line OK'
    );
};

done_testing;
