#!/usr/bin/perl
use Shell;
use Net::IRC;
use WWW::Mechanize;
use HTML::TreeBuilder;
use HTML::Element;
use URI::Escape;
use Carp qw(croak);
use Digest::SHA qw( hmac_sha512_hex);
use JSON qw(decode_json);
use Thread;
no warnings 'utf8'; # Ignore Wide Character in Print warnings.
use strict;

system "clear";

our $server = "otomiko.brb.dj";
our $mynick = "IrcBot";
our $channel = "#cyberia";
our @admins = ("",""); # channel admins
our $opnick = ""; # computer admin
our $opident = "";

my @modules = <./data/modules/*.so>;

print "@modules\n";

our $opkey = "$opnick $opident";
 $opkey =~ s/a-z/A-Z/g;
 $opkey =~ s/ //g;
 $opkey =~ tr/a-z/A-Z/s;
 $opkey =~ tr/G-Z/A-F0-9/d;
 #print "Generated Operator Key: $opkey\x0a";
 
our $btcekey = "";
our $btcesecret = "";

# Default libraries for quotes and slaps.
our $quotelib = "data/lib/quotes.lib";
our $slaplib = "data/lib/slap.lib";

if (! -e $quotelib) { print "Defualt Quote Library Not Found! Setting Value To Null!! Please Load A Library With ~quote lib filename.\n" }
if (! -e $slaplib) { print "Defualt Slap Library Not Found!\n" }


sub beattime {
	my $time = shift || time();
	my $hsecs;

	my ($sec, $min, $hour, $mday, $mon, $year, $yday, $isdst) =
		gmtime($time);

	if ($hour != 23) {
  	  $hsecs = (($hour + 1) * 60) * 60;	
	}
	$hsecs += ($min * 60);
	$hsecs += $sec;
	return sprintf("%.2f", $hsecs / 86.4);
}

my $irc=new Net::IRC;
my $conn=$irc->newconn(Nick =>"$mynick", Server => "$server", Ircname => "$mynick", Username => "$mynick");

sub on_connect {
	our ($self)=shift;
	$self->join("$channel");
sub ticker_high {
	while (1) {
		my $itime = beattime(time());
		my @time = split(/ /, localtime());
		my $turl = "https://btc-e.com/api/2/btc_usd/ticker";
		my $m = WWW::Mechanize->new();
		$m->get($turl);
		my $c = $m->content;
		my $decoded_json = decode_json( $c );
		my $ticker = $decoded_json->{'ticker'}; # Json decodes to an arrayref$
		$self->notice("$channel","$time[1]-$time[2]-$time[3] \@$itime BTC : $ticker->{'avg'} USD");
		sleep 3600;
	}
}
sub radio {
my $playing = "";

	sub poll {
		my $url = "http://otomiko.brb.dj:8000/json.xsl";
		my $m = WWW::Mechanize->new();
		$m->get($url);
		my $c = $m->content;
		my $decoded_json = decode_json( $c );
		$decoded_json = $decoded_json->{'mounts'};
		$decoded_json = $decoded_json->{'/otomiko.mp3'};
		my $title = $decoded_json->{'title'};

		if ($playing eq $title) { return; }
		else { $playing = $title; }
		$self->notice("$channel","Currently Playing: $playing\n");
	}

while(1) {
	poll();
	sleep 10;
}
}
my $thr = new Thread \&ticker_high;
my $thr1 = new Thread \&radio;
}

sub on_join {
	our ($self)=shift;
	our ($event)=shift;
	our ($nick)=($event->nick);
	our ($user)=($event->user);
	our ($host)=($event->host);
	our ($uhost)=($event->userhost);
	if ( $nick eq $mynick ) { }
	elsif ($user ~~ @admins) { $self->mode("$channel","+o","$nick"); }
	else {
        $self->notice($nick, "╔════════════════════════════════╗");
        $self->notice($nick, "║ Cafe Rules:                    ║");
        $self->notice($nick, "║  In this cafe there will be no ║");
        $self->notice($nick, "║  discrimination between humans ║");
        $self->notice($nick, "║  and androids.                 ║");
        $self->notice($nick, "║                          ~Nagi ║");
        $self->notice($nick, "╚════════════════════════════════╝");
		$self->privmsg($channel, "Welcome $nick\, Please follow the rules and enjoy your stay."); # Greet the user.
		$self->mode("$channel","+v","$nick");
	}
}

sub on_kick { # Auto-Rejoin on Kick
	our ($self) = shift;
	$self->join($channel);
}

sub on_message { # Handle messages and commands in the channel.
	our ($self)=shift;
	our ($event)=shift;
	our ($message)=($event->args);
	our ($nick)=($event->nick);
	our ($user)=($event->user);
	our ($host)=($event->host);
	our ($uhost)=($event->userhost);
	our @message=split(/ /, $message);
	
	# Generate the unique ID.
	our $ID = "$nick $user";
	$ID =~ s/a-z/A-Z/g;
    $ID =~ s/ //g;
    $ID =~ tr/a-z/A-Z/s;
    $ID =~ tr/G-Z/A-F0-9/d;
	
	if ($message[0] eq '~rehash') {
		if ($ID eq $opkey) {
			my @modules = <./data/modules/*.so>;
			$self->notice("$channel","Rehashed Modules: @modules");
		}
		if ($ID ne $opkey) { $self->privmsg("$channel","Authorization required."); }
	}
	foreach (@modules) {
		do "$_";
	};
}

sub on_pmessage { # Handle messages and commands in the channel.
        our ($self)=shift;
        our ($event)=shift;
        our ($message)=($event->args);
        our ($nick)=($event->nick);
        our ($user)=($event->user);
        our ($host)=($event->host);
        our ($uhost)=($event->userhost);
        our @message=split(/ /, $message);

        # Generate the unique ID.
        our $ID = "$nick $user";
        $ID =~ s/a-z/A-Z/g;
        $ID =~ s/ //g;
        $ID =~ tr/a-z/A-Z/s;
        $ID =~ tr/G-Z/A-F0-9/d;
        
	if ($message[0] eq '~rehash') {
		if ($ID eq $opkey) {
			my @modules = <./data/modules/*.so>;
			$self->notice("$nick","Rehashed Modules: @modules");
		}
		if ($ID ne $opkey) { $self->privmsg("$nick","Authorization required."); }
	}
	foreach (@modules) {
		do "$_";
	};
	

}

$conn->add_handler('public', \&on_message);
$conn->add_handler('msg', \&on_pmessage);
$conn->add_handler('376', \&on_connect);
$conn->add_global_handler('kick', \&on_kick);
$conn->add_global_handler('join', \&on_join);
$irc->start;
