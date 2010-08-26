use strict;
use warnings;
use lib 't/lib';

use Test::More;
use Test::Module::Install::TestPreload;

ok my $cmd = find_make_test_command(__FILE__), 'find make test command';
like $cmd, qr|sub { print scalar localtime }->\(\); |, 'find preload code';
like $cmd, qr|system.+cat.+Makefile\.PL|, 'find preload coderef';
like $cmd, qr|\\\$\$ENV{__TEST__} = 1|, 'find escaped sigil';

done_testing;
