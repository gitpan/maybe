#!/usr/bin/perl -c

package maybe;
use 5.006;
our $VERSION = 0.01;

=head1 NAME

maybe - use a Perl module and ignore error if can't be loaded

=head1 SYNOPSIS

  use Getopt::Long;
  use maybe 'Getopt::Long::Descriptive';
  if (Getopt::Long::Descriptive->VERSION) {  # run-time checking
    Getopt::Long::Descriptive::describe_options("usage: %c %o", @options);
  }
  else {
    Getopt::Long::GetOptions(\%options, @$opt_spec);
  }

  use maybe 'Carp' => 'confess';
  use constant HAS_CARP => !! CARP->VERSION;
  if (HAS_CARP) {  # compilation-time checking
    confess("Bum!");
  }
  else {
    die("Bum!);
  }

=head1 DESCRIPTION

This pragma loads a Perl module.  If the module can't be loaded, the
error will be ignored.  Otherwise, the module's import method is called
with unchanged caller stack.

=for readme stop

=cut


# no strict;
# no warnings;


# Pragma handling
sub import {
    shift @_;  # eq __PACKAGE__

    my $package = shift @_;
    return unless $package;

    my $file = $package . '.pm';
    $file =~ s{::}{/}g;

    local $SIG{__DIE__};
    eval {
        require $file;
    };
    return if $@;

    # Check version if first element on list is a version number.
    if (defined $_[0] and $_[0] =~ m/^\d/) {
        my $version = shift @_;
        eval {
            $package->VERSION($version);
        };
        return if $@;
    }

    # Do not call import if list contains only empty string.
    return if @_ == 1 and defined $_[0] and $_[0] eq '';

    my $method = $package->can('import');
    return unless $method;

    unshift @_, $package;
    goto &$method;
}


1;


__END__

=head1 USAGE

=over

=item use maybe I<Module>;

It is exactly equivalent to

  BEGIN { eval { require Module; }; Module->import; }

except that I<Module> must be a quoted string.

=item use maybe I<Module> => I<LIST>;

It is exactly equivalent to

  BEGIN { eval { require Module; }; Module->import( LIST ); }

=item use maybe I<Module> => I<version>, I<LIST>;

It is exactly equivalent to

  BEGIN { eval { require Module; Module->VERSION(version); } Module->import( LIST ); }

=item use maybe I<Module> => '';

If the I<LIST> contains only one empty string, it is exactly equivalent to

  BEGIN { eval { require Module; }; }

=back

=head1 SEE ALSO

L<if>, L<all>, L<first>.

=head1 BUGS

If you find the bug, please report it.

=for readme continue

=head1 AUTHOR

Piotr Roszatycki E<lt>dexter@debian.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2008 by Piotr Roszatycki E<lt>dexter@debian.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>
