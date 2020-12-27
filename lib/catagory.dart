import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nittocatadmin/item.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: Text("Category"),
          actions: [IconButton(icon: Icon(Icons.add,size:30,color: Colors.white),
              tooltip: "Add Category",
              onPressed: () =>Navigator.of(context).push(PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (BuildContext context, Animation<double> animation,
                      Animation<double> secondaryAnimation)=>RotationTransition(
                    turns: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                          opacity: animation,
                          child:PostCategory()
                      ),
                    ),
                  )
              )).then((value) => setState(() {})
              ))]
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('category').snapshots(),
          builder: (BuildContext context,AsyncSnapshot<QuerySnapshot>snapshot){
            if(snapshot.connectionState==ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            }else{
              if(snapshot.hasData){
                return OrientationBuilder(
                  builder: (_,orientation){
                    return GridView.builder(
                      itemCount: snapshot.data.docs.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3),
                      itemBuilder: (_,int index){
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ItemPage(text: snapshot.data.docs[index]['name'],cUid:snapshot.data.docs[index]['cUid'],)),
                            );
                          },
                          onLongPress: ()=>updateAndDeleteBottomSet(context, snapshot.data.docs[index]['cUid'],snapshot.data.docs[index]['imageUrl'], snapshot.data.docs[index]['name']),
                          child: GridTile(
                              child: Padding(
                                padding: const EdgeInsets.only(top:8.0),
                                child: Column(
                                  //mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                              width: MediaQuery.of(context).size.width*0.40,
                                              height: MediaQuery.of(context).size.height*0.18,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.fill, image: CachedNetworkImageProvider(
                                                    snapshot.data.docs[index]['imageUrl']
                                                )
                                                ),
                                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                color: Colors.grey,
                                              ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(3),
                                        child: Center(child: Text(snapshot.data.docs[index]['name'],maxLines: 1,
                                            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 16),
                                        )),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ),
                        );
                      },
                    );
                  },
                );
            }else{
                return Center(child:CircularProgressIndicator());
              }
            }
          },
        ),
      )
    );
  }
  void updateAndDeleteBottomSet(BuildContext context,String uid,String imageSrc,String cName){
    showModalBottomSheet(
        context: context,
        elevation: 10.0,
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        builder: (BuildContext context,){
          return SafeArea(
            child: Container(
              child: Wrap(
                children: [
                  new ListTile(
                      leading: new Icon(Icons.edit),
                      title: new Text('Edit'),
                      onTap: ()=>Navigator.of(context).push(PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, Animation<double> animation,
                              Animation<double> secondaryAnimation)=>RotationTransition(
                            turns: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                  opacity: animation,
                                  child:PostCategory(cUid: uid,imageUrl: imageSrc,)
                              ),
                            ),
                          )
                      )).then((value) => setState(() {})
                      )),
                  new ListTile(
                    leading: new Icon(Icons.delete),
                    title: new Text('Delete'),
                    onTap: () {
                      uid!=null?FirebaseFirestore.instance.collection('category').doc(uid).delete()
                          .whenComplete(() => Navigator.of(context).pop()):print('No uid get');
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
  Future showAlertDialog(BuildContext context,DocumentSnapshot deleteItem) {

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed:  () {
        FirebaseFirestore.instance.collection('category').doc(deleteItem['cUid'].toString()).delete().whenComplete(()=>Navigator.of(context).pop());
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Category"),
      content: Text("Are you sure You Want to delete This Category?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

/*  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }*/
}


class PostCategory extends StatefulWidget {
  final String uName;
  final  String cUid;
  final String imageUrl;

  const PostCategory({this.uName,this.cUid,this.imageUrl});


  @override
  _PostCategoryState createState() => _PostCategoryState(cUid: cUid,uName: uName,imageUrl: imageUrl);
}

class _PostCategoryState extends State<PostCategory> {

  final String uName;
  final  String cUid;
  final String imageUrl;


  static var uuid = Uuid();
  var uidCategory=uuid.v4(options: {
    'rng': UuidUtil.cryptoRNG
  });

  FirebaseStorage storage = FirebaseStorage.instance;
  TextEditingController categoryNameController=new TextEditingController();

  File _image;
  String url;

  _PostCategoryState({this.uName, this.cUid, this.imageUrl});
  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      _image = image;
    });

  }

  _imgFromGallery() async {
    File image = await  ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() {
      _image = image;
    });
    Reference reference=storage.ref().child('category/$uidCategory');
    UploadTask uploadTask = reference.putFile(image);
    uploadTask.catchError((e)=>print(e.toString()))..whenComplete(() async{
      var downloadUrl=await reference.getDownloadURL();
      setState(() {
        url=downloadUrl.toString();
      });
    });
    //uploadTask.catchError((e)=>print(e.toString()));

  }
  uploadCategory(String name,String imageUrl)async{
    List<Map<String,dynamic>>_list=[];
    DocumentReference dr=FirebaseFirestore.instance.collection('category').doc(uidCategory);
    Map<String,dynamic>task={
      'name':name,
      'imageUrl':imageUrl,
      'cUid':uidCategory,
      'items':FieldValue.arrayUnion(_list)
    };
    dr.set(task).whenComplete(() => Navigator.of(context).pop());
  }
  setTxtToEditingController(String name){
    if(name!=null){
      categoryNameController.value=TextEditingValue(text: name);

    }else{
      categoryNameController.value=TextEditingValue.empty;
    }
  }
  @override
  void initState() {
    setTxtToEditingController(uName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white.withOpacity(0.92),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 1),
        child: FloatingActionButton(
          elevation: 0.0,
          backgroundColor: Colors.white.withOpacity(0.01),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Center(
              child: Icon(Icons.clear,color: Colors.black,)
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top:100.0,left: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _imgFromGallery();
                    },
                    child: _image != null
                        ? ClipRRect(
                      //borderRadius: BorderRadius.circular(100),
                      child: imageUrl==null?Image.file(
                        _image,
                        width: 200,
                        height: 200,
                        fit: BoxFit.fitHeight,
                      ):Image.network(imageUrl,width: 200,
                        height: 200,
                        fit: BoxFit.fitHeight,)
                    )
                        : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(50)),
                      width: 200,
                      height: 200,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: categoryNameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Category Name',
                    hintText: 'Input Category Name',
                  ),
                  //validator:(value)=>value!=null?value:'Enter category name'

                ),

                SizedBox(height: 30),

                imageUrl==null?Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0))),
                    child: Text("Upload Category"),
                    onPressed: () {
                      if(url!=null && categoryNameController.text.isNotEmpty){
                        uploadCategory(categoryNameController.text.toString(),url);
                      }else{
                        print('something Wrong');
                      }
                    },
                  ),
                ):Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0))),
                    child: Text("Update Item"),
                    onPressed: () {

                      if(imageUrl!=null && categoryNameController.text.isNotEmpty){
                        print('update');
                        Map<String,dynamic> task={
                          'name':categoryNameController.text.toString(),
                          'imageUrl':imageUrl==null?url:imageUrl,
                        };
                        FirebaseFirestore.instance.collection('category').doc(cUid).update(task).whenComplete(() {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        });
                      }else{
                        print('something Wrong');
                        print(url);
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}
