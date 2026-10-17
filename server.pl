#!/usr/bin/env perl
use strict;
use warnings;
use IO::Socket::INET;
use File::Basename;

my $port = 8080;
my $root = "/Users/nanaminanami/Documents/HiMyDream/日本旅遊報報/app";

my $server = IO::Socket::INET->new(
    LocalAddr => '127.0.0.1',
    LocalPort => $port,
    Proto     => 'tcp',
    Listen    => 10,
    Reuse     => 1
) or die "Cannot create server on port $port: $!\n";

print "HTTP Server running on http://127.0.0.1:$port/\n";

my %mimes = (
    'html' => 'text/html; charset=utf-8',
    'css'  => 'text/css; charset=utf-8',
    'js'   => 'application/javascript; charset=utf-8',
    'json' => 'application/json; charset=utf-8',
    'png'  => 'image/png',
    'jpg'  => 'image/jpeg',
    'svg'  => 'image/svg+xml'
);

while (my $client = $server->accept()) {
    my $req = <$client>;
    next unless $req;
    
    # Simple GET parser
    if ($req =~ /^GET\s+([^\s\?]+)/) {
        my $path = $1;
        $path = '/index.html' if $path eq '/' or $path eq '';
        
        my $filepath = "$root$path";
        $filepath =~ s/\.\.//g; # basic sanitize
        
        if (-f $filepath) {
            my ($ext) = $filepath =~ /\.([^.]+)$/;
            $ext = lc($ext || 'html');
            my $mime = $mimes{$ext} || 'text/plain';
            
            open(my $fh, '<:raw', $filepath);
            my $content = do { local $/; <$fh> };
            close($fh);
            
            my $len = length($content);
            print $client "HTTP/1.1 200 OK\r\n";
            print $client "Content-Type: $mime\r\n";
            print $client "Content-Length: $len\r\n";
            print $client "Connection: close\r\n\r\n";
            print $client $content;
        } else {
            my $msg = "404 Not Found";
            print $client "HTTP/1.1 404 Not Found\r\n";
            print $client "Content-Type: text/plain\r\n";
            print $client "Content-Length: " . length($msg) . "\r\n";
            print $client "Connection: close\r\n\r\n$msg";
        }
    }
    close($client);
}

