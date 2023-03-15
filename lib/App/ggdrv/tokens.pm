package App::ggdrv::tokens ; #use strict;
use warnings;
use 5.030 ; 
use feature 'say' ;
use Net::Google::OAuth ; #use Exporter 'import';
use Term::ANSIColor qw[ color :constants ] ; $Term::ANSIColor::AUTORESET = 1 ;

my ($gfile, $cid, $csec, $email, $scope, $rtoken0, $atoken0 ) ;
return 1 ; 

sub tokens ( $$$ ) { 
  $gfile = $ENV{ GGDRV_API } // "~/.ggdrv2303v1" ;
  $cid = qx [ sed -ne's/^CLIENT_ID[ =:\t]*//p' $gfile ] =~ s/\n$//r ; #"54525797.....34dseo.apps.googleusercontent.com" ;
  $csec = qx [ sed -ne's/^CLIENT_SECRET[ =:\t]*//p' $gfile ] =~ s/\n$//r ; # "GOCSP...YUbpe1" ; 
  $email = qx [ sed -ne's/^EMAIL[ =:\t]*//p' $gfile ] =~ s/\n$//r ;
  $scope = 'drive'; #my $SCOPE  = 'spreadsheets';
  $rtoken0 = qx [ sed -ne's/^REFRESH_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ; #"1//0e8......yLDJyrKxXNJY" ; 
  $atoken0 = qx [ sed -ne's/^ACCESS_TOKEN[ =:\t]*//p' $gfile ] =~ s/\n$//r ; #"1//0e8......yLDJyrKxXNJY" ; 
  my $get = $_[0] ;
  my $try = $_[1] ;
  my $atoken = $_[2] ; 
  $atoken ? atoken ($try) : $get ? get_tokens () : show_tokens ( $try ) ; 
  1 ;
}

sub show_tokens () { 
  say "REFRESH TOKEN from the setup file: " , $rtoken0 ; 
  say "ACCESS  TOKEN from the setup file: " , $atoken0 ;
  1 ; 
}

# アクセストークンとリフレッシュトークンを獲得する。
sub get_tokens ( $ ) { 
  my $try = $_[0] ; 
  say YELLOW "次の英文をよく読み、それを実行せよ。途中で「続行」のボタンを2回押すことになるであろう。" ;
  say 'Paste the following url into your browser. Push "Continue" button twice. Then copy the URL on your browser to paste here.' ;
  my $oauth = Net::Google::OAuth->new( -client_id => $cid, -client_secret => $csec ) ;
  $oauth->generateAccessToken( -scope => $scope, -email => $email ) ;
  my $atoken = $oauth -> getAccessToken () ;
  my $rtoken = $oauth -> getRefreshToken () ; 
  print "This is ACCESS TOKEN:\n"; print "=" x 20 . "\n"; print $atoken . "\n"; print "=" x 20 . "\n" ;
  print "This is REFRESH TOKEN:\n";  print "=" x 20 . "\n"; print $rtoken . "\n"; print "=" x 20 . "\n" ;
  qx [ sed -i.bak -e's|^\\(REFRESH_TOKEN[ =:\t]*\\).*\$|\\1$rtoken|' $gfile ] if ! $try ; 
  qx [ sed -i.bak -e's/^\\(ACCESS_TOKEN[ =:\t]*\\).*\$/\\1$atoken/'  $gfile ] if ! $try ; 
  1 ;
}

# クライアントIDとクライアントシークレット、リフレッシュトークン(計3個の情報)から、アクセストークンを取得する。
sub atoken ( $ ) { 
  my $try = $_[0] ;
  my $oauth = Net::Google::OAuth->new( -client_id => $cid, -client_secret => $csec ) ;
  my $x1 = $oauth -> refreshToken ( -refresh_token => $rtoken0 )  ;
  my $atoken = $oauth -> getAccessToken () ;
  say $atoken ;
  qx [ sed -i.bak -e's/^\\(ACCESS_TOKEN[ =:\t]*\\).*\$/\\1$atoken/' $gfile ] if ! $try ;
  # qxが\を解釈するので、この行を編集するときは要注意。
  # qxに sed で行末を表す$を渡す際に、$が何かPerlの変数として解釈されないように、\が前に必要。
  # sed では Mac だと -i に引数が必要。
  # sed では、\1 にキャプチャするための括弧は、元々\が必要。それをqxに渡す場合に\をさらに前に追加。
}


## ヘルプ (オプション --help が与えられた時に、動作する)

=encoding utf8

=head1

 $0 

 元々の動作 :

   有効なクライアントIDとクライアントシークレットを記入した設定をファイルを元に「アクセストークン」と「リフレッシュトークン」を得る。
   sedを用いて、設定ファイルを編集していることに注意。

   → 手動作業が、追加で必要。
   → URLを生成して、ブラウザに表示させて、
     2回意味のあるクリックをしたら、ブラウザのURL欄に現れるhttp://localhost:8000/?state=uniq_state_36113&code= のような
     文字列が現れて、それを再び$0 にコピペすることで上記が実行出来る。
   

 別の動作( -a の指定による ) : 
   リフレッシュトークン(半年間有効)から、1時間有効なアクセストークンを生成する(標準出力に出力する)。
    → 約160文字。実行する度に異なるアクセストークンが生成される。
    → ブラウザを用いた認証は必要としないので、手動の作業を必要とはしない。

  オプション: 
    -a : リフレッシュトークンから、アクセストークンを得る。(約160文字)
    -r : 単に記録されているリフレッシュトークンを出力する。(約100文字)
    -w : 設定ファイルに書込を実行する。


