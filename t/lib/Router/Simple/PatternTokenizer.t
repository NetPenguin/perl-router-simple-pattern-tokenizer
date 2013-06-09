use 5.014;
use common::sense;

use Test::More;

my $class;
BEGIN {
    use_ok($class='Router::Simple::PatternTokenizer');
}

# ----
# Helpers.

# ----
# Tests.
subtest 'plain string' => sub {
    my $target = $class->new();
    my @tokens = $target->tokenize('/foo/bar/baz');
    is_deeply(\@tokens, [
        { type => 'separator', value => '/' },
        { type => 'fixed'    , value => 'foo' },
        { type => 'separator', value => '/' },
        { type => 'fixed'    , value => 'bar' },
        { type => 'separator', value => '/' },
        { type => 'fixed'    , value => 'baz' },
    ]);
};

subtest ':name' => sub {
    my $target = $class->new();
    my @tokens = $target->tokenize('/:foo/:bar/:baz');
    is_deeply(\@tokens, [
        { type => 'separator', value => '/' },
        { type => 'named'    , name => 'foo' },
        { type => 'separator', value => '/' },
        { type => 'named'    , name => 'bar' },
        { type => 'separator', value => '/' },
        { type => 'named'    , name => 'baz' },
    ]);
};

subtest '{name}' => sub {
    my $target = $class->new();
    my @tokens = $target->tokenize('/{foo}/{bar}/{baz}');
    is_deeply(\@tokens, [
        { type => 'separator', value => '/' },
        { type => 'named'    , name => 'foo' },
        { type => 'separator', value => '/' },
        { type => 'named'    , name => 'bar' },
        { type => 'separator', value => '/' },
        { type => 'named'    , name => 'baz' },
    ]);
};

subtest '{name:pattern}' => sub {
    my $target = $class->new();
    my @tokens = $target->tokenize('/{foo:[0-9]+}/{bar:[0-9]{2,4}}/{baz:\w+}');
    is_deeply(\@tokens, [
        { type => 'separator', value => '/' },
        { type => 'named'    , name => 'foo', pattern => '[0-9]+' },
        { type => 'separator', value => '/' },
        { type => 'named'    , name => 'bar', pattern => '[0-9]{2,4}' },
        { type => 'separator', value => '/' },
        { type => 'named'    , name => 'baz', pattern => '\w+' },
    ]);
};

subtest '*' => sub {
    my $target = $class->new();
    my @tokens = $target->tokenize('/foo/*/*');
    is_deeply(\@tokens, [
        { type => 'separator', value => '/' },
        { type => 'fixed'    , value => 'foo' },
        { type => 'separator', value => '/' },
        { type => 'splat' },
        { type => 'separator', value => '/' },
        { type => 'splat' },
    ]);
};

subtest 'mixed' => sub {
    my $target = $class->new();
    my @tokens = $target->tokenize('/foo/:bar/{baz}/{hoge:[0-9]{2}}/*/*.*');
    is_deeply(\@tokens, [
        { type => 'separator', value => '/' },
        { type => 'fixed'    , value => 'foo' },
        { type => 'separator', value => '/' },
        { type => 'named'    , name => 'bar' },
        { type => 'separator', value => '/' },
        { type => 'named'    , name => 'baz' },
        { type => 'separator', value => '/' },
        { type => 'named'    , name => 'hoge', pattern => '[0-9]{2}' },
        { type => 'separator', value => '/' },
        { type => 'splat' },
        { type => 'separator', value => '/' },
        { type => 'splat' },
        { type => 'fixed'    , value => '.' },
        { type => 'splat' },
    ]);
};

# ----
done_testing;
