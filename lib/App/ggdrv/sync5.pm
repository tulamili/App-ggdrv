package App::ggdrv::sync5 ;
use strict ; 
use warnings ; 
use feature qw [ say ] ; 
use Cwd ;

return 1 ; 

sub cat ( $ ) { return qx[ cat $_[0] ] } # ファイルの中身を取り出す。2個のファイルで中身を比較する目的で、作成。

sub sync5 {
  $ARGV[1] //= '.' ;
  my $dir0 = cwd ;
  my $dir1 = shift @ARGV ; # qx [ mkdir -p $dir ] if $o{p} ; 
  my $dir2 = shift @ARGV ; # qx [ mkdir -p $dir ] if $o{p} ; 
   my @cmd ; 
  while ( <> ) {
    chomp ; 
    my @F = split /\t/ , $_ ;
    next if ! -f "$dir2/$F[2]" ; # 新しいファイルがそもそも存在しないなら、何もしない。
    #push @cmd , qq [$FindBin::Bin/update12.pl $F[1]:$F[2] ] if ! -f "$dir1/$F[2]" || (cat "$dir1/$F[2]") ne (cat "$dir2/$F[2]") ; 
    push @cmd , qq [$0 update -20 $F[1] $F[2] ] if ! -f "$dir1/$F[2]" || (cat "$dir1/$F[2]") ne (cat "$dir2/$F[2]") ; 
  }
  chdir $dir2 or die ;
  for ( @cmd ){ 
    say $_ ;
    say " --> " , qx [ $_ ]  =~ s/\n\s+/ /grs =~ s/\n/ /grs ; 
  }
  chdir $dir0 or die ; 
}
  
=encoding utf8

=head1

 ggdrv sync5 OLD_DIR NEW_DIR < VAR_FILE

  OLD_DIR : ローカルのディレクトリ。古いファイルがあると見なされる。
  NEW_DIR : ローカルのディレクトリ。新しいファイルがあると見なされる。未指定なら、現行ディレクトリ .　が仮定される。
  VAR_FILE : 5列のTSV形式ファイルとなる。 "200   FILE_ID  FILE_NAME   MIMETYPE   drive#file"
  
  動作 : 
   (単純な同期では無いと言える。ローカルで2個のフォルダを用意して、違えばGoogleドライブにアップ。
    つまり、OLD_DIR は、そのGoogleドライブと毎回あらかじめ、きちんと同期されていると仮定してある。)
   VAR_FILEの各行が表す各ファイルfileについて、OLD_DIR/file が NEW_DIR/file と内容が違っていたら、
   グーグルドライブにアップロード。ここで、OLD_DIRは グーグルドライブと download5により同期されていると想定。

    約1.5秒ごとに1ファイルを更新するであろう。

 オプション : 
 
 開発メモ : 
   * cwd を用いた。getcwd ではなく。
   
=cut
