use strict;
use warnings;
use lib 't/lib';

use Test::More;
use Test::Module::Install::TestPreload;

ok my $cmd = find_make_test_command(__FILE__), 'find make test command';
like $cmd, qr/-MFoo::Bar/, 'find preload module';

done_testing;
