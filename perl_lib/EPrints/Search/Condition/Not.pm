######################################################################
#
# EPrints::Search::Condition::Not
#
######################################################################
#
#
######################################################################

=pod

=head1 NAME

B<EPrints::Search::Condition::Not> - "Not" search condition

=head1 DESCRIPTION

Negate the result of a sub-condition.

=cut

package EPrints::Search::Condition::Not;

use EPrints::Search::Condition;
use Scalar::Util;

@ISA = qw( EPrints::Search::Condition );

use strict;

sub new
{
	my( $class, $inner ) = @_;

	return bless { op=>"NOT", sub_op=>$inner }, $class;
}

#sub optimise
#{
#	my( $self, %opts ) = @_;
#	if( $self->{sub_op}->isa( "EPrints::Search::Condition::Not" ) )
#	{
#		return $self->{sub_op}->{sub_op};
#	}
#	return $self;
#}

sub logic
{
	my( $self, %opts ) = @_;
	return 'NOT (' . $self->{sub_op}->logic(%opts) . ')';
}

1;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2000-2011 University of Southampton.

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints L<http://www.eprints.org/>.

EPrints is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

EPrints is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints.  If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

