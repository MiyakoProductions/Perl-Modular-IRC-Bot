#!/usr/bin/perl
use Shell;
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

our $irc=new Net::IRC;
our $conn=$irc->newconn(Nick =>"$ournick", Server => "$server", Ircname => "$ournick", Username => "$ournick");

sub on_connect {
	our ($self)=shift;
	$self->join("$channel");

}

sub on_join {
	our ($self)=shift;
	our ($event)=shift;
	our ($nick)=($event->nick);
	our ($user)=($event->user);
	our ($host)=($event->host);
	our ($uhost)=($event->userhost);
	
}


sub on_kick { # Auto-Rejoin on Kick
	our ($self) = shift;
	$self->join($channel);
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
