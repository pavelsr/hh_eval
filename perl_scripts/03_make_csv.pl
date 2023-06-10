#!/usr/bin/env perl
# Основной скрипт предобработки, генерит data.csv из data.json

use File::Slurp;
use JSON::MaybeXS;
use DDP;
use Data::Dumper;
use Data::Dumper::AutoEncode;
use Text::CSV;

my $text = read_file('data.json');
my $items = decode_json $text;
warn scalar @$items;

my @headers_in_order = qw/
  name
  all_text
  response_url
  age
  gender
  location
  edu_lvl
  edu_institut
  edu_spec
  experience_months
  resume_title
  desired_salary
  english_level
  cover_letter_text
  cover_letter_text_not_auto
  skills
  skills_detailed
/;

my @rows;
for my $item (@$items) {
  my $row = {};

  $row->{name} = undef;
  if ($item->{resume}{last_name}) {
    $row->{name}.= $item->{resume}{last_name};
  }
  if ($item->{resume}{first_name}) {
    $row->{name}.= " ".$item->{resume}{first_name};
  }
  if ($item->{resume}{middle_name}) {
    $row->{name}.= " ".$item->{resume}{middle_name};
  }

  $row->{age} = $item->{resume}{age};
  $row->{gender} = $item->{resume}{gender}{id};
  $row->{location} = $item->{resume}{area}{name};

  $row->{edu_lvl} = $item->{resume}{education}{level}{name};
  $row->{edu_institut} = $item->{resume}{education}{primary}[0]{name};
  $row->{edu_spec} = $item->{resume}{education}{primary}[0]{result};

  $row->{experience_months} = $item->{resume}{total_experience}{months};
  $row->{resume_title} = $item->{resume}{title};
  $row->{desired_salary} = $item->{resume}{salary}{amount};

  $row->{english_level} = [ grep { $_->{id} eq "eng" } @{$item->{resume_detailed}{language}} ]->[0]->{level}{id};

  $row->{cover_letter_text} = $item->{messages}{items}[0]{text};

  $row->{skills} = join( " ", @{$item->{resume_detailed}{skill_set}} );
  $row->{skills_detailed} = $item->{resume_detailed}{skills};

  my $separator = "\n";
  $row->{all_text} = $row->{resume_title};
  if ($row->{cover_letter_text}) {
    $row->{all_text} .= $separator.$row->{cover_letter_text};
  }
  if ($row->{skills}) {
    $row->{all_text} .= $separator.$row->{skills};
  }
  if ($row->{skills_detailed}) {
    $row->{all_text} .= $separator.$row->{skills_detailed};
  }

  $row->{response_url} = "https://hh.ru/resume/".$item->{resume}{id}."?vacancyId=77247460";

  my $row_arr = [];
  for my $header (@headers_in_order) {
    push @$row_arr, $row->{$header};
  }
  push @rows, $row_arr;
}

unshift(@rows, \@headers_in_order);

my $filename = "data.csv";
my $csv = Text::CSV->new() or die "Cannot use CSV: ".Text::CSV->error_diag ();
open $fh, ">:encoding(utf8)", $filename or die "$filename: $!";
$csv->say ($fh, $_) for @rows;
close $fh or die "$filename: $!";
