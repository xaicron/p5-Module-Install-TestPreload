use inc::Module::Install;

name 'MyModule';
all_from 'lib/MyModule.pm';

tests 't/*.t';

test_preload_module 'Foo::Bar';

auto_include;
WriteAll;
