
use strict ;

our @ISA = ( ) ;

package Wappo2::Position ;

our $pos = {                            } ;

our @mov = ( '' , '^' , '<' , 'v' , '>' ) ;

sub new
{

  my $self  = shift                              ;

  my $class = ref ( $self ) || $self             ;

  my $arg   = shift                              ;

  my %init  = ( ref ( $self ) ? %$self : %$arg ) ;

  my $this  = { }                                ;

# This WON'T work with nested references.

  for ( keys ( %init ) )
  {
    if    ( ref ( $init { $_ } ) eq 'HASH'  )
    {
      $this -> { $_ } = { % { $init { $_ } } } ;
    }
    elsif ( ref ( $init { $_ } ) eq 'ARRAY' )
    {
      $this -> { $_ } = [ @ { $init { $_ } } ] ;
    }
    else
    {
      $this -> { $_ } =       $init { $_ }     ;
    }
  }

  bless  ( $this , $class ) ;

  return ( $this          ) ;

}

sub id
{

  my $this = shift ;

  my $id   = ''    ;

  $id .= $this -> xy ( 'wappo'  ) ;
  $id .= $this -> xy ( 'red'    ) ;
  $id .= $this -> xy ( 'blue'   ) ;
  $id .= $this -> xy ( 'violet' ) ;
  $id .= $this -> xy ( 'fire'   ) ;

  $id .= join ( '' , @ { $this -> { tmp_wall_east_status  } } ) ;
  $id .= join ( '' , @ { $this -> { tmp_wall_south_status } } ) ;

  return ( $id ) ;

}

