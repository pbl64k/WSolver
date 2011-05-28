#!perl

use strict           ;

use Wappo2::Position ;

my $pos =
{
  max_x => 6 ,
  max_y => 6 ,

  wappo  => { x => 2 , y => 3 } ,
  red    => { x => 6 , y => 5 } ,
  blue   => { x => 1 , y => 1 } ,
  violet => { x => 0 , y => 0 } ,
  t1     => { x => 1 , y => 3 } ,
  t2     => { x => 3 , y => 5 } ,
  fire   => { x => 2 , y => 4 } ,
  goal   => { x => 3 , y => 2 } ,

  wall_east  =>
  {
    12 => 1 ,
    22 => 1 ,
    52 => 1 ,
    53 => 1 ,
    15 => 1 ,
    45 => 1 ,
  } ,

  wall_south =>
  {
    32 => 1 ,
    52 => 1 ,
    53 => 1 ,
    24 => 1 ,
    34 => 1 ,
    45 => 1 ,
  } ,

  tmp_wall_east         => [                   ] ,

  tmp_wall_east_status  => [                   ] ,

  tmp_wall_south        => [ 43 , 64 , 15 , 65 ] ,

  tmp_wall_south_status => [  1 ,  1 ,  1 ,  1 ] ,

  solution => '' ,

} ;

my $start = Wappo2::Position -> new ( $pos ) ;

$start -> solve ( 0 ) ;

<STDIN>;

1
