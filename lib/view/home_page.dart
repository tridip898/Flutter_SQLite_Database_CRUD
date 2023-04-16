import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sqlite_database/database/notes_database.dart';
import 'package:get/get.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //
  List<Map<String, dynamic>> _journal=[];
  bool _isLoading=true;

  //this method retrieve all the data from database
  void _refreshJournal() async{
    final data=await SQLHelper.getItems();
    setState(() {
      _journal=data;
      _isLoading=false;
    });
  }

  final TextEditingController _titleController= TextEditingController();
  final TextEditingController _descriptionController=TextEditingController();

  //this method is used for add new data in database
  Future<void> _addItems() async{
    await SQLHelper.createItems(_titleController.text, _descriptionController.text);
    _refreshJournal();
    print("Number of items is table ${_journal.length}");
  }

  //this method is for update data in database
  Future<void> _updateItems(int id) async{
    await SQLHelper.updateItems(id, _titleController.text, _descriptionController.text);
    _refreshJournal();
  }

  //this method we used for delete data from database
  void _deleteItem(int id) async{
    await SQLHelper.deleteItems(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully Data Deleted",style: TextStyle(fontSize: 13.sp,color: Colors.black),)));
    _refreshJournal();
  }
  //this method is bottom modal sheet which we used for insert and update data in database
  void _showForm(int? id) async{
    //this is for update database data
    if( id!= null){
      final existingJournal= _journal.firstWhere((element) => element['id'] == id);
      _titleController.text=existingJournal['title'];
      _descriptionController.text=existingJournal['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_)=>Container(
          width: 100.w,
          padding: EdgeInsets.only(
            top: 15,
            right: 15,
            left: 15,
            //this will prevent the soft keyboard from covering the text field
            bottom: MediaQuery.of(context).viewInsets.bottom+120
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(hintText: "Title",hintStyle: TextStyle(fontSize: 13.sp)),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(hintText: "Description",hintStyle: TextStyle(fontSize: 13.sp)),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                      onPressed: () async{
                        if(id == null){
                          await _addItems();
                        }else if(id != null){
                          await _updateItems(id);
                        }
                        //clear the text field
                        _titleController.text="";
                        _descriptionController.text="";

                        Navigator.pop(context);
                      },
                    child: Text(id==null ? "Add New Item": "Update Item",style: TextStyle(fontSize: 14.sp,color: Colors.white,fontWeight: FontWeight.w600),),
                    color: Colors.deepPurple,
                    height: 4.h,
                    padding: EdgeInsets.symmetric(horizontal: 6.w,vertical: 1.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                  ),

                ],
              )
            ],
          ),
    ));
  }

  @override
  void initState() {
    super.initState();
    //we call the method
    _refreshJournal();
    print("Number of items in database ${_journal.length}");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: ()=>_showForm(null),
          child: Icon(Icons.add,size: 3.5.h,),
          backgroundColor: Colors.blue,
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: ListView.separated(itemBuilder: (_,index){
            return Card(
              color: Colors.purpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
              ),
              child: ListTile(
                title: Text(_journal[index]['title'],style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w600,color: Colors.white),),
                subtitle: Text(_journal[index]['description'],style: TextStyle(fontSize: 13.sp,color: Colors.grey.shade200),),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(onPressed: ()=>_showForm(_journal[index]['id']),
                          icon: Icon(Icons.edit,size: 4.h,)),
                      IconButton(onPressed: (){
                        return _deleteItem(_journal[index]['id']);
                      }, icon: Icon(Icons.delete,size: 4.h,))
                    ],
                  ),
                ),
              ),
            );
          }, separatorBuilder: (_,index)=>Divider(),
              itemCount: _journal.length),
        ),
      ),
    );
  }
}
