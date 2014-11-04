# 使用perl语言编写的QQ机器人(采用webqq协议)

## 核心依赖模块:

* JSON
* Digest::MD5
* AnyEvent::UserAgent
* LWP::UserAgent
* Mail::SendEasy

## 客户端异步框架:

  client 
   | 
   ->login()
      |
      |->timer(60s)->_get_msg_tip()#heartbeat 
      |        +-------------------------<------------------------------+
      |        |                                                        |
      |->_recv_message()-[put]-> Webqq::Message::Queue -[get]-> on_receive_message()
      |
      |->send_message() -[put]--+                       +-[get]-> _send_message() ---+
      |                           \                   /                              +
      |->send_sess_message()-[put]-Webqq::Message::Queue-[get]->_send_sess_message()-+               
      |                              /              \                                +
      |->send_group_message()-[put]-+                +-[get]->_send_group_message()--+
      |                                                                              +
      |                          on_send_message() ---<---- msg->{cb} -------<-------+
      +->run()
  
