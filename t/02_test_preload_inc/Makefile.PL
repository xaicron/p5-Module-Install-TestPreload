use inc::Module::Install;

name 'MyModule';
all_from 'lib/MyModule.pm';

tests 't/*.t';

test_preload_inc '/path/to/lib';

auto_include;
WriteAll;
