package Moo::HandleMoose::_TypeMap;
use strictures 1;

package
  Moo::HandleMoose;
our %TYPE_MAP;

package Moo::HandleMoose::_TypeMap;

use Scalar::Util ();
use Tie::Hash ();

our @ISA = qw(Tie::StdHash);

our %WEAK_TYPES;

sub STORE {
  Scalar::Util::weaken($WEAK_TYPES{$_[1]} = $_[1]);
  $_[0]->SUPER::STORE(@_[1..$#_]);
}

sub CLONE {
  %TYPE_MAP = map {
    defined $WEAK_TYPES{$_} ? ($WEAK_TYPES{$_} => $TYPE_MAP{$_}) : ()
  } keys %TYPE_MAP;
  %WEAK_TYPES = map {
    defined $WEAK_TYPES{$_} ? ($WEAK_TYPES{$_} => $WEAK_TYPES{$_}) : ()
  } keys %WEAK_TYPES;
  Scalar::Util::weaken($_) for values %WEAK_TYPES;
}

require B
  if keys %TYPE_MAP;

%WEAK_TYPES = map {
  if (/(?:^|=)[A-Z]+\(0x([0-9a-zA-Z]+)\)$/) {
    my $id = do { no warnings 'portable'; hex "$1" };
    my $sv = bless \$id, 'B::SV';
    my $ref = eval { $sv->object_2svref };
    if (!defined $ref) {
      die <<'END_ERROR';
Moo has been loaded inside a thread, but types were defined before creating the
thread.  This is broken.  This can be fixed by making sure Moo is loaded before
creating a thread.
END_ERROR
    }
    $ref => $ref;
  }
  else {
    $_ => $_;
  }
} keys %TYPE_MAP;

%{tie %TYPE_MAP, __PACKAGE__} = %TYPE_MAP;

1;
