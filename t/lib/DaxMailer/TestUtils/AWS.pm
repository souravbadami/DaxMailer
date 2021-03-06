package t::lib::DaxMailer::TestUtils::AWS;
use strict;
use warnings;

# ABSTRACT: Mock AWS messages

use JSON::MaybeXS;

my $json = JSON::MaybeXS->new;

sub _packet {
    my $message = $_[0];
    return $json->encode(
        {
            Type => 'Notification',
            Message => $message,
        }
    );
}

sub sns_complaint {
    my $email = $_[1];
    die "Need an email address parameter" unless $email;
    my $message = $json->encode(
        {
            notificationType => 'Complaint',
            complaint => {
                complainedRecipients => [
                    {
                        emailAddress => $email,
                    },
                ]
            }
        }
    );
    return _packet( $message );
}

sub sns_permanent_bounce {
    my $email = $_[1];
    die "Need an email address parameter" unless $email;
    my $message = $json->encode(
        {
            notificationType => 'Bounce',
            bounce => {
                bounceType => 'Permanent',
                bouncedRecipients => [
                    {
                        emailAddress => $email,
                    },
                ]
            }
        }
    );
    return _packet( $message );
}

sub sns_transient_bounce {
    my $email = $_[1];
    die "Need an email address parameter" unless $email;
    my $message = $json->encode(
        {
            notificationType => 'Bounce',
            bounce => {
                bounceType => 'Transient',
                bouncedRecipients => [
                    {
                        emailAddress => $email,
                    },
                ]
            }
        }
    );
    return _packet( $message );
}

1;
