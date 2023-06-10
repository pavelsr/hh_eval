#!/usr/bin/env perl
# Скрипт получает: сообщения (для вывода сопроводительного письма), резюме (для вывода ключевых навыков)
# Сохраняет в data.json

use LWP::UserAgent;
use File::Slurp;
use JSON::MaybeXS;
use DDP;
use Data::Dumper;
use Data::Dumper::AutoEncode;
use Text::CSV;

my $ACCESS_TOKEN=$ENV{HH_RU_API_TOKEN};
my $IN_FILENAME='raw_data.json'
my $OUT_FILENAME='data.json'

my $ua  = LWP::UserAgent->new();
$ua->default_header('Authorization' => "Bearer $ACCESS_TOKEN");
my $text = read_file($IN_FILENAME);
my $items = decode_json $text;

sub api_query {
  my ($url) = @_;
  my $resp = $ua->get( $url );
  if ( $resp->is_success ) {
    warn "OK $url";
    my $json_resp = decode_json( $resp->decoded_content );
    return $json_resp;
  }
  else {
    warn "NOT OK $url";
    return undef;
  }
}

while (my ($index, $item) = each @$items) {
  print "$index\n";
  $item->{messages} = api_query( $item->{messages_url} );
  $item->{resume_detailed} = api_query( $item->{resume}{url} );
}

write_file($OUT_FILENAME, encode_json($items) );
