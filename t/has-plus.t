use Moo::_strictures;
use Test::More;
use Test::Fatal;

{
  package RollyRole;

  use Moo::Role;

  has f => (is => 'ro', default => sub { 0 });
}

{
  package ClassyClass;

  use Moo;

  has f => (is => 'ro', default => sub { 1 });
}

{
  package UsesTheRole;

  use Moo;

  with 'RollyRole';
}

{
  package UsesTheRole2;

  use Moo;

  with 'RollyRole';

  has '+f' => (default => sub { 2 });
}

{

  package ExtendsTheClass;

  use Moo;

  extends 'ClassyClass';

  has '+f' => (default => sub { 3 });
}

{
  package RoleWithTheRole;
  use Moo::Role;

  with 'RollyRole';

  has '+f' => (default => sub { 4 });
}

{
  package UsesTheOtherRole;
  use Moo;

  with 'RoleWithTheRole';
}

{
  package BlowsUp;

  use Moo;

  ::like(::exception { has '+f' => () }, qr/\Qhas '+f'/, 'Kaboom');
}

{
  package RoleBlowsUp;

  use Moo::Role;

  ::like(::exception { has '+f' => () }, qr/\Qhas '+f'/, 'Kaboom');
}

{
  package ClassyClass2;
  use Moo;
  has d => (is => 'ro', default => sub { 4 });
}

{
  package MultiClass;
  use Moo;
  extends 'ClassyClass', 'ClassyClass2';
  ::is(::exception {
    has '+f' => ();
  }, undef, 'extend attribute from first parent');
  ::like(::exception {
    has '+d' => ();
  }, qr/no d attribute already exists/,
    'can\'t extend attribute from second parent');
}

is(UsesTheRole->new->f, 0, 'role attr');
is(ClassyClass->new->f, 1, 'class attr');
is(UsesTheRole2->new->f, 2, 'role attr with +');
is(ExtendsTheClass->new->f, 3, 'class attr with +');
is(UsesTheOtherRole->new->f, 4, 'role attr with + in role');

done_testing;
