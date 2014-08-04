use strict;
use Test::More tests => (14);

BEGIN { use_ok( "EPrints" ); }
BEGIN { use_ok( "EPrints::Test" ); }

my $session = EPrints::Test::get_test_session( 0 );
my $rv;

$rv = EPrints::Script::execute( "2", { session=>$session } );
ok( defined $rv, "EPScript returns a value" );
is( $rv->[0], 2, "EPScript returns correct value?" );
is( $rv->[1], "INTEGER", "EPScript returns correct value?" );

$rv = EPrints::Script::execute( '$foo{bar}', { session=>$session, foo=>{ bar=>23 } } );
is( $rv->[0], 23, "Value from a passed parameter" );

$rv = EPrints::Script::execute( '17+9', { session=>$session } );
is( $rv->[0], 26, "17+9: Basic Math" );

$rv = EPrints::Script::execute( '17-9', { session=>$session } );
is( $rv->[0], 8, "17-9: Basic Math" );

$rv = EPrints::Script::execute( '-42', { session=>$session } );
is( $rv->[0], -42, "-42: Unary minus" );

$rv = EPrints::Script::execute( '1--42', { session=>$session } );
is( $rv->[0], 43, "1--42: Unary minus again" );

$rv = EPrints::Script::execute( '-5*---(2+3)', { session=>$session } );
is( $rv->[0], 25, "-5*---(2+3): Unary minus with brackets and stacked uminus" );

$rv = EPrints::Script::execute( '$list.join(":")', { session=>$session, list=>[[1,2,3],"ARRAY"] } );
is( $rv->[0], "1:2:3", "join() function" );

my $mfield = $session->dataset( "user" )->field( "roles" );
$rv = EPrints::Script::execute( '$list.join(":")', { session=>$session, list=>[["a","b","c"],$mfield] } );
is( $rv->[0], "a:b:c", "join() function on a multiple field value" );

## Test render_value_function

my $dataset = $session->get_repository->dataset( "archive" );
my $eprint = EPrints::DataObj::EPrint->new_from_data( $session->get_repository, { eprint_status => "archive" }, $dataset );
$eprint->set_value( 'title', 'The Title' );
sub render_func
{
	my( $session, $field, $value, $extra ) = @_;
	return $session->make_text( 'field="'.$field->name.'", value="'.$value.'", extra='.($extra//'') );
}

$rv = EPrints::Script::execute( '$ep.render_value_function("::render_func","title")', { session=>$session, ep=>[$eprint] } );
is( $rv->[1], "XHTML", "render_value_function() without extra returns XHTML" );
is( $rv->[0]->nodeValue, 'field="title", value="The Title", extra=', "render_value_function() without extra runs" );

$rv = EPrints::Script::execute( '$ep.render_value_function("::render_func","title", "xyz")', { session=>$session, ep=>[$eprint] } );
is( $rv->[1], "XHTML", "render_value_function() with extra returns XHTML" );
is( $rv->[0]->nodeValue, 'field="title", value="The Title", extra=xyz', "render_value_function() with extra runs" );

throws_ok {
	EPrints::Script::execute( '$ep.render_value_function("::render_func","title", "xyz")', { session=>$session, ep=>[1,"INT"] } )
} qr/can't get a property from anything except a hash or object/, 'catches non-data objects'; # NB: error from `property()`


$session->terminate;

ok(1);

