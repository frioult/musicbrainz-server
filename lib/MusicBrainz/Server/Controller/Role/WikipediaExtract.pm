package MusicBrainz::Server::Controller::Role::WikipediaExtract;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use namespace::autoclean;

after show => sub {
    my ($self, $c) = @_;

    $self->_get_extract($c, 1);
};

sub wikipedia_extract : Chained('load') PathPart('wikipedia-extract')
{
    my ($self, $c) = @_;

    $self->_get_extract($c, 0);

    $c->stash->{template} = 'components/wikipedia_extract.tt';
}

sub _get_extract
{
    my ($self, $c, $cache_only) = @_;

    my $entity = $c->stash->{entity};
    my $wanted_lang = $c->stash->{current_language} // 'en';
    # Remove country codes, at least for now
    $wanted_lang =~ s/[_-][A-Za-z]+$//;

    my ($wp_link) = map {
            $_->target;
        } sort {
            if (defined $_) {
                my $l = $_->target;
                $l->language eq $wanted_lang;
            }
        } @{ $entity->relationships_by_link_type_names('wikipedia') };

    if ($wp_link) {

        my $wp_extract = $c->model('WikipediaExtract')->get_extract($wp_link->page_name, $wanted_lang, $wp_link->language, cache_only => $cache_only);
        if ($wp_extract) {
            $c->stash->{wikipedia_extract} = $wp_extract;
        } else {
            $c->stash->{wikipedia_extract_url} = $c->req->uri . '/wikipedia-extract';
        }
    }
}

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2012 Ian McEwen
Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
