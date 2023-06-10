#!/usr/bin/env perl

use URI;
use DDP;
use LWP::UserAgent;
use JSON::MaybeXS;
use File::Slurp;

my $ACCESS_TOKEN=$ENV{HH_RU_API_TOKEN};
my $VACANCY_ID=77247460
my $OUT_FILENAME='raw_data.json'

my $base_url = 'https://api.hh.ru/negotiations/consider?vacancy_id='+$VACANCY_ID+'&per_page=50';
my $ua  = LWP::UserAgent->new();
$ua->default_header('Authorization' => "Bearer $ACCESS_TOKEN");

my $PAGES_TOTAL=13

sub api_query {
  my ($url) = @_;
  my $resp = $ua->get( $url );
  if ( $resp->is_success ) {
    warn "OK $url";
    my $json_resp = decode_json( $resp->decoded_content );
    return $json_resp;
  }
  else {
    confess $response->status_line;
  }
}

my @result;
for (my $p=0; $p<$PAGES_TOTAL; $p++) {
  my $json_resp = api_query($base_url ."&page=".$p);
  warn "Curr $curr_page resp ". $json_resp->{page} . " total ".$json_resp->{pages};
  push @result, @{$json_resp->{items}};
  $curr_page++;
}
warn scalar @result;
write_file($OUT_FILENAME, encode_json(\@result) );
