use inc::Module::Install;

name 'MyModule';
all_from 'lib/MyModule.pm';

tests 't/*.t';

test_preload_code 'print scalar localtime';
test_preload_code sub { system qw/cat Makefile.PL/ };
test_preload_code '$ENV{__TEST__} = 1';

auto_include;
WriteAll;
