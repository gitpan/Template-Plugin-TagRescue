use strict;
use Template::Test;

test_expect(\*DATA, undef, {
    text => '<B>Bold!</B> and <I>Italic!</I> and <A href="http://www.cpan.org/">CPAN</A>'
});

__END__
--test--
[% USE TagRescue -%]
[% FILTER html_except_for('b','i') -%]
[% text %]
[%- END %]
--expect--
<B>Bold!</B> and <I>Italic!</I> and &lt;A href=&quot;http://www.cpan.org/&quot;&gt;CPAN&lt;/A&gt;

--test--
[% USE TagRescue -%]
[% text | html_except_for('i') %]
--expect--
&lt;B&gt;Bold!&lt;/B&gt; and <I>Italic!</I> and &lt;A href=&quot;http://www.cpan.org/&quot;&gt;CPAN&lt;/A&gt;

--test--
[% USE TagRescue -%]
[% FILTER html_except_for() -%]
[% text %]
[%- END %]
--expect--
&lt;B&gt;Bold!&lt;/B&gt; and &lt;I&gt;Italic!&lt;/I&gt; and &lt;A href=&quot;http://www.cpan.org/&quot;&gt;CPAN&lt;/A&gt;
