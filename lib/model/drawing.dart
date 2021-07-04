
class Drawing {
  String offsets;
  String update;
  String filePath;
  String colorList;

  Drawing.fromJson(Map<String, dynamic> json)
      : offsets = json['OFFSET'],
        update = json['UP_DATE'],
        filePath = json['FILE_PATH'],
        colorList = json['COLOR_LIST'];

  Map<String, dynamic> toJson() => {
        'OFFSET': offsets,
        'UP_DATE': update,
        'FILE_PATH': filePath,
        'COLOR_LIST': colorList
      };

  Drawing({this.offsets, this.update, this.filePath, this.colorList});
}