sub print_pos
{

  my $this  = shift ;

  my $buff1 = ''    ;
  my $buff2 = ''    ;

  print ( ' '    ) ;
  for ( 1 .. $this -> { max_x } )
  {
    print ( ' ' . $_ ) ;
  }
  print ( "\n\n" ) ;

  for my $y ( 1 .. $this -> { max_y } )
  {
    print ( $y . ' ' ) ;

    $buff1 = ''   ;
    $buff2 = '  ' ;

    for my $x ( 1 .. $this -> { max_x } )
    {
      my $tmp1 ;

      my $xy = $x . $y ;

      if    ( $xy eq $this -> xy ( 'wappo'  ) )
      {
        $buff1 .= 'W' ;
      }
      elsif ( $xy eq $this -> xy ( 'red'    ) )
      {
        $buff1 .= 'R' ;
      }
      elsif ( $xy eq $this -> xy ( 'blue'   ) )
      {
        $buff1 .= 'B' ;
      }
      elsif ( $xy eq $this -> xy ( 'violet' ) )
      {
        $buff1 .= 'V' ;
      }
      elsif ( $xy eq $this -> xy ( 't1'     ) )
      {
        $buff1 .= 'T' ;
      }
      elsif ( $xy eq $this -> xy ( 't2'     ) )
      {
        $buff1 .= 'T' ;
      }
      elsif ( $xy eq $this -> xy ( 'fire'   ) )
      {
        $buff1 .= 'F' ;
      }
      elsif ( $xy eq $this -> xy ( 'goal'   ) )
      {
        $buff1 .= 'X' ;
      }
      else
      {
        $buff1 .= ' ' ;
      }

      if ( $this -> { wall_east  } -> { $xy } )
      {
        $buff1 .= '|' ;
      }
      else
      {
        my $tmp2 = 0 ;

        for ( 0 .. $#{ $this -> { tmp_wall_east  } } )
        {
          if ( ( $xy eq $this -> { tmp_wall_east         } -> [ $_ ] ) &&
               (        $this -> { tmp_wall_east_status  } -> [ $_ ] )  )
          {
            $tmp2 = 1 ;
          }
        }

        $buff1 .= $tmp2 ? '!' : ' ' ;
      }

      if ( $this -> { wall_south } -> { $xy } )
      {
        $buff2 .= '- ' ;
      }
      else
      {
        my $tmp2 = 0 ;

        for ( 0 .. $#{ $this -> { tmp_wall_south } } )
        {
          if ( ( $xy eq $this -> { tmp_wall_south        } -> [ $_ ] ) &&
               (        $this -> { tmp_wall_south_status } -> [ $_ ] )  )
          {
            $tmp2 = 1 ;
          }
        }

        $buff2 .= $tmp2 ? '= ' : '  ' ;
      }
    }

    print $buff1."\n".$buff2."\n";
  }

  return ( 1 ) ;

}

sub solve
{

  my $this = shift ;

  my $arg  = shift ;

  if ( $arg == 0 )
  {

    if ( exists ( $pos -> { $this -> id ( ) } ) )
    {

      return ( $pos -> { $this -> id ( ) } ) ;

    }

#print $this->{solution}."\n";

#<><^v<v>^^v><^^

#if ( $this-> { solution } =~ /^\<\>\<\^\v<v\>\^\^/ )
#{
#  print $this->print_pos()."\n";
#  print $this->id()."\n";
#  <STDIN>;
#}

    $pos -> { $this -> id ( ) } = $this -> check ( ) ;

    for ( 1 .. 4 )
    {
      my $p = $this -> new   (    ) ;

      my $r = $p    -> solve ( $_ ) ;

      if ( $r == 1 )
      {

        return ( $r ) ;

      }
    }

    return ( 0 ) ;

  }
  else
  {
    if ( ! $this -> go ( $arg ) )
    {

      return ( 0 ) ;

    }

    if ( $this -> check ( ) == 1 )
    {

      return ( 1 ) ;

    }

    for ( 0 .. 2 )
    {
      $this -> moveviolet ( ) ;

      if ( ! $this -> check ( ) )
      {

        return ( 0 ) ;

      }
    }

    for ( 0 .. 1 )
    {
      $this -> movered    ( ) ;
      $this -> moveblue   ( ) ;

      if ( ! $this -> check ( ) )
      {

        return ( 0 ) ;

      }
    }

    return ( $this -> solve ( 0 ) ) ;
  }

  return ( 0 ) ;

}

sub go
{

  my $this  = shift ;

  my $arg   = shift ;

  my $newxy = ''    ;

  $this -> { solution } .= $mov [ $arg ] ;

  print($this->{solution}."\n");

  if    ( $arg == 1 )
  {
    $this -> { wappo } -> { y } -= 1 ;

    $newxy = $this -> xy ( 'wappo' ) ;

    return ( 0 ) if ( $newxy eq $this -> xy ( 'red'    )    ) ;
    return ( 0 ) if ( $newxy eq $this -> xy ( 'blue'   )    ) ;
    return ( 0 ) if ( $newxy eq $this -> xy ( 'violet' )    ) ;
    return ( 0 ) if ( $newxy =~ /0/                         ) ;
    return ( 0 ) if ( $this -> { wall_south } -> { $newxy } ) ;

    for ( 0 .. $#{ $this -> { tmp_wall_south } } )
    {
      if ( ( $this -> { tmp_wall_south }        -> [ $_ ] eq $newxy ) &&
           ( $this -> { tmp_wall_south_status } -> [ $_ ]           )  )
      {
        return ( 0 ) ;
      }
    }

    if ( $newxy eq $this -> xy ( 'fire' ) )
    {
      $this -> { fire } -> { y } -= 1 ;

      $newxy = $this -> xy ( 'fire' ) ;

      for ( 'red' , 'blue' , 'violet' , 't1' , 't2' , 'goal' )
      {
        return ( 0 ) if ( $newxy eq $this -> xy ( $_ ) ) ;
      }

      return ( 0 ) if ( $newxy =~ /0/                         ) ;
      return ( 0 ) if ( $this -> { wall_south } -> { $newxy } ) ;

      for ( 0 .. $#{ $this -> { tmp_wall_south } } )
      {
        if ( ( $this -> { tmp_wall_south }        -> [ $_ ] eq $newxy ) &&
             ( $this -> { tmp_wall_south_status } -> [ $_ ]           )  )
        {
          return ( 0 ) ;
        }
      }
    }
  }
  elsif ( $arg == 2 )
  {
    $this -> { wappo } -> { x } -= 1 ;

    $newxy = $this -> xy ( 'wappo' ) ;

    return ( 0 ) if ( $newxy eq $this -> xy ( 'red'    )    ) ;
    return ( 0 ) if ( $newxy eq $this -> xy ( 'blue'   )    ) ;
    return ( 0 ) if ( $newxy eq $this -> xy ( 'violet' )    ) ;
    return ( 0 ) if ( $newxy =~ /0/                         ) ;
    return ( 0 ) if ( $this -> { wall_east  } -> { $newxy } ) ;

    for ( 0 .. $#{ $this -> { tmp_wall_east  } } )
    {
      if ( ( $this -> { tmp_wall_east  }        -> [ $_ ] eq $newxy ) &&
           ( $this -> { tmp_wall_east_status  } -> [ $_ ]           )  )
      {
        return ( 0 ) ;
      }
    }

    if ( $newxy eq $this -> xy ( 'fire' ) )
    {
      $this -> { fire } -> { x } -= 1 ;

      $newxy = $this -> xy ( 'fire' ) ;

      for ( 'red' , 'blue' , 'violet' , 't1' , 't2' , 'goal' )
      {
        return ( 0 ) if ( $newxy eq $this -> xy ( $_ ) ) ;
      }

      return ( 0 ) if ( $newxy =~ /0/                         ) ;
      return ( 0 ) if ( $this -> { wall_east  } -> { $newxy } ) ;

      for ( 0 .. $#{ $this -> { tmp_wall_east  } } )
      {
        if ( ( $this -> { tmp_wall_east  }        -> [ $_ ] eq $newxy ) &&
             ( $this -> { tmp_wall_east_status  } -> [ $_ ]           )  )
        {
          return ( 0 ) ;
        }
      }
    }
  }
  elsif ( $arg == 3 )
  {
    $newxy = $this -> xy ( 'wappo' ) ;

    return ( 0 ) if ( $this -> { wall_south } -> { $newxy } ) ;

    for ( 0 .. $#{ $this -> { tmp_wall_south } } )
    {
      if ( ( $this -> { tmp_wall_south }        -> [ $_ ] eq $newxy ) &&
           ( $this -> { tmp_wall_south_status } -> [ $_ ]           )  )
      {
        return ( 0 ) ;
      }
    }

    $this -> { wappo } -> { y } += 1 ;

    $newxy = $this -> xy ( 'wappo' ) ;

    return ( 0 ) if ( $newxy eq $this -> xy ( 'red'    )    ) ;
    return ( 0 ) if ( $newxy eq $this -> xy ( 'blue'   )    ) ;
    return ( 0 ) if ( $newxy eq $this -> xy ( 'violet' )    ) ;
    return ( 0 ) if ( $newxy =~ /7/                         ) ;

    if ( $newxy eq $this -> xy ( 'fire' ) )
    {
      $newxy = $this -> xy ( 'fire' ) ;

      return ( 0 ) if ( $this -> { wall_south } -> { $newxy } ) ;

      for ( 0 .. $#{ $this -> { tmp_wall_south } } )
      {
        if ( ( $this -> { tmp_wall_south }        -> [ $_ ] eq $newxy ) &&
             ( $this -> { tmp_wall_south_status } -> [ $_ ]           )  )
        {
          return ( 0 ) ;
        }
      }

      $this -> { fire } -> { y } += 1 ;

      $newxy = $this -> xy ( 'fire' ) ;

      for ( 'red' , 'blue' , 'violet' , 't1' , 't2' , 'goal' )
      {
        return ( 0 ) if ( $newxy eq $this -> xy ( $_ ) ) ;
      }

      return ( 0 ) if ( $newxy =~ /7/                         ) ;
    }
  }
  elsif ( $arg == 4 )
  {
    $newxy = $this -> xy ( 'wappo' ) ;

    return ( 0 ) if ( $this -> { wall_east  } -> { $newxy } ) ;

    for ( 0 .. $#{ $this -> { tmp_wall_east  } } )
    {
      if ( ( $this -> { tmp_wall_east  }        -> [ $_ ] eq $newxy ) &&
           ( $this -> { tmp_wall_east_status  } -> [ $_ ]           )  )
      {
        return ( 0 ) ;
      }
    }

    $this -> { wappo } -> { x } += 1 ;

    $newxy = $this -> xy ( 'wappo' ) ;

    return ( 0 ) if ( $newxy eq $this -> xy ( 'red'    )    ) ;
    return ( 0 ) if ( $newxy eq $this -> xy ( 'blue'   )    ) ;
    return ( 0 ) if ( $newxy eq $this -> xy ( 'violet' )    ) ;
    return ( 0 ) if ( $newxy =~ /7/                         ) ;

    if ( $newxy eq $this -> xy ( 'fire' ) )
    {
      $newxy = $this -> xy ( 'fire' ) ;

      return ( 0 ) if ( $this -> { wall_east  } -> { $newxy } ) ;

      for ( 0 .. $#{ $this -> { tmp_wall_east  } } )
      {
        if ( ( $this -> { tmp_wall_east  }        -> [ $_ ] eq $newxy ) &&
             ( $this -> { tmp_wall_east_status  } -> [ $_ ]           )  )
        {
          return ( 0 ) ;
        }
      }

      $this -> { fire } -> { x } += 1 ;

      $newxy = $this -> xy ( 'fire' ) ;

      for ( 'red' , 'blue' , 'violet' , 't1' , 't2' , 'goal' )
      {
        return ( 0 ) if ( $newxy eq $this -> xy ( $_ ) ) ;
      }

      return ( 0 ) if ( $newxy =~ /7/                         ) ;
    }
  }

  if    ( $this -> xy ( 'wappo' ) eq $this -> xy ( 't1' ) )
  {
    $this -> { wappo } = { % { $this -> { t2 } } } ;
  }
  elsif ( $this -> xy ( 'wappo' ) eq $this -> xy ( 't2' ) )
  {
    $this -> { wappo } = { % { $this -> { t1 } } } ;
  }

  $this -> { red    } -> { tp } = 0 ;
  $this -> { blue   } -> { tp } = 0 ;
  $this -> { violet } -> { tp } = 0 ;

  return ( 1 ) ;

}

sub movered
{

  my $this  = shift ;

  my $newxy = ''    ;

  my $cant  = 0     ;

  return ( 0 ) if ( $this -> { red } -> { tp }    ) ;
  return ( 0 ) if ( $this -> xy ( 'red' ) eq '00' ) ;

  if    ( $this -> { wappo } -> { y } < $this -> { red } -> { y } )
  {
    $newxy = $this -> { red } -> { x } . ( $this -> { red } -> { y } - 1 ) ;

    $cant = 1 if ( $this -> { wall_south } -> { $newxy } ) ;

    for ( 0 .. $#{ $this -> { tmp_wall_south } } )
    {
      if ( ( $this -> { tmp_wall_south }        -> [ $_ ] eq $newxy ) &&
           ( $this -> { tmp_wall_south_status } -> [ $_ ]           )  )
      {
        $cant = 1 ;
      }
    }

    $cant = 1 if ( $newxy eq $this -> xy ( 'fire' ) ) ;

    if ( ! $cant )
    {

      $this -> { red } -> { y } -= 1 ;

      if ( $this -> check2 ( ) )
      {
        if    ( $this -> xy ( 'red' ) eq $this -> xy ( 't1' ) )
        {
          $this -> { red } = { % { $this -> { t2 } } } ;
          $this -> { red } -> { tp } = 1 ;
        }
        elsif ( $this -> xy ( 'red' ) eq $this -> xy ( 't2' ) )
        {
          $this -> { red } = { % { $this -> { t1 } } } ;
          $this -> { red } -> { tp } = 1 ;
        }
      }

      return ( 1 ) ;

    }
  }
  elsif ( $this -> { wappo } -> { y } > $this -> { red } -> { y } )
  {
    $newxy = $this -> xy ( 'red' ) ;

    $cant = 1 if ( $this -> { wall_south } -> { $newxy } ) ;

    for ( 0 .. $#{ $this -> { tmp_wall_south } } )
    {
      if ( ( $this -> { tmp_wall_south }        -> [ $_ ] eq $newxy ) &&
           ( $this -> { tmp_wall_south_status } -> [ $_ ]           )  )
      {
        $cant = 1 ;
      }
    }

    $newxy = $this -> { red } -> { x } . ( $this -> { red } -> { y } + 1 ) ;

    $cant = 1 if ( $newxy eq $this -> xy ( 'fire' ) ) ;

    if ( ! $cant )
    {

      $this -> { red } -> { y } += 1 ;

      if ( $this -> check2 ( ) )
      {
        if    ( $this -> xy ( 'red' ) eq $this -> xy ( 't1' ) )
        {
          $this -> { red } = { % { $this -> { t2 } } } ;
          $this -> { red } -> { tp } = 1 ;
        }
        elsif ( $this -> xy ( 'red' ) eq $this -> xy ( 't2' ) )
        {
          $this -> { red } = { % { $this -> { t1 } } } ;
          $this -> { red } -> { tp } = 1 ;
        }
      }

      return ( 1 ) ;

    }
  }

  $cant = 0 ;

  if    ( $this -> { wappo } -> { x } < $this -> { red } -> { x } )
  {
    $newxy = ( $this -> { red } -> { x } - 1 ) . $this -> { red } -> { y } ;

    $cant = 1 if ( $this -> { wall_east  } -> { $newxy } ) ;

    for ( 0 .. $#{ $this -> { tmp_wall_east  } } )
    {
      if ( ( $this -> { tmp_wall_east  }        -> [ $_ ] eq $newxy ) &&
           ( $this -> { tmp_wall_east_status  } -> [ $_ ]           )  )
      {
        $cant = 1 ;
      }
    }

    $cant = 1 if ( $newxy eq $this -> xy ( 'fire' ) ) ;

    if ( ! $cant )
    {

      $this -> { red } -> { x } -= 1 ;

      if ( $this -> check2 ( ) )
      {
        if    ( $this -> xy ( 'red' ) eq $this -> xy ( 't1' ) )
        {
          $this -> { red } = { % { $this -> { t2 } } } ;
          $this -> { red } -> { tp } = 1 ;
        }
        elsif ( $this -> xy ( 'red' ) eq $this -> xy ( 't2' ) )
        {
          $this -> { red } = { % { $this -> { t1 } } } ;
          $this -> { red } -> { tp } = 1 ;
        }
      }

      return ( 1 ) ;

    }
  }
  elsif ( $this -> { wappo } -> { x } > $this -> { red } -> { x } )
  {
    $newxy = $this -> xy ( 'red' ) ;

    $cant = 1 if ( $this -> { wall_east  } -> { $newxy } ) ;

    for ( 0 .. $#{ $this -> { tmp_wall_east  } } )
    {
      if ( ( $this -> { tmp_wall_east  }        -> [ $_ ] eq $newxy ) &&
           ( $this -> { tmp_wall_east_status  } -> [ $_ ]           )  )
      {
        $cant = 1 ;
      }
    }

    $newxy = ( $this -> { red } -> { x } + 1 ) . $this -> { red } -> { y } ;

    $cant = 1 if ( $newxy eq $this -> xy ( 'fire' ) ) ;

    if ( ! $cant )
    {

      $this -> { red } -> { x } += 1 ;

      if ( $this -> check2 ( ) )
      {
        if    ( $this -> xy ( 'red' ) eq $this -> xy ( 't1' ) )
        {
          $this -> { red } = { % { $this -> { t2 } } } ;
          $this -> { red } -> { tp } = 1 ;
        }
        elsif ( $this -> xy ( 'red' ) eq $this -> xy ( 't2' ) )
        {
          $this -> { red } = { % { $this -> { t1 } } } ;
          $this -> { red } -> { tp } = 1 ;
        }
      }

      return ( 1 ) ;

    }
  }

  return ( 0 ) ;

}

sub moveblue
{

  my $this  = shift ;

  my $newxy = ''    ;

  my $cant  = 0     ;

  return ( 0 ) if ( $this -> { blue } -> { tp }    ) ;
  return ( 0 ) if ( $this -> xy ( 'blue' ) eq '00' ) ;

  if    ( $this -> { wappo } -> { x } < $this -> { blue } -> { x } )
  {
    $newxy = ( $this -> { blue } -> { x } - 1 ) . $this -> { blue } -> { y } ;

    $cant = 1 if ( $this -> { wall_east  } -> { $newxy } ) ;

    for ( 0 .. $#{ $this -> { tmp_wall_east  } } )
    {
      if ( ( $this -> { tmp_wall_east  }        -> [ $_ ] eq $newxy ) &&
           ( $this -> { tmp_wall_east_status  } -> [ $_ ]           )  )
      {
        $cant = 1 ;
      }
    }

    $cant = 1 if ( $newxy eq $this -> xy ( 'fire' ) ) ;

    if ( ! $cant )
    {

      $this -> { blue } -> { x } -= 1 ;

      if ( $this -> check2 ( ) )
      {
        if    ( $this -> xy ( 'blue' ) eq $this -> xy ( 't1' ) )
        {
          $this -> { blue } = { % { $this -> { t2 } } } ;
          $this -> { blue } -> { tp } = 1 ;
        }
        elsif ( $this -> xy ( 'blue' ) eq $this -> xy ( 't2' ) )
        {
          $this -> { blue } = { % { $this -> { t1 } } } ;
          $this -> { blue } -> { tp } = 1 ;
        }
      }

      return ( 1 ) ;

    }
  }
  elsif ( $this -> { wappo } -> { x } > $this -> { blue } -> { x } )
  {
    $newxy = $this -> xy ( 'blue' ) ;

    $cant = 1 if ( $this -> { wall_east  } -> { $newxy } ) ;

    for ( 0 .. $#{ $this -> { tmp_wall_east  } } )
    {
      if ( ( $this -> { tmp_wall_east  }        -> [ $_ ] eq $newxy ) &&
           ( $this -> { tmp_wall_east_status  } -> [ $_ ]           )  )
      {
        $cant = 1 ;
      }
    }

    $newxy = ( $this -> { blue } -> { x } + 1 ) . $this -> { blue } -> { y } ;

    $cant = 1 if ( $newxy eq $this -> xy ( 'fire' ) ) ;

    if ( ! $cant )
    {

      $this -> { blue } -> { x } += 1 ;

      if ( $this -> check2 ( ) )
      {
        if    ( $this -> xy ( 'blue' ) eq $this -> xy ( 't1' ) )
        {
          $this -> { blue } = { % { $this -> { t2 } } } ;
          $this -> { blue } -> { tp } = 1 ;
        }
        elsif ( $this -> xy ( 'blue' ) eq $this -> xy ( 't2' ) )
        {
          $this -> { blue } = { % { $this -> { t1 } } } ;
          $this -> { blue } -> { tp } = 1 ;
        }
      }

      return ( 1 ) ;

    }
  }

  $cant = 0 ;

  if    ( $this -> { wappo } -> { y } < $this -> { blue } -> { y } )
  {
    $newxy = $this -> { blue } -> { x } . ( $this -> { blue } -> { y } - 1 ) ;

    $cant = 1 if ( $this -> { wall_south } -> { $newxy } ) ;

    for ( 0 .. $#{ $this -> { tmp_wall_south } } )
    {
      if ( ( $this -> { tmp_wall_south }        -> [ $_ ] eq $newxy ) &&
           ( $this -> { tmp_wall_south_status } -> [ $_ ]           )  )
      {
        $cant = 1 ;
      }
    }

    $cant = 1 if ( $newxy eq $this -> xy ( 'fire' ) ) ;

    if ( ! $cant )
    {

      $this -> { blue } -> { y } -= 1 ;

      if ( $this -> check2 ( ) )
      {
        if    ( $this -> xy ( 'blue' ) eq $this -> xy ( 't1' ) )
        {
          $this -> { blue } = { % { $this -> { t2 } } } ;
          $this -> { blue } -> { tp } = 1 ;
        }
        elsif ( $this -> xy ( 'blue' ) eq $this -> xy ( 't2' ) )
        {
          $this -> { blue } = { % { $this -> { t1 } } } ;
          $this -> { blue } -> { tp } = 1 ;
        }
      }

      return ( 1 ) ;

    }
  }
  elsif ( $this -> { wappo } -> { y } > $this -> { blue } -> { y } )
  {
    $newxy = $this -> xy ( 'blue' ) ;

    $cant = 1 if ( $this -> { wall_south } -> { $newxy } ) ;

    for ( 0 .. $#{ $this -> { tmp_wall_south } } )
    {
      if ( ( $this -> { tmp_wall_south }        -> [ $_ ] eq $newxy ) &&
           ( $this -> { tmp_wall_south_status } -> [ $_ ]           )  )
      {
        $cant = 1 ;
      }
    }

    $newxy = $this -> { blue } -> { x } . ( $this -> { blue } -> { y } + 1 ) ;

    $cant = 1 if ( $newxy eq $this -> xy ( 'fire' ) ) ;

    if ( ! $cant )
    {

      $this -> { blue } -> { y } += 1 ;

      if ( $this -> check2 ( ) )
      {
        if    ( $this -> xy ( 'blue' ) eq $this -> xy ( 't1' ) )
        {
          $this -> { blue } = { % { $this -> { t2 } } } ;
          $this -> { blue } -> { tp } = 1 ;
        }
        elsif ( $this -> xy ( 'blue' ) eq $this -> xy ( 't2' ) )
        {
          $this -> { blue } = { % { $this -> { t1 } } } ;
          $this -> { blue } -> { tp } = 1 ;
        }
      }

      return ( 1 ) ;

    }
  }

  return ( 0 ) ;

}

sub moveviolet
{

  my $this  = shift ;

  my $newxy = ''    ;

  my $cant  = 0     ;

  my $difx  = 0     ;

  my $dify  = 0     ;

  return ( 0 ) if ( $this -> { violet } -> { tp } ) ;

  if ( $this -> xy ( 'violet' ) eq '00' )
  {
    return ( 0 ) ;
  }

  if    ( $this -> { wappo } -> { x } < $this -> { violet } -> { x } )
  {
    $difx = -1 ;
  }
  elsif ( $this -> { wappo } -> { x } > $this -> { violet } -> { x } )
  {
    $difx =  1 ;
  }

  if    ( $this -> { wappo } -> { y } < $this -> { violet } -> { y } )
  {
    $dify = -1 ;
  }
  elsif ( $this -> { wappo } -> { y } > $this -> { violet } -> { y } )
  {
    $dify =  1 ;
  }

  $newxy = ( $this -> { violet } -> { x } + $difx ) .
           ( $this -> { violet } -> { y } + $dify ) ;

  if ( ( $difx != 0 ) && ( $dify != 0 ) )
  {
    my $wallx ;
    my $wally ;

    if ( $newxy ne $this -> xy ( 'fire' ) )
    {
      if ( ( $difx ==  1 ) && ( $dify ==  1 ) )
      {
        $wallx = ( $this -> { violet } -> { x }     ) .
                 ( $this -> { violet } -> { y } + 1 ) ;
        $wally = ( $this -> { violet } -> { x } + 1 ) .
                 ( $this -> { violet } -> { y }     ) ;
      }
      if ( ( $difx == -1 ) && ( $dify ==  1 ) )
      {
        $wallx = ( $this -> { violet } -> { x } - 1 ) .
                 ( $this -> { violet } -> { y } + 1 ) ;
        $wally = ( $this -> { violet } -> { x } - 1 ) .
                 ( $this -> { violet } -> { y }     ) ;
      }
      if ( ( $difx ==  1 ) && ( $dify == -1 ) )
      {
        $wallx = ( $this -> { violet } -> { x }     ) .
                 ( $this -> { violet } -> { y } - 1 ) ;
        $wally = ( $this -> { violet } -> { x } + 1 ) .
                 ( $this -> { violet } -> { y } - 1 ) ;
      }
      if ( ( $difx == -1 ) && ( $dify == -1 ) )
      {
        $wallx = ( $this -> { violet } -> { x } - 1 ) .
                 ( $this -> { violet } -> { y } - 1 ) ;
        $wally = ( $this -> { violet } -> { x } - 1 ) .
                 ( $this -> { violet } -> { y } - 1 ) ;
      }

      if ( ( ! $this -> { wall_east  } -> { $wallx } ) &&
           ( ! $this -> { wall_south } -> { $wally } )  )
      {

        for ( 0 .. $#{ $this -> { tmp_wall_east  } } )
        {
          if ( ( $this -> { tmp_wall_east  }        -> [ $_ ] eq $wallx ) &&
               ( $this -> { tmp_wall_east_status  } -> [ $_ ]           )  )
          {
            $this -> { tmp_wall_east_status  } = 0 ;
          }
        }

        for ( 0 .. $#{ $this -> { tmp_wall_south } } )
        {
          if ( ( $this -> { tmp_wall_south }        -> [ $_ ] eq $wally ) &&
               ( $this -> { tmp_wall_south_status } -> [ $_ ]           )  )
          {
            $this -> { tmp_wall_south_status } = 0 ;
          }
        }

        $this -> { violet } -> { x } += $difx ;
        $this -> { violet } -> { y } += $dify ;

        if ( $this -> check2 ( ) )
        {
          if    ( $this -> xy ( 'violet' ) eq $this -> xy ( 't1' ) )
          {
            $this -> { violet } = { % { $this -> { t2 } } } ;
            $this -> { violet } -> { tp } = 1 ;
          }
          elsif ( $this -> xy ( 'violet' ) eq $this -> xy ( 't2' ) )
          {
            $this -> { violet } = { % { $this -> { t1 } } } ;
            $this -> { violet } -> { tp } = 1 ;
          }
        }

        return ( 1 ) ;

      }
    }
  }

  $dify = 0 ;

  $newxy = ( $this -> { violet } -> { x } + $difx ) .
           ( $this -> { violet } -> { y } + $dify ) ;

  if ( ( $dify == 0 ) && ( $difx != 0 ) )
  {
    if ( $newxy ne $this -> xy ( 'fire' ) )
    {
      my $wall = ( ( $difx == 1 ) ? ( $this -> { violet } -> { x } .
                                      $this -> { violet } -> { y } )
                                  : $newxy                           ) ;

      if ( ! $this -> { wall_east  } -> { $wall } )
      {

        for ( 0 .. $#{ $this -> { tmp_wall_east  } } )
        {
          if ( ( $this -> { tmp_wall_east  }        -> [ $_ ] eq $newxy ) &&
               ( $this -> { tmp_wall_east_status  } -> [ $_ ]           )  )
          {
            $this -> { tmp_wall_east_status  } = 0 ;
          }
        }

        $this -> { violet } -> { x } += $difx ;

        if ( $this -> check2 ( ) )
        {
          if    ( $this -> xy ( 'violet' ) eq $this -> xy ( 't1' ) )
          {
            $this -> { violet } = { % { $this -> { t2 } } } ;
            $this -> { violet } -> { tp } = 1 ;
          }
          elsif ( $this -> xy ( 'violet' ) eq $this -> xy ( 't2' ) )
          {
            $this -> { violet } = { % { $this -> { t1 } } } ;
            $this -> { violet } -> { tp } = 1 ;
          }
        }

        return ( 1 ) ;

      }
    }
  }

  $difx = 0 ;
  if    ( $this -> { wappo } -> { y } < $this -> { violet } -> { y } )
  {
    $dify = -1 ;
  }
  elsif ( $this -> { wappo } -> { y } > $this -> { violet } -> { y } )
  {
    $dify =  1 ;
  }

  $newxy = ( $this -> { violet } -> { x } + $difx ) .
           ( $this -> { violet } -> { y } + $dify ) ;

  if ( ( $difx == 0 ) && ( $dify != 0 ) )
  {
    if ( $newxy ne $this -> xy ( 'fire' ) )
    {
      my $wall = ( ( $dify == 1 ) ? ( $this -> { violet } -> { x } .
                                      $this -> { violet } -> { y } )
                                  : $newxy                           ) ;

      if ( ! $this -> { wall_south } -> { $wall } )
      {

        for ( 0 .. $#{ $this -> { tmp_wall_south } } )
        {
          if ( ( $this -> { tmp_wall_south }        -> [ $_ ] eq $newxy ) &&
               ( $this -> { tmp_wall_south_status } -> [ $_ ]           )  )
          {
            $this -> { tmp_wall_south_status } = 0 ;
          }
        }

        $this -> { violet } -> { y } += $dify ;

        if ( $this -> check2 ( ) )
        {
          if    ( $this -> xy ( 'violet' ) eq $this -> xy ( 't1' ) )
          {
            $this -> { violet } = { % { $this -> { t2 } } } ;
            $this -> { violet } -> { tp } = 1 ;
          }
          elsif ( $this -> xy ( 'violet' ) eq $this -> xy ( 't2' ) )
          {
            $this -> { violet } = { % { $this -> { t1 } } } ;
            $this -> { violet } -> { tp } = 1 ;
          }
        }

        return ( 1 ) ;

      }
    }
  }

  return ( 0 ) ;

}

sub check
{

  my $this = shift ;

  if ( $this -> xy ( 'wappo' ) eq $this -> xy ( 'goal' ) )
  {

    print "\n\n\n *** SOLVED!!! ***\n\n\n" ;

    return ( 1 ) ;

  }

  if ( ( $this -> xy ( 'wappo' ) eq $this -> xy ( 'red'    ) ) ||
       ( $this -> xy ( 'wappo' ) eq $this -> xy ( 'blue'   ) ) ||
       ( $this -> xy ( 'wappo' ) eq $this -> xy ( 'violet' ) )  )
  {

    return ( 0 ) ;

  }

  if ( ( $this -> xy ( 'red' ) eq $this -> xy ( 'blue' ) ) &&
       ( $this -> xy ( 'red' ) ne '00'                   )  )
  {
    $this -> { violet } = { % { $this -> { red } } } ;
    $this -> { red    } = { x => 0 , y => 0        } ;
    $this -> { blue   } = { x => 0 , y => 0        } ;
  }

  return ( -1 ) ;

}

sub check2
{

  my $this = shift ;

  if ( $this -> xy ( 'wappo' ) eq $this -> xy ( 'goal' ) )
  {

    print "\n\n\n *** SOLVED!!! ***\n\n\n" ;

    return ( 1 ) ;

  }

  if ( ( $this -> xy ( 'wappo' ) eq $this -> xy ( 'red'    ) ) ||
       ( $this -> xy ( 'wappo' ) eq $this -> xy ( 'blue'   ) ) ||
       ( $this -> xy ( 'wappo' ) eq $this -> xy ( 'violet' ) )  )
  {

    return ( 0 ) ;

  }

  return ( -1 ) ;

}

sub xy
{

  my $this = shift ;

  my $obj  = shift ;

  return ( $this -> { $obj } -> { x } . $this -> { $obj } -> { y } ) ;

}

1
