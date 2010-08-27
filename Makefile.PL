use inc::Module::Install;
name 'Module-Install-TestPreload';
all_from 'lib/Module/Install/TestPreload.pm';

requires 'Module::Install';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
