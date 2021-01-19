import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nanoid/async/nanoid.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class ItemPage extends StatefulWidget {
  final String text;
  final String cUid;

  ItemPage({this.text,this.cUid});


  @override
  _ItemPageState createState() => _ItemPageState(text: text,cUid: cUid);
  
}
class _ItemPageState extends State<ItemPage> {
  final String text;
  final String cUid;

  _ItemPageState({this.text,this.cUid});

  int index1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(text)),
        actions: [IconButton(icon: Icon(Icons.add,size:30,color: Colors.white),
          tooltip: "Add Item",
          onPressed: () =>Navigator.of(context).push(PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation)=>RotationTransition(
                turns: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child:PostItem(cName: text,)
                  ),
                ),
              )
          )).then((value) => setState(() {})
        ))]
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('product').where('category',isEqualTo: text.trim()).snapshots(),
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
                          crossAxisCount: (orientation == Orientation.portrait) ? 3 : 4),
                      itemBuilder: (_,index){
                        return GestureDetector(
                          onTap: (){
                            _productDetails(context,snapshot.data.docs[index]['pImageUrl'],snapshot.data.docs[index]['pName'],snapshot.data.docs[index]['pPrice'],snapshot.data.docs[index]['pDescription']);
                          },
                          onLongPress: ()=>updateAndDeleteBottomSet(context, snapshot.data.docs[index]['pUid'], snapshot.data.docs[index]['pImageUrl'], snapshot.data.docs[index]['pName'],
                              snapshot.data.docs[index]['pPrice'], snapshot.data.docs[index]['pDescription'],snapshot.data.docs[index]['category']),
                          child: GridTile(
                              child: Padding(
                                padding: const EdgeInsets.only(top:8.0),
                                child: Column(
                                  //mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.24,
                                      height: MediaQuery.of(context).size.height*0.11,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.fill, image: CachedNetworkImageProvider(
                                            snapshot.data.docs[index]['pImageUrl']
                                        )
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        color: Colors.grey,
                                      ),
                                    ),
                                    // Material(
                                    //   shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(22.0)),
                                    //   elevation: 3.0,
                                    //   child: Image.network(
                                    //     items[index]['pImageUrl'],
                                    //     fit: BoxFit.fill,
                                    //     height: 50,
                                    //     width: 50,
                                    //   ),
                                    // ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(3),
                                        child: Center(child: Text(snapshot.data.docs[index]['pName'],maxLines: 1,)),
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
 void updateAndDeleteBottomSet(BuildContext context,String uid,String imageSrc,String pName,String pPrice,String pDescription,String categoryName){
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
                                child:PostItem(cUid: uid,imageUrl: imageSrc,pName: pName,pPrice: pPrice,pDescription: pDescription,cName: categoryName,)
                            ),
                          ),
                        )
                    )).then((value) => setState(() {})
                    )),
                new ListTile(
                  leading: new Icon(Icons.delete),
                  title: new Text('Delete'),
                  onTap: () {
                    FirebaseFirestore.instance.collection('category').doc(cUid).delete().whenComplete(() => Navigator.of(context).pop());
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
 }
  void _productDetails(context,String imageSrc,String pName,String pPrice,String pDescription) {
    showModalBottomSheet(
        context: context,
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
                child: ListView(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.edit,color: Colors.black,size: 25,),
                      onPressed: ()=>Navigator.of(context).push(PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, Animation<double> animation,
                              Animation<double> secondaryAnimation)=>RotationTransition(
                            turns: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                  opacity: animation,
                                  child:PostItem(cUid: cUid,imageUrl: imageSrc,pName: pName,pPrice: pPrice,pDescription: pDescription,)
                              ),
                            ),
                          )
                      )).then((value) => setState(() {})
                      )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Material(
                        elevation: 3.0,
                        child: Image.network(
                          imageSrc,
                          fit: BoxFit.fill,
                          height: 200,
                          width: 200,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left:18.0, bottom:20.0),
                    child: Text(pName,
                      style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Text(pPrice,
                      style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left:20.0,top :18.0),
                    child: Text(pDescription,
                        style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    )),
                  ),
                ],
              )
            ),
          );
        }
    );
  }

}


class PostItem extends StatefulWidget {
  final String cUid;
  final String imageUrl;
  final String pName;
  final String pPrice;
  final String pDescription;
  final String cName;

  PostItem({this.cUid,this.imageUrl,this.pName,this.pPrice,this.pDescription,this.cName});


  @override
  _PostItemState createState() => _PostItemState(cUid: cUid,imageUrl: imageUrl,pName: pName,pDescription: pDescription,pPrice: pPrice,cName: cName);
}

class _PostItemState extends State<PostItem> {
  final String cUid;
  final String imageUrl;
  final String pName;
  final String pPrice;
  final String pDescription;
  final String cName;
  _PostItemState({this.cUid,this.imageUrl,this.pName,this.pPrice,this.pDescription,this.cName});

  static var uuid = Uuid();
  var uidCategory=uuid.v4(options: {
    'rng': UuidUtil.cryptoRNG
  });

