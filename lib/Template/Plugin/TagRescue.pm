package Template::Plugin::TagRescue;

use strict;
use HTML::Parser 3.08;
use vars qw($VERSION);
$VERSION = 0.03;

require Template::Plugin;
use base qw(Template::Plugin);

use vars qw($FILTER_NAME);
$FILTER_NAME = 'html_except_for';

sub new {
    my($self, $context, @args) = @_;
    my $name = $args[0] || $FILTER_NAME;
    $context->define_filter($name, $self->filter_factory, 1);
    return $self;
}

sub filter_factory {
    my $self = shift;
    
    my $p = HTML::Parser->new(api_version => 3);
    $p->handler(default => \&escape, 'event,text,tagname');

    return sub {
	my ($context, @tags) = @_;
	reset_vars(ref $tags[0] eq 'ARRAY' ? @{$tags[0]} : @tags);
	return sub {
	    $p->parse(shift);
	    $p->eof;
	    return get_result();
	};
    };
}

{
    my $escape_html = escape_method();
    my $result      = '';
    my @except      = ();

    sub escape {
	my ($event, $text, $tagname) = @_;
	$tagname ||= '';
	if ($event eq 'text' or !(grep {/^$tagname$/i} @except)) {
	    $result .= $escape_html->($text);
	} else {
	    $result .= $text;
	}
    }

    sub reset_vars { $result = ''; @except = @_; }
    sub get_result { return $result; }
}

sub escape_method {
    eval {
	require Apache::Util;
	Apache::Util::escape_html('');
    };
    return \&Apache::Util::escape_html unless $@;

    eval {
	require HTML::Entities;
    };
    return \&HTML::Entities::encode_entities unless $@;

    die q/Can't locate Apache::Util or HTML::Entities/;
}

1;
__END__

=head1 NAME

Template::Plugin::TagRescue - TT Plugin to escape html tags except for marked

=head1 SYNOPSIS

  [% USE TagRescue %]

  [% FILTER html_except_for('b') -%]
  <B>Bold!</B> and <I>Italic!</I><BR>
  [%- END %]

  # Output:
  # <B>Bold!</B> and &lt;I&gt;Italic!&lt;/I&gt;&lt;BR&gt;

  [% '<B>Bold!</B> and <I>Italic!</I><BR>' | html_except_for('i','br') %]

  # Output:
  # &lt;B&gt;Bold!&lt;/B&gt; and <I>Italic!</I><BR>

  [% taglist = ['b', 'br']; '<B>Bold!</B> and <I>Italic!</I><BR>' | html_except_for(taglist) %]

  # Output:
  # <B>Bold!</B> and &lt;I&gt;Italic!&lt;/I&gt;<BR>

=head1 DESCRIPTION

Template::Plugin::TagRescue is a plugin for TT, which allows you to
escape html tags except for ones you set in templates.

=head1 AUTHOR

Satoshi Tanimoto E<lt>tanimoto@edge.co.jpE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Template>

=cut
