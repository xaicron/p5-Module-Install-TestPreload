package Test::Module::Install::TestPreload;

use strict;
use warnings;
use File::Find;
use File::Temp qw/tempdir/;
use File::Spec;
use File::Copy;
use File::Basename;
use Cwd;
use Config;
use Exporter 'import';

our @EXPORT = qw/find_make_test_command/;

sub find_make_test_command {
    my ($path) = @_;
    $path = _get_dist_dir($path);
    
    my $cwd = getcwd;
    my $tmpdir = tempdir CLEANUP => 1;
    
    deep_copy($path, $tmpdir);
    
    my $make_test_command;
    
    chdir $tmpdir or die $!;
    local $@;
    eval {
        run_make($cwd);
        $make_test_command = sub {
            open my $fh, 'Makefile' or die "Makefile: $!";
            while (<$fh>) {
                last if /\$\(FULLPERLRUN\) "-MExtUtils::Command::MM"/;
            }
            return $_;
        }->();
        die "make test command not found" unless $make_test_command;
    };
    chdir $cwd or die $!;
    
    die $@ if $@;
    
    return $make_test_command;
}

sub run_make {
    my $distdir = shift;
    die "Makefile.PL not found" unless -f 'Makefile.PL';
    _addinc("$distdir/blib/lib");
    run_cmd(qq{$^X Makefile.PL "$distdir/lib"});
    run_cmd(make());
}

sub run_cmd {
    my ($cmd) = @_;
    local $?;
    my $result = `$^X Makefile.PL`;
    die "$cmd failed ($result)" if $?;
    return $result;
}

sub make {
    $Config{make} || 'make';
}

sub deep_copy {
    my ($from, $to) = @_;
    
    my $from_path = quotemeta $from;
    find {
        wanted => sub {
            return if /^\.\.?$/;
            my $file = $_;
            (my $name = $File::Find::name) =~ s/$from_path//;
            if (-f $file) {
#                printf "%s => %s\n", $file, File::Spec->catfile($to, $name);
                copy $file, File::Spec->catfile($to, $name) or die ": $!";
            }
            else {
#                printf "%s => %s\n", $file, File::Spec->catfile($to, $name);
                mkdir File::Spec->catfile($to, $name) or die $!;
            }
       },
    }, $from;
}

sub _addinc {
    my ($path) = @_;
    my $file = 'Makefile.PL';
    open my $fh, '<', $file or die $!;
    my $data = do { local $/; <$fh> };
    close $fh;
    open $fh, '>', $file or die $!;
    print $fh "use lib qw($path);\n";
    print $fh $data;
    close $fh;
}

sub _get_dist_dir {
    my $path = shift;
    $path =~ s/\.t$//;
    die "$path is not directory" unless -d $path;
    return $path;
}

1;
__END__
