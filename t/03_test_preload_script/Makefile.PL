use inc::Module::Install;

name 'MyModule';
all_from 'lib/MyModule.pm';

tests 't/*.t';

test_preload_script 'script/foo.pl';

auto_include;
WriteAll;
