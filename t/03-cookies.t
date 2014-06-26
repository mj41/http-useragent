use Test;

use HTTP::Cookies;
use HTTP::Request;
use HTTP::Response;

plan 25;

my $file = './cookies.dat';

my $c = HTTP::Cookies.new(
    file     => $file,
);

# new
ok $c, 'new 1/3';
is $c.file, $file, 'new 2/3';
is $c.autosave, 0, 'new 3/3';

# set-cookie
$c.set-cookie(
    'Set-Cookie: name1=value1; expires=DATE; Path=/; Domain=gugl; secure'
);
my $c1 = $c.cookies[0];
ok $c1, 'set-cookie 1/10';
is $c1.name, 'name1', 'set-cookie 2/10';
is $c1.value, 'value1', 'set-cookie 3/10';
is $c1.fields.elems, 3, 'set-cookie 4/10';
is $c1.secure, 'secure', 'set-cookie 5/10';

$c.set-cookie(
    'Set-Cookie: name2=value2; expires=DATE2; Path=/path/; Domain=gugle;'
);
my $c2 = $c.cookies[1];
ok $c2, 'set-cookie 6/10';
is $c2.name, 'name2', 'set-cookie 7/10';
is $c2.value, 'value2', 'set-cookie 8/10';
is $c2.fields.elems, 3, 'set-cookie 9/10';
ok !$c2.secure, 'set-cookie 10/10';

# Str
my $result = "Set-Cookie: name1=value1; expires=DATE; Path=/; Domain=gugl; secure\nSet-Cookie: name2=value2; expires=DATE2; Path=/path/; Domain=gugle";
is $c.Str, $result, 'Str 1/1';

# save
my $file_header = "#LWP6-Cookies-0.1\n";
$c.save;
is $c.file.IO.slurp, $file_header ~ $result ~ "\n", 'save 1/1';

# clear
$c.clear;
ok !$c.cookies, 'clear 1/1';

# load
$c.load;
is $c.Str, $result, 'load 1/1';

$c = HTTP::Cookies.new(
    file     => $file,
    autosave => 1,
);
$c.load;

# add-cookie-header
my $req = HTTP::Request.new;
$c.add-cookie-header($req);
is $req.header('Cookie').values.elems, 2, 'add-cookie-header 1/3';

$req = HTTP::Request.new(GET => 'gugle');
$c.add-cookie-header($req);
is $req.header('Cookie').values.elems, 1, 'add-cookie-header 2/3';

$c.set-cookie(
    'Set-Cookie: name3=value3; expires=DATE2; Path=/test; Domain=gugle;'
);
$req = HTTP::Request.new(GET => 'gugle/test');
$c.add-cookie-header($req);
is $req.header('Cookie').values.elems, 1, 'add-cookie-header 3/3';

# extract-cookkies
my $resp = HTTP::Response.new(200);
$resp.header( Set-Cookie => 'k=v');
$c.extract-cookies($resp);
is $c.cookies.elems, 4, 'extract-cookies 1/1';

# clear-expired
$c.set-cookie('Set-Cookie: n1=v1; Expires=Sun, 06 Nov 1994 08:49:37 GMT');
ok $c.clear-expired, 'clear-expired 1/3';
is $c.cookies.elems, 4, 'clear-expired 2/3';
ok ! $c.cookies.grep({ .name eq 'n1' }), 'clear-expired 3/3';

# autosave
$c.clear;
is $c.cookies.elems, 0, 'autosave 1/1';
