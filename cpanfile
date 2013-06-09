requires 'common::sense';
requires 'Carp';
requires 'Data::Util';
requires 'List::MoreUtils';

on 'test' => sub {
    requires 'Test::More';
    requires 'Router::Simple';
};
