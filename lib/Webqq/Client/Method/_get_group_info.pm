use JSON;
sub Webqq::Client::_get_group_info {
    my $self = shift;
    my $gcode = shift;
    my $ua = $self->{ua};
    my $cache_data =  $self->{cache_for_group}->retrieve($gcode);
    return $cache_data if defined $cache_data;
    my $api_url = 'http://s.web2.qq.com/api/get_group_info_ext2';
    my @query_string  = (
        gcode   =>  $gcode,
        cb      =>  "undefined",
        vfwebqq =>  $self->{qq_param}{vfwebqq},
        t       =>  time(),
    ); 
    my @query_string_pairs;
    push @query_string_pairs , shift(@query_string) . "=" . shift(@query_string) while(@query_string);
    my @headers = (Referer => 'http://s.web2.qq.com/proxy.html?v=20110412001&callback=1&id=3');
    my $response = $ua->get($api_url.'?'.join("&",@query_string_pairs),@headers);
    if($response->is_success){
        print $response->content(),"\n" if $self->{debug};
        my $json = JSON->new->utf8->decode($response->content()); 
        return undef if ($json->{retcode}!=0 and $json->{retcode}!=1);
        $json->{result}{ginfo}{name} = encode("utf8",$json->{result}{ginfo}{name});
        delete $json->{result}{ginfo}{members};
        for my $m(@{ $json->{result}{minfo} }){
            for(keys %$m){
                $m->{$_} = encode("utf8",$m->{$_});
            }
        }
        my $group_info  = {
            ginfo   =>  $json->{result}{ginfo},
            minfo   =>  $json->{result}{minfo},
        };
        #查询结果同时进行缓存，以优化查询速度
        $self->{cache_for_group}->store($gcode,$group_info,3600);
        return $group_info;
    }
    else{return undef;}
}
1;
