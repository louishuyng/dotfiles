#!/usr/bin/perl
# Cuts the second field (text) of tab-separated lines to fit MAX pt and appends …. Hangul/Han are 10.6pt (measured from a capture), emoji 16pt, the rest 7.2pt (12px monospace).
# Counts grapheme clusters, so combining accents add no width
#   perl fit.pl MAX < lines
use utf8; use strict; binmode STDIN, ':utf8'; binmode STDOUT, ':utf8';
my $max = shift || 123;
sub w { $_[0] =~ /\p{Emoji_Presentation}/ ? 16 : $_[0] =~ /[\p{Hangul}\p{Han}\p{Hiragana}\p{Katakana}]/ ? 10.375 : 7.2 }
while (my $l = <STDIN>) {
  chomp $l; my @f = split /\t/, $l, -1;
  if (@f > 1) {
    my @c = $f[1] =~ /(\X)/g; my $t = 0; $t += w($_) for @c;
    if ($t > $max) {
      my $o = ''; my $x = 7.2;                          # room for …
      for (@c) { last if $x + w($_) > $max; $x += w($_); $o .= $_ }
      $o =~ s/\s+$//; $f[1] = "$o…";
    }
  }
  print join("\t", @f), "\n";
}
