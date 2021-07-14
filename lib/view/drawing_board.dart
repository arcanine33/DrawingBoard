import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:Drawing/controller/controller.dart';
import 'package:Drawing/model/drawing.dart';
import 'package:Drawing/model/drawing_paint.dart';
import 'package:Drawing/widgets/raised_btn.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class DrawingBoard extends StatefulWidget {
  DrawingBoard({Key key}) : super(key: key);

  @override
  _DrawingBoardState createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  final _offsets = <Offset>[]; //전체 offset
  final _currentAction = <Offset>[]; // 현재 offset
  final linkedList = LinkedList<MyEntry>(); //전체 offset, color
  int currentDrawingLine = 0;
  int lastNullIndex = 0;
  int currentLinkedListIndex = 0;
  File file;
  double appBarHeight = 0.0 ;
  PickedFile pickedFile;
  bool isPen = true;
  List<Color> colorList = List<Color>();
  List<Color> currentColorList = List<Color>();


  @override
  void initState() {
    super.initState();

    if(linkedList.isNotEmpty)
      currentLinkedListIndex = linkedList.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            RaisedBtn(text: 'SAVE', onPressed : () async {
              await controller.saveData(_offsets,
                  pickedFile == null ? null : pickedFile.path, isPen, colorList);

              Fluttertoast.showToast(
                  msg: '저장되었습니다.',
                  gravity: ToastGravity.CENTER,
                  textColor: Colors.white,
                  backgroundColor: Colors.indigo);
            }),
           RaisedBtn(text: 'LOAD', onPressed: () async {
             await showDialog(
                 context: context,
                 builder: (context) {
                   return SimpleDialog(
                       title: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text('불러오기'),
                           IconButton(
                               icon: Icon(Icons.clear),
                               onPressed: () {
                                 Navigator.of(context).pop();
                               })
                         ],
                       ),
                       children: [loadSaveData()]);
                 });
           },),
            RaisedBtn(text: 'ADD',
              onPressed: () async {
                appBarHeight = AppBar().preferredSize.height;
                pickedFile =
                await ImagePicker().getImage(source: ImageSource.gallery);
                setState(() {
                  file = File(pickedFile.path);
                });
            },),
            RaisedBtn(
              icon: Icons.arrow_back,
              onPressed: () {
                if (currentLinkedListIndex == 0) return;

                lastNullIndex = getLastPreviousNullIndex();

                currentLinkedListIndex--;
                _offsets.removeRange(lastNullIndex, _offsets.length);
                colorList.removeRange(lastNullIndex, colorList.length);
              },
            ),
            RaisedBtn(
              icon: Icons.arrow_forward,
              onPressed: () {
                if (currentLinkedListIndex == linkedList.length) return; //현재 상태가 마지막일경우

                for (Offset offset in linkedList.elementAt(currentLinkedListIndex).offsets) {
                  _offsets.add(offset);
                }

                for(Color color in linkedList.elementAt(currentLinkedListIndex).colors) {
                  colorList.add(color);
                }

                currentLinkedListIndex++;
              },
            ),
            RaisedBtn(
              text: 'PEN',
              color: isPen ? Colors.deepPurple : Colors.grey,
              onPressed: () {
                setState(() {
                  isPen = true;
                });
              },
            ),
            RaisedBtn(
              text: 'ERASE',
              color: isPen ? Colors.grey : Colors.deepPurple,
              onPressed: () {
                setState(() {
                  isPen = false;
                });
              },
            ),
          ],
        ),
        body: drawLine()
    );
  }

  Widget drawLine () {
    return GestureDetector(
      onPanDown: (details) {
        setState(() {
          _offsets.add(details.localPosition);
          _currentAction.add(details.localPosition);
          colorList.add(isPen ? Colors.black : Colors.white);
          currentColorList.add(isPen ? Colors.black : Colors.white);

          for (int i = linkedList.length; i > currentLinkedListIndex; i--)
            linkedList.remove(linkedList.last);
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _offsets.add(details.localPosition);
          _currentAction.add(details.localPosition);
          colorList.add(isPen ? Colors.black : Colors.white);
          currentColorList.add(isPen ? Colors.black : Colors.white);
        });
      },
      onPanEnd: (details) {
        setState(() {
          _offsets.add(null);
          _currentAction.add(null);
          colorList.add(isPen ? Colors.black : Colors.white);
          currentColorList.add(isPen ? Colors.black : Colors.white);
          currentLinkedListIndex++;

          linkedList.add(MyEntry(List.from(_currentAction), List.from(currentColorList)));
          _currentAction.clear();
          currentColorList.clear();

        });
      },
      child: checkFileImage(),
    );
  }

  Widget checkFileImage() {
    if (file == null) {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: CustomPaint(
          painter: DrawingPaint(_offsets, colorList),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(image: DecorationImage(image: FileImage(file), fit: BoxFit.cover)),
        height: MediaQuery.of(context).size.height - appBarHeight,
        width: MediaQuery.of(context).size.width,
        child: CustomPaint(
          painter: DrawingPaint(_offsets, colorList),
        ),
      );
    }
  }

  Widget buildListTile (Drawing drawing) {
    return ListTile(
      title: Text('${drawing.update}'),
      onTap: () {
        List<dynamic> convertOffsets = json.decode(drawing.offsets);
        List<dynamic> convertColors = json.decode(drawing.colorList);
        _offsets.clear();
        colorList.clear();

        for(int i=0; i < convertOffsets.length; i++) {
          if(convertOffsets[i][0] == null) {
            _offsets.add(null);
            colorList.add(Color(int.parse(convertColors[i].split('(0x')[1].split(')')[0], radix: 16)));
          } else {
            _offsets.add(Offset(convertOffsets[i][0], convertOffsets[i][1]));
            colorList.add(Color(int.parse(convertColors[i].split('(0x')[1].split(')')[0], radix: 16)));
          }
        }

        if(drawing.filePath == null)
          file = null;
        else
          file = File(drawing.filePath);

        currentLinkedListIndex = 0;
        linkedList.clear();
        Navigator.of(context).pop();
        setState(() {});
      },
    );
  }

  Widget loadSaveData () {
    return FutureBuilder(
      future: Controller().getSaveList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0)
              return Container(
                child: Text('저장한 정보가 없습니다. '),
              );
            else
              return Container(
                height: MediaQuery.of(context).size.height / 2,
                width: double.minPositive,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) =>
                        buildListTile(snapshot.data[index])),
              );
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  int getLastPreviousNullIndex() {
    return _offsets.length - linkedList.elementAt(currentLinkedListIndex - 1).offsets.length;
  }

}

class MyEntry extends LinkedListEntry<MyEntry> {
  final List<Offset> offsets;
  final List<Color> colors;

  MyEntry(this.offsets, this.colors);

}

/*class MyEntry {
  final List<Offset> offsets;
  final List<Color> colors;

  MyEntry(this.offsets, this.colors);

}*/
