package Router::Simple::PatternTokenizer;
use 5.014;
use common::sense;

use Carp qw(croak);
use Data::Util qw(is_string);
use List::MoreUtils qw(natatime);

=head1 NAME

Router::Simple::PatternTokenizer - Router::Simple のルーティングルールのパターンを要素ごとに分割します

=head1 SYNOPSIS

  use Router::Simple;
  use Router::Simple::PatternTokenizer;
  
  my $router = Router::Simple->new();
  $router->connect('/', {controller => 'Root', action => 'show'});
  $router->connect('/blog/{year:[0-9]+}/{month}', {controller => 'Blog', action => 'monthly'});
  
  my $app = sub {
      my $env = shift;
      if (my ($match, $route) = $router->routematch($env)) {
          my $tokenizer = Router::Simple::PatternTokenizer->new();
          my @tokens = $tokenizer->tokenize($route->pattern);
      } else {
          return [404, [], ['not found']];
      }
  };

=cut

sub new {
    my $class = shift;
    return bless {}, $class;
}

=head1 METHODS

=head2 tokenize($pattern)

I<$pattern> を分解して複数のトークンからなる配列を返します。
各トークンは、以下のいずれかの形式となります。

=over

=item separator - パスの区切り文字

  { type => 'separator', value => '/' }

=item fixed - 固定文字列

  { type => 'fixed', value => 'blog' }

=item named - 名前付けされた可変文字列

  { type => 'named', name => 'year', pattern => '[0-9]+' }

=item split - * で表現される可変文字列

  { type => 'splat' }

=back

=cut
sub tokenize {
    my ($self, $pattern) = @_;
    croak("Argument 'pattern' is not string.(pattern: $pattern)")
        unless is_string($pattern);

    my @xs = $pattern =~ m!
        \{((?:\{[0-9,]+\}|[^{}]+)+)\} | # /blog/{year:\d{4}}
        :([A-Za-z0-9_]+)              | # /blog/:year
        (\*)                          | # /blog/*/*
        ([/])                         | # separator
        ([^{:*/]+)                      # normal string
    !xmsg;

    my @tokens;
    my $itr = natatime(5, @xs);
    while (my @ys = $itr->()) {
        if (defined(my $y=$ys[0])) {    # /blog/{year:\d{4}}
            my ($name, $rest) = split(qr/:/, $y, 2);
            push @tokens, {
                type => 'named',
                name => $name,
                defined $rest ? (pattern => $rest) : (),
            };
        }
        elsif (defined(my $y=$ys[1])) { # /blog/:year
            push @tokens, { type => 'named', name => $y };
        }
        elsif (defined(my $y=$ys[2])) { # /blog/*/*
            push @tokens, { type => 'splat' };
        }
        elsif (defined(my $y=$ys[3])) { # separator
            push @tokens, { type => 'separator', value => $y };
        }
        elsif (defined(my $y=$ys[4])) { # normal string
            push @tokens, { type => 'fixed', value => $y };
        }
        else {
            croak("Unexpected pattern.(pattern: $pattern)");
        }
    }

    return @tokens;
}

1;