  FirebaseStorage storage = FirebaseStorage.instance;
  TextEditingController itemNameController=new TextEditingController();
  TextEditingController itemPriceController=new TextEditingController();
  TextEditingController itemDescriptionController=new TextEditingController();

  File _image;
  String url;


  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      _image = image;
    });

    uploadImageToFirebase(image); //for upload image from camera
  }

  _imgFromGallery() async {
    File image = await  ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() {
      _image = image;
    });
    uploadImageToFirebase(image);   //for upload image from gallery
  }
  uploadImageToFirebase(File _file){
    Reference reference=storage.ref().child('product/$uidCategory');
    UploadTask uploadTask = reference.putFile(_file);
    uploadTask.catchError((e)=>print(e.toString()))..whenComplete(() async{
      var downloadUrl=await reference.getDownloadURL();
      setState(() {
        url=downloadUrl.toString();
      });
    });
  }
  uploadProduct(String pName,String imageUrl,String pPrice,String pDescription,String cName,)async{
    var productId = await nanoid(10);
    print(productId);
    DocumentReference dr=FirebaseFirestore.instance.collection('product').doc(productId);
    Map<String,dynamic>task={
      'category':cName,
      'pUid':productId,
      'pImageUrl':imageUrl,
      'pName':pName,
      'pPrice':pPrice,
      'pDescription':pDescription,

    };
    dr.set(task).whenComplete(() => Navigator.of(context).pop());
  }
  deleteAndUploadProduct(String name,String url,String price,String description)async{
    Map<String,dynamic>task={
      'pImageUrl':url,
      'pName':name,
      'pPrice':price,
      'pDescription':description,
    };
    Map<String,dynamic>removeTask={
      'pImageUrl':imageUrl,
      'pName':pName,
      'pPrice':pPrice,
      'pDescription':pDescription,
    };
    List val=[];
    val.add(removeTask);
    print(val.toString());
    FirebaseFirestore.instance.collection('category').doc(cUid).update({
      'items':FieldValue.arrayRemove(val)
    }).then((value) => FirebaseFirestore.instance.collection('category').doc(cUid).update({
      'items':FieldValue.arrayUnion([task])
    })).whenComplete(() {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });
  }
  setTxtToEditingController(String name,String price,String description){
    if(name!=null && price!=null && description !=null){
      itemNameController.value=TextEditingValue(text: name);
      itemPriceController.value=TextEditingValue(text: price);
      itemDescriptionController.value=TextEditingValue(text: description);
    }else{
      itemNameController.value=TextEditingValue.empty;
      itemPriceController.value=TextEditingValue.empty;
      itemDescriptionController.value=TextEditingValue.empty;
    }
  }
  @override
  void initState() {
    setTxtToEditingController(pName, pPrice, pDescription);
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
               imageUrl==null? Center(
                  child: GestureDetector(
                    onTap: () {
                      _showPicker(context);
                    },
                    child: _image != null
                        ? ClipRRect(
                      //borderRadius: BorderRadius.circular(100),
                      child: Image.file(
                        _image,
                        width: 200,
                        height: 200,
                        fit: BoxFit.fitHeight,
                      ),
                    ) : Container(
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
                ): GestureDetector(
                 onTap: ()=>_showPicker(context),
                 child: ClipRRect(
                   child: _image==null?Image.network(
                     imageUrl,
                     width: 200,
                     height: 200,
                     fit: BoxFit.fitHeight,
                   ):Image.file(
                     _image,
                     width: 200,
                     height: 200,
                     fit: BoxFit.fitHeight,
                   ),
                 ),
               ),
                TextFormField(
                  controller: itemNameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Item Name',
                    hintText: 'Input Item Name',
                  ),
                ),
                TextFormField(
                  controller: itemPriceController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Item price',
                    hintText: 'Input Item price',
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: itemDescriptionController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Item Description',
                    hintText: 'Input Item Description',
                  ),
                ),

                SizedBox(height: 30),

                // Upload product
               imageUrl==null? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0))),
                    child: Text("Upload Item"),
                    onPressed: () {
                      if(url!=null && itemNameController.text.isNotEmpty && itemPriceController.text.isNotEmpty && itemDescriptionController.text.isNotEmpty){
                        print('not update');
                        uploadProduct(itemNameController.text.toString(), url,
                            itemPriceController.text.toString(), itemDescriptionController.text.toString(),cName);//upload single product firebase array
                      }else{
                        print('something Wrong');
                        print(url);
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

                     if(imageUrl!=null && itemNameController.text.isNotEmpty && itemPriceController.text.isNotEmpty && itemDescriptionController.text.isNotEmpty){
                       print('update');
                       deleteAndUploadProduct(itemNameController.text.toString(), url!=null?url:imageUrl,
                           itemPriceController.text.toString(), itemDescriptionController.text.toString());//upload single product firebase array
                     }else{
                       // Fluttertoast.showToast(
                       //     msg: "Some input is missing",
                       //     toastLength: Toast.LENGTH_SHORT,
                       //     gravity: ToastGravity.CENTER,
                       //     timeInSecForIosWeb: 1,
                       //     backgroundColor: Colors.red,
                       //     textColor: Colors.white,
                       //     fontSize: 16.0
                       // );
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