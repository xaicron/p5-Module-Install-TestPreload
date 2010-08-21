package Module::Install::TestPreload;

use strict;
use warnings;
use vars qw($VERSION @MODULES @INCLUDES  @SCRIPTS @CODES);
$VERSION = '0.01_01';

use base qw(Module::Install::Base);
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
    $self = shift;
    return unless @_;
    push @INCLUDES, @_;
}

{
    my $org = ExtUtils::MM_Any->can('test_via_harness');
    sub test_via_harness_org {
        $org->(@_);
    }
}

*ExtUtils::MM_Any::test_via_harness = sub {
    my($self, $perl, $tests) = @_;

    my $pre_load_include = @INCLUDES ? join '', map { qq|"-I$_" |   } @INCLUDES : '';
    my $pre_load_modules = @MODULES  ? join '', map { qq|"-M$_" |   } @MODULES  : '';
    my $pre_load_scripts = @SCRIPTS  ? join '', map { qq|do '$_'; | } @SCRIPTS  : '';
    my $pre_load_codes   = @CODES    ? join '', map { qq|sub { $_ }->(); | } map { ref $_ eq 'CODE' ? $bd->coderef2text($_) : $_ } @CODES : '';
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

Module::Install::TestPreload - 

=head1 SYNOPSIS

  # in Makefile.PL
  use inc::Module::Install;
  tests 't/*t';
  test_preload_module 'Foo';
  test_preload_script 'bar.pl';
  test_preload_codes  'print scalar localtime, "\n"';
  
  # maybe make test is
  perl -MExtUtils::Command::MM -MFoo -e "do 'bar.pl'; sub { print scalar localtime, \"\n\" }->(); test_harness(0, 'inc')" t/*t

=head1 DESCRIPTION

Module::Install::TestPreload is

=head1 AUTHOR

Yuji Shimada E<lt>xaicron {at} cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
