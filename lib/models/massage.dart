class Message {
  Message({
    required this.formid,
    required this.toid,
    required this.msg,
    required this.read,
    required this.type,
    required this.send,
  });
  late final String formid;
  late final String toid;
  late final String msg;
  late final String read;
  late final String type;
  late final String send;

  Message.fromJson(Map<String, dynamic> json){
    formid = json['formid'].toString();
    toid = json['toid'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == 'text' ? 'text' : 'image';
    send = json['send'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['formid'] = formid;
    data['toid'] = toid;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type;
    data['send'] = send;
    return data;
  }
}
