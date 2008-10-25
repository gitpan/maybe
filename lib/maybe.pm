#!/usr/bin/perl -c

package maybe;
use 5.006;
our $VERSION = 0.02;

=head1 NAME

maybe - Use a Perl module and ignore error if can't be loaded

=head1 SYNOPSIS

  use Getopt::Long;
  use maybe 'Getopt::Long::Descriptive';
  if (maybe::HAVE_GETOPT_LONG_DESCRIPTIVE) {
    Getopt::Long::Descriptive::describe_options("usage: %c %o", @options);
  }
  else {
    Getopt::Long::GetOptions(\%options, @$opt_spec);
  }

  use maybe 'Carp' => 'confess';
  if (maybe::HAVE_CARP) {
    confess("Bum!");
  }
  else {
    die("Bum!);
  }

=head1 DESCRIPTION

This pragma loads a Perl module.  If the module can't be loaded, the
error will be ignored.  Otherwise, the module's import method is called
with unchanged caller stack.

The special constant B<maybe::HAVE_I<MODULE>> is created and it

=for readme stop

=cut


# no strict;
# no warnings;


# Pragma handling
sub import {
    shift @_;  # eq __PACKAGE__

    my $package = shift @_;
    return unless $package;

    my $macro = $package;
    $macro =~ s{(::|[^A-Za-z0-9_])}{_}g;
    $macro = 'HAVE_' . uc($macro);

    my $file = $package . '.pm';
    $file =~ s{::}{/}g;

    local $SIG{__DIE__};
    eval {
        require $file;
    };
    goto ERROR if $@;

    # Check version if first element on list is a version number.
    if (defined $_[0] and $_[0] =~ m/^\d/) {
        my $version = shift @_;
        eval {
            $package->VERSION($version);
        };
        goto ERROR if $@;
    }

    # Package is just loaded
    undef *{$macro} if defined &$macro;
    *{$macro} = sub () { !! 1 };

    # Do not call import if list contains only empty string.
    return if @_ == 1 and defined $_[0] and $_[0] eq '';

    my $method = $package->can('import');
    return unless $method;

    unshift @_, $package;
    goto &$method;


    ERROR:

    undef *{$macro} if defined &$macro;
    *{$macro} = sub () { not 1 };

    return;
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

=head1 CONSTANTS

=over

=item HAVE_I<MODULE>

This constant is set after trying to load the module.  The name of constant is
created from uppercased module name.  The "::" string and any non-alphanumeric
character is replaced with underscore.  The constant contains the true value
if the module was loaded or false value otherwise.

  use maybe 'File::Spec::Win32';
  return unless maybe::HAVE_FILE_SPEC_WIN32;

=back

=head1 SEE ALSO

L<if>, L<all>, L<first>.

=head1 BUGS

The Perl doesn't clean up the module if it wasn't loaded to the end, i.e.
because of syntax error.

The name of constant could be the same for different modules, i.e. "Module",
"module" and "MODULE" generate maybe::HAVE_MODULE constant.

=for readme continue

=head1 AUTHOR

Piotr Roszatycki E<lt>dexter@debian.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2008 by Piotr Roszatycki E<lt>dexter@debian.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>
