package Module::Install::TestPreload;

use strict;
use warnings;
use vars qw($VERSION @MODULES @INCLUDES  @SCRIPTS @CODES);
$VERSION = '0.01_01';

use base qw(Module::Install::Base);
use ExtUtils::MM_Any;
use B::Deparse;

my $bd = B::Deparse->new;

sub test_preload_module {
    my $self = shift;
    return unless @_;
    push @MODULES, @_;
}

sub test_preload_script {
    my $self = shift;
    return unless @_;
    push @SCRIPTS, @_;
}

sub test_preload_code {
    my $self = shift;
    return unless @_;
    push @CODES, @_;
}

sub test_preload_inc {
    my $self = shift;
    return unless @_;
    push @INCLUDES, @_;
}

{
    my $org = ExtUtils::MM_Any->can('test_via_harness');
    sub test_via_harness_org {
        $org->(@_);
    }
}

no warnings 'redefine';
*ExtUtils::MM_Any::test_via_harness = sub {
    my($self, $perl, $tests) = @_;

    my $pre_load_include = @INCLUDES ? join '', map { qq|"-I$_" |   } @INCLUDES : '';
    my $pre_load_modules = @MODULES  ? join '', map { qq|"-M$_" |   } @MODULES  : '';
    my $pre_load_scripts = @SCRIPTS  ? join '', map { qq|do '$_'; | } @SCRIPTS  : '';
    my $pre_load_codes   = @CODES    ? join '', map { qq|sub { $_ }->(); | } map { ref $_ eq 'CODE' ? $bd->coderef2text($_) : $_ } @CODES : '';
       $pre_load_codes =~ s/\$/\\\$\$/g;
       $pre_load_codes =~ s/"/\\"/g;
       $pre_load_codes =~ s/\n/ /g;

    return
        qq{\t$perl "-MExtUtils::Command::MM" }.
        $pre_load_include .
        $pre_load_modules .
        qq{"-e" "}        .
        $pre_load_scripts .
        $pre_load_codes   .
        qq{test_harness(\$(TEST_VERBOSE), '\$(INST_LIB)', '\$(INST_ARCHLIB)')" $tests\n}
    ;
};

1;
__END__

=head1 NAME

Module::Install::TestPreload - preload codes for test

=head1 SYNOPSIS

  # in Makefile.PL
  use inc::Module::Install;
  tests 't/*t';
  test_preload_inc    "$ENV{HOME}/perl5/lib";
  test_preload_module 'Foo';
  test_preload_script 'bar.pl';
  test_preload_codes  'print scalar localtime, "\n"';
  
  # maybe make test is
  perl -MExtUtils::Command::MM -I/home/xaicron/perl5/lib -MFoo -e "do 'bar.pl'; sub { print scalar localtime, \"\n\" }->(); test_harness(0, 'inc')" t/*t

=head1 DESCRIPTION

Module::Install::TestPreload is helps make a variety of processing of during the make test.

=head1 FUNCTIONS

=over

=item test_preload_module(@modules)

Setting preload modules in make test command.

  use inc::Module::Install;
  tests 't/*t';
  test_preload_module('Foo', 'Bar::Baz');
  
  # maybe make test is
  perl -MExtUtils::Command::MM -MFoo -MBar::Baz -e "test_harness(0, 'inc')" t/*t

=item test_preload_inc(@inc_paths)

Setting preload module include paths in make test command.

  use inc::Module::Install;
  tests 't/*t';
  test_preload_inc('/path/to/lib');
  
  # maybe make test is
  perl -MExtUtils::Command::MM -I/path/to/lib -e "test_harness(0, 'inc')" t/*t

=item test_preload_script(@script_files)

Setting preload script files in make test command.

  use inc::Module::Install;
  tests 't/*t';
  test_preload_script('/path/to/script.pl');
  
  # maybe make test is
  perl -MExtUtils::Command::MM "do '/path/to/script.pl'; test_harness(0, 'inc')" t/*t

=item test_preload_codes(@codes)

Setting preload perl codes in make test command.

  use inc::Module::Install;
  tests 't/*t';
  test_preload_code('print scalar localtime , "\n"', sub { system qw/cat README/ });
  
  # maybe make test is
  perl -MExtUtils::Command::MM "sub { print scalar localtme, "\n" }->(); sub { system 'cat', 'README' }->(); test_harness(0, 'inc')" t/*t

The perl codes runs test_preload_script files runs later.

  use inc::Module::Install;
  tests 't/*t';
  test_preload_script('/path/to/script.pl');
  test_preload_code('print scalar localtime , "\n"');
  
  # maybe make test is
  perl -MExtUtils::Command::MM "do '/path/to/script.pl'; sub { print scalar localtme, "\n" }->(); test_harness(0, 'inc')" t/*t

=back

=head1 AUTHOR

Yuji Shimada E<lt>xaicron {at} cpan.orgE<gt>

=head1 SEE ALSO

L<Module::Install>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
