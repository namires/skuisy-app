import 'package:flutter/material.dart';
import 'package:skuisy_project/data/bloc/product_bloc.dart';
import 'package:skuisy_project/data/model/product_model.dart';
import 'package:skuisy_project/ui/screens/product_details.dart';
import 'package:getflutter/getflutter.dart';
import 'package:intl/intl.dart';

class ListProduct extends StatefulWidget {
  @override
  _ListProductState createState() => _ListProductState();
}

class _ListProductState extends State<ListProduct> {
  @override
  Widget build(BuildContext context) {
    ProductBloc productBloc = ProductBloc();

    return StreamBuilder<List<Product>>(
      stream: productBloc.productListAll,
      builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Align(
              alignment: Alignment.center,
              child: Container(
                height: 200,
                margin: EdgeInsets.only(top: 150),
                child: Text(
                  "No product",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.black),
                ),
              ),
            );
          } else
            return buildAllProductList(snapshot);
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildAllProductList(AsyncSnapshot snapshot) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Text(
              'Our Products',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            _gridBuilder(snapshot, context)
          ],
        ));
  }
}

Widget _gridBuilder(AsyncSnapshot snapshot, BuildContext _context) {
  var size = MediaQuery.of(_context).size;
  final double itemHeight = (size.height - kToolbarHeight - 24) / 2.3;
  final double itemWidth = size.width / 2;
  final NumberFormat moneyFormat = new NumberFormat("##,##0", "en_US");

  return GridView.builder(
    itemCount: snapshot.data.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 12,
      childAspectRatio: (itemWidth / itemHeight),
    ),
    itemBuilder: (BuildContext context, int index) {
      Product _product = snapshot.data[index];
      String amount = "${moneyFormat.format(_product.price)},-";
      return GestureDetector(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          elevation: 5,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                   borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                    child: GFImageOverlay(
                      height: 200,
                      width: 300,
                      colorFilter: _product.stock == 0 ? new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken) : null,
                      image: NetworkImage(_product.picture),
                      child: _product.stock == 0 ? Center(
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text('Out of Stock', style: TextStyle(color: Colors.red)),
                        )
                      ) : null,
                    )
                  )
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _product.title.length < 16 ? 
                          _product.title : _product.title.substring(0, 17) +'...',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Rp. ${amount}',
                          style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            Image(
                              width: 18,
                              height: 18,
                              image: AssetImage('assets/images/online-store.png'),
                            ),
                            SizedBox(width: 5),
                            Text(
                              _product.seller,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        )
                      ],
                    )
                  )
                ),
                // Text(_product.description)
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => ProductDetails()));
        },
      );
    },
    shrinkWrap: true,
    padding: EdgeInsets.all(0),
    controller: ScrollController(keepScrollOffset: true),
  );
}